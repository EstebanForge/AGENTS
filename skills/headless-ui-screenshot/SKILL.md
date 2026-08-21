---
name: headless-ui-screenshot
description: Screenshot-verify a GUI or webview app (Wails, GTK, Electron) on a headless Linux box with Xvfb and ffmpeg x11grab, when no display exists and the UI layout must be checked visually before shipping a slice.
---

## When to use this skill

Use this skill when a task must visually verify a desktop app's UI on a machine with no display: shipping a UI slice of Wicket QA Studio (`wicket-qa-studio/app`), checking a layout against a wireframe, or reproducing a rendering bug that needs a picture. Signals: "screenshot the app", "verify the UI", "does the layout match the spec", any headless box + GUI binary combination.

Do not use it for web pages reachable by URL (use agent-browser) or for anything verifiable through DOM/text assertions alone.

## The recipe

Completion criterion: a PNG captured from the running app, opened and checked against the expected layout; processes cleaned up.

1. Prepare a demo environment (skip if the app needs no config):

```bash
DEMO=$(mktemp -d /tmp/app-demo.XXXX)
mkdir -p $DEMO/home/.config/<app-config-dir> $DEMO/appdata
# write the app's config files under $DEMO/home/... and seed any
# state the UI reads (caches, markers) under $DEMO/appdata
```

2. Start Xvfb on a spare display at the design size, then the app inside it:

```bash
(Xvfb :95 -screen 0 1150x760x24 > /dev/null 2>&1 &)   # pick a free display
sleep 1
export HOME=$DEMO/home GDK_BACKEND=x11 LIBGL_ALWAYS_SOFTWARE=1
DISPLAY=:95 ./build/bin/<app> > /tmp/app-run.log 2>&1 &
sleep 6                                               # let the UI settle
```

Run the app inside an exec session so `kill_session` reaps it; WebKit apps also print a `JSC_SIGNAL_FOR_GC` line that confirms the webview started.

3. Capture one frame:

```bash
DISPLAY=:95 ffmpeg -y -f x11grab -video_size 1150x760 -i :95 -frames:v 1 /tmp/app-slice.png
```

Open the PNG with the read tool and compare against the wireframe or spec: every region present, states correct (badges, banners), no overflow.

4. Clean up by PID, not by pattern:

```bash
pgrep -a Xvfb        # note the :95 PID, kill it
pgrep -a <app>       # kill_session should have taken the app already
```

## Gotchas the environment does not confess

- **Capture tool**: Homebrew's ImageMagick `import` has no X11 delegate ("delegate library support not built-in '' (X11)") and `xwd`/`scrot` are absent. ffmpeg x11grab is the one that works.
- **WebKitGTK headless**: needs `GDK_BACKEND=x11` and `LIBGL_ALWAYS_SOFTWARE=1`, or it warns about DRI3/MESA and may not paint.
- **The big X**: Xvfb's default root cursor renders as a large black X in captures. It is the pointer, not a UI defect; move on.
- **pkill self-match**: `pkill -f "Xvfb :95"` matches the calling shell's own command line (the pattern appears in it) and kills your session. Use `pgrep` + kill by PID, or `pkill -x <exact-name>`.
- **Stray binaries**: `go build ./...` inside the app module drops a binary named after the module in the working directory. Remove it before committing.
