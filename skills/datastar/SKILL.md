---
name: datastar
description: Build reactive hypermedia-driven web apps using Datastar. Covers signals, data-* attributes, SSE backend events, expressions, actions, and patterns like CQRS, click-to-edit, active search, infinite scroll, and bulk update. Use when working with Datastar framework, data-* attributes, SSE patch events, or backend-driven HTML apps.
---

# Datastar

Hypermedia framework. Backend drives frontend via SSE. Frontend reactivity via `data-*` attributes and signals. Single CDN include, no npm required.

**CSP note**: Datastar uses `Function()` constructors, requiring `unsafe-eval` in Content Security Policy.

## Quick Start

```html
<script type="module" src="https://cdn.jsdelivr.net/gh/starfederation/datastar@v1.0.2/bundles/datastar.js"></script>
```

Core pattern: `data-*` attributes on HTML elements, `$signalName` for reactive state, `@action()` for backend calls.

```html
<input data-bind:query />
<button data-on:click="@get('/search')">Search</button>
<div id="results"></div>
```

## Core Concepts

### Signals (`$`)

Reactive variables. Auto-track changes. `$` prefix required.

- **Create**: `data-signals:foo="'hello'"` or `data-bind:foo` (from input)
- **Read**: `$foo` in any expression
- **Set**: `$foo = 'new'` in any `data-on` handler
- **Computed**: `data-computed:upper="$foo.toUpperCase()"` (read-only, no side effects)
- **Nested**: `data-signals:form.name` => `$form.name`
- **Object syntax**: `data-signals="{a: 1, b: {c: 2}}"`
- **Hyphenation**: `data-bind:foo-bar` creates `$fooBar` (auto camelCase)
- **Private signals**: Names starting with `_` (e.g. `_loading`) are NOT sent to backend. Use for client-only state.
- **No `__` in names**: Double underscore is the modifier delimiter. `data-signals:foo__bar` will break.

### Modifiers (`__`)

Modifiers alter attribute behavior. Applied with double underscore syntax. Used in virtually every non-trivial app.

| Modifier | Applies to | Example |
|---|---|---|
| `__debounce.Xms` | `data-on:*` | `data-on:input__debounce.200ms="@get('/search')"` |
| `__throttle.Xms` | `data-on:*` | `data-on:scroll__throttle.100ms="..."` |
| `__window` | `data-on:*` | `data-on:keydown__window="evt.key === 'Enter' && ..."` |
| `__document` | `data-on:*` | Document-scoped events |
| `__outside` | `data-on:click` | Click-outside-to-close menus |
| `__prevent` | `data-on:*` | `data-on:click__prevent="@post('/...')"` |
| `__stop` | `data-on:*` | stopPropagation |
| `__once` | `data-on:*`, `data-on-intersect` | Single-fire listener |
| `__delay.Xms` | `data-init` | `data-init__delay.500ms="..."` |
| `__duration.Xms` or `__duration.Xs` | `data-on-interval` | `data-on-interval__duration.5s="@get('/poll')"` |
| `__duration.leading` | `data-on-interval` | Fire immediately then wait duration. e.g. `__duration.5s.leading`. Caution: infinite loops in backend-returned HTML |
| `__exit` | `data-on-intersect` | Trigger when element leaves viewport |
| `__half`, `__full` | `data-on-intersect` | Intersection thresholds (50%, 100%) |
| `__threshold.X` | `data-on-intersect` | Custom intersection threshold (e.g. `__threshold.25`) |
| `__ifmissing` | `data-signals` | `data-signals:foo__ifmissing="'default'"` only sets if not yet defined |
| `__case.camel` | `data-on:*` | Force camelCase event names |
| `__passive` | `data-on:*` | Passive event listener (scroll perf) |
| `__capture` | `data-on:*` | Capture phase |
| `__viewtransition` | `data-on:*`, `data-init`, `data-on-intersect`, `data-on-interval` | Wrap in View Transition API |
| `__self` | `data-ignore` | Ignore only element, not children |
| `__prop`, `__event` | `data-bind` | Force property binding, customize sync event |
| `__terse` | `data-json-signals` | Compact JSON output |

For exhaustive modifier lists, fetch https://data-star.dev/reference/attributes

### Data Attributes (full list)

