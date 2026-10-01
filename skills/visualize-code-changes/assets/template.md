# <Change name> — before & after

<!--
Structure notes (delete this comment in the real document):
  * Lead with prose. Someone skimming should understand the change without
    decoding a diagram.
  * Keep diagrams as ```mermaid source, not exported images — GitHub renders
    them natively and the source stays reviewable in future diffs.
  * The "What changed" diagram is the one people actually read. Before/After
    exist to make it trustworthy.
-->

**Scope:** `<git ref, PR, or "uncommitted working tree">`
**Files:** `path/one.py`, `path/two.py`

<Two or three sentences: what this change accomplishes and why. Plain language,
no diagram vocabulary.>

<!--
For a change that touches several files -- especially a move or a split -- a
table like this is often the most useful thing in the document, because it tells
the reader where NOT to spend time. Drop it when only one file changed.

| File | What happened | Review effort |
|---|---|---|
| `pkg/calculator.py` | moved byte-for-byte | none |
| `pkg/invoice.py`    | moved, 3 lines changed | a minute |
| `pkg/tax.py`        | rewritten from scratch | all of it |
-->

## Before

<One line naming the key property of the old design — usually the thing the
change was made to fix.>

```mermaid
flowchart TD
  %% 5-15 nodes, scoped to the region the change touches plus one hop
```

## After

<One line on what is structurally different now.>

```mermaid
flowchart TD
  %% same altitude and same node names as Before wherever behaviour is unchanged,
  %% so the two diagrams are visually comparable
```

## What changed

```mermaid
flowchart TD
  %% Merged view: before and after in one graph, every node marked by its fate.

  classDef added   fill:#d4f8d4,stroke:#2ea043,color:#1f2328
  classDef removed fill:#ffd7d5,stroke:#cf222e,color:#1f2328
  classDef changed fill:#fff5cc,stroke:#bf8700,color:#1f2328
  classDef same    fill:#f6f8fa,stroke:#8c959f,color:#1f2328
```

**Legend** — 🟩 added · 🟥 removed · 🟨 modified · ⬜ unchanged.
Dotted red edges are call paths that no longer exist.

## Notes

- <Anything the diagram can't carry: perf implications, migration ordering,
  follow-up work.>
- <Any behaviour you inferred rather than confirmed, so a reader knows which
  parts to double-check.>
