#!/usr/bin/env python3
"""Mechanical readout for the asa35 A/B (issue #35, metric 1).

Usage: python3 -I overlap.py <arm_dir> [<arm_dir> ...]

For each arm directory containing members/<member>.md:
  * findings per member = items under the heading that contains "Concern",
    where an item is a `###`/`####` heading or a top-level list bullet whose
    text (or the next 2 lines) carries a severity word
    (critical|high|medium|low).
  * each finding is normalized to (title_tokens, locations):
      - title_tokens: lowercase alphanumeric words of the item line, minus the
        severity word, markdown, and a stop-list; stemmed crudely (strip a
        trailing 's').
      - locations: every `path:line` or bare mcp file reference in the item's
        block (item line + following lines up to the next item).
  * two findings from DIFFERENT members match if either
      (a) they cite the same file with line numbers within +/-5, or
      (b) Jaccard(title_tokens) >= 0.5.
  * pairwise overlap for members (i, j) = matched_pairs / min(n_i, n_j)
    (0 when either has no findings). The arm's score is the mean over all
    member pairs. Lower = more differentiated reviews (the #35 prediction for
    the treatment arm).
The script prints a per-arm table and the per-pair matrix; no judgment.
"""
import re, sys, itertools, os, json

SEV = re.compile(r"\b(critical|high|medium|low)\b", re.I)
LOC = re.compile(r"((?:[\w.-]+/)*[\w.-]+\.(?:js|json|md|yml|yaml|mjs|ts)):(\d+)")
FILE = re.compile(r"\b((?:[\w.-]+/)*[\w.-]+\.(?:js|json|md|yml|yaml|mjs|ts))\b")
STOP = set("the a an of in on to for and or is are be with without by from as at "
           "this that it its into no not vs via when per any all each file line "
           "severity concern concerns issue why matters fix location".split())

def tokens(s):
    s = SEV.sub(" ", s)
    s = re.sub(r"[`*_#>\[\]()|:/.,;!?\"'-]", " ", s.lower())
    out = set()
    for w in s.split():
        if len(w) < 3 or w in STOP or w.isdigit():
            continue
        out.add(w[:-1] if w.endswith("s") and len(w) > 4 else w)
    return out

def section_lines(text):
    """Lines of the Concerns section (from the heading containing 'concern'
    up to the next heading of the same or higher level)."""
    lines = text.splitlines()
    start = level = None
    for i, l in enumerate(lines):
        m = re.match(r"^(#{1,6})\s+(.*)", l)
        if m and "concern" in m.group(2).lower():
            start, level = i + 1, len(m.group(1)); break
    if start is None:
        return []
    out = []
    for l in lines[start:]:
        m = re.match(r"^(#{1,6})\s+", l)
        if m and len(m.group(1)) <= level:
            break
        out.append(l)
    return out

FIELD = re.compile(r"^\W*(location|why it matters|why|fix|concrete fix|fixes|severity|impact|"
                   r"recommendation|not recommended|adjacent|evidence|effort|signature trade-off|"
                   r"mode|reviewer|scope|note|verification|cost|trigger)\b", re.I)

def strip_md(l):
    return re.sub(r"^(#{1,6}|[-*+]|\d+[.)])\s*", "", l).strip().strip("*").strip()

def findings(text):
    """Items in the Concerns section. Three shapes are recognised:
    (a) `###`/`####` heading lines (severity in the line or next 2 lines);
    (b) bold-lead paragraph lines `**...**` with a severity word in the line;
    (c) top-level `-`/`1.` bullets with a severity word in the line.
    Lines whose text starts with a field label (Location, Why it matters, Fix,
    ...) are never findings."""
    sec = section_lines(text)
    items, cur = [], None
    for idx, l in enumerate(sec):
        is_head = re.match(r"^#{3,6}\s+\S", l)
        is_bold = re.match(r"^\*\*\S", l)
        is_bullet = re.match(r"^(?:[-*+]|\d+[.)])\s+\S", l)
        if is_head or is_bold or is_bullet:
            txt = strip_md(l)
            if not FIELD.match(txt):
                window = " ".join(sec[idx:idx+3]) if is_head else l
                if SEV.search(window):
                    cur = {"title": txt, "block": [l]}
                    items.append(cur); continue
        if cur is not None:
            cur["block"].append(l)
    for it in items:
        head = "\n".join(it["block"][:3])
        m = SEV.search(it["title"]) or SEV.search(head)
        it["sev"] = m.group(1).lower() if m else "?"
        it["tok"] = tokens(it["title"])
        blk = "\n".join(it["block"])
        it["locs"] = [(os.path.basename(f), int(n)) for f, n in LOC.findall(blk)]
        it["files"] = {os.path.basename(f) for f in FILE.findall(blk)}
    return items

