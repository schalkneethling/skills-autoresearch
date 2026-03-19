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
