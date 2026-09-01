# System Rules — Token Efficiency

Strict, mandatory. Follow at all times.

## Context Gathering
- Never read whole directories. List only.
- Ignore lock files and large config files unless relevant.
- Search for specific functions/symbols, not entire large files.

## Output Generation
- No filler, pleasantries, or summaries.
- Output only code or terminal commands.

## Editing
- Never rewrite whole files for a few-line change.
- Use targeted diffs or precise edits.

## Execution
- Fail fast. After 2 bash failures, stop and ask the human.
- Combine commands with `&&`.

## Orchestration
- Only the `orchestrator` agent delegates (via the task tool), and only when explicitly requested.
- Specialists do not delegate: `explore` (read-only discovery), `planner` (read-only plans), `coder` (writes/edits, no search/test), `reviewer` (verification + tests, no edits).
- Pipeline order when coordinating: explore -> planner -> coder -> reviewer.
- Delegation prompts must carry exact file paths and expected output; expect compact summaries back.