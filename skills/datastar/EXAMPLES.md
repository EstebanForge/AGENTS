# Datastar Examples

Complete, idiomatic code examples extracted from the official docs. Copy and adapt.

---

## Active Search (Debounced Input)

Live search as user types. Debounced to avoid hammering backend.

```html
<input
    type="text"
    placeholder="Search..."
    data-bind:search
    data-on:input__debounce.200ms="@get('/search')"
/>
<div id="results">
    <!-- Backend morphs results here -->
</div>
```

Backend receives `$search` in `datastar` query param. Returns `text/html` with matching results morphed into `#results`.

---

## Click to Edit (Inline Edit Pattern)

Show details, click Edit to swap to form, PUT to save, morph back.

**Display state:**
```html
<div id="contact">
    <p>First Name: John</p>
    <p>Last Name: Doe</p>
    <p>Email: [email protected]</p>
    <div role="group">
        <button
            data-indicator:_fetching
            data-attr:disabled="$_fetching"
            data-on:click="@get('/contacts/1/edit')"
        >
            Edit
        </button>
        <button
            data-indicator:_fetching
            data-attr:disabled="$_fetching"
            data-on:click="@patch('/contacts/1/reset')"
        >
            Reset
        </button>
    </div>
</div>
```

**Edit state (returned by backend via SSE patch):**
```html
<div id="contact">
    <label>
        First Name
        <input type="text" data-bind:first-name data-attr:disabled="$_fetching">
    </label>
    <label>
        Last Name
        <input type="text" data-bind:last-name data-attr:disabled="$_fetching">
    </label>
    <label>
        Email
        <input type="email" data-bind:email data-attr:disabled="$_fetching">
    </label>
    <div role="group">
        <button
            data-indicator:_fetching
            data-attr:disabled="$_fetching"
            data-on:click="@put('/contacts/1')"
        >
            Save
        </button>
        <button
            data-indicator:_fetching
            data-attr:disabled="$_fetching"
            data-on:click="@get('/contacts/1/cancel')"
        >
            Cancel
        </button>
    </div>
</div>
```

No form needed. Signals are sent automatically on PUT. Backend is source of truth for validation.

---

## Bulk Update (Multi-Row Selection)

Select rows via checkboxes, bulk activate/deactivate.

```html
<div
    id="demo"
    data-signals__ifmissing="{_fetching: false, selections: Array(4).fill(false)}"
>
    <table>
        <thead>
            <tr>
                <th>
                    <input
                        type="checkbox"
                        data-bind:_all
                        data-on:change="$selections = Array(4).fill($_all)"
                        data-effect="$selections; $_all = $selections.every(Boolean)"
                        data-attr:disabled="$_fetching"
                    />
                </th>
                <th>Name</th>
                <th>Email</th>
                <th>Status</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>
                    <input
                        type="checkbox"
                        data-bind:selections
                        data-attr:disabled="$_fetching"
                    />
                </td>
                <td>Joe Smith</td>
                <td>[email protected]</td>
                <td>Active</td>
            </tr>
            <!-- More rows... -->
        </tbody>
    </table>
    <div role="group">
        <button
            data-on:click="@put('/bulk/activate')"
            data-indicator:_fetching
            data-attr:disabled="$_fetching"
        >
            Activate
        </button>
        <button
            data-on:click="@put('/bulk/deactivate')"
            data-indicator:_fetching
            data-attr:disabled="$_fetching"
        >
            Deactivate
        </button>
    </div>
</div>
```

Key patterns: `data-signals__ifmissing` for defaults, `data-effect` to sync select-all checkbox, array signals for row selections.

---

## Edit Row (Table Inline Edit)

**Read-only row:**
```html
<tr>
    <td>Joe Smith</td>
    <td>[email protected]</td>
    <td>
        <button data-on:click="@get('/contacts/0/edit')">Edit</button>
    </td>
</tr>
```

**Edit state (backend morphs this row):**
```html
<tr>
    <td>
        <input type="text" data-bind:name>
    </td>
    <td>
        <input type="text" data-bind:email>
    </td>
    <td>
        <button data-on:click="@get('/contacts/cancel')">Cancel</button>
        <button data-on:click="@patch('/contacts/0')">Save</button>
    </td>
</tr>
```

Backend returns the whole table with the edited row swapped to input fields.

---

## Delete Row

```html
<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Email</th>
            <th>Actions</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>Joe Smith</td>
            <td>[email protected]</td>
            <td>
                <button
                    data-on:click="confirm('Are you sure?') && @delete('/contacts/0')"
                    data-indicator:_fetching
                    data-attr:disabled="$_fetching"
                >
                    Delete
                </button>
            </td>
        </tr>
    </tbody>
</table>
```

`confirm()` returns a boolean, used with `&&` to gate the DELETE request.

---

## File Upload

Files are base64-encoded into signals. No form required.

