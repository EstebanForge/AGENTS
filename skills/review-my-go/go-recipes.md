## Go Recipes Review Annex (github.com/nikolaydubina/go-recipes)
### Practice checks (distilled to diff-reviewable only)
- recipe:goleak — Tests spawning goroutines with no leak guard. Suggest goleak.VerifyNone (TestMain or per-test). Pairs with #62.
- recipe:execctx — exec.Command on a cancellable path orphans the process. Use exec.CommandContext (errgroup for fan-out).
- recipe:untested-pkg — Changed package has zero test files. Check: `go list -json ./... | jq 'select((.TestGoFiles|length)==0) | .ImportPath'`.
- recipe:benchstat — Diff claims a perf win with no before/after evidence. Demand `go test -bench` plus `benchstat old.txt new.txt`; table-driven `b.Run` per size.
- recipe:enumguard — Enum type permits arithmetic, operators, or implicit conversion of untyped constants. Compile-time blocking: wrap the value in a struct in its own package with the field unexported.
- recipe:cgo — New import may pull cgo into a static or distroless build. Confirm linking intent; CGO_ENABLED=0 check if the image assumes it.
- recipe:govulncheck — go.mod bumps or adds a dependency. Suggest `govulncheck ./...` (reports only reachable vulns).
