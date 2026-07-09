---
name: obscura
description: Lightweight Rust headless fetch/scrape engine (not a full browser). One-shot page reads, bulk parallel scraping, and a CDP/MCP server for Puppeteer/Playwright/MCP automation. User-invoked; reach for it by name.
allowed-tools: Bash(obscura:*), Bash(obscura-worker:*)
disable-model-invocation: true
---

# obscura

A **read-only fetch** engine: fast, light, parallel. Not a full browser.
Binary on PATH: `obscura` (worker `obscura-worker` lives alongside it).

## obscura vs agent-browser

Default browser tool is `agent-browser`. Reach for `obscura` only inside its lane.

| Reach for... | when the job is |
|---|---|
| **obscura** | reading page contents (text/html/links/markdown) from static or light-JS pages; bulk parallel scraping; CDP server for an existing Puppeteer/Playwright script; clearing basic bot challenges; stealth/antidetect |
| **agent-browser** | screenshots; interactive forms/login; heavy SPA or ES-module pages; rendering fidelity; Electron desktop apps; anything needing a real browser |

**Escalate to `agent-browser` if obscura fails** — its V8/DOM layer is incomplete and throws on complex pages (verified: GitHub's ES-module bundles crash with `TypeError: Cannot convert undefined or null to object`). Treat a JS-thrown exit-101 as the signal to switch, not as a bug to debug.

## Verify it's installed first

```bash
obscura --version    # expect: obscura 0.1.x
```

Exit 127 / "command not found" → on host install `~/.local/bin/obscura`; in the Construct container rebuild the image (`construct build`) so the post_install hook lands it. No `git clone`, no `cargo build` — the supported install is the prebuilt binary.

## fetch — one page

```bash
obscura fetch https://example.com --dump text --quiet
```

`--dump` is the main lever:
- `text` — visible text only (cheapest; start here)
- `html` — rendered DOM
- `markdown` — DOM→Markdown (clean for feeding to an LLM)
- `links` — every link URL
- `assets` — every sub-resource URL the page would fetch, NDJSON (one JSON object per asset; great for finding SPA API endpoints)
- `original` — raw response body verbatim, binary-safe (use for images/JSON/CSS where the JS layer should be bypassed)

Other flags worth remembering: `--eval "JS"` (run an expression, return result), `--selector "css"` (wait for element), `--wait-until networkidle0` (wait for a quiet network), `--timeout 30` (seconds), `--output file` (write result to file).

Completion criterion: the command exits 0 and returns the extracted content in the requested dump format. If it exits non-zero, do NOT silently retry the same way — read the error, then either switch dump mode, add `--wait-until`/`--timeout`, or escalate to agent-browser.

## scrape — many pages in parallel

```bash
obscura scrape url1 url2 url3 --concurrency 25 --format json --quiet
```

Workers inherit any global `--proxy`. Use `--eval` to extract one value per page. This is obscura's strength: hundreds of parallel fetches per host with a fraction of Chrome's memory. Suppress progress with `--quiet` for script-friendly stdout.

## serve — CDP server for Puppeteer / Playwright

```bash
obscura serve --port 9222          # ws://127.0.0.1:9222/devtools/browser
obscura serve --port 9222 --stealth
```

Connect with Puppeteer (`browserWSEndpoint`) or Playwright (`connectOverCDP`). Your existing scripts work **only across the CDP methods obscura implements** (Target, Page, Runtime, DOM, Network, Fetch, Storage, Input). Do not assume full Chrome parity — a script using an unimplemented method will fail, and that's expected, not a bug. Request interception (`setRequestInterception` / `page.route`) works as usual.

## mcp — tools for an AI agent

```bash
obscura mcp                 # stdio (Claude Desktop / MCP clients launching a subprocess)
obscura mcp --http --port 8080   # http://127.0.0.1:8080/mcp
```

Exposes: `browser_navigate`, `browser_snapshot`, `browser_click`, `browser_fill`, `browser_type`, `browser_press_key`, `browser_select_option`, `browser_evaluate`, `browser_wait_for`, `browser_network_requests`, `browser_console_messages`, `browser_close`. No screenshots in this set — there is no layout/rendering engine.

## stealth (anti-detect lane)

`--stealth` is global (before or after the subcommand; applies to fetch/serve/scrape/mcp). Two layers, gated differently:

- **Always on with `--stealth` (prebuilt binary included):** consistent `navigator`/User-Agent/WebGL fingerprint, `navigator.webdriver` masked, native functions patched against `Function.prototype.toString` detection, 3,520 tracker domains blocked.
- **Requires a `--features stealth` build:** TLS / HTTP-2 fingerprint impersonation (JA3/JA4 + ALPN-ordering defeat). The prebuilt release binary does NOT confirm this layer; if you need TLS impersonation, build from source with `cargo build --release --features stealth`.

Clears (with the fingerprint + tracker layer): Cloudflare non-interactive JS challenge, basic Akamai/DataDome/PerimeterX.
Does NOT clear: interactive CAPTCHAs (Turnstile interactive, hCaptcha), WebGPU/WebAssembly-based fingerprinters.

```bash
obscura fetch https://protected.example --stealth --dump html --quiet
```

## Proxy

Global flag, inherited by scrape workers: `obscura --proxy socks5://127.0.0.1:1080 fetch …` (HTTP or SOCKS5).

## Recipes

Compositions the flag list alone won't teach you. Each sits at a fork point where the wrong move fails silently or returns the wrong thing. All verified against the installed binary.

**Binary resource (image/JSON/CSS): bypass the JS layer, stream raw bytes.**
`--dump html` on a binary returns garbage; `--dump original` streams the response body verbatim. Redirect to a file.
```bash
obscura fetch https://httpbin.org/image/png --dump original --quiet > photo.png
```

**Extract structured data with `--eval` — it returns the JS value as JSON.**
Quote the expression; arrays/objects print to stdout. This is the canonical extraction move.
```bash
obscura fetch https://news.ycombinator.com --quiet \
  --eval "Array.from(document.querySelectorAll('.titleline > a')).map(a => ({title: a.textContent.trim(), url: a.href}))"
```

**Discover a SPA's real API endpoints with `--dump assets`.**
Assets is NDJSON, one `{"url","type"}` object per sub-resource the page would fetch. Filter the URL field for the API host.
```bash
obscura fetch https://app.example.com --dump assets --quiet | jq -r 'select(.url | test("api")) | .url'
```

**Dynamic page: wait for a quiet network AND bound the wait.**
`networkidle0` waits until no requests are in flight (client-rendered SPAs); `--timeout` stops slow/broken pages from hanging. Pair them.
```bash
obscura fetch https://app.example.com --wait-until networkidle0 --timeout 20 --dump html --quiet
```

## Guardrails

- **No screenshots. No rendering fidelity.** Need pixels or pixel-perfect output → `agent-browser`.
- **Heavy JS can throw.** ES-module-heavy SPAs may crash the V8/DOM layer (exit 101). Verify on the target page; escalate on failure.
- **No interactive logins.** For auth, inject cookies/session over CDP; don't expect obscura to drive a login flow.
- **Not full Chrome.** Some browser APIs and CDP methods are missing. Check the CDP table above before assuming a Puppeteer/Playwright feature works.
- **Memory cap on JS-heavy pages:** pass `--v8-flags "--max-old-space-size=4096"` if you hit `JavaScript heap out of memory`.