LOC_TOL, TITLE_J = 5, 0.5

def match(a, b, loc_tol=None, title_j=None):
    loc_tol = LOC_TOL if loc_tol is None else loc_tol
    title_j = TITLE_J if title_j is None else title_j
    for fa, la in a["locs"]:
        for fb, lb in b["locs"]:
            if fa == fb and abs(la - lb) <= loc_tol:
                return "loc"
    if a["tok"] and b["tok"]:
        j = len(a["tok"] & b["tok"]) / len(a["tok"] | b["tok"])
        if j >= title_j:
            return "title"
    return None

def mean_overlap(members, loc_tol, title_j):
    names = sorted(members); scores = []
    for i, j in itertools.combinations(names, 2):
        fi, fj = members[i], members[j]
        matched = sum(1 for a in fi if any(match(a, b, loc_tol, title_j) for b in fj))
        denom = min(len(fi), len(fj))
        scores.append(matched / denom if denom else 0.0)
    return sum(scores) / len(scores) if scores else 0.0

def hotspots(members, tol=5):
    """Cluster every cited (file,line) across all findings in the arm; return
    (n_clusters, share of findings touching the largest cluster)."""
    pts = []
    for m, fs in members.items():
        for k, f in enumerate(fs):
            for loc in f["locs"]:
                pts.append((loc, (m, k)))
    pts.sort()
    clusters = []
    for (fl, fid) in pts:
        if clusters and clusters[-1][0][0][0] == fl[0] and fl[1] - clusters[-1][-1][0][1] <= tol:
            clusters[-1].append((fl, fid))
        else:
            clusters.append([(fl, fid)])
    total = sum(len(fs) for fs in members.values())
    if not clusters:
        return 0, 0.0, None
    big = max(clusters, key=lambda c: len({fid for _, fid in c}))
    share = len({fid for _, fid in big}) / total if total else 0.0
    return len(clusters), share, (big[0][0][0], big[0][0][1], big[-1][0][1])

def arm(dirpath):
    members = {}
    for fn in sorted(os.listdir(os.path.join(dirpath, "members"))):
        if fn.endswith(".md"):
            members[fn[:-3]] = findings(open(os.path.join(dirpath, "members", fn), encoding="utf8").read())
    names = sorted(members)
    pair_scores, pair_detail = {}, []
    for i, j in itertools.combinations(names, 2):
        fi, fj = members[i], members[j]
        matched = 0
        for a in fi:
            for b in fj:
                how = match(a, b)
                if how:
                    matched += 1
                    pair_detail.append((i, j, how, a["title"][:60], b["title"][:60]))
                    break
        denom = min(len(fi), len(fj))
        pair_scores[(i, j)] = matched / denom if denom else 0.0
    mean = sum(pair_scores.values()) / len(pair_scores) if pair_scores else 0.0
    return members, pair_scores, pair_detail, mean

def main():
    for d in sys.argv[1:]:
        members, pairs, detail, mean = arm(d)
        label = os.path.basename(d.rstrip("/"))
        total = sum(len(v) for v in members.values())
        print(f"## Arm {label}: {len(members)} members, {total} findings, mean pairwise overlap {mean:.3f}")
        print("| member | findings | critical | high | medium | low |")
        print("|---|---|---|---|---|---|")
        for m, fs in members.items():
            c = {s: sum(1 for f in fs if f["sev"] == s) for s in ("critical", "high", "medium", "low")}
            print(f"| {m} | {len(fs)} | {c['critical']} | {c['high']} | {c['medium']} | {c['low']} |")
        print()
        print("Pairwise overlap (matched / min(n_i, n_j)):")
        for (i, j), s in sorted(pairs.items()):
            print(f"  {i} x {j}: {s:.2f}")
        print("Sensitivity (mean pairwise overlap): " + ", ".join(
            f"tol={t}/jac={j}: {mean_overlap(members, t, j):.3f}" for t in (0, 5, 20) for j in (0.3, 0.5)))
        nc, share, big = hotspots(members)
        print(f"Location clusters (±5 lines, same file): {nc}; largest cluster {big} touches {share:.0%} of findings")
        print(f"Cross-member matched pairs: {len(detail)}")
        for i, j, how, ta, tb in detail:
            print(f"  [{how}] {i} <-> {j}: {ta!r} ~ {tb!r}")
        print()
        json.dump({"arm": label, "members": {m: [{"title": f["title"], "sev": f["sev"], "locs": f["locs"]} for f in fs] for m, fs in members.items()},
                   "pairwise": {f"{i}|{j}": s for (i, j), s in pairs.items()}, "mean_pairwise_overlap": mean, "total_findings": total},
                  open(os.path.join(d, "overlap.json"), "w"), indent=1)

if __name__ == "__main__":
    main()
