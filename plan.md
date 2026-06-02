# Framework Extraction Plan

## Immediate Hackernews Cleanup

Use Charming's existing `Screen#narrow?` helper instead of duplicating breakpoint logic.

Files:

- `app/views/layouts/application_layout.rb`
- `app/components/app_frame_component.rb`

Change:

- Replace `screen.width < 72 && screen.height >= 20`
- With `screen.narrow?(below: 72, min_height: 20)`

## Framework Extraction Candidates

### 1. Pane Dimension Access

Hackernews still guesses content dimensions with screen-wide constants like `screen.width - 42` and `screen.height - 12`.

Proposed Charming API:

- Allow layout pane blocks to receive the pane rect.
- Example: `pane(:content) { |rect| render_body(width: rect.width, height: rect.height) }`

Benefit:

- Apps can render content based on actual pane dimensions instead of duplicating layout math.

### 2. Sidebar Navigation Component

Hackernews repeats sidebar rendering logic that also exists in generated Charming layouts.

Proposed Charming component:

- `Charming::Presentation::Components::SidebarNavigation`

It should support:

- Routes
- Active route marker
- Cursor marker
- Focused/unfocused styling
- Optional route de-duping

### 3. Command Palette Modal Helper

Generated apps and Hackernews both wrap command palettes in the same modal boilerplate.

Proposed API:

- `command_palette_modal`
- Or `Charming::Presentation::Components::CommandPaletteModal`

Benefit:

- Removes repeated modal title/help/width/theme wiring.

### 4. Activity Indicator Label Fitting

Hackernews manually switches long loading labels to `"Working"` based on content width.

Proposed `ActivityIndicator` options:

- `max_width:`
- `fallback_label:`

Benefit:

- Keeps loading indicators stable in constrained layouts.

### 5. Multi-Line Selectable List

`StoryListComponent` manually implements viewport windowing for multi-line rows.

Potential Charming component:

- `BlockList`
- Or extend `List` to support multi-line item renderers.

Benefit:

- Apps with feed cards, search results, or logs can reuse selected-window behavior.

## Should Stay App-Specific

These should not move into Charming:

- Hacker News feed names and commands.
- Story title/domain/points/comment formatting.
- Article extraction behavior.
- Hacker News pagination footer wording.

## Recommended Order

1. Clean up Hackernews duplicate `narrow?` logic.
2. Add pane dimension access to Charming.
3. Extract sidebar navigation rendering.
4. Add command palette modal helper.
5. Consider a multi-line list component after another app needs it.
