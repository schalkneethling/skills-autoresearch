# Scoring Rubric — Semantic HTML Skill Evaluation

You are judging the quality of HTML output produced by an AI coding agent that was
guided by a semantic HTML skill. Score each applicable dimension on a 0–3 scale.

## Scoring Scale

- **3 — Excellent.** Consistently correct, demonstrates deep understanding, no issues.
- **2 — Good.** Mostly correct with minor issues that don't harm usability or accessibility.
- **1 — Weak.** Meaningful problems that would affect users or assistive technology.
- **0 — Poor.** Fundamental misunderstanding or missing entirely.

## Dimensions

### element_choice (0–3)

Does the output use the right HTML element for each piece of content?

| Score | Criteria |
|-------|----------|
| 3 | Every element is the best semantic match. Buttons are `<button>`, links are `<a>`, time values use `<time>`, code uses `<pre><code>`, etc. No `<div>` or `<span>` used where a semantic element exists. |
| 2 | Almost all elements are correct. One or two minor mismatches (e.g., a `<div>` where a `<p>` would be better) but no critical errors. |
| 1 | Several wrong element choices. Generic elements used where semantic ones exist. Interactive elements built from `<div>` + click handlers. |
| 0 | Pervasive div/span soup. No evidence of semantic element selection. |

Key things to check:
- Are interactive elements (`<button>`, `<a>`, `<input>`, `<select>`) native?
- Is `<time>` used for dates with a `datetime` attribute?
- Is `<address>` used correctly (only for contact info about the author/owner)?
- Are `<blockquote>`, `<cite>`, `<code>`, `<pre>` used when appropriate?
- Is `<article>` used for self-contained content that could be syndicated?

### aria_discipline (0–3)

Is ARIA used sparingly and only when native HTML doesn't suffice?

| Score | Criteria |
|-------|----------|
| 3 | ARIA used only where native HTML cannot provide the semantics. No redundant ARIA (e.g., `role="button"` on a `<button>`). Labels provided where required (nav, form landmarks). |
| 2 | Mostly disciplined. One or two redundant ARIA attributes, or a missed label on a landmark. |
| 1 | ARIA overuse — multiple attributes that duplicate native semantics, or ARIA used to patch what native elements would have provided. |
| 0 | Heavy ARIA usage compensating for non-semantic markup. `role`, `aria-*` attributes everywhere instead of using proper elements. |

Key things to check:
- No `role="button"` on `<button>`, `role="link"` on `<a>`, `role="navigation"` on `<nav>`
- `<nav>` elements have `aria-label` or `aria-labelledby` (required)
- `<section>` elements have `aria-labelledby` when used as landmarks
- `aria-label` is not used on elements where a visible text label (via `<label>`) would work
- No `aria-hidden="true"` on focusable elements

### heading_hierarchy (0–3)

Is the heading structure logical and well-organised?

| Score | Criteria |
|-------|----------|
| 3 | Single h1, no skipped levels, heading levels reflect document structure not visual size, component headings are configurable or appropriate level is documented. |
| 2 | Correct hierarchy with minor issues — e.g., heading level is correct but hardcoded in a reusable component without noting it should be configurable. |
| 1 | Skipped levels (h1 → h3), multiple h1 elements, or headings chosen for visual size. |
| 0 | No heading structure, or headings used decoratively with no logical hierarchy. |

Key things to check:
- Exactly one `<h1>` per page
- No skipped levels (h1 → h2 → h3, not h1 → h3)
- Headings reflect document outline, not visual prominence
- Non-heading text that looks prominent is styled with CSS classes, not heading tags
- Prices, badges, and status text are NOT headings

### landmark_structure (0–3)

Are HTML landmark elements used to convey page structure?

| Score | Criteria |
|-------|----------|
| 3 | Appropriate landmarks used: `<header>`, `<nav>`, `<main>`, `<footer>`, `<aside>`, `<search>`, `<article>`, `<section>` (with label). Not overused — only where they aid navigation. All navigations and form landmarks are labelled. `<main>` used correctly. Skip navigation links present and appropriate to the page's complexity. |
| 2 | Most landmarks correct. Minor issue like a missing label on a nav, a `<section>` used without a label, or skip links present but incomplete for the page's complexity. `<main>` usage correct. |
| 1 | Key landmarks missing (e.g., no `<main>`, no `<nav>`), or landmarks overused (every div replaced with section). No skip navigation. |
| 0 | No landmark elements. Flat div structure. |

Key things to check:
- **`<main>` used correctly**: exactly one per page, contains only the primary content of the page, does not wrap the site header, footer, or primary navigation. Content inside `<main>` should be unique to the page — repeated site-wide elements (logo, site nav, footer) belong outside it.
- **Skip navigation links**: one or more skip links appear at the top of the page as the first focusable elements, allowing keyboard and screen reader users to bypass repeated blocks. The links may be visually hidden until focused. Which targets to include depends on the page's complexity — common targets include:
  - "Skip to content" → links to `<main>` (should always be present)
  - "Skip to search" → links to the search input or `<search>` element (when search is prominent)
  - "Skip to navigation" → links to the primary `<nav>` (when navigation is not at the top, e.g., sidebar layouts)
  - A simple page with top nav might only need "Skip to content". A dashboard with a sidebar nav and a search bar might warrant all three.
