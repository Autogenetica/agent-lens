#!/usr/bin/env python3
"""Blind extractor for the asa#35 A/B rerun (task-a5e5dabd).

Takes an arm's concatenated member reviews (A/review.md, B/review.md) and emits
one file per member containing ONLY the rated sections (Concerns and
Recommendations), with the treatment's structural tells removed:

  * drops sections whose heading matches the treatment persona fields
    (Silent checklist / Blocking criteria / Signature trade-off) and
    everything else that isn't Concerns or Recommendations;
  * redacts the treatment phrases inline ("[redacted]") rather than dropping lines,
    so arm B does not lose rated content;
  * normalizes per-concern headers to one canonical form
    ("### Cn (severity): title") so arm A's "### C1. title (critical)" and
    arm B's "**C1 — critical. title**" are indistinguishable;
  * numbers output files by shuffled slot, writing the slot->member map to
    a sealed key file the rater must not open until scoring is done.

Usage: python3 -I extract-rated.py <review.md> <outdir> [--seed N]
"""
import re, sys, json, random, pathlib

KEEP = {"concerns", "recommendations"}
REDACT = re.compile(r"silent[ -]checklist|signature[ -]trade[ -]?off|blocking[ -]criteri\w*", re.I)
HDR_A = re.compile(r"^###\s+(C\d+)[.:]?\s+(.*?)\s*\((\w+)\)\s*$")
HDR_B = re.compile(r"^\*\*(C\d+)\s*[—–-]+\s*(\w+)\.\s*(.*?)\*\*\s*$")
HDR_S = re.compile(r"^###\s+(critical|high|medium|low)\s*[:.]\s*(.*?)\s*$", re.I)
SEV_SUFFIX = re.compile(r"\s*(?:Severity:|[—–-]+)\s*\*{0,2}(critical|high|medium|low)\*{0,2}\s*(\([^)]*\))?\s*$", re.I)

MEMBER_HDR = re.compile(r"^#{1,2}\s+(?!Arm )(.*\breview\b.*)$", re.I | re.M)
SECTION_HDR = re.compile(r"^(#{2,3})\s+(?!(?:C\d+|critical|high|medium|low)\b)(.*)$", re.I)
# A "###" heading only switches sections when it names a known top-level section;
# otherwise it is content (e.g. "### Immediate" under Recommendations). "##" always switches.
SECTION_WORDS = {"perspective", "key", "strengths", "concerns", "recommendations",
                 "risks", "silent", "signature", "blocking"}

def members(text):
    starts = [m.start() for m in MEMBER_HDR.finditer(text)]
    return [text[a:b] for a, b in zip(starts, starts[1:] + [len(text)])]

def rated_sections(member_text):
    lines, keep, cur = [], False, None
    for ln in member_text.splitlines():
        m = SECTION_HDR.match(ln)
        if m and (m.group(1) == "##" or m.group(2).strip().lower().split()[0].rstrip(",:") in SECTION_WORDS):
            cur = m.group(2).strip().lower().split(" (")[0].split(" within")[0]
            keep = cur in KEEP
            if keep:
                lines.append(f"## {cur.capitalize()}")
            continue
        if not keep:
            continue
        ln = REDACT.sub("[redacted]", ln)
        sv = SEV_SUFFIX.search(ln)
        if ln.startswith("### ") and sv:
            ln = f"### ({sv.group(1).lower()}): " + SEV_SUFFIX.sub("", ln[4:]).strip(".: ")
        a, b, c = HDR_A.match(ln), HDR_B.match(ln), HDR_S.match(ln)
        if c:
            ln = f"### ({c.group(1).lower()}): {c.group(2)}"
        if a:
            ln = f"### {a.group(1)} ({a.group(3).lower()}): {a.group(2)}"
        elif b:
            ln = f"### {b.group(1)} ({b.group(2).lower()}): {b.group(3)}"
        lines.append(ln)
    return "\n".join(lines).strip() + "\n"

def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    seed = int(sys.argv[sys.argv.index("--seed") + 1]) if "--seed" in sys.argv else 0
    src, outdir = pathlib.Path(args[0]), pathlib.Path(args[1])
    outdir.mkdir(parents=True, exist_ok=True)
    ms = members(src.read_text())
    order = list(range(len(ms)))
    random.Random(seed).shuffle(order)
    key = {}
    for slot, idx in enumerate(order, 1):
        title = ms[idx].splitlines()[0].lstrip("# ").strip()
        (outdir / f"slot-{slot:02d}.md").write_text(rated_sections(ms[idx]))
        key[f"slot-{slot:02d}"] = title
    (outdir / "KEY-sealed.json").write_text(json.dumps(key, indent=2) + "\n")
    print(f"{src}: {len(ms)} members -> {outdir} (key sealed, seed={seed})")

if __name__ == "__main__":
    main()
