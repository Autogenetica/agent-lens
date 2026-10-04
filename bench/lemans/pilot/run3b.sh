#!/usr/bin/env bash
# Run 3b: relaunch only the run-3 trials that died before their first model
# call (OpenRouter 402 insufficient-credits from 02:15Z 2026-09-26 — 133 of
# 198: 42 baseline / 44 lensed / 47 vocab). A dead trial dir under
# <arm>/runs/run3/claude-haiku-4.5/<task>__<id>/ has result.json but no
# agent.patch. Nothing in runs/run3 is touched; new trials land in runs/run3b.
#
#   PLAN=1 bench/lemans/pilot/run3b.sh    # print the per-arm relaunch plan, exit
#   bench/lemans/pilot/run3b.sh           # launch, watch, write the combined readout
#   C=3 CEILING=45 bench/lemans/pilot/run3b.sh
#
# Pre-flight: https://openrouter.ai/api/v1/credits must show a real balance —
# the script refuses under $MIN_BALANCE so it can't repeat run 3's failure mode.
# Per arm, dead trials are grouped by task; each distinct "attempts missing"
# count becomes one `lemans run -k <count> --task …` call (k applies to every
# --task in a call, so a task missing 2 attempts must not ride in a k=3 call).
# Groups run sequentially inside an arm; the three arms run in parallel, -c 3
# each, same as run3.sh. Same watchdog (spend ceiling + first-5 cache gate).
# On completion: readout.rb over run3 + run3b with the dead run-3 trials
# dropped, so the RESULTS file is the actual k=3 pilot. Prints "== done".
set -uo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo="$(cd "$here/../../.." && pwd)"
export PATH="$HOME/.orbstack/bin:$HOME/.local/share/mise/shims:$PATH"
set -a; . "$repo/.env"; set +a
: "${OPENROUTER_API_KEY:?OPENROUTER_API_KEY absent}"

C="${C:-3}"; CEILING="${CEILING:-45}"; MIN_BALANCE="${MIN_BALANCE:-40}"
DATE="${DATE:-$(date +%Y-%m-%d)}"; MODEL_DIR="${MODEL_DIR:-claude-haiku-4.5}"
ARMS=(baseline lensed vocab)

# dead_tasks <arm> -> lines "<count> <task>", one per task with dead trials
dead_tasks() {
  local d="$here/$1/runs/run3/$MODEL_DIR" t
  for t in "$d"/*/; do
    [ -f "$t/result.json" ] && [ ! -f "$t/agent.patch" ] && basename "$t" | sed 's/__.*//'
  done | sort | uniq -c | awk '{print $1, $2}'
}

total=0
for arm in "${ARMS[@]}"; do
  n=$(dead_tasks "$arm" | awk '{s+=$1} END{print s+0}'); total=$((total + n))
  echo "== $arm: $n dead trials to relaunch"
  for k in 3 2 1; do
    tasks=$(dead_tasks "$arm" | awk -v k="$k" '$1==k{print $2}' | tr '\n' ' ')
    [ -n "$tasks" ] && echo "   -k $k: $tasks"
  done
done
echo "== total $total (run 3 readout expected 133)"
if [ "${PLAN:-0}" = 1 ]; then echo "== PLAN only, not launching"; exit 0; fi
[ "$total" -gt 0 ] || { echo "nothing dead — exiting"; exit 0; }

bal=$(curl -s https://openrouter.ai/api/v1/credits -H "Authorization: Bearer $OPENROUTER_API_KEY" \
  | ruby -rjson -e 'd=JSON.parse(STDIN.read)["data"]; puts (d["total_credits"].to_f - d["total_usage"].to_f).round(2)')
echo "== openrouter balance \$$bal (need >= \$$MIN_BALANCE)"
awk -v b="$bal" -v m="$MIN_BALANCE" 'BEGIN{exit !(b>=m)}' || { echo "== REFUSED: balance below \$$MIN_BALANCE"; exit 2; }

