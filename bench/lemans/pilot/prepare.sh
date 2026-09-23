#!/usr/bin/env bash
# Build both pilot arms from a local ai-evals checkout.
#
#   bench/lemans/pilot/prepare.sh [AI_EVALS_DIR] [TASK ...]
#
# baseline/tasks  <- byte-for-byte copy of ai-evals/tasks
# lensed/tasks    <- lensify.rb output (lens SKILL.md prepended to instruction.md)
# control/tasks   <- lensify.rb output with control/LENS.md (vocabulary control; gated by control/check.rb)
# */docker        <- copy of ai-evals/docker (the Dockerfile bench.yml points at)
#
# Task names are identical across both arms, so `lemans report` rows pair up
# per task. Neither tasks/ nor docker/ is committed (see .gitignore).
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
lemans_dir="$(dirname "$here")"
ai_evals="${1:-$HOME/src/ai-evals}"
shift || true

[ -f "$ai_evals/bench.yml" ] || { echo "no ai-evals checkout at $ai_evals" >&2; exit 1; }

ruby "$here/control/check.rb" "$ai_evals"

rm -rf "$here/baseline/tasks" "$here/lensed/tasks" "$here/control/tasks"
mkdir -p "$here/baseline/tasks"

if [ $# -gt 0 ]; then
  for t in "$@"; do cp -R "$ai_evals/tasks/$t" "$here/baseline/tasks/"; done
else
  cp -R "$ai_evals/tasks/." "$here/baseline/tasks/"
fi

ruby "$lemans_dir/lensify.rb" --lens "$lemans_dir/lens/SKILL.md" \
  --tasks "$ai_evals/tasks" --out "$here/lensed/tasks" "$@"

ruby "$lemans_dir/lensify.rb" --lens "$here/control/LENS.md" \
  --tasks "$ai_evals/tasks" --out "$here/control/tasks" "$@"

for arm in baseline lensed control; do
  rm -rf "$here/$arm/docker"
  cp -R "$ai_evals/docker" "$here/$arm/docker"
done

echo "baseline: $(ls "$here/baseline/tasks" | wc -l | tr -d ' ') tasks"
echo "lensed:   $(ls "$here/lensed/tasks" | wc -l | tr -d ' ') tasks"
echo "control:  $(ls "$here/control/tasks" | wc -l | tr -d ' ') tasks"
