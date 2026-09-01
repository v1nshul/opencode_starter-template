# Token-Optimized AI Starter Kit

A minimal, budget-friendly starting point for agentic coding projects. Ships
with strict token-efficiency rules so your agent spends tokens on code, not
chatter.

## Start a new project in 3 steps

1. `git clone <this repo> my-project && cd my-project`
2. `rm -rf .git && git init` — drop the template history for a clean start
3. `opencode` — launch, and the token rules apply automatically

## Verify the token rules actually save tokens

The `token-lean` agent and `AGENTS.md` rules only help if they change behavior.
Measure them instead of guessing:

```sh
./bench/run.sh --model opencode/<model-id>   # 3 runs each: build vs token-lean
python3 bench/summary.py                     # comparison table + % delta
```

Requires a connected provider (`opencode auth login`) and Python >= 3.11.
`--model` is required (no default) so a run never silently burns an unintended
model; `BENCH_MODEL` is an equivalent alternative. Use a Zen model id
(`opencode/big-pickle`, `opencode/mimo-v2.5-free`, ...) — check `opencode models`
or `/models` in the TUI for what your provider serves. Results land in
`bench/report/report.json`; per-run event streams are in
`bench/report/events/`. Set run count with `--runs N`; see `--help`.

Bundled fixtures: `math-lib` (greenfield), `bug-hunt` (fix-bugs loop), and
`orchestrated` (full delegation pipeline). Add your own by dropping a
`<name>.toml` in `bench/tasks/` with a `prompt` field, then run
`./bench/run.sh --model <id> --task <name>`.

## Multi-agent orchestration

Beyond the single `token-lean` agent, this template ships a small orchestrator
pattern for multi-step work. Delegation is explicit: the orchestrator only
invokes a specialist when you ask it to.

| agent | mode | tools | role |
| --- | --- | --- | --- |
| `orchestrator` | primary | read/grep/glob/list/bash, no edits | decomposes work, delegates on request |
| `explore` | subagent | read-only | discovery: find files/symbols, map structure |
| `planner` | subagent | read-only | produce an implementation plan |
| `coder` | subagent | read/edit only, no search/test | implement from exact instructions |
| `reviewer` | subagent | read + bash, no edits | verify changes, run tests |

Protocol: `explore -> planner -> coder -> reviewer`. Specialists never delegate
(`task_budget` 0); only the orchestrator can (`task_budget` 10, depth limit 3).

Use it in the TUI:

```
Switch to the orchestrator (Tab), then:
  use explore to map the workspace
  have the planner outline the implementation
  delegate the implementation to coder
  have reviewer run the tests
```

Or `@mention` a specialist directly for one-off work (`@explore find the auth
flow`).

## Sample results

Benchmarked with the free Zen model `opencode/big-pickle`, task `math-lib`,
one run per agent:

| metric | build | token-lean |
| --- | --- | --- |
| input | 3,308 | 2,507 |
| output | 952 | 1,118 |
| cache_read | 50,432 | 39,488 |
| **total** | **4,260** | **3,625** |

**Delta: token-lean saves 14.9%** over the default `build` agent on this
workload. Treat these numbers as illustrative of the harness, not a guarantee —
ratios vary by model, task, and run count. Rerun `./bench/run.sh` for
deterministic, model-specific results.