```html
<label>
    <p>Pick anything less than 1MB</p>
    <input type="file" data-bind:files multiple/>
</label>
<button
    data-on:click="$files.length && @post('/upload')"
    data-attr:disabled="!$files.length"
>
    Submit
</button>
```

Signal `$files` contains `{name: string, contents: string, mime: string}[]` with base64-encoded contents.

---

## Form Submission (Non-Signal)

Use `{contentType: 'form'}` to send as standard form data. No signals sent.

**Inside a form:**
```html
<form data-on:submit="@get('/endpoint', {contentType: 'form'})">
    <input type="text" name="foo" required />
    <button>Submit form</button>
</form>
```

`data-on:submit` auto-prevents default form submission.

**From outside a form (with selector):**
```html
<form id="myform">
    <input type="checkbox" name="checkboxes" value="foo" />
    <input type="checkbox" name="checkboxes" value="bar" />
</form>

<button data-on:click="@get('/endpoint', {contentType: 'form', selector: '#myform'})">
    Submit GET request from outside the form
</button>
```

---

## Infinite Scroll

```html
<div data-on-intersect="@get('/items/more')">
    Loading...
</div>
```

When sentinel element scrolls into view, fetches more items. Backend appends new content after the sentinel using `mode append` in SSE patch.

---

## Inline Validation

Debounced POST on each keystroke for server-side validation.

```html
<div id="demo">
    <label>
        Email Address
        <input
            type="email"
            required
            aria-live="polite"
            aria-describedby="email-info"
            data-bind:email
            data-on:keydown__debounce.500ms="@post('/validate')"
        />
    </label>
    <p id="email-info" class="info">Validation hint here.</p>
    <label>
        First Name
        <input
            type="text"
            required
            aria-live="polite"
            data-bind:first-name
            data-on:keydown__debounce.500ms="@post('/validate')"
        />
    </label>
    <button data-on:click="@post('/signup')">Sign Up</button>
</div>
```

Backend returns morphed form with validation messages. Each keystroke (debounced 500ms) triggers validation.

---

## Lazy Tabs

```html
<div id="demo">
    <div role="tablist">
        <button
            role="tab"
            aria-selected="true"
            data-on:click="@get('/tabs/0')"
        >
            Tab 0
        </button>
        <button
            role="tab"
            aria-selected="false"
            data-on:click="@get('/tabs/1')"
        >
            Tab 1
        </button>
        <button
            role="tab"
            aria-selected="false"
            data-on:click="@get('/tabs/2')"
        >
            Tab 2
        </button>
    </div>
    <div role="tabpanel">
        <p>Tab content loaded from backend...</p>
    </div>
</div>
```

Tab state lives in backend HTML. Each click fetches and morphs the tabpanel content.

---

## Progress Bar (SSE Streaming)

```html
<div id="progress-bar"
     data-init="@get('/progress/updates', {openWhenHidden: true})"
>
    <svg width="200" height="200" viewbox="-25 -25 250 250"
         style="transform: rotate(-90deg)">
        <!-- Background circle -->
        <circle r="90" cx="100" cy="100"
                fill="transparent" stroke="#e0e0e0"
                stroke-width="16px" stroke-dasharray="565.48px"
                stroke-dashoffset="565px"></circle>
        <!-- Progress circle -->
        <circle r="90" cx="100" cy="100"
                fill="transparent" stroke="#6bdba7"
                stroke-width="16px" stroke-linecap="round"
                stroke-dashoffset="282px"
                stroke-dasharray="565.48px"></circle>
        <!-- Percentage text -->
        <text x="44px" y="115px" fill="#6bdba7"
              font-size="52px" font-weight="bold"
              style="transform:rotate(90deg) translate(0px, -196px)">
            50%
        </text>
    </svg>

    <div data-on:click="@get('/progress/updates', {openWhenHidden: true})">
        <button>Completed! Try again?</button>
    </div>
</div>
```

`data-init` opens SSE stream on page load. Backend sends updated SVG every 500ms via `datastar-patch-elements`. `{openWhenHidden: true}` keeps connection alive when tab is hidden.

---

## TodoMVC (Complex State)

Full CRUD app with filtering, all server-driven via SSE.

```html
<section id="todomvc" data-init="@get('/todomvc/updates')">
    <header id="todo-header">
        <input
            type="checkbox"
            data-on:click__prevent="@post('/todomvc/-1/toggle')"
            data-init="el.checked = false"
        />
        <input
            id="new-todo"
            type="text"
            placeholder="What needs to be done?"
            data-signals:input
            data-bind:input
            data-on:keydown="
                evt.key === 'Enter' && $input.trim() && @patch('/todomvc/-1') && ($input = '');
            "
        />
    </header>
    <ul id="todo-list">
        <!-- Backend renders todo items via SSE -->
    </ul>
    <div id="todo-actions">
        <span><strong>0</strong> items pending</span>
        <button data-on:click="@put('/todomvc/mode/0')">All</button>
        <button data-on:click="@put('/todomvc/mode/1')">Pending</button>
        <button data-on:click="@put('/todomvc/mode/2')">Completed</button>
        <button data-on:click="@put('/todomvc/reset')">Reset</button>
    </div>
</section>
```