| Attribute | Purpose | Example |
|---|---|---|
| `data-bind` | Two-way bind to input value | `data-bind:email` |
| `data-text` | Set text content | `data-text="$count"` |
| `data-show` | Show/hide (display:none) | `data-show="$isOpen"` |
| `data-class` | Toggle CSS class | `data-class:active="$selected"` |
| `data-attr` | Set any HTML attribute | `data-attr:disabled="$saving"` |
| `data-style` | Set inline style | `data-style:color="'red'"` |
| `data-on` | Event listener (supports modifiers) | `data-on:click="$count++"` |
| `data-signals` | Create/update signals | `data-signals:count="0"` |
| `data-computed` | Derived read-only signal (no side effects!) | `data-computed:doubled="$n*2"` |
| `data-effect` | Run expression on signal change (for side effects) | `data-effect="console.log($foo)"` |
| `data-indicator` | Signal true while request in-flight | `data-indicator:_loading` |
| `data-init` | Run on init + re-patch | `data-init="@get('/init')"` |
| `data-ref` | Store element reference in signal | `data-ref:myEl` |
| `data-ignore` | Skip Datastar processing entirely | `data-ignore` |
| `data-ignore-morph` | Skip morphing this element | `data-ignore-morph` |
| `data-preserve-attr` | Preserve attr across morphs | `data-preserve-attr="class"` |
| `data-on-intersect` | Trigger on viewport intersection | `data-on-intersect="@get('/more')"` |
| `data-on-interval` | Trigger on timer | `data-on-interval__duration.5s="@get('/poll')"` |
| `data-on-signal-patch` | Trigger on signal change | `data-on-signal-patch="$foo"` |
| `data-on-signal-patch-filter` | Filter which signal patches trigger | `data-on-signal-patch-filter="/^form\./"` |
| `data-json-signals` | Display signals as JSON (debugging, supports `__terse` and `{include/exclude}` filters) | `data-json-signals` |

**Attribute evaluation order matters**: `data-indicator` must appear before `data-init` / backend actions in the HTML to ensure the indicator signal exists when the request fires.

### Actions (`@`)

Safe helper functions. The `@` prefix is a security sandbox; arbitrary JS cannot call these.

**Frontend:**
- `@peek(fn)` - Read signals without subscribing to changes: `@peek(() => $bar)`
- `@setAll(value, filter?)` - Bulk set signals. Value FIRST, optional filter second: `@setAll(true, {include: /^menu\./})`
- `@toggleAll(filter?)` - Bulk toggle signals: `@toggleAll({include: /^menu\.isOpen\./})`

**Backend (SSE responses):**
- `@get(url, opts)` - GET request
- `@post(url, opts)` - POST request
- `@put(url, opts)` - PUT request
- `@patch(url, opts)` - PATCH request
- `@delete(url, opts)` - DELETE request

All backend actions send all signals by default (`datastar` query param for GET, JSON body for others). Private signals (`_` prefix) excluded. Use `{filterSignals: /regex/}` to limit (not recommended; prefer sending all).

**Form submission**: Use `{contentType: 'form'}` to send as form data instead of signals. Auto-finds closest `<form>`, validates, and sends form elements. `data-on:submit` auto-prevents default.

### Expressions

JS-like strings evaluated in sandboxed context. Key differences from plain JS:
- `$signalName` auto-resolves to signal value
- `el` refers to current element
- `evt` (or `event`) refers to event object in `data-on` handlers
- Statements separated by `;` (line breaks NOT sufficient)
- JS operators work: ternary `?:`, logical `&&`, `||`
- Actions only work with `@` prefix (security)
- Async code not awaited; dispatch custom events instead

```html
<div data-on:click="$count++; @post('/save')">
```

## Backend Integration (SSE)

Backend responds with `text/event-stream`. Each event patches DOM or signals.

### Event Types

**Patch Elements** (morph DOM):
```
event: datastar-patch-elements
data: elements <div id="target">Updated!</div>

```

**Patch Signals** (update state):
```
event: datastar-patch-signals
data: signals {count: 42, name: 'updated'}

```

**Patch Elements modes**: `outer` (default/morph), `inner`, `replace`, `prepend`, `append`, `before`, `after`, `remove`.

**Remove element**:
```
event: datastar-patch-elements
data: selector #obsolete
data: mode remove

```

### Response Content Types

| Content-Type | Behavior |
|---|---|
| `text/html` | Morph top-level elements by ID |
| `application/json` | Patch signals (JSON Merge Patch) |
| `text/event-stream` | Stream SSE events (preferred) |
| `text/javascript` | Execute as JS |

### SDKs Available

Go, Python, PHP, Ruby, Rust, C#, TypeScript/Node, Clojure, Kotlin, Java.

See https://data-star.dev/reference/sdks for per-language setup.

## Patterns & Best Practices

### The Tao of Datastar

1. **Backend is source of truth**. Most state lives server-side.
2. **Use signals sparingly**. Only for user interactions and sending data to backend.
3. **In Morph We Trust**. Send fat HTML chunks; morph handles diffing. "Fat morph" is more resilient: if SSE drops and reconnects, the full state is sent, nothing lost.
4. **SSE over JSON**. Multiple events per response, long-lived connections, 200:1 Brotli compression.
5. **Backend templating for DRY**. Use your server template language, not frontend abstractions.
6. **Use `<a>` for navigation**. Let the browser handle history. No custom routing.
7. **No optimistic updates**. Use loading indicators instead. Don't deceive users.
8. **Loading indicators**: `data-indicator:_loading` + `data-show="$_loading"`.

