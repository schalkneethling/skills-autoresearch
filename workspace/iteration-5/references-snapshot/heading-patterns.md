# Heading Patterns in Component Systems

Strategies for maintaining proper heading hierarchy in component-based architectures.

## The Challenge

Component-based development creates a tension:

- Components should be reusable across contexts
- Heading levels depend on surrounding document structure
- Content authors may not understand heading hierarchy
- Hardcoded levels break in different contexts

## Pattern 1: Configurable Heading Level

Make heading level a prop/parameter with a sensible default.

```jsx
// React example
function Card({ title, headingLevel = 3, children }) {
  const Heading = `h${headingLevel}`;
  return (
    <article className="card">
      <Heading>{title}</Heading>
      {children}
    </article>
  );
}
```

```twig
{# Twig example #}
{% set heading_tag = heading_level|default(3) %}
<article class="card">
  <h{{ heading_tag }}>{{ title }}</h{{ heading_tag }}>
  {{ content }}
</article>
```

### When to Use

- Generic components used in multiple contexts
- Components where nesting depth varies
- CMS-driven content where authors control usage

### Trade-offs

- Moves responsibility to component consumer
- Authors may not choose correctly
- Sensible default reduces but doesn't eliminate risk

## Pattern 2: Context-Aware Defaults

Set defaults based on known component relationships.

```jsx
// Section always starts a new heading context
function Section({ title, children }) {
  return (
    <section aria-labelledby="section-title">
      <h2 id="section-title">{title}</h2>
      {children}
    </section>
  );
}

// Cards within sections default to h3
function CardList({ cards }) {
  return (
    <ul className="card-list">
      {cards.map((card) => (
        <li key={card.id}>
          <Card title={card.title} headingLevel={3} />
        </li>
      ))}
    </ul>
  );
}
```

### When to Use

- Known parent-child component relationships
- Design systems with predictable nesting patterns
- When you control both container and child components

### Trade-offs

- Less flexible
- Breaks if components are used outside expected context
- Requires documentation of expected usage

## Pattern 3: Heading Component Abstraction

Create a heading component that handles both semantic and visual concerns.

```jsx
function Heading({ level, visualLevel = level, children, className = "" }) {
  const Tag = `h${level}`;
  const visualClass = `u-heading-${visualLevel}`;

  return <Tag className={`${visualClass} ${className}`}>{children}</Tag>;
}

// Usage: semantic h3, visual appearance of h2
<Heading level={3} visualLevel={2}>
  Section Title
</Heading>;
```

### When to Use

- Design requires visual hierarchy different from semantic
- Large headings needed at deep nesting levels
- Consistent visual treatment across varying semantic levels

### Benefits

- Separates concerns clearly
- Documents the distinction explicitly
- Enables correct semantics without design compromise

## Pattern 4: Inherited Configuration

Generic components inherit heading config when specialised.

```jsx
// Generic card
function Card({ title, headingLevel = 3, headingClass, children }) {
  const Heading = `h${headingLevel}`;
  return (
    <article className="card">
      <Heading className={headingClass}>{title}</Heading>
      {children}
    </article>
  );
}

// Specialised product card - knows its context
function ProductCard({ product, headingLevel = 3 }) {
  return (
    <Card
      title={product.name}
      headingLevel={headingLevel}
      headingClass="product-card__title"
    >
      <p className="product-card__price">{product.price}</p>
      <p className="product-card__description">{product.description}</p>
    </Card>
  );
}

// Page section - sets context for children
function FeaturedProducts({ products }) {
  return (
    <section aria-labelledby="featured-heading">
      <h2 id="featured-heading">Featured Products</h2>
      <ul className="product-grid">
        {products.map((product) => (
          <li key={product.id}>
            <ProductCard product={product} headingLevel={3} />
          </li>
        ))}
      </ul>
    </section>
  );
}
```

### When to Use

- Design systems with component inheritance
- When generic components are always wrapped by specific ones
- Clear ownership of heading level decision

## Visual-Only Headings

When text should look like a heading but not affect document outline:

```html
<!-- Looks like a heading, but isn't one semantically -->
<p class="u-heading-xl">Sale ends tomorrow!</p>

<!-- Compare to actual heading -->
<h2 class="u-heading-xl">Product Categories</h2>
```

### When to Use

- Promotional text that looks prominent but isn't structural
- Decorative typography
- Labels that don't introduce content sections

### CSS Utility Classes

```css
/* Size-based utilities separate from semantic level */
.u-heading-xs {
  font-size: var(--font-size-xs);
}
.u-heading-s {
  font-size: var(--font-size-s);
}
.u-heading-m {
  font-size: var(--font-size-m);
}
.u-heading-l {
  font-size: var(--font-size-l);
}
.u-heading-xl {
  font-size: var(--font-size-xl);
}

/* All share heading-like properties */
.u-heading-xs,
.u-heading-s,
.u-heading-m,
.u-heading-l,
.u-heading-xl {
  font-weight: var(--font-weight-bold);
  line-height: var(--line-height-tight);
}
```

## Checklist for Component Headings

When building a component with a heading:

- [ ] Is the heading level configurable?
- [ ] Is there a sensible default?
- [ ] Is the default documented?
- [ ] Can visual appearance be controlled independently?
- [ ] Does the component work at all reasonable heading levels?
- [ ] Is the expected context documented?

## Pattern 5: Section Headings for Item Listings

When a page lists items (products, articles, results), always place a section `<h2>` between the page `<h1>` and the item-level headings. This prevents individual item names from appearing as top-level sections in the document outline.

```
h1: "Running Shoes"          ← page title
  h2: "24 results"           ← section heading (can be visually subtle)
    h3: "Nike Pegasus 41"    ← item heading
    h3: "Adidas Ultraboost"  ← item heading
```

The section heading doesn't need to be visually prominent—it can be small, styled as a count or category label—but it must exist semantically. This matters because screen reader users often navigate by heading list; without the intermediate `<h2>`, all product names appear at the same level as major page sections.

### When there are multiple sections on the same page

```
h1: "Shop"
  h2: "Featured Products"
    h3: "Nike Pegasus 41"
  h2: "New Arrivals"
    h3: "Adidas Ultraboost"
  h2: "On Sale"
    h3: "Brooks Ghost 16"
```

Each section gets its own `<h2>`; items under it get `<h3>`. The rule is simple: the item heading level is always one deeper than its containing section heading.

### In content pages with multiple named sections

The same principle applies to articles, blog posts, and settings pages:

```
h1: "Account Settings"
  h2: "Profile"          ← fieldset legend or section heading
  h2: "Notifications"
  h2: "Privacy"
    ← no h3 needed unless sections contain sub-sections
```

## Common Mistakes

### Hardcoded Levels

```jsx
// Fragile: breaks when used outside expected context
function Card({ title }) {
  return (
    <article>
      <h3>{title}</h3> {/* What if this is used at h2 level? */}
    </article>
  );
}
```

**In plain HTML**, heading levels are always hardcoded — there is no prop system. When writing plain HTML with a specific heading level, add a comment documenting the assumed context so the next developer knows when to change it:

```html
<!-- h3 assumes this card is inside a section with an h2 heading.
     If reusing this markup at the top level, change to h2. -->
<article class="product-card">
  <h3 class="product-card__title">Nike Air Zoom Pegasus 41</h3>
  ...
</article>
```

Without this comment, the heading level looks like an arbitrary choice. The comment communicates intent and warns consumers about context dependency.

### Level Chosen for Appearance

```html
<!-- Wrong: h4 chosen because it's smaller -->
<h4 class="card-title">Product Name</h4>

<!-- Right: appropriate level with visual override -->
<h3 class="card-title u-heading-s">Product Name</h3>
```

### Missing Defaults

```jsx
// Dangerous: undefined heading level
function Card({ title, headingLevel }) {
  const Heading = `h${headingLevel}`; // h undefined if not passed
  return <Heading>{title}</Heading>;
}

// Safe: always has a valid level
function Card({ title, headingLevel = 3 }) {
  const Heading = `h${headingLevel}`;
  return <Heading>{title}</Heading>;
}
```