echo "== run3b start $(date -u +%FT%TZ) c=$C ceiling=\$$CEILING trials=$total arms=${ARMS[*]}"
echo "run3b $(date -u +%FT%TZ)" > "$repo/.parked"

pids=()
for arm in "${ARMS[@]}"; do
  mkdir -p "$here/$arm/runs/run3b"
  (
    for k in 3 2 1; do
      tasks=$(dead_tasks "$arm" | awk -v k="$k" '$1==k{print $2}')
      [ -n "$tasks" ] || continue
      task_args=(); for t in $tasks; do task_args+=(--task "$t"); done
      echo "== $arm -k $k: $(echo $tasks | wc -w | tr -d ' ') tasks $(date -u +%FT%TZ)"
      ( cd "$repo" && exec nice -n 10 lemans run --bench "$here/$arm" --backend docker \
          --runs-dir "$here/$arm/runs/run3b" -k "$k" -c "$C" "${task_args[@]}" )
    done
  ) > "$here/$arm/runs/run3b/lemans.log" 2>&1 &
  pids+=($!); echo "arm $arm pid $!"
done

spend() { ruby -rjson -e 'puts Dir[ARGV[0]].sum { |f| JSON.parse(File.read(f)).dig("usage","cost_usd").to_f }' "$here/*/runs/run3b/*/*/result.json"; }
count() { ls "$here"/*/runs/run3b/*/*/result.json 2>/dev/null | wc -l | tr -d ' '; }
hit()   { ruby -rjson -e 'i=c=0; Dir[ARGV[0]].each { |f| u=JSON.parse(File.read(f))["usage"]; i+=u["input_tokens"].to_i; c+=u["cached_tokens"].to_i }; puts i.zero? ? 0 : (100*c/i)' "$here/*/runs/run3b/*/*/result.json"; }
alive() { for p in "${pids[@]}"; do kill -0 "$p" 2>/dev/null && return 0; done; return 1; }
killall_arms() { echo "== KILL: $1 $(date -u +%FT%TZ)"; kill "${pids[@]}" 2>/dev/null; sleep 5; kill -9 "${pids[@]}" 2>/dev/null; docker ps -q --filter name=lemans | xargs -r docker rm -f >/dev/null 2>&1; echo "$1" > "$here/run3b.KILLED"; }

gate_checked=0
while alive; do
  sleep 120
  n=$(count); s=$(spend); h=$(hit)
  echo "$(date -u +%H:%MZ) trials=$n spend=\$$s cache=${h}%"
  if [ "$gate_checked" = 0 ] && [ "$n" -ge 5 ]; then
    gate_checked=1
    [ "$h" -lt 50 ] && { killall_arms "cache hit ${h}% < 50% on first $n trials"; break; }
  fi
  awk -v s="$s" -v c="$CEILING" 'BEGIN{exit !(s>c)}' && { killall_arms "spend \$$s > \$$CEILING"; break; }
done
wait 2>/dev/null

echo "== runs finished $(date -u +%FT%TZ) trials=$(count) spend=\$$(spend) cache=$(hit)%"
echo "== reach.rb cross-check (run3b only)"
ruby "$here/reach.rb" baseline="$here/baseline/runs/run3b" lensed="$here/lensed/runs/run3b" vocab="$here/vocab/runs/run3b" 2>&1 || true
out="$here/RESULTS-$DATE.md"
RUNS='{run3,run3b}' DROP_DEAD=1 ruby "$here/readout.rb" "$DATE" > "$out" && echo "== combined readout written $out"
cd "$repo" && git add "$out" && git commit -q -m "bench(lemans): run 3 + 3b combined readout (auto-generated by run3b.sh)" && git push -q -u origin "$(git rev-parse --abbrev-ref HEAD)" && echo "== pushed"
rm -f "$repo/.parked"
echo "== done $(date -u +%FT%TZ)"
