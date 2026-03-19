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
