---
name: write-good-rust
description: Apply curated idiomatic-Rust checks BEFORE writing or heavily editing Rust (.rs) code, so code complies from the first draft. For reviewing existing diffs use review-my-rust.
---
# Write Good Rust

Pre-write prevention. Eleven rules models still get wrong, cited to the full rubric in [rust-smells.md](../review-my-rust/rust-smells.md) (§ = anti-pattern name there). Review stays with [review-my-rust](../review-my-rust/SKILL.md); this skill is prevention only.

## Rules

1. **No bare `unwrap`** (§ Excessive use of .unwrap): `?`, `match`, or `unwrap_or` outside tests; panics are not error handling.
2. **Borrowed params** (§ Unnecessary Indirection): `&str` / `&[T]`, never `&String` / `&Vec<T>`.
3. **Clone is not a tool** (§ Unnecessary Heap Cloning): borrow first; `.clone()` only at ownership boundaries.
4. **No `Rc<RefCell<T>>` reflex** (§ Overusing Smart Pointers): one owning `Vec` plus indices beats shared mutable graphs.
5. **Borrow conflicts are structural** (§ Overextending Conflicting Reference Lifetimes): reorder so borrows end before mutation; do not fight NLL with scopes.
6. **`Path` over strings** (§ Treating Paths as Strings): `Path::new(dir).join(name)`; `format!` paths break on separators.
7. **Concat in loops** (§ Inefficient String Concatenation): `join` or `push_str` into `String::with_capacity`.
8. **Valid by construction** (§ Two-State Uninitialized Object): constructors return `Result<Self>`, no empty-then-populate states.
9. **`Option`/`Result`, not sentinels** (§ Sentinel Values): no `-1`, `""`, or `None`-as-error return codes.
10. **Trait bounds over files** (§ Hardcoded File Inputs): accept `impl Read` / `impl Write`, not paths.

11. **Async runtime hygiene** (§ Blocking the Async Runtime Across `.await`): no `std::fs`, `thread::sleep`, or held `MutexGuard` across `.await`; use async primitives, `spawn_blocking`, short lock scopes.

## While writing

Hold the list while drafting. When a listed construct is about to be emitted, recheck it against its rule first. Done when: the emitted code honors every applicable rule. Compliance is silent: no self-review narration in the output.