- `<nav>` used for navigation sections, each labelled
- `<header>` and `<footer>` used for page/section headers and footers
- `<search>` used for search functionality
- `<aside>` used for tangentially related content
- `<section>` has `aria-labelledby` when used (otherwise it's just a div)
- Landmarks are not overused (not every grouping needs to be a landmark)

### form_semantics (0–3)

Are forms properly structured with labels, grouping, and error handling?

| Score | Criteria |
|-------|----------|
| 3 | All inputs have `<label>` elements. Related fields grouped with `<fieldset>`/`<legend>`. Error messages use `aria-invalid` + `aria-describedby`. Appropriate input types used. No placeholder-only fields. |
| 2 | Labels and grouping mostly correct. Minor gap like a missing fieldset for a radio group, or error pattern slightly off. |
| 1 | Missing labels on multiple fields, no fieldset grouping, or errors handled without accessible markup. |
| 0 | Inputs without labels, no grouping, placeholder-as-label pattern, no error handling. |

Key things to check:
- Every `<input>`, `<select>`, `<textarea>` has a `<label>` (visible or visually hidden)
- `<fieldset>` and `<legend>` used for thematic groups (address, payment, radio buttons)
- Error messages are associated via `aria-describedby`, fields marked with `aria-invalid`
- Error messages are actionable (state the problem AND how to fix it)
- Appropriate `type` attributes: `email`, `tel`, `url`, `number`, etc.
- Appropriate `autocomplete` attributes where relevant
- No placeholder text substituting for labels
- Required fields indicated accessibly (not just with colour)

### content_realism (0–3)

Does the output account for real-world content variability?

| Score | Criteria |
|-------|----------|
| 3 | Realistic content (real names, varied lengths, plausible data). Structure handles edge cases (long text, missing images, varying counts). No "Product 1, Product 2" or "Lorem ipsum". |
| 2 | Mostly realistic with minor placeholders. Structure appears to handle variability. |
| 1 | Generic placeholder content. No consideration for content variability. |
| 0 | Entirely placeholder content ("Item 1", "Lorem ipsum"). |

### list_semantics (0–3)

Are lists used appropriately for collections where count matters?

| Score | Criteria |
|-------|----------|
| 3 | Lists used where knowing the count aids the user (nav items, search results, product cards). Correct list type chosen (ul, ol, dl, menu). Items not in lists where count is irrelevant. |
| 2 | Lists mostly correct. Minor issue like using `<ul>` where `<ol>` would be better (e.g., breadcrumbs). |
| 1 | Lists missing where they'd help (cards as raw divs), or wrong list types used. |
| 0 | No lists used, or lists used purely for styling (CSS resets aside). |

Key things to check:
- Navigation items in `<ul>` within `<nav>`
- Breadcrumbs in `<ol>` (order matters)
- Card collections in `<ul>` or `<ol>`
- `<dl>` used for key-value pairs, glossaries, metadata
- `<ol>` used for sequential/ranked content with `reversed`/`start` where appropriate
- Lists NOT used where count is irrelevant to the user

### table_semantics (0–3)

Are tables used correctly for two-dimensional data?

| Score | Criteria |
|-------|----------|
| 3 | `<table>` used only for tabular data. Full structure: `<caption>`, `<thead>`, `<tbody>`, `<th scope>`. Not used for layout. Responsive considerations mentioned or handled. |
| 2 | Correct usage with minor omission (e.g., missing `<caption>` or `<tfoot>`). |
| 1 | Table used but missing key semantics (no `<th>`, no scope, no caption). |
| 0 | Table used for layout, or tabular data presented without table markup. |

Key things to check:
- `<caption>` describes the table's purpose
- `<thead>`, `<tbody>` (and `<tfoot>` if applicable) used for grouping
- `<th>` with `scope="col"` or `scope="row"` for header cells
- Table not used for layout purposes
- Data that belongs in a table IS in a table (not a grid of divs)

## Scoring Process

1. Read the eval case prompt and key expectations
2. Read the HTML output
3. For each dimension listed in the eval's `focus_dimensions`, score 0–3
4. For dimensions NOT listed in `focus_dimensions`, score only if relevant content exists
5. Write a brief justification for each score (1-2 sentences)
6. Note any issues not covered by the dimensions
7. Calculate the composite score (average of all scored dimensions)

## Output Format

Return a JSON object:

```json
{
  "eval_id": 1,
  "eval_name": "product-listing-page",
  "scores": {
    "element_choice": { "score": 3, "justification": "..." },
    "aria_discipline": { "score": 2, "justification": "..." },
    "heading_hierarchy": { "score": 3, "justification": "..." },
    "landmark_structure": { "score": 3, "justification": "..." },
    "form_semantics": { "score": 2, "justification": "..." },
    "content_realism": { "score": 3, "justification": "..." },
    "list_semantics": { "score": 3, "justification": "..." },
    "table_semantics": null
  },
  "composite_score": 2.71,
  "expectations_met": [
    "Uses <header>, <nav>, <main>, <aside>, <footer> landmarks appropriately",
    "Product cards use <article>"
  ],
  "expectations_missed": [
    "Product card heading level is not hardcoded — component does not mention configurability"
  ],
  "additional_observations": [
    "Good use of <search> element for the search bar"
  ]
}
```

Dimensions with a `null` score are excluded from the composite average.
