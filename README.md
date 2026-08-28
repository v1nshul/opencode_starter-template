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
./bench/run.sh            # 3 runs each: build vs token-lean, same model
python3 bench/summary.py  # comparison table + % delta
```

Requires a connected provider (e.g. `opencode auth login` for Zen). Results
land in `bench/report/report.json`; per-run event streams are in
`bench/report/events/`. Override the pinned model or run count with
`--model opencode/<id>` and `--runs N`.

Add a new workload by dropping a `<name>.toml` fixture in `bench/tasks/` with
a `prompt` field, then run `./bench/run.sh --task <name>`.
