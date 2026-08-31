#!/usr/bin/env python3
"""Render a human-readable comparison table from bench/report/report.json."""
import json, sys, os
from pathlib import Path

def main(path: str) -> None:
    data = json.loads(Path(path).read_text())
    agents = data.get("agents", {})
    names = list(agents.keys())
    if len(names) < 2:
        print("need at least two agents in report", file=sys.stderr)
        sys.exit(1)

    print(f"task: {data['task']}   model: {data['model']}   runs/agent: {data['runs']}\n")
    hdr = f"{'metric':<14}" + "".join(f"{n:>16}" for n in names)
    print(hdr)
    print("-" * (14 + 16 * len(names)))

    for metric in ("input", "output", "reasoning", "cache_read", "cache_write", "total", "cost"):
        row = f"{metric:<14}"
        for n in names:
            v = agents[n].get(metric, 0)
            if metric == "cost":
                row += f"{v:>16.4f}"
            else:
                row += f"{v:>16,}"
        print(row)

    a, b = names[0], names[1]
    print()
    base = agents[a]["total"] or 1
    delta = (agents[b]["total"] - agents[a]["total"]) / base * 100
    print(f"{a} total: {agents[a]['total']:,}  (baseline)")
    print(f"{b} total: {agents[b]['total']:,}")
    print(f"delta ({b} vs {a}): {delta:+.1f}%  "
          + ("SAVES tokens" if delta < 0 else "USES more (or no savings)"))
    base_cost = agents[a]["cost"] or 0
    if base_cost:
        print(f"cost delta: {agents[b]['cost']-base_cost:+.4f}")

if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), "report/report.json"))