### CQRS Pattern

Single long-lived GET for reads, short-lived POST/PUT/DELETE for writes:
```html
<div id="main" data-init="@get('/stream')">
    <button data-on:click="@post('/do_thing')">Act</button>
</div>
```

For CQRS loading indicators, manual class toggling is recommended (DOM gets patched from backend anyway):
```html
<button data-on:click="el.classList.add('loading'); @post('/do_thing')">
    Do something
    <span>Loading...</span>
</button>
```

### Event Delegation (DRY)

Avoid N listeners on N buttons. Use parent delegation:
```html
<div data-on:click="evt.target.tagName == 'BUTTON' && @get('/endpoint')">
    <button>First</button>
    <button>Second</button>
</div>
```

Or use `data-on:click` on a parent with per-button data attributes:
```html
<div data-on:click="evt.target.closest('button[data-id]') && @get('/item/' + evt.target.closest('button').dataset.id)">
```

### Form Handling

```html
<form data-on:submit="@post('/save', {contentType: 'form'})">
    <input name="email" required />
    <button type="submit">Save</button>
</form>
```

`data-on:submit` auto-prevents default. `{contentType: 'form'}` sends form data instead of signals.

### Prevent FOUC (Flash of Unstyled Content)

Hide elements until Datastar processes them:
```html
<button data-show="$ready" style="display: none">Save</button>
```

### Redirect from Backend

Patch a `<script>` tag via SSE. Use SDK `redirect()` helper when available (handles Firefox history quirks):
```
event: datastar-patch-elements
data: elements <script>setTimeout(() => { location.href = '/new-page' }, 0)</script>

```

Firefox replaces history for `location.href` without `setTimeout`. SDK helpers handle this automatically.

### Custom Events (props down, events up)

For web components and external scripts:
```html
<my-widget
    data-attr:value="$foo"
    data-on:change="$result = evt.detail.value"
/>
```

### File Upload

Files bound via `data-bind:files` are base64-encoded into signal format `{name, contents, mime}[]`:
```html
<input type="file" data-bind:files multiple />
<button data-on:click="$files.length && @post('/upload')" data-attr:disabled="!$files.length">
    Upload
</button>
```

No form needed. File contents auto-encoded as base64 in signals.

### Infinite Scroll / Load More

Use `data-on-intersect` on a sentinel element:
```html
<div data-on-intersect="@get('/more')">
    Loading...
</div>
```

### `data-init` Re-triggering

`data-init` fires on page load, when element is patched into DOM, AND when attribute is modified. For long-lived SSE streams, place `data-init` on a stable container that won't be re-morphed, or you'll get duplicate connections.

### Security

- Escape all user-controlled values in expressions (XSS prevention)
- The `@` prefix is a security sandbox preventing arbitrary JS execution
- Never trust frontend signals; validate on backend

## Anti-Patterns

- **Don't** manage complex state in frontend signals. Let backend drive.
- **Don't** use optimistic updates. Show loading state, confirm from backend.
- **Don't** build SPA routing. Use `<a>` tags and page reloads.
- **Don't** overuse custom JS in expressions. Extract to web components.
- **Don't** use `data-computed` for side effects. Use `data-effect` instead.
- **Don't** use `__duration.leading` modifier on `data-on-interval` in backend-returned HTML. It creates infinite request loops.
- **Don't** use `__` in signal names. It's the modifier delimiter.
- **Don't** skip escaping user-controlled values in expressions.
- **Don't** use `data-on-interval` when SSE can push updates instead.
- **Don't** send partial signals without good reason. Prefer sending all (private `_` signals excluded automatically).

## Pro Features (Commercial License)

Attributes: `data-animate`, `data-custom-validity`, `data-match-media`, `data-on-raf`, `data-on-resize`, `data-persist`, `data-query-string`, `data-replace-url`, `data-scroll-into-view`, `data-view-transition`.

Actions: `@clipboard()`, `@fit()`, `@intl()`.

Rocket: Web component API. `rocket(tagName, { ... })` with reactive props.

See https://data-star.dev/pro for details.

## Examples

17 complete, idiomatic code examples in [EXAMPLES.md](EXAMPLES.md):

Active Search, Click to Edit, Bulk Update, Edit Row, Delete Row, File Upload, Form Submission, Infinite Scroll, Inline Validation, Lazy Tabs, Progress Bar, TodoMVC, Sortable, Web Component, Event Delegation, Signal Watcher, Custom Plugin.

Copy and adapt. Each example is self-contained with working HTML.

For deeper reference, the official docs can be fetched on demand from `data-star.dev`.
