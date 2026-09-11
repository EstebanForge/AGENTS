---
name: write-good-javascript
description: Apply curated JavaScript checks BEFORE writing or heavily editing JS (.js/.mjs/.cjs) code, so code complies from the first draft. For reviewing existing diffs use review-my-javascript.
---
# Write Good JavaScript

Pre-write prevention. Twelve rules models still get wrong, cited to the full rubric in [js-flaws.md](../review-my-javascript/js-flaws.md). Review stays with [review-my-javascript](../review-my-javascript/SKILL.md); this skill is prevention only.

## Rules

1. **Strict equality** (#1): `===`; `==` coerces.
2. **Await every promise** (#3/#4): no floating promises; every chain gets `await` or `.catch`.
3. **No async `forEach`** (#5): `Promise.all` over `map` for concurrency, `for...of` for order.
4. **No argument mutation** (#6): return new arrays/objects; side effects stay out of parameters.
5. **Bound `this`** (#7): method references passed as callbacks get bound or wrapped in arrows.
6. **No prototype/global patches** (#8): standalone helpers, never `Array.prototype.x = ...`.
7. **`textContent`, not `innerHTML`** (#11): user data is never rendered as HTML unsanitized.
8. **Non-blocking I/O** (#15): `fs.promises`, no `readFileSync` in request paths.
9. **`execFile`, not `exec`** (#16): arg arrays; shell string plus user input is command injection.
10. **`crypto` for secrets** (#17): `crypto.randomUUID()` / `randomBytes`; `Math.random` is not randomness for tokens.
11. **No prototype pollution** (#9): deny `__proto__` / `prototype` / `constructor` keys when merging untrusted input.
12. **Path traversal** (#18): `path.resolve` plus a base-dir containment check on every user-supplied path.

## While writing

Hold the list while drafting. When a listed construct is about to be emitted, recheck it against its rule first. Done when: the emitted code honors every applicable rule. Compliance is silent: no self-review narration in the output.
