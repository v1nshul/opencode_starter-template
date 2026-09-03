# Benchmark Results

Task: `math-lib` | Model: `opencode/big-pickle` | Runs/agent: 3

## Token usage

| metric       | build    | token-lean | orchestrator |
|--------------|----------|------------|--------------|
| input        | 27,106   | 33,330     | 26,804       |
| output       | 4,154    | 1,441      | 3,838        |
| reasoning    | 0        | 0          | 0            |
| cache_read   | 178,112  | 101,312    | 165,376      |
| cache_write  | 0        | 0          | 0            |
| **total**    | **31,260** | **34,771** | **30,642** |
| cost         | 0.0000   | 0.0000     | 0.0000       |

## Deltas vs baseline (build)

- **orchestrator**: −2.0% — SAVES tokens
- **token-lean**: +11.2% — USES more (no savings)

## Completion gates

| agent        | completed |
|--------------|-----------|
| build        | 2/3       |
| token-lean   | 0/3       |
| orchestrator | 2/3       |

Notes: `token-lean` produced the fewest output tokens (1,441) but failed all
completion gates — it saved output tokens by not writing the required files
(`src/mathlib.py`, `test_mathlib.py`). `orchestrator` was cheapest on total
tokens while completing 2/3 runs.

Generated: 2026-09-03. Raw data: `bench/report/report.json` (gitignored).
