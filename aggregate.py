#!/usr/bin/env python3
"""
Aggregate scores from a single iteration into a summary.

Usage:
    python3 scripts/aggregate.py workspace/iteration-1/

Reads all scores-*.json files in the directory and produces summary.json.
"""

import json
import sys
import os
from pathlib import Path
from collections import defaultdict


def load_scores(iteration_dir: Path) -> list[dict]:
    """Load all score files from an iteration directory."""
    scores = []
    for f in sorted(iteration_dir.glob("scores-*.json")):
        with open(f) as fh:
            scores.append(json.load(fh))
    return scores


def aggregate(scores: list[dict]) -> dict:
    """Compute per-dimension averages, weakest dimensions, and composite."""
    dimension_scores = defaultdict(list)
    eval_summaries = []

    for score_data in scores:
        eval_summary = {
            "eval_id": score_data.get("eval_id"),
            "eval_name": score_data.get("eval_name"),
            "composite_score": score_data.get("composite_score"),
            "expectations_missed": score_data.get("expectations_missed", []),
        }
        eval_summaries.append(eval_summary)

        for dim, value in score_data.get("scores", {}).items():
            if value is not None and isinstance(value, dict) and value.get("score") is not None:
                dimension_scores[dim].append({
                    "score": value["score"],
                    "eval_id": score_data.get("eval_id"),
                    "eval_name": score_data.get("eval_name"),
                    "justification": value.get("justification", ""),
                })

    # Per-dimension averages
    dimension_averages = {}
    for dim, entries in dimension_scores.items():
        scores_list = [e["score"] for e in entries]
        avg = sum(scores_list) / len(scores_list) if scores_list else 0
        lowest = min(entries, key=lambda e: e["score"]) if entries else None
        dimension_averages[dim] = {
            "average": round(avg, 2),
            "count": len(scores_list),
            "min": min(scores_list) if scores_list else None,
            "max": max(scores_list) if scores_list else None,
            "weakest_eval": {
                "eval_name": lowest["eval_name"],
                "score": lowest["score"],
                "justification": lowest["justification"],
            } if lowest else None,
        }

    # Overall composite
    all_composites = [s.get("composite_score", 0) for s in scores if s.get("composite_score") is not None]
    overall_composite = round(sum(all_composites) / len(all_composites), 2) if all_composites else 0

    # Weakest dimensions (sorted ascending)
    ranked_dimensions = sorted(dimension_averages.items(), key=lambda x: x[1]["average"])

    # All missed expectations across evals
    all_missed = []
    for s in eval_summaries:
        for missed in s.get("expectations_missed", []):
            all_missed.append({
                "eval_name": s["eval_name"],
                "expectation": missed,
            })

    return {
        "overall_composite": overall_composite,
        "num_evals": len(scores),
        "dimension_averages": dimension_averages,
        "weakest_dimensions": [
            {"dimension": dim, "average": data["average"]}
            for dim, data in ranked_dimensions[:3]
        ],
        "strongest_dimensions": [
            {"dimension": dim, "average": data["average"]}
            for dim, data in reversed(ranked_dimensions[-3:])
        ],
        "eval_summaries": eval_summaries,
        "missed_expectations": all_missed,
    }


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 scripts/aggregate.py <iteration-dir>")
        sys.exit(1)

    iteration_dir = Path(sys.argv[1])
    if not iteration_dir.is_dir():
        print(f"Error: {iteration_dir} is not a directory")
        sys.exit(1)

    scores = load_scores(iteration_dir)
    if not scores:
        print(f"No scores-*.json files found in {iteration_dir}")
        sys.exit(1)

    summary = aggregate(scores)

    output_path = iteration_dir / "summary.json"
    with open(output_path, "w") as fh:
        json.dump(summary, fh, indent=2)

    # Also print a human-readable report
    print(f"\n{'=' * 60}")
    print(f"  ITERATION SUMMARY — {iteration_dir.name}")
    print(f"{'=' * 60}")
    print(f"\n  Overall composite score: {summary['overall_composite']}/3.00")
    print(f"  Evals scored: {summary['num_evals']}")

    print(f"\n  Dimension Averages:")
    for dim, data in sorted(summary["dimension_averages"].items(), key=lambda x: x[1]["average"]):
        bar = "█" * int(data["average"] * 10) + "░" * (30 - int(data["average"] * 10))
        print(f"    {dim:25s}  {data['average']:.2f}  {bar}")

    if summary["weakest_dimensions"]:
        print(f"\n  Weakest dimensions (focus here):")
        for w in summary["weakest_dimensions"]:
            print(f"    → {w['dimension']} ({w['average']:.2f})")

    if summary["missed_expectations"]:
        print(f"\n  Missed expectations ({len(summary['missed_expectations'])} total):")
        for m in summary["missed_expectations"][:10]:
            print(f"    [{m['eval_name']}] {m['expectation']}")
        if len(summary["missed_expectations"]) > 10:
            print(f"    ... and {len(summary['missed_expectations']) - 10} more")

    print(f"\n  Full results: {output_path}")
    print()


if __name__ == "__main__":
    main()
