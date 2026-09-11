---
name: write-good-typescript
description: Apply curated TypeScript and React checks BEFORE writing or heavily editing TS/TSX (.ts/.tsx/.jsx) code, so code complies from the first draft. For reviewing existing diffs use review-my-typescript.
---
# Write Good TypeScript

Pre-write prevention. Thirteen rules models still get wrong, cited to the full rubric in [ts-flaws.md](../review-my-typescript/ts-flaws.md). Review stays with [review-my-typescript](../review-my-typescript/SKILL.md); this skill is prevention only.

## Rules

1. **No `as` cast to silence the compiler** (#1): narrow or parse (schema / type guard).
2. **Narrow `unknown`** (#2): check shape before access; a cast re-creates `any`.
3. **Effect cleanup** (#4): every subscription, timer, listener, socket stops in the returned cleanup.
4. **Immutable state** (#5): new arrays/objects via the setter; never mutate held state.
5. **Functional updaters** (#6): `setX(prev => ...)` when the next value reads the old one.
6. **Abort effect fetches** (#9): `AbortController` in cleanup; a late response must not write stale state.
7. **Boolean `&&` render** (#11): `items.length > 0 && <List/>`; bare `&&` renders a literal `0`.
8. **Stable keys** (#12): identity (`item.id`), not array index, in dynamic lists.
9. **No render-phase `setState`** (#13): derive during render; a setter in the body loops forever.
10. **Stable deps** (#14): a dep created in render refires its effect every render; stabilize that one dep.
11. **Allowlist URL schemes** (#15): `javascript:` hrefs run as script; `new URL()` then check protocol.
12. **No tokens in `localStorage`** (#16): HttpOnly cookies or in-memory short-lived tokens.
13. **No raw HTML from data** (#7): render as children; `dangerouslySetInnerHTML` only over sanitized output.

## While writing

Hold the list while drafting. When a listed construct is about to be emitted, recheck it against its rule first. Done when: the emitted code honors every applicable rule. Compliance is silent: no self-review narration in the output.
