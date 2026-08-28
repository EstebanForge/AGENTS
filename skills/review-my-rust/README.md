# review-my-rust

A skill that reviews Rust changes (working tree, staged, commit, or range) against a Rust Code Smells guide. Findings name the section and anti-pattern (e.g. `Error Handling Traps > Excessive .unwrap()`), propose the idiomatic fix, and end in an Approve / Request Changes / Needs Discussion verdict.

Successor of the `@estebanforge/pi-rust-review` pi extension (deprecated 2026).

## Install

```bash
ln -s "$(pwd)" ~/.agents/skills/review-my-rust
```

Or copy the folder into any agent skills directory.

## Usage

Ask your agent: "Review my Rust." Point at a commit or range for narrower scope: "Review my Rust, main..HEAD."
