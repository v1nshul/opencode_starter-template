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
