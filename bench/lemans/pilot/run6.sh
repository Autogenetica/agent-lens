#!/usr/bin/env bash
# Run 6 of the lens pilot: the pre-registered check-reachability split.
# Two arms, baseline then process, byte-identical to runs 2/4 (the script
# refuses if `git diff lemans/run4-corpus-arms -- <arms>` is non-empty), both
# forced to gpt-5.6-luna with `--model` (baseline's bench.yml has said Haiku
# since run 3; the override keeps the arm directory untouched). All 22
# Writebook tasks, -k 10, -c 3, host-side miniswen, docker backend. Trials
# land in <arm>/runs/run6/gpt-5.6-luna/ so the run-2/run-4 dirs stay as they are.
#
#   PLAN=1 bench/lemans/pilot/run6.sh     # pre-flight only, exit before launch
#   bench/lemans/pilot/run6.sh            # launch, watch, write the readout
#   C=3 CEILING=9 MIN_BALANCE=10 bench/lemans/pilot/run6.sh
#
# Pre-flight refuses if: OPENROUTER_API_KEY absent, OpenRouter credits under
# $MIN_BALANCE, arm diff non-empty, a named task dir missing, docker down.
# Watchdog every 120 s: spend > $CEILING kills the run; a wrong model id on
# the first finished trial kills it; no finished trial 20 min into an arm
# (image build or setup hung) kills it. After the first arm, spend above
# half the ceiling stops the second arm from starting. On completion:
# `lemans report` per arm → split/lemans-report-run6-<arm>.txt, readout6.rb →
# RESULTS-<date>-run6.md, commit + push the branch, remove .parked, "== done".
# Detach with `nohup … &` in a subshell (no setsid on macOS); never edit this
# file while it runs (bash reads by byte offset).
set -uo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo="$(cd "$here/../../.." && pwd)"
export PATH="$HOME/.orbstack/bin:$HOME/.local/share/mise/shims:$PATH"
if [ -f "$repo/.env" ]; then set -a; . "$repo/.env"; set +a; fi
: "${OPENROUTER_API_KEY:?OPENROUTER_API_KEY absent}"

K="${K:-10}"; C="${C:-3}"; CEILING="${CEILING:-9}"; MIN_BALANCE="${MIN_BALANCE:-10}"
MODEL="${MODEL:-openrouter/openai/gpt-5.6-luna}"; MODEL_DIR="${MODEL##*/}"
RUN="${RUN:-run6}"; BASE_REF="${BASE_REF:-lemans/run4-corpus-arms}"
ARMS=(baseline process)
TASKS=(ac-deep-link-return ac-throttle-search aj-enqueue-after-commit aj-resumable-cleanup
  ar-announce-once ar-archive-book-access ar-atomic-import ar-bulk-access-grants
  ar-compact-positions ar-erase-account ar-release-recap ar-tenant-isolation
  as-purge-embedded-images as-variant-processed-once av-toc-cache-per-role hello-world
  hw-scoped-broadcast sec-audit-sweep sup-cache-library-digest sup-legacy-conversions
  sup-log-to-terminal tst-error-page-flake)
task_args=(); for t in "${TASKS[@]}"; do task_args+=(--task "$t"); done

ts() { date -u +%FT%TZ; }
refuse() { echo "== REFUSED: $*"; exit 2; }

echo "== $RUN pre-flight $(ts) k=$K c=$C ceiling=\$$CEILING model=$MODEL arms=${ARMS[*]} tasks=${#TASKS[@]}"
echo "== branch $(git -C "$repo" rev-parse --abbrev-ref HEAD) @ $(git -C "$repo" rev-parse --short HEAD)"

arm_paths=(); for a in "${ARMS[@]}"; do arm_paths+=("$here/$a"); done
if git -C "$repo" diff --quiet "$BASE_REF" -- "${arm_paths[@]}" && [ -z "$(git -C "$repo" status --porcelain -- "${arm_paths[@]}")" ]; then
  echo "== arm diff against $BASE_REF: empty (bench/lemans/pilot/{baseline,process} byte-identical)"
else
  git -C "$repo" diff --stat "$BASE_REF" -- "${arm_paths[@]}"; git -C "$repo" status --porcelain -- "${arm_paths[@]}"
  refuse "arm directories differ from $BASE_REF"
fi
for a in "${ARMS[@]}"; do
  for t in "${TASKS[@]}"; do [ -d "$here/$a/tasks/$t" ] || refuse "$a/tasks/$t missing (run prepare.sh)"; done
  grep -q 'gpt-5.6-luna\|claude-haiku-4.5' "$here/$a/bench.yml" || refuse "$a/bench.yml model line unexpected"
done
echo "== tasks present in both arms"
docker info >/dev/null 2>&1 || refuse "docker not reachable"
echo "== docker up; lemans images: $(docker images --format '{{.Repository}}' | grep -c '^lemans-')"

bal=$(curl -s https://openrouter.ai/api/v1/credits -H "Authorization: Bearer $OPENROUTER_API_KEY" \
  | ruby -rjson -e 'd=JSON.parse(STDIN.read)["data"]; puts (d["total_credits"].to_f - d["total_usage"].to_f).round(2)')
