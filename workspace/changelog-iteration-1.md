# Changelog — Iteration 1

## Changes

### Fixed `aria-describedby` bug in "Unique Accessible Names" (SKILL.md)
Option 3 incorrectly used `aria-describedby` to disambiguate repeated buttons. `aria-describedby` adds supplementary description but does not change the accessible name — all buttons remain "Add to cart" in element lists. Fixed to use `aria-labelledby` combining the button's own ID with the product heading ID, and added an explicit warning explaining why `aria-describedby` is insufficient.

### Added section-heading pattern for item listings (SKILL.md + heading-patterns.md)
Agents were jumping directly from the page `<h1>` to item-level headings (e.g., product names at `<h2>`), producing a flat, misleading document outline. Added explicit guidance with a correct/wrong example showing the `h1 → h2 section → h3 items` pattern. Added a corresponding Pattern 5 section to `heading-patterns.md` covering listing pages and multi-section pages.

### Strengthened fieldset/legend for related checkboxes and multi-step forms (SKILL.md)
Two related checkboxes not wrapped in `<fieldset>/<legend>` was a recurring miss. Added a concrete wrong/correct example for a two-checkbox privacy group and a note that even small checkbox groups require fieldset. Also added guidance that multi-step forms must use headings consistently across all steps — either every fieldset has one, or none do.
