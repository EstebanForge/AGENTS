---
name: write-good-go
description: Apply curated high-frequency Go mistake and performance checks BEFORE writing or heavily editing Go (.go) code, so code complies from the first draft. For reviewing existing diffs use review-my-go.
---
# Write Good Go

Pre-write prevention. Ten correctness rules models still get wrong, cited to the full rubric in [go-mistakes.md](../review-my-go/go-mistakes.md), plus performance rules distilled from [goperf.dev](https://goperf.dev/) (Go Optimization Guide, CC BY 4.0; magnitudes quoted from its published benchmarks). Review stays with [review-my-go](../review-my-go/SKILL.md); this skill is prevention only.

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

## Performance: hot path

Apply when the code sits on a hot path or allocates in a loop. Profile before micro-tuning cold code; that is the guide's own first rule.

1. **Preallocate** ([mem-prealloc](https://goperf.dev/01-common-patterns/mem-prealloc/)): `make([]T, 0, n)` and `make(map[K]V, n)` when size is known or estimable. Unpreallocated append re-copies: 4x slower, 19x the allocs at 10k elements.
2. **Keep values on the stack** ([stack-alloc](https://goperf.dev/01-common-patterns/stack-alloc/)): no returned pointers to locals, no boxing, no closure capture on hot paths. Verify with `go build -gcflags="-m"`, hunt `moved to heap`. Escaped alloc ~40x slower.
3. **Order struct fields** ([fields-alignment](https://goperf.dev/01-common-patterns/fields-alignment/)): largest to smallest, group same-size fields. Pad `_ [56]byte` between fields written by different goroutines (false sharing, 64B cache lines). Confirm with the fieldalignment linter.
4. **Box pointers, not values** ([interface-boxing](https://goperf.dev/01-common-patterns/interface-boxing/)): `[]Shape` holds `*T`; boxing into an interface always heap-allocates, even an int. ~19% slower for 4KB values.
5. **Pool short-lived objects** ([object-pooling](https://goperf.dev/01-common-patterns/object-pooling/)): `sync.Pool` for resettable buffers and scratch under measured alloc churn; `Reset()` before reuse; never pool shared or long-lived state. ~20x on 4KB buffer reuse.
6. **Slice, don't copy** ([zero-copy](https://goperf.dev/01-common-patterns/zero-copy/)): re-slice instead of copying when ownership is clear; a retained `buf[:n]` pins the whole backing array, so copy out anything that outlives the read loop. Use mmap direct pages only for memory-bound work.
7. **Atomics for simple state** ([atomic-ops](https://goperf.dev/01-common-patterns/atomic-ops/)): counters, flags, one-shot gates use `atomic.Int64` / CAS; mutex when the invariant spans fields. ~27% faster, gap widens under contention.
8. **Lazy init** ([lazy-init](https://goperf.dev/01-common-patterns/lazy-init/)): `sync.Once` / `sync.OnceValue` for expensive setup. Do not hand-roll an atomic init dance.
9. **Publish immutable snapshots** ([immutable-data](https://goperf.dev/01-common-patterns/immutable-data/)): build read-heavy config, routes, flags once with deep copies, swap via `atomic.Pointer`; readers take no lock.
10. **Batch and buffer I/O** ([buffered-io](https://goperf.dev/01-common-patterns/buffered-io/), [batching-ops](https://goperf.dev/01-common-patterns/batching-ops/)): wrap writers in `bufio` and `Flush()`; batch DB/RPC calls. Buffered writes ~62x, batched file I/O ~12x. Skip when per-item latency beats throughput.
11. **Bound concurrency** ([worker-pool](https://goperf.dev/01-common-patterns/worker-pool/)): fixed worker pool plus buffered channel; never unbounded `go` per task under load. CPU-bound pool ~= NumCPU; I/O-bound may exceed.
12. **Cut GC before tuning it** ([gc](https://goperf.dev/01-common-patterns/gc/)): reduce allocations first; touch `GOGC` only with pprof evidence; set `GOMEMLIMIT` below the container limit.

## Performance: network services

1. **Deadline every read and write** ([long-lived-connections](https://goperf.dev/02-networking/long-lived-connections/)): set and refresh deadlines per loop iteration; close conns with `defer`. A deadline-less read parks the goroutine forever on a dead peer.
2. **Drain response bodies** ([efficient-net-use](https://goperf.dev/02-networking/efficient-net-use/)): `io.Copy(io.Discard, resp.Body)` before `Close()`, else keep-alive reuse dies and fds exhaust.
3. **One tuned client per upstream** ([efficient-net-use](https://goperf.dev/02-networking/efficient-net-use/)): `Transport` with `MaxConnsPerHost`, `MaxIdleConns`, `IdleConnTimeout`; keep `Client.Timeout` short (2s, not 30s); get resilience from retries, not long timeouts.
4. **Set socket options deliberately** ([low-level-optimizations](https://goperf.dev/02-networking/low-level-optimizations/)): `SetNoDelay(true)` for small latency-sensitive writes; keepalive 30-60s; apply options inside `ListenConfig.Control`, never after bind.
5. **Design backpressure in** ([resilient-connection-handling](https://goperf.dev/02-networking/resilient-connection-handling/)): bounded queues, non-blocking `select`/`default` drops, short enqueue timeouts (~50ms), a circuit breaker per downstream; shed with 503 + `Retry-After`, never resets.
6. **Cache DNS yourself** ([dns_performance](https://goperf.dev/02-networking/dns_performance/)): Go caches nothing; pre-resolve fixed endpoints or run a TTL cache with a custom `Resolver` (`PreferGo: true`).
7. **Enable the TLS fast path** ([tls-for-speed](https://goperf.dev/02-networking/tls-for-speed/)): session tickets with a rotated 32-byte key (saves a full RTT), ECDSA certs, ECDHE + AES-GCM, `MinVersion: TLS12`, explicit `NextProtos: ["h2", "http/1.1"]`; empty ALPN silently downgrades to HTTP/1.1.
8. **Pick the transport on purpose** ([tcp-http2-grpc](https://goperf.dev/02-networking/tcp-http2-grpc/)): gRPC for internal RPC, HTTP/2 for public APIs, raw TCP with 4-byte length-prefix framing only when both ends are yours; QUIC for lossy or mobile paths.

## While writing

Hold all three lists while drafting. When a listed construct is about to be emitted, recheck it against its rule first. Performance rules apply to hot paths and network code; do not spend them on cold setup code. Done when: the emitted code honors every applicable rule. Compliance is silent: no self-review narration in the output.
