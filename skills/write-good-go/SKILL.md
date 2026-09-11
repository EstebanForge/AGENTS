---
name: write-good-go
description: Apply curated high-frequency Go mistake checks BEFORE writing or heavily editing Go (.go) code, so code complies from the first draft. For reviewing existing diffs use review-my-go.
---
# Write Good Go

Pre-write prevention. Ten rules models still get wrong, cited to the full rubric in [go-mistakes.md](../review-my-go/go-mistakes.md). Review stays with [review-my-go](../review-my-go/SKILL.md); this skill is prevention only.

## Rules

1. **Slice aliasing** (#25/#26): `append` on a sub-slice can mutate the original; use three-index slicing `s[l:h:m]` or `copy`. A retained sub-slice pins the whole backing array; `copy` to release it.
2. **Typed nil error** (#45): a typed nil pointer returned as `error` is a non-nil interface; return explicit `nil`.
3. **Wrapped errors** (#50/#51): `errors.Is` / `errors.As`; never `==` or type assertion on wrapped errors.
4. **Loop variable capture** (#63/#32): pre-Go-1.22 the loop var and `&range` elements alias one variable; check the module's `go.mod` version and pass as args when older.
5. **Sync pitfalls** (#70/#71/#74): never copy a mutex-guarded struct; assignment copies a guarded slice/map's header, not its data; `wg.Add` before `go`; sync types travel by pointer.
6. **Context lifetime** (#61/#62): a request ctx dies with the response (`WithoutCancel` for background work); every goroutine gets a stop plan.
7. **Defer** (#47/#35): arguments evaluate at `defer` time; `defer` inside a loop runs at function return, not per iteration.
8. **String building** (#39): `strings.Builder` in loops, never `+=`.
9. **Empty slice** (#22/#23): `len(s) == 0` tests emptiness; nil vs empty differ under JSON/reflect.
10. **HTTP clients and resources** (#79/#81): every `http.Client` sets timeouts; every `resp.Body`, `sql.Rows`, and file closes via `defer`.

## While writing

Hold the list while drafting. When a listed construct is about to be emitted, recheck it against its rule first. Done when: the emitted code honors every applicable rule. Compliance is silent: no self-review narration in the output.
