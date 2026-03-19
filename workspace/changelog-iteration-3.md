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
