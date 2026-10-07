#!/usr/bin/env python3
"""Split the lens pilot's luna arms by hidden-check test-reachability.
R-subset = Writebook tasks whose hidden checks are >= 80% 'R' (stated in the
ticket + assertable with request/response or DB-state assertions in a plain
Rails integration/model test). Classification is by hand, see lens-corpus2.md.
usage: python3 reanalysis.py [pilot_dir]"""
import json, glob, os, sys
from collections import defaultdict
PILOT = sys.argv[1] if len(sys.argv) > 1 else os.path.expanduser("~/src/agent-lens/bench/lemans/pilot")
R = {"ac-deep-link-return","ac-throttle-search","aj-enqueue-after-commit","aj-resumable-cleanup",
     "ar-announce-once","ar-archive-book-access","ar-atomic-import","ar-compact-positions",
     "ar-erase-account","ar-release-recap","ar-tenant-isolation","av-toc-cache-per-role",
     "sec-audit-sweep","sup-legacy-conversions"}
NOT_R = {"ar-bulk-access-grants","as-purge-embedded-images","as-variant-processed-once",
         "hw-scoped-broadcast","sup-cache-library-digest","sup-log-to-terminal","tst-error-page-flake"}
ARMS = ["baseline","lensed","vocab","app","process","process2","noheader"]
print("columns: arm | R-subset pass/trials | not-R pass/trials | hello-world | total")
per_task = defaultdict(lambda: defaultdict(lambda: [0,0]))
for arm in ARMS:
    r=[0,0]; n=[0,0]; h=[0,0]
    for f in glob.glob(f"{PILOT}/{arm}/runs/gpt-5.6-luna/*/result.json"):
        d=json.load(open(f)); t=d["task"]; p=float(d.get("reward") or 0)>=1
        if not (d.get("outcome") or {}).get("scored"): continue
        b = r if t in R else n if t in NOT_R else h
        b[0]+=p; b[1]+=1
        per_task[t][arm][0]+=p; per_task[t][arm][1]+=1
    tot=r[0]+n[0]+h[0]; tt=r[1]+n[1]+h[1]
    print(f"{arm:9s} R {r[0]:3d}/{r[1]:<3d} ({100*r[0]/max(1,r[1]):.0f}%)   notR {n[0]:3d}/{n[1]:<3d} ({100*n[0]/max(1,n[1]):.0f}%)   hello {h[0]}/{h[1]}   total {tot}/{tt}")
print("\nR-subset tasks with headroom (any arm < 5/5):")
for t in sorted(R):
    cells = per_task[t]
    if all(cells[a][0]==cells[a][1] for a in ARMS if cells[a][1]): continue
    print(f"  {t:26s} " + " ".join(f"{a}={cells[a][0]}/{cells[a][1]}" for a in ARMS))
print("\nnot-R tasks:")
for t in sorted(NOT_R):
    cells = per_task[t]
    print(f"  {t:26s} " + " ".join(f"{a}={cells[a][0]}/{cells[a][1]}" for a in ARMS))
# pooled process-type vs baseline on R-subset, two-proportion z
import math
def pooled(arms, S):
    p=t=0
    for a in arms:
        for task in S: p+=per_task[task][a][0]; t+=per_task[task][a][1]
    return p,t
for label,S in (("R-subset",R),("not-R",NOT_R)):
    p1,t1=pooled(["process","process2","noheader"],S); p0,t0=pooled(["baseline"],S)
    pp=(p1+p0)/(t1+t0); se=math.sqrt(pp*(1-pp)*(1/t1+1/t0)) if 0<pp<1 else float("nan")
    z=((p1/t1)-(p0/t0))/se if se else float("nan")
    print(f"\n{label}: process-type pooled {p1}/{t1} ({100*p1/t1:.0f}%) vs baseline {p0}/{t0} ({100*p0/t0:.0f}%)  z={z:.2f}")
