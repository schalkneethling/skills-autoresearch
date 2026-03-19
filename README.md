# Semantic HTML Skill — Auto-Improvement Loop

An autonomous eval-and-improve loop for the [semantic-html](https://github.com/schalkneethling/webdev-agent-skills/tree/main/semantic-html) agent skill, inspired by [Karpathy's autoresearch](https://github.com/karpathy/autoresearch).

## How It Works

The loop follows a simple cycle:

1. **Generate** — Each eval prompt is sent to Claude with the skill loaded as context
2. **Judge** — A separate Claude call scores each HTML output across 8 quality dimensions
3. **Aggregate** — Scores are averaged, weakest dimensions identified
4. **Improve** — Claude edits the skill to address the weakest areas
5. **Repeat** — Until the target score is reached or iterations are exhausted

## Scoring Dimensions

| Dimension | What It Measures |
|-----------|------------------|
| `element_choice` | Right element for the job (button vs div, article vs div, etc.) |
| `aria_discipline` | ARIA used sparingly, only when native HTML can't do it |
| `heading_hierarchy` | Logical heading structure, no skipped levels |
| `landmark_structure` | Proper use of header, nav, main, footer, etc. |
| `form_semantics` | Labels, fieldsets, error handling |
| `content_realism` | Real-world content, not "Product 1" placeholders |
| `list_semantics` | Lists used where count helps the user |
| `table_semantics` | Full table structure with caption, thead, th[scope] |

Each dimension is scored 0–3. The composite score is the average of all scored dimensions.

## Project Structure

```
semantic-html-autoloop/
├── README.md              ← You are here
├── program.md             ← Agent instructions (the "meta-skill")
├── skill/                 ← Working copy of the skill (agent edits this)
│   ├── SKILL.md
│   └── references/
├── evals/
│   ├── eval-cases.json    ← 8 eval prompts with expectations
│   └── rubric.md          ← Detailed scoring criteria
├── scripts/
│   ├── run-loop.sh        ← Main orchestration script
│   ├── judge-prompt.md    ← System prompt for the LLM judge
│   └── aggregate.py       ← Score aggregation
└── workspace/             ← Iteration results
    ├── iteration-1/
    │   ├── skill-snapshot.md
    │   ├── output-0.html ... output-7.html
    │   ├── scores-0.json ... scores-7.json
    │   └── summary.json
    ├── iteration-2/
    │   └── ...
    └── changelog.md
```

## Quick Start

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed and authenticated
- Python 3.10+
- Your semantic-html skill

### Setup

```bash
# Clone or copy this directory
cd semantic-html-autoloop

# Edit config.json — set skill_source to your skill's location
cat config.json
# {
#   "skill_source": "~/projects/webdev-agent-skills/semantic-html",
#   "max_iterations": 5,
#   "target_score": 2.7
# }
```

The script will copy your skill into `skill/` automatically on each run,
so your original files are never modified directly.

### Option A: Run the Script Directly

```bash
bash scripts/run-loop.sh
```

### Option B: Let Claude Code Drive (Recommended)

This is closer to the autoresearch spirit — you point Claude Code at the
program.md and let it run the loop with judgment about when and how to improve.

```bash
claude
# Then in the Claude Code session:
> Read program.md and evals/eval-cases.json, then run the auto-improvement
> loop on the skill in skill/. Start with iteration 1.
```

This approach lets Claude Code make more nuanced decisions about what to change,
rather than following the rigid script.

### Option C: Interactive Mode

Run individual iterations and review between each one:

```bash
claude
> Read program.md. Run just iteration 1 — generate outputs and score them,
> then show me the summary before making any changes to the skill.
```

## Eval Cases

The 8 eval cases cover the full breadth of the skill:

| # | Name | Tests |
|---|------|-------|
| 1 | Product listing page | Landmarks, headings, lists, article, search, form filters |
| 2 | FAQ page | Details/summary, breadcrumbs, heading hierarchy |
| 3 | Data table with controls | Table semantics, form controls, pagination |
| 4 | Multi-step form | Fieldset/legend, labels, error handling, autocomplete |
| 5 | Blog article page | Article, time, aside, comments, address element |
| 6 | Dashboard sidebar nav | Multiple navs, aria-current, landmark labels |
| 7 | Pricing comparison table | Table with row/col headers, boolean features |
| 8 | Settings form | Radio groups, toggles, fieldset nesting, danger zone |

## Customising

### Adding eval cases

Add entries to `evals/eval-cases.json`. Each needs an `id`, `name`, `prompt`,
`focus_dimensions`, and `key_expectations`. The expectations are used by the
judge — make them specific and testable.

### Adjusting the rubric

Edit `evals/rubric.md` to change scoring criteria. Be careful here — the rubric
is the foundation of the entire loop. Changes propagate to every iteration.

### Changing the target

The default target of 2.7/3.0 means "consistently good with room for occasional
minor issues". Adjust in `run-loop.sh` or pass as a CLI argument.

## Tips

- **Review early iterations manually.** Before trusting the loop, look at the
  HTML outputs and judge scores for iteration 1. Are the scores fair? Are the
  evals testing what you think they're testing?

- **The changelog is your friend.** `workspace/changelog.md` tracks what changed
  each iteration and why. If scores regress, the changelog helps you understand
  what went wrong.

- **Don't let it run too long unattended.** Unlike autoresearch where the metric
  is unambiguous, LLM-as-judge can drift. Check in after a few iterations.

- **The best iteration might not be the last.** The script tracks the best score
  across all iterations. If iteration 3 scored 2.8 but iteration 5 scored 2.6
  (because a change regressed something), the script will point you to iteration 3.
