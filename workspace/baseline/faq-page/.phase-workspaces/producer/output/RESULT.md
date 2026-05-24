# FAQ Page - Semantic HTML Generation Result

## Task
Generate semantically correct HTML for a FAQ page for the SaaS product "FlowBoard".

## Output File
- `output/index.html` - Complete FAQ page with semantic HTML structure

## Key Implementation Details

### Semantic Structure
1. **Skip Navigation Links** - Placed at the very top as the first focusable elements
   - "Skip to content" link to main FAQ section
   - "Skip to search" link to search input

2. **Landmark Navigation**
   - Site header with logo and primary navigation
   - Breadcrumb navigation using `<nav aria-label="Breadcrumb">` with `<ol>` for ordered list
   - Breadcrumb items properly marked with `aria-current="page"` on current page

3. **Main Content Structure**
   - Single `<h1>` heading for page title: "Frequently Asked Questions"
   - `<main id="main-content">` wraps only the FAQ content
   - Site header and footer are outside the main element

4. **FAQ Sections**
   - Three FAQ categories using `<h2>` headings:
     - Getting Started (4 questions)
     - Billing & Plans (4 questions)
     - Integrations (3 questions)
   - Each section wrapped in `<section>` elements

5. **Expandable Questions**
   - All questions use native HTML `<details>/<summary>` elements for progressive disclosure
   - No custom ARIA disclosure patterns used
   - Each question has a summary and detailed answer

6. **Search/Filter Input**
   - Properly labeled with `<label for="search-input">Search FAQ</label>`
   - Input has both id and aria-label for accessibility

7. **Contact Section**
   - "Still need help?" uses `<h2>` heading
   - Contact support link is a standard `<a>` element
   - Phone number is a semantic `<a href="tel:+1-800-555-0123">` link

8. **Footer**
   - Located outside `<main>` element
   - Contains navigation and copyright information

## Content
- FlowBoard product branding
- 11 realistic FAQ questions with helpful answers covering common user questions
- Professional and context-appropriate answers
- Breadcrumb trail: Home > Support > FAQ

## Compliance with Expectations
All 14 key expectations have been met:
- ✓ Breadcrumb uses `<nav>` with `aria-label`
- ✓ `<main>` wraps only FAQ content
- ✓ Skip links are first focusable elements
- ✓ Breadcrumb items in `<ol>`
- ✓ FAQ categories use `<h2>`
- ✓ Questions use `<details>/<summary>`
- ✓ No `<dl>` markup for questions
- ✓ Native `<details>/<summary>` pattern
- ✓ Search input has labeled `<label>`
- ✓ "Still need help?" uses `<h2>`
- ✓ Contact links are proper `<a>` elements
- ✓ Single `<h1>` on page
- ✓ No heading levels skipped
- ✓ No improper use of `<address>` tag
