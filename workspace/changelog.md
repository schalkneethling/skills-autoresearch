## Iteration 1
Score: 2.89
# Changelog — Iteration 1

## Changes

### Fixed `aria-describedby` bug in "Unique Accessible Names" (SKILL.md)
Option 3 incorrectly used `aria-describedby` to disambiguate repeated buttons. `aria-describedby` adds supplementary description but does not change the accessible name — all buttons remain "Add to cart" in element lists. Fixed to use `aria-labelledby` combining the button's own ID with the product heading ID, and added an explicit warning explaining why `aria-describedby` is insufficient.

### Added section-heading pattern for item listings (SKILL.md + heading-patterns.md)
Agents were jumping directly from the page `<h1>` to item-level headings (e.g., product names at `<h2>`), producing a flat, misleading document outline. Added explicit guidance with a correct/wrong example showing the `h1 → h2 section → h3 items` pattern. Added a corresponding Pattern 5 section to `heading-patterns.md` covering listing pages and multi-section pages.

### Strengthened fieldset/legend for related checkboxes and multi-step forms (SKILL.md)
Two related checkboxes not wrapped in `<fieldset>/<legend>` was a recurring miss. Added a concrete wrong/correct example for a two-checkbox privacy group and a note that even small checkbox groups require fieldset. Also added guidance that multi-step forms must use headings consistently across all steps — either every fieldset has one, or none do.
---
## Iteration 2
Score: 2.88
# Changelog — Iteration 2

## Changes

### SKILL.md

- **ARIA in CSS (element_choice / aria_discipline):** Added new subsection "ARIA Attributes Belong in HTML, Not CSS" explaining that `aria-hidden: true` written as a CSS property has no effect. Clarified that CSS `::before`/`::after` generated content is already excluded from the accessibility tree, so no `aria-hidden` is needed there at all.

- **CSS-only state (aria_discipline):** Added "CSS-Only State Is Invisible to Assistive Technology" principle under Native Over ARIA. Progress indicators, status badges, and toggle states conveyed only via CSS classes are invisible to screen readers; state must also be expressed with `aria-current`, `aria-selected`, visually-hidden text, or another DOM-level mechanism.

- **ARIA reference integrity (aria_discipline):** Added a note after the Hint Text `aria-describedby` example warning that broken ID references fail silently. `aria-describedby="foo-hint"` does nothing if the target element has no `id="foo-hint"` attribute.

- **Double landmark (aria_discipline):** Added a note to the Section Element section warning against nesting a `<section aria-labelledby="x">` and a `<form aria-labelledby="x">` that reference the same ID — screen readers announce the label twice.

- **Checklist (all dimensions):** Added five new warning signs covering: ARIA in CSS, broken ID references, CSS-only state with no SR equivalent, nested landmarks sharing an ID, and plain HTML heading levels without a context comment.

### heading-patterns.md

- **Plain HTML hardcoded headings (heading_hierarchy):** Extended the "Hardcoded Levels" mistake with a plain HTML example showing how to add an HTML comment documenting the assumed nesting context when a heading level is hardcoded. Without this comment the level looks arbitrary and consumers don't know when to change it.

## Why

The three weakest dimensions (heading_hierarchy 2.62, aria_discipline 2.75, element_choice 2.88) shared a common thread: missing guidance on the *consequences* of specific mistakes — ARIA attributes in CSS silently do nothing, ID mismatches silently break associations, CSS classes silently omit state from the accessibility tree. Guidance now explains why these fail rather than just listing what not to do.
---
## Iteration 3
Score: 2.85
# Changelog — Iteration 3

## Changes made to `skill/SKILL.md`

### 1. ARIA Discipline — `<search>` + `<form role="search">` redundancy (aria_discipline, was 2.62)
Added an explicit example showing that `<search>` already exposes the `search` landmark role, making `role="search"` on a nested `<form>` redundant. Included correct vs. incorrect code and a named rule ("The `<search>` element rule") to make the principle memorable.

### 2. Content Realism — realistic placeholder guidance (content_realism, was 2.75)
Added a "Use realistic placeholder content" paragraph warning against generic stand-ins like "Your Company" or "example@test.com". Explains *why* it matters: under-filled placeholders mask real wrapping, overflow, and truncation problems.

### 3. Form Semantics — multi-step form fieldset requirement + submit button rule (form_semantics, was 2.83)
Replaced the brief multi-step forms note with explicit before/after code showing that each step must be `<fieldset>/<legend>`, not `<section>/<h2>`, because the `<legend>` provides per-field context that headings do not. Added a separate constraint: `<button type="submit">` must be inside a `<form>` element; a submit button outside any form is semantically incorrect.

### 4. Heading Hierarchy — tracking context across the full page (heading_hierarchy, was 2.88)
Added a "Track heading context throughout the full page" paragraph before the section-headings guidance. Addresses the root cause (authors assigning levels in isolation) and states the concrete rule: a subsection's heading is always one level deeper than its containing section's heading.
---
## Iteration 4
Score: 2.87
# Changelog — Iteration 4

## Changes

### SKILL.md

**Filter sidebars require a `<form>` wrapper (form_semantics, landmark_structure)**
Added a dedicated section "Filter Sidebars Require a `<form>` Wrapper" with a before/after example. A group of `<fieldset>` elements without a `<form>` parent is not a form landmark and cannot be natively submitted or reset — this was the root cause of the product-listing-page miss.

**`aria-labelledby` over `aria-label` when a visible heading exists (aria_discipline)**
Added a new subsection under "Native Over ARIA" explaining when to prefer `aria-labelledby` over `aria-label`. If a form has an adjacent `<h2>`, referencing it via `aria-labelledby` keeps accessible and visible names in sync. This addresses the multi-step-form minor issue (form with `aria-label="Checkout"` next to an `<h2>Checkout</h2>`).

**Comment author fields added to fieldset/legend list (form_semantics)**
Added "Comment author fields (name, email, message)" to the thematic grouping list, addressing the blog-article-page miss where a comment form omitted `<fieldset>/<legend>`.

**Boolean/status values in table cells (element_choice, aria_discipline)**
Added a "Boolean and Status Values in Table Cells" section under Tables, explaining that icon-only ✓/✗ indicators should be accompanied by visible text ('Yes'/'No'). Addresses the pricing-comparison-table miss.

**Checklist updated**
Added three new warning signs corresponding to the above: filter fieldsets without `<form>`, `aria-label` duplicating a visible heading, and icon-only boolean table values.
---
