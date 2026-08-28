#!/usr/bin/env bash
#
# Token-usage benchmark harness.
#
# Runs the SAME task through two opencode agents (`build` and `token-lean`)
# under the same pinned model, parses per-session token usage from the
# `--format json` event stream, and writes a comparison report.
#
# Usage:
#   ./bench/run.sh [--task math-lib] [--runs 3] [--model MODEL] [--out DIR]
#
# Env:
#   BENCH_MODEL   model id to pin for every run (default: from BENCH_MODEL or
#                 the model id baked into this script)
#   OPENCODE_BIN  path to opencode binary (default: `opencode`)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN="${OPENCODE_BIN:-opencode}"
MODEL="${BENCH_MODEL:-opencode/claude-sonnet-4-6}"
RUNS=3
TASK_DIR="$ROOT/tasks"
TASK="math-lib"
OUT="$ROOT/report"
AGENTS=(build token-lean)

while [[ $# -gt 0 ]]; do
  case "$1" in
    --task) TASK="$2"; shift 2 ;;
    --runs) RUNS="$2"; shift 2 ;;
    --model) MODEL="$2"; shift 2 ;;
    --out) OUT="$2"; shift 2 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

FIXTURE="$TASK_DIR/$TASK.toml"
if [[ ! -f "$FIXTURE" ]]; then
  echo "task fixture not found: $FIXTURE" >&2
  exit 2
fi

if ! command -v "$BIN" >/dev/null 2>&1; then
  echo "opencode binary not found: $BIN" >&2
  exit 2
fi

# Credential sanity check before burning runs.
if [[ "$(opencode auth list 2>/dev/null | grep -c '^│')" -le 1 ]]; then
  echo "WARN: no provider credentials detected. Runs will likely fail." >&2
fi

PROMPT="$(python3 -c "import tomllib,sys; print(tomllib.load(open('$FIXTURE','rb'))['prompt'])")"

mkdir -p "$OUT/events"
: > "$OUT/audit.log"

report_json="{"
report_json+="\"task\":\"$TASK\",\"model\":\"$MODEL\",\"runs\":$RUNS,"
report_json+="\"agents\":{"

declare -A inputs outputs reasoning cache_read cache_write costs counts

for agent in "${AGENTS[@]}"; do
  mkdir -p "$OUT/scratch-$agent"
  for i in $(seq 1 "$RUNS"); do
    scratch="$OUT/scratch-$agent/run-$i"
    rm -rf "$scratch" && mkdir -p "$scratch"
    events="$OUT/events/$agent-$i.jsonl"

    echo "[$(date +%H:%M:%S)] $agent run $i/$RUNS (model=$MODEL)" | tee -a "$OUT/audit.log"

    # Run in an isolated scratch dir so caches/work are comparable.
    ( cd "$scratch" && \
      "$BIN" run --format json --model "$MODEL" --agent "$agent" "$PROMPT" \
        > "$events" 2>>"$OUT/audit.log" ) || {
      echo "  run failed (see $OUT/audit.log) — skipping" | tee -a "$OUT/audit.log"
      continue
    }

    # Aggregate assistant token usage from message.updated events.
    read -r ti to tr cr cw ct <<< "$(python3 - "$events" "$agent" "$i" <<'PY'
import json, sys
ev = sys.argv[1]
tot = {"input":0,"output":0,"reasoning":0,"cache_read":0,"cache_write":0,"cost":0.0}
n = 0
with open(ev, encoding="utf-8") as f:
    for line in f:
        line = line.strip()
        if not line: continue
        try: e = json.loads(line)
        except Exception: continue
        if e.get("type") != "message.updated": continue
        info = (e.get("properties") or {}).get("info") or {}
        if info.get("role") != "assistant": continue
        t = info.get("tokens") or {}
        tot["input"]   += t.get("input", 0)
        tot["output"]  += t.get("output", 0)
        tot["reasoning"] += t.get("reasoning", 0)
        c = t.get("cache") or {}
        tot["cache_read"]  += c.get("read", 0)
        tot["cache_write"] += c.get("write", 0)
        tot["cost"] += info.get("cost", 0.0) or 0.0
        n += 1
print(tot["input"], tot["output"], tot["reasoning"],
      tot["cache_read"], tot["cache_write"], round(tot["cost"], 4))
PY
)"
    : "${ti:=0}" "${to:=0}" "${tr:=0}" "${cr:=0}" "${cw:=0}" "${ct:=0}"
    inputs[$agent]=$(( ${inputs[$agent]:-0} + ti ))
    outputs[$agent]=$(( ${outputs[$agent]:-0} + to ))
    reasoning[$agent]=$(( ${reasoning[$agent]:-0} + tr ))
    cache_read[$agent]=$(( ${cache_read[$agent]:-0} + cr ))
    cache_write[$agent]=$(( ${cache_write[$agent]:-0} + cw ))
    costs[$agent]=$(python3 -c "print('${costs[$agent]:-0}' if False else round(${costs[$agent]:-0}+$ct,4))")
  done

  report_json+="\"$agent\":{"
  report_json+="\"input\":${inputs[$agent]:-0},"
  report_json+="\"output\":${outputs[$agent]:-0},"
  report_json+="\"reasoning\":${reasoning[$agent]:-0},"
  report_json+="\"cache_read\":${cache_read[$agent]:-0},"
  report_json+="\"cache_write\":${cache_write[$agent]:-0},"
  report_json+="\"total\":$(( ${inputs[$agent]:-0} + ${outputs[$agent]:-0} + ${reasoning[$agent]:-0} )),"
  report_json+="\"cost\":${costs[$agent]:-0}"
  report_json+="}"
  if [[ "$agent" != "${AGENTS[-1]}" ]]; then report_json+=","; fi
done

report_json+="}}"
echo "$report_json" | python3 -m json.tool > "$OUT/report.json"

echo
echo "Benchmark complete — report: $OUT/report.json"
