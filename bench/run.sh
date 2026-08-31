#!/usr/bin/env bash
#
# Token-usage benchmark harness.
#
# Runs the SAME task through two opencode agents (`build` and `token-lean`)
# under one pinned model, parses per-session token usage from the
# `--format json` event stream, and writes a comparison report.
#
# Usage:
#   ./bench/run.sh --model MODEL [--task math-lib] [--runs N] [--out DIR]
#
# Model is REQUIRED (no default) so a run never burns an unintended model.
# Pass --model or set BENCH_MODEL.
#
# Env:
#   BENCH_MODEL   model id for every run (alternative to --model)
#   OPENCODE_BIN  path to opencode binary (default: `opencode`)
set -euo pipefail

usage() {
  sed -n '2,17p' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN="${OPENCODE_BIN:-opencode}"
MODEL="${BENCH_MODEL:-}"
RUNS=3
TASK="math-lib"
OUT="$ROOT/report"
AGENTS=(build token-lean)

while [[ $# -gt 0 ]]; do
  case "$1" in
    --task) TASK="$2"; shift 2 ;;
    --runs) RUNS="$2"; shift 2 ;;
    --model) MODEL="$2"; shift 2 ;;
    --out) OUT="$2"; shift 2 ;;
    -h|--help) usage 0 ;;
    *) echo "unknown arg: $1 (try --help)" >&2; exit 2 ;;
  esac
done

[[ -n "$MODEL" ]] || { echo "error: --model MODEL (or BENCH_MODEL) is required" >&2; usage 2; }

FIXTURE="$ROOT/tasks/$TASK.toml"
[[ -f "$FIXTURE" ]] || { echo "task fixture not found: $FIXTURE" >&2; exit 2; }

command -v "$BIN" >/dev/null || { echo "opencode binary not found: $BIN" >&2; exit 2; }

python3 -c 'import tomllib' 2>/dev/null || { echo "python >= 3.11 required (tomllib)" >&2; exit 2; }

# Credential sanity check before burning runs.
if ! "$BIN" auth list 2>/dev/null | grep -q .; then
  echo "WARN: no provider credentials detected. Runs will likely fail." >&2
fi

PROMPT="$(python3 - "$FIXTURE" <<'PY'
import tomllib, sys
with open(sys.argv[1], "rb") as f:
    print(tomllib.load(f)["prompt"])
PY
)"

mkdir -p "$OUT/events"
rm -f "$OUT/events"/*.jsonl 2>/dev/null || true
: > "$OUT/audit.log"

for agent in "${AGENTS[@]}"; do
  for i in $(seq 1 "$RUNS"); do
    scratch="$OUT/scratch-$agent/run-$i"
    rm -rf "$scratch" && mkdir -p "$scratch"
    events="$OUT/events/$agent-$i.jsonl"

    echo "[$(date +%H:%M:%S)] $agent run $i/$RUNS (model=$MODEL)" | tee -a "$OUT/audit.log"

    # Run in an isolated scratch dir so caches/work are comparable.
    ( cd "$scratch" && \
      "$BIN" run --format json --model "$MODEL" --agent "$agent" "$PROMPT" \
        > "$events" 2>>"$OUT/audit.log" ) \
      || echo "  run failed (see $OUT/audit.log)" | tee -a "$OUT/audit.log"
  done
done

# Aggregate assistant token usage from message.updated events and emit report.
python3 - "$OUT" "$TASK" "$MODEL" "$RUNS" "${AGENTS[@]}" <<'PY'
import json, sys
from pathlib import Path

out, task, model, runs, *agents = sys.argv[1:]
report = {"task": task, "model": model, "runs": int(runs), "agents": {}}
zero = {"input": 0, "output": 0, "reasoning": 0,
        "cache_read": 0, "cache_write": 0, "cost": 0.0}

for agent in agents:
    tot = dict(zero)
    for ev in sorted(Path(out, "events").glob(f"{agent}-*.jsonl")):
        for line in ev.read_text().splitlines():
            try:
                e = json.loads(line)
            except ValueError:
                continue
            if e.get("type") != "message.updated":
                continue
            info = (e.get("properties") or {}).get("info") or {}
            if info.get("role") != "assistant":
                continue
            t = info.get("tokens") or {}
            tot["input"] += t.get("input", 0)
            tot["output"] += t.get("output", 0)
            tot["reasoning"] += t.get("reasoning", 0)
            c = t.get("cache") or {}
            tot["cache_read"] += c.get("read", 0)
            tot["cache_write"] += c.get("write", 0)
            tot["cost"] += info.get("cost", 0.0) or 0.0
    tot["cost"] = round(tot["cost"], 4)
    tot["total"] = tot["input"] + tot["output"] + tot["reasoning"]
    report["agents"][agent] = tot

path = Path(out, "report.json")
path.write_text(json.dumps(report, indent=2) + "\n")
print(f"Benchmark complete — report: {path}")
PY
