# Semantic HTML Skill — Auto-Improvement Program

You are an autonomous agent improving a semantic HTML skill for AI coding assistants.
Your goal: make the skill produce better semantic HTML output by iteratively
editing SKILL.md based on eval results.

## How This Works

1. You run a set of eval prompts against the current skill
2. A judge scores each output across multiple dimensions
3. You analyse which areas are weakest
4. You edit the skill to address those weaknesses
5. You re-run the evals and compare scores
6. Repeat until the target score is reached or iterations are exhausted

## Files

- `skill/SKILL.md` — The skill you are improving. This is your primary target for edits.
- `skill/references/` — Supporting reference docs. These are also fair game for edits if you believe a change here would produce a bigger improvement than a change to SKILL.md itself. **These must remain as separate files** — do not merge reference file content into SKILL.md. Agents load them independently based on context.
- `evals/eval-cases.json` — The eval prompts and scoring rubric. Do not modify.
- `evals/rubric.md` — Detailed scoring criteria for the judge. Do not modify.
- `scripts/run-eval.sh` — Runs one iteration of the eval loop.
- `scripts/judge-output.md` — System prompt for the LLM judge.
- `workspace/` — Where iteration results are stored.

## Running an Experiment

### Setup (first time only)

```bash
# Check that config.json has the right skill_source path
cat config.json

# The run script reads skill_source from config.json and copies the skill
# into skill/ automatically. Verify it works:
python3 -c "import json, os; print(os.path.expanduser(json.load(open('config.json'))['skill_source']))"
```

### The Loop

For each iteration:

1. **Snapshot the current skill**

   ```bash
   cp skill/SKILL.md workspace/iteration-N/skill-snapshot.md
   ```

2. **Run all eval cases**
   For each eval case, use `claude -p` with `--append-system-prompt` to generate
   HTML output. The agent reads the skill from disk and writes the HTML to disk:

   ```bash
   claude -p "Read the skill at skill/SKILL.md and its references, then write
     semantic HTML for this task to workspace/iteration-N/output-INDEX.html:
     $(cat evals/eval-cases.json | jq -r '.evals[INDEX].prompt')" \
     --append-system-prompt "Generate semantic HTML following the skill. Write only the HTML file." \
     --max-turns 5
   ```

3. **Score each output**
   For each output, the judge reads the HTML and rubric from disk and writes scores:

   ```bash
   claude -p "Read evals/rubric.md and workspace/iteration-N/output-INDEX.html.
     Score the HTML against this eval case:
     $(cat evals/eval-cases.json | jq '.evals[INDEX]')
     Write scores to workspace/iteration-N/scores-INDEX.json" \
     --append-system-prompt "Score the HTML output following the rubric. Write only the JSON file." \
     --max-turns 5
   ```

4. **Aggregate scores**

   ```bash
   python3 scripts/aggregate.py workspace/iteration-N/
   ```

   This produces `workspace/iteration-N/summary.json` with per-dimension averages
   and identifies the weakest dimensions.

5. **Decide: improve or stop**
   - If composite score >= target (default 2.7/3.0): stop, you're done
   - If iteration count >= max (default 5): stop, report best iteration
   - Otherwise: analyse weaknesses and edit the skill

6. **Improve the skill**
   Read `workspace/iteration-N/summary.json`. Look at:
   - Which dimensions scored lowest across all evals
   - Which specific eval cases scored lowest
   - What patterns emerge (e.g., consistently poor form semantics)

   Then edit `skill/SKILL.md` (and optionally reference files) to address those
   weaknesses. Be targeted — change the sections relevant to the weak dimensions.
   Don't rewrite the whole skill each iteration.

7. **Log the change**

   ```bash
   echo "## Iteration N" >> workspace/changelog.md
   echo "Weakest dimensions: ..." >> workspace/changelog.md
   echo "Changes made: ..." >> workspace/changelog.md
   echo "---" >> workspace/changelog.md
   ```

8. **Go to step 1 for iteration N+1**

## Important Principles

- **Targeted edits over rewrites.** Change what's weak, preserve what works.
- **Explain the why.** When adding guidance to the skill, explain *why* it matters,
  not just what to do. AI agents respond better to reasoning than to rigid rules.
- **Don't overfit.** The evals are a sample. If you add guidance that only helps
  one specific eval case, you're probably overfitting. Look for general principles.
- **Track what you changed.** The changelog helps you understand what worked.
- **Respect the skill's voice.** The existing skill has a clear, thoughtful tone.
  Maintain that. Prefer explaining reasoning over rigid rules — but when something
  is a genuine accessibility or spec boundary, a firm constraint is appropriate.
