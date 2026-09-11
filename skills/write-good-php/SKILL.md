---
name: write-good-php
description: Apply curated PHP 8.2+ checks BEFORE writing or heavily editing PHP (.php) code, so code complies from the first draft. For reviewing existing diffs use review-my-php.
---
# Write Good PHP

Pre-write prevention. Eleven rules models still get wrong, cited to the full rubric in [php-anti-patterns.md](../review-my-php/php-anti-patterns.md). Review stays with [review-my-php](../review-my-php/SKILL.md); this skill is prevention only.

## Rules

1. **strict_types** (#1): `declare(strict_types=1)` opens every file.
2. **Strict comparison** (#2/#14): `===` / `identical` everywhere; secrets compare with `hash_equals`.
3. **No `@`** (#5): suppression hides fatals; handle the false/`null` return instead.
4. **Narrow catch** (#6): catch the specific exception, log, rethrow; never a bare `\Throwable` swallow.
5. **`in_array` strict** (#7): third arg `true`, always.
6. **Prepared SQL** (#9): placeholders only; interpolation of user data is injection.
7. **Escaped output** (#10): `htmlspecialchars` (or the framework's escaper) on every echo of user data.
8. **CSRF token** (#11): state-changing POST verifies a per-session token (`hash_equals`).
9. **No `unserialize` on input** (#13): `json_decode` with `JSON_THROW_ON_ERROR`.
10. **Password hashing** (#15): `password_hash` / `password_verify`; md5/sha1 are not password hashes.
11. **Open redirect** (#16): user-controlled `Location` values are validated; path-only, rejecting `//`.

## While writing

Hold the list while drafting. When a listed construct is about to be emitted, recheck it against its rule first. Done when: the emitted code honors every applicable rule. Compliance is silent: no self-review narration in the output.
