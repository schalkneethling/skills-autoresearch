# Settings Form with Grouped Controls - Output

## Task Summary
Generated semantic HTML for an account settings page with properly grouped form controls.

## File Generated
- `output/index.html` - The complete HTML form

## Key Features Implemented

### Form Structure
- Main `<form>` element wrapping all content
- Four main sections implemented as `<fieldset>` elements with `<legend>` headings

### Profile Section
- Display Name: text input with associated label
- Bio: textarea with associated label
- Avatar Upload: file input with associated label

### Notifications Section
- Email Notifications: checkbox toggle with label
- Push Notifications: checkbox toggle with label
- Notification Frequency: nested fieldset with radio button group (Instant/Daily Digest/Weekly Digest)
  - All radio buttons share the same `name` attribute (`notification_frequency`)
  - Each option has a unique ID and associated label

### Privacy Section
- Profile Visibility: nested fieldset with radio button group (Public/Friends Only/Private)
  - All radio buttons share the same `name` attribute (`profile_visibility`)
  - Each option has a unique ID and associated label
- Show Online Status: checkbox with label
- Allow Search Engines to Index Profile: checkbox with label

### Danger Zone Section
- Clearly marked as a dangerous operation area
- Delete Account button: `<button type="button">` (not a link)
- Explanatory text about permanent deletion

### Action Buttons
- Save Changes: `<button type="submit">` for form submission
- Delete Account: `<button type="button">` for secondary action

## Semantic HTML Compliance

✓ Each settings section uses `<fieldset>` with `<legend>`
✓ All inputs have associated `<label>` elements
✓ Radio button groups are within a `<fieldset>` with a `<legend>`
✓ Toggle switches use checkbox inputs (not custom div patterns)
✓ File upload uses `<input type="file">` with a label
✓ Textarea has a label
✓ Delete Account is a `<button>` (not a link)
✓ Save Changes is a `<button type="submit">`
✓ Section headings use consistent heading levels (legend as heading)
✓ Legends serve as visual headings (no redundant `<h2>` elements)
✓ No placeholder-only inputs (all inputs have labels)
✓ Radio buttons have matching name attributes within their group
✓ The form as a whole is a `<form>` element