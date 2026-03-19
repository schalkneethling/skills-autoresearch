#!/usr/bin/env bash
# =============================================================================
# Semantic HTML Skill — Auto-Improvement Loop
# =============================================================================
#
# This script orchestrates the eval → judge → aggregate → improve cycle.
# Run it from the project root (semantic-html-autoloop/).
#
# Configuration is read from config.json in the project root:
#   {
#     "skill_source": "~/projects/webdev-agent-skills/semantic-html",
#     "max_iterations": 5,
#     "target_score": 2.7
#   }
#
# Prerequisites:
#   - Claude Code CLI (`claude`) installed and authenticated
#   - Python 3 available
#   - config.json with skill_source pointing to your skill directory
#
# Usage:
#   bash scripts/run-loop.sh
#
# =============================================================================

set -euo pipefail

CONFIG_FILE="config.json"
EVALS_FILE="evals/eval-cases.json"
RUBRIC_FILE="evals/rubric.md"
JUDGE_PROMPT="scripts/judge-prompt.md"
SKILL_DIR="skill"
WORKSPACE="workspace"

# All claude -p calls run non-interactively, so they need permission to
# read/write files without prompting. This flag is required because there
# is no TTY to approve tool use.
CLAUDE_FLAGS="--dangerously-skip-permissions"

# ---- Read config ----
if [ ! -f "${CONFIG_FILE}" ]; then
    echo "Error: ${CONFIG_FILE} not found."
    echo ""
    echo "Create a config.json in the project root with at minimum:"
    echo '  { "skill_source": "/path/to/your/semantic-html" }'
    exit 1
fi