Key patterns: `data-init` for SSE stream, `__prevent` modifier, multi-statement expressions with `;`, `data-init="el.checked = false"` to set initial DOM state.

---

## Sortable (External JS Integration)

```html
<div data-signals:order-info="'Initial order'" data-text="$orderInfo"></div>
<div id="sortContainer" data-on:reordered="$orderInfo = event.detail.orderInfo">
    <button>Item 1</button>
    <button>Item 2</button>
    <button>Item 3</button>
    <button>Item 4</button>
    <button>Item 5</button>
</div>

<script type="module">
    import Sortable from 'https://cdn.jsdelivr.net/npm/sortablejs/+esm'
    new Sortable(sortContainer, {
        animation: 150,
        ghostClass: 'opacity-25',
        onEnd: (evt) => {
            sortContainer.dispatchEvent(
                new CustomEvent('reordered', {
                    detail: {
                        orderInfo: `Moved from position ${evt.oldIndex + 1} to ${evt.newIndex + 1}`
                    }
                })
            )
        }
    })
</script>
```

Pattern: external JS dispatches custom events, Datastar reacts via `data-on:reordered`. Props down, events up.

---

## Web Component Integration

```html
<label>
    Reversed
    <input type="text" value="Your Name" data-bind:_name/>
</label>
<span data-signals:_reversed data-text="$_reversed"></span>
<reverse-component
    data-on:reverse="$_reversed = evt.detail.value"
    data-attr:name="$_name"
></reverse-component>

<script>
    class ReverseComponent extends HTMLElement {
        static get observedAttributes() {
            return ["name"];
        }

        attributeChangedCallback(name, oldValue, newValue) {
            const value = [...newValue].toReversed().join("");
            this.dispatchEvent(new CustomEvent("reverse", {
                detail: { value }
            }));
        }
    }

    customElements.define("reverse-component", ReverseComponent);
</script>
```

`data-attr:name` passes signal value as attribute (props down). `data-on:reverse` listens for custom event (events up). Note `_` prefix on signals: private, not sent to backend.

---

## Event Delegation (Event Bubbling)

Single listener on parent handles all child button clicks.

```html
<div id="demo">
    Key pressed: <span data-text="$key"></span>
    <div
        data-on:click="$key = evt.target.closest('button[data-id]')?.dataset.id ?? $key"
    >
        <button data-id="ENTER">ENTER</button>
        <button data-id="CLEAR">CLEAR</button>
        <button data-id="1">1</button>
        <button data-id="2">2</button>
        <button data-id="3">3</button>
    </div>
</div>
```

`evt.target.closest('button[data-id]')` resolves the clicked button regardless of nested elements. Avoids N listeners on N buttons.

---

## Signal Change Watcher (on-signal-patch)

React to specific signal changes with include/exclude filters.

```html
<div data-signals="{counter: 0, message: 'Hello', allChanges: [], counterChanges: []}">
        <button data-on:click="$message = `Updated: ${performance.now().toFixed(2)}`">Update Message</button>
        <button data-on:click="$counter++">Increment Counter</button>
        <button
            class="error"
            data-on:click="$allChanges.length = 0; $counterChanges.length = 0"
        >
            Clear All Changes
        </button>

    <!-- Watch counter changes only -->
    <div
        data-on-signal-patch="$counterChanges.push(patch)"
        data-on-signal-patch-filter="{include: /^counter$/}"
    >
        <h3>Counter Changes Only</h3>
        <pre data-json-signals__terse="{include: /^counterChanges/}"></pre>
    </div>

    <!-- Watch all changes (excluding change logs themselves) -->
    <div
        data-on-signal-patch="$allChanges.push(patch)"
        data-on-signal-patch-filter="{exclude: /allChanges|counterChanges/}"
    >
        <h3>All Signal Changes</h3>
        <pre data-json-signals__terse="{include: /^allChanges/}"></pre>
    </div>
</div>
```

`patch` variable in `data-on-signal-patch` contains the signal change details. Filter with `{include: /regex/}` or `{exclude: /regex/}`.

---

## Custom Plugin (Action + Attribute)

**Custom action:**
```js
action({
    name: 'alert',
    apply(ctx, value) {
        alert(value)
    }
})
```
Usage: `@alert('Hello from an action')`

**Custom attribute:**
```js
attribute({
    name: 'alert',
    requirement: {
        key: 'denied',    // no key allowed (data-alert, not data-alert:foo)
        value: 'must',    // value is required (data-alert="...")
    },
    returnsValue: true,
    apply({ el, rx }) {
        const callback = () => alert(rx())
        el.addEventListener('click', callback)
        return () => el.removeEventListener('click', callback)
    }
})
```
Usage: `data-alert="'Hello from an attribute'"`

The returned cleanup function is called when the element is removed from the DOM.
