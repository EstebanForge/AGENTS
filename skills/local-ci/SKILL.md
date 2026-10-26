---
name: local-ci
description: Run GitHub Actions CI locally with Local CI to validate changes before pushing. Use when testing, running checks, or validating code changes.
license: MIT
compatibility: Requires Node.js 22+ and Docker or Podman
metadata:
  author: redwoodjs
  version: "1.0.0"
---

# Local CI

Run the full CI pipeline locally before pushing. CI was green before you started; any failure is caused by your changes.

## Binary Name

The globally installed binary from `run-local-ci` is named `local-ci`.

## Podman / DOCKER_HOST Note

`local-ci` strictly rejects `DOCKER_HOST` in the environment and requires `LOCAL_CI_DOCKER_HOST`.
When running on hosts where `DOCKER_HOST` is exported in the shell:

```bash
env -u DOCKER_HOST LOCAL_CI_DOCKER_HOST="unix:///run/user/$(id -u)/podman/podman.sock" local-ci run --quiet --all --pause-on-failure
```

Or if `DOCKER_HOST` is not set:

```bash
LOCAL_CI_DOCKER_HOST="unix:///run/user/$(id -u)/podman/podman.sock" local-ci run --quiet --all --pause-on-failure
```

## Run

```bash
local-ci run --quiet --all --pause-on-failure
```

Or for a specific workflow:

```bash
local-ci run --workflow .github/workflows/ci.yml --pause-on-failure
```

Pipes are safe: pause-on-failure works through `| tee log`, `> log.txt`, etc. When stdout is not a TTY, the launcher detaches the run and the foreground process exits **77** when a step pauses, freeing the pipe while the container stays paused for `retry`.

## Retry

When a step fails, the run pauses automatically. Fix the issue, then retry:

```bash
local-ci retry --name <runner-name>
```

To re-run from an earlier step:

```bash
local-ci retry --name <runner-name> --from-step <N>
```

Repeat until all jobs pass. Do not push to trigger remote CI when local-ci can run it locally.

## Machine-readable output (`--json`)

For programmatic monitoring, add `--json` (or set `LOCAL_CI_JSON=1`) to emit an NDJSON event stream on stdout (one JSON object per line). Events:

- `run.start` (with `schemaVersion: 1`, `runId`)
- `job.start`, `job.finish` (`status: passed|failed`)
- `step.start`, `step.finish` (`status: passed|failed|skipped`)
- `run.paused` (carries `runner` + `retry_cmd`)
- `run.finish` (`status: passed|failed`)
- `diagnostic`

`--json` is decoupled from `--quiet`, and the diff renderer is suppressed under `--json`. Combined with the exit-77 pause signal, this allows agents to parse `run.paused` events and call `retry`.