SKILL_SOURCE=$(python3 -c "
import json, os
config = json.load(open('${CONFIG_FILE}'))
source = config.get('skill_source', '')
if not source:
    print('')
else:
    print(os.path.expanduser(source))
")

MAX_ITERATIONS=$(python3 -c "
import json
config = json.load(open('${CONFIG_FILE}'))
print(config.get('max_iterations', 5))
")

TARGET_SCORE=$(python3 -c "
import json
config = json.load(open('${CONFIG_FILE}'))
print(config.get('target_score', 2.7))
")

if [ -z "${SKILL_SOURCE}" ]; then
    echo "Error: 'skill_source' is missing from ${CONFIG_FILE}."
    echo ""
    echo "Set it to the path of the skill directory you want to improve, e.g.:"
    echo '  { "skill_source": "~/projects/webdev-agent-skills/semantic-html" }'
    exit 1
fi

if [ ! -d "${SKILL_SOURCE}" ]; then
    echo "Error: skill_source directory not found: ${SKILL_SOURCE}"
    echo "Check the path in ${CONFIG_FILE}."
    exit 1
fi

if [ ! -f "${SKILL_SOURCE}/SKILL.md" ]; then
    echo "Error: No SKILL.md found in ${SKILL_SOURCE}"
    echo "Are you pointing to the right directory?"
    exit 1
fi

# ---- Copy skill into working directory ----
echo "Copying skill from ${SKILL_SOURCE} into ${SKILL_DIR}/..."
rm -rf "${SKILL_DIR}"
cp -r "${SKILL_SOURCE}" "${SKILL_DIR}"
echo "  ✓ Skill copied"
echo ""

echo "=============================================="
echo "  Semantic HTML Skill Auto-Improvement Loop"
echo "=============================================="
echo "  Source:         ${SKILL_SOURCE}"
echo "  Max iterations: ${MAX_ITERATIONS}"
echo "  Target score:   ${TARGET_SCORE}"
echo "  Evals:          ${EVALS_FILE}"
echo "=============================================="
echo ""

# Validate prerequisites
if ! command -v claude &> /dev/null; then
    echo "Error: 'claude' CLI not found. Install Claude Code first."
    exit 1
fi

if ! command -v python3 &> /dev/null; then
    echo "Error: python3 not found."
    exit 1
fi

if [ ! -f "${EVALS_FILE}" ]; then
    echo "Error: ${EVALS_FILE} not found."
    exit 1
fi

NUM_EVALS=$(python3 -c "import json; print(len(json.load(open('${EVALS_FILE}'))['evals']))")
echo "Found ${NUM_EVALS} eval cases."
echo ""

# ---- Helper: compare floats ----
score_meets_target() {
    python3 -c "import sys; sys.exit(0 if float('$1') >= float('$2') else 1)"
}

# ---- Main loop ----
BEST_SCORE="0"
BEST_ITERATION="0"

for ITER in $(seq 1 "${MAX_ITERATIONS}"); do
    ITER_DIR="${WORKSPACE}/iteration-${ITER}"
    mkdir -p "${ITER_DIR}"

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  ITERATION ${ITER} / ${MAX_ITERATIONS}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Step 1: Snapshot the current skill
    cp "${SKILL_DIR}/SKILL.md" "${ITER_DIR}/skill-snapshot.md"
    if [ -d "${SKILL_DIR}/references" ]; then
        cp -r "${SKILL_DIR}/references" "${ITER_DIR}/references-snapshot/"
    fi
    echo "  ✓ Skill snapshot saved"

    # Step 2: Run each eval case
    for EVAL_IDX in $(seq 0 $((NUM_EVALS - 1))); do
        EVAL_NAME=$(python3 -c "import json; print(json.load(open('${EVALS_FILE}'))['evals'][${EVAL_IDX}]['name'])")
        EVAL_PROMPT=$(python3 -c "
import json
data = json.load(open('${EVALS_FILE}'))
print(data['evals'][${EVAL_IDX}]['prompt'])
")

        echo "  Running eval ${EVAL_IDX}: ${EVAL_NAME}..."

        OUTPUT_FILE="${ITER_DIR}/output-${EVAL_IDX}.html"

        # Build the skill context as a file the agent can reference
        SKILL_CONTEXT_FILE="${ITER_DIR}/.skill-context-${EVAL_IDX}.md"
        cat "${SKILL_DIR}/SKILL.md" > "${SKILL_CONTEXT_FILE}"
        if [ -d "${SKILL_DIR}/references" ]; then
            for ref_file in "${SKILL_DIR}"/references/*.md; do
                if [ -f "${ref_file}" ]; then
                    echo "" >> "${SKILL_CONTEXT_FILE}"
                    echo "--- Reference: $(basename "${ref_file}") ---" >> "${SKILL_CONTEXT_FILE}"
                    cat "${ref_file}" >> "${SKILL_CONTEXT_FILE}"
                fi
            done
        fi

        # Using --append-system-prompt to keep Claude Code's built-in file I/O
        # capabilities while adding the skill guidance. The agent reads the skill
        # context file and writes the HTML output file directly.
        claude -p "You are a frontend developer writing semantic HTML.

Read the skill guidance at ${SKILL_CONTEXT_FILE} and follow it precisely.

Then complete this task and write ONLY the HTML markup to ${OUTPUT_FILE}.
No explanations, no markdown — just write the HTML file.

Task: ${EVAL_PROMPT}" \
            ${CLAUDE_FLAGS} \
            --append-system-prompt "You are generating semantic HTML for an eval. Read the skill file, then write the HTML output to the specified path. Do not explain your work." \
            --max-turns 5 \
            > /dev/null 2>&1 || {
            echo "  ⚠ Eval ${EVAL_IDX} failed, writing empty output"
            echo "<!-- Generation failed -->" > "${OUTPUT_FILE}"
        }

        # Clean up the temporary context file
        rm -f "${SKILL_CONTEXT_FILE}"

        if [ -f "${OUTPUT_FILE}" ]; then
            echo "    ✓ Output saved"
        else
            echo "    ⚠ No output file produced"
            echo "<!-- No output produced -->" > "${OUTPUT_FILE}"
        fi
    done

    # Step 3: Score each output with the judge
    echo "  Scoring outputs..."
    for EVAL_IDX in $(seq 0 $((NUM_EVALS - 1))); do
        OUTPUT_FILE="${ITER_DIR}/output-${EVAL_IDX}.html"
        SCORES_FILE="${ITER_DIR}/scores-${EVAL_IDX}.json"

        EVAL_CASE=$(python3 -c "
import json
data = json.load(open('${EVALS_FILE}'))
print(json.dumps(data['evals'][${EVAL_IDX}], indent=2))
")

        # The judge reads the HTML output and rubric from disk and writes
        # its scoring JSON to disk — no shell argument size limits to worry about.
        claude -p "You are a strict but fair judge evaluating HTML output for semantic correctness, accessibility, and adherence to web standards.

Read the scoring rubric at ${RUBRIC_FILE}.
Read the HTML output to evaluate at ${OUTPUT_FILE}.

Here is the eval case with the prompt, focus dimensions, and key expectations:

${EVAL_CASE}

Score the HTML output following the rubric precisely. Write your scores as a JSON object to ${SCORES_FILE}.
Respond ONLY by writing the JSON file — no other output." \
            ${CLAUDE_FLAGS} \
            --append-system-prompt "You are scoring HTML output for a semantic HTML eval. Read the rubric and HTML files, then write the JSON scores to the specified path. No commentary." \
            --max-turns 5 \
            > /dev/null 2>&1 || {
            echo "  ⚠ Scoring eval ${EVAL_IDX} failed"
            echo '{"eval_id": '${EVAL_IDX}', "composite_score": 0, "scores": {}, "expectations_met": [], "expectations_missed": ["scoring failed"]}' \
                > "${SCORES_FILE}"
        }

        if [ ! -f "${SCORES_FILE}" ]; then
            echo "  ⚠ No scores file produced for eval ${EVAL_IDX}"
            echo '{"eval_id": '${EVAL_IDX}', "composite_score": 0, "scores": {}, "expectations_met": [], "expectations_missed": ["scoring failed"]}' \
                > "${SCORES_FILE}"
        fi
    done
    echo "  ✓ All outputs scored"

    # Step 4: Aggregate
    python3 scripts/aggregate.py "${ITER_DIR}"
    COMPOSITE=$(python3 -c "import json; print(json.load(open('${ITER_DIR}/summary.json'))['overall_composite'])")

    echo ""
    echo "  Composite score: ${COMPOSITE} / 3.00 (target: ${TARGET_SCORE})"

    # Track best
    if python3 -c "import sys; sys.exit(0 if float('${COMPOSITE}') > float('${BEST_SCORE}') else 1)"; then
        BEST_SCORE="${COMPOSITE}"
        BEST_ITERATION="${ITER}"
    fi

    # Step 5: Check if we've met the target
    if score_meets_target "${COMPOSITE}" "${TARGET_SCORE}"; then
        echo ""
        echo "  ✅ TARGET REACHED! Score ${COMPOSITE} >= ${TARGET_SCORE}"
        echo ""
        break
    fi

    # Step 6: If not the last iteration, improve the skill
    if [ "${ITER}" -lt "${MAX_ITERATIONS}" ]; then
        echo ""
        echo "  Score below target. Improving skill..."

        SUMMARY=$(cat "${ITER_DIR}/summary.json")

        # Build a listing of reference files for the agent to know about
        REF_LISTING=""
        if [ -d "${SKILL_DIR}/references" ]; then
            for ref_file in "${SKILL_DIR}"/references/*.md; do
                if [ -f "${ref_file}" ]; then
                    REF_LISTING="${REF_LISTING}  - ${SKILL_DIR}/references/$(basename "${ref_file}")
"
                fi
            done
        fi

        IMPROVE_PROMPT="You are improving a semantic HTML skill for AI coding agents.

## Current Iteration Results

${SUMMARY}

## Skill File Structure

The skill consists of separate files that must remain separate:
- ${SKILL_DIR}/SKILL.md — The main skill file
${REF_LISTING}
Read each of these files before making changes. Do NOT merge reference files into SKILL.md.
The SKILL.md references these files via its 'References' section, and agents load them separately.

## Your Task

Based on the iteration results, identify the weakest areas and improve the skill.

Rules:
1. Make TARGETED edits. Don't rewrite the entire skill.
2. Focus on the weakest dimensions and missed expectations.
3. Explain WHY guidance matters, not just WHAT to do.
4. Preserve the skill's existing tone and structure.
5. Prefer explaining reasoning over rigid rules, but use firm constraints for genuine accessibility or spec boundaries.
6. Don't overfit to specific eval cases. Look for general principles.
7. Keep the file structure intact — SKILL.md and each reference file remain separate files.

Steps:
1. Read ${SKILL_DIR}/SKILL.md and all files in ${SKILL_DIR}/references/
2. Decide what to change based on the weakest dimensions and missed expectations
3. Write your changes directly to the files on disk
4. After writing, create a brief changelog entry at ${WORKSPACE}/changelog-iteration-${ITER}.md
   describing what you changed and why (2-5 lines)"

        claude -p "${IMPROVE_PROMPT}" \
            ${CLAUDE_FLAGS} \
            --append-system-prompt "You are improving a skill by editing files on disk. Read the existing files, make targeted edits, and write them back. Do NOT combine separate files into one. Write a changelog entry when done." \
            --max-turns 15 \
            > /dev/null 2>&1 || {
            echo "  ⚠ Improvement step failed"
        }

        # Capture the changelog if the agent wrote one
        if [ -f "${WORKSPACE}/changelog-iteration-${ITER}.md" ]; then
            echo "## Iteration ${ITER}" >> "${WORKSPACE}/changelog.md"
            echo "Score: ${COMPOSITE}" >> "${WORKSPACE}/changelog.md"
            cat "${WORKSPACE}/changelog-iteration-${ITER}.md" >> "${WORKSPACE}/changelog.md"
            echo "---" >> "${WORKSPACE}/changelog.md"
            echo "  ✓ Skill updated (see changelog)"
        else
            echo "  ✓ Skill updated (no changelog written)"
        fi
    fi

    echo ""
done

# ---- Final report ----
echo "=============================================="
echo "  AUTO-IMPROVEMENT COMPLETE"
echo "=============================================="
echo "  Best score:     ${BEST_SCORE} (iteration ${BEST_ITERATION})"
echo "  Target:         ${TARGET_SCORE}"
echo "  Best skill at:  workspace/iteration-${BEST_ITERATION}/skill-snapshot.md"
echo ""

if [ -f "${WORKSPACE}/changelog.md" ]; then
    echo "  Changelog:"
    cat "${WORKSPACE}/changelog.md"
fi

echo ""
echo "  To use the best version:"
echo "    cp workspace/iteration-${BEST_ITERATION}/skill-snapshot.md ${SKILL_DIR}/SKILL.md"
echo ""