echo "== openrouter balance \$$bal (need >= \$$MIN_BALANCE)"
awk -v b="$bal" -v m="$MIN_BALANCE" 'BEGIN{exit !(b>=m)}' || refuse "balance below \$$MIN_BALANCE"
if [ "${PLAN:-0}" = 1 ]; then echo "== PLAN only, not launching"; exit 0; fi

snap="$repo/runs/snap-$RUN"; mkdir -p "$snap"
for a in "${ARMS[@]}"; do rsync -a --exclude runs "$here/$a/" "$snap/$a/"; done
echo "== arms snapshotted to $snap"
echo "$RUN $(ts) pid $$" > "$repo/.parked"
echo "== $RUN start $(ts)"

spend() { ruby -rjson -e 'puts Dir[ARGV[0]].sum { |f| JSON.parse(File.read(f)).dig("usage","cost_usd").to_f }.round(4)' "$here/*/runs/$RUN/*/*/result.json"; }
count() { ls "$here"/*/runs/$RUN/*/*/result.json 2>/dev/null | wc -l | tr -d ' '; }
hit()   { ruby -rjson -e 'i=c=0; Dir[ARGV[0]].each { |f| u=JSON.parse(File.read(f))["usage"]; i+=u["input_tokens"].to_i; c+=u["cached_tokens"].to_i }; puts i.zero? ? 0 : (100*c/i)' "$here/*/runs/$RUN/*/*/result.json"; }
models() { ruby -rjson -e 'puts Dir[ARGV[0]].map { |f| JSON.parse(File.read(f))["model"] }.tally.inspect' "$here/*/runs/$RUN/*/*/result.json"; }
kill_run() { echo "== KILL: $1 $(ts)"; kill "$pid" 2>/dev/null; sleep 5; kill -9 "$pid" 2>/dev/null; docker ps -q --filter name=lemans | xargs docker rm -f >/dev/null 2>&1; echo "$1" > "$here/$RUN.KILLED"; }

killed=0; model_checked=0
for arm in "${ARMS[@]}"; do
  mkdir -p "$here/$arm/runs/$RUN"
  echo "== arm $arm start $(ts) spend-so-far=\$$(spend)"
  ( cd "$repo" && exec nice -n 10 lemans run --bench "$here/$arm" --backend docker --model "$MODEL" \
      --runs-dir "$here/$arm/runs/$RUN" -k "$K" -c "$C" "${task_args[@]}" ) \
      > "$here/$arm/runs/$RUN/lemans.log" 2>&1 &
  pid=$!; echo "arm $arm pid $pid"
  arm_t0=$(date +%s); arm_n0=$(count)
  while kill -0 "$pid" 2>/dev/null; do
    sleep 120
    n=$(count); s=$(spend); h=$(hit)
    echo "$(date -u +%H:%MZ) $arm trials=$n spend=\$$s cache=${h}%"
    if [ "$model_checked" = 0 ] && [ "$n" -ge 1 ]; then
      model_checked=1
      m=$(models); echo "== first finished trial model(s): $m"
      case "$m" in *"$MODEL"*) ;; *) kill_run "model id is $m, expected $MODEL"; killed=1; break ;; esac
    fi
    if [ "$n" -eq "$arm_n0" ] && [ $(( $(date +%s) - arm_t0 )) -gt 1200 ]; then kill_run "no finished trial 20 min into $arm (build/setup hung)"; killed=1; break; fi
    awk -v s="$s" -v c="$CEILING" 'BEGIN{exit !(s>c)}' && { kill_run "spend \$$s > \$$CEILING"; killed=1; break; }
  done
  wait "$pid" 2>/dev/null; echo "== arm $arm finished $(ts) exit=$? trials=$(count) spend=\$$(spend) cache=$(hit)%"
  [ "$killed" = 1 ] && break
  if [ "$arm" = "${ARMS[0]}" ]; then
    half=$(awk -v c="$CEILING" 'BEGIN{print c/2}')
    awk -v s="$(spend)" -v h="$half" 'BEGIN{exit !(s>h)}' && { echo "== STOP: first arm spent \$$(spend) > \$$half (half the ceiling); not starting ${ARMS[1]}"; echo "first-arm spend over half ceiling" > "$here/$RUN.KILLED"; break; }
  fi
done

echo "== runs finished $(ts) trials=$(count) spend=\$$(spend) cache=$(hit)% models=$(models)"
for arm in "${ARMS[@]}"; do
  [ -d "$here/$arm/runs/$RUN/$MODEL_DIR" ] || continue
  ( cd "$repo" && lemans report --runs-dir "$here/$arm/runs/$RUN/$MODEL_DIR" -A task ) > "$here/split/lemans-report-$RUN-$arm.txt" 2>&1 \
    && echo "== lemans report $arm → split/lemans-report-$RUN-$arm.txt"
done
DATE="${DATE:-$(date +%Y-%m-%d)}"; out="$here/RESULTS-$DATE-$RUN.md"
K="$K" RUN="$RUN" MODEL_DIR="$MODEL_DIR" ruby "$here/split/readout6.rb" "$DATE" > "$out" && echo "== readout written $out"
cd "$repo" && git add "$out" "$here"/split/lemans-report-$RUN-*.txt && git commit -q -m "bench(lemans): run 6 mechanical readout (auto-generated by run6.sh)" && git push -q -u origin "$(git rev-parse --abbrev-ref HEAD)" && echo "== pushed"
rm -f "$repo/.parked"
echo "== done $(ts)"
