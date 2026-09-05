---
name: headless-ui-screenshot
description: Capture screenshots of desktop GUI applications on headless Linux systems using Xvfb. Use when visually verifying Linux desktop apps without an active display.
---

## Scope

For web pages reachable by URL, use `agent-browser` instead. When DOM or text assertions answer the question, use them; this skill is for visual verification of Linux desktop apps under Xvfb.

## The recipe

1. Prepare a demo environment. Done when the app's config files and seeded state (caches, markers) sit under `$DEMO` and the app would read them.

```bash
DEMO=$(mktemp -d /tmp/app-demo.XXXX)
mkdir -p $DEMO/home/.config/<app-config-dir> $DEMO/appdata
# write config under $DEMO/home/..., seed state under $DEMO/appdata
```

2. Start Xvfb on a spare display at the design size, then the app inside it. Done when the app process is alive and the log shows the webview started (WebKit apps print a `JSC_SIGNAL_FOR_GC` line).

```bash
(Xvfb :95 -screen 0 1150x760x24 > /dev/null 2>&1 &)   # pick a free display
sleep 1
export HOME=$DEMO/home GDK_BACKEND=x11 LIBGL_ALWAYS_SOFTWARE=1
DISPLAY=:95 ./build/bin/<app> > /tmp/app-run.log 2>&1 &
sleep 6                                               # let the UI settle
```

Run the app inside an exec session so `kill_session` reaps it.

3. Capture one frame and read it. Done when the PNG is open beside the wireframe and every region checked: present, states correct (badges, banners), nothing overflowing.

```bash
DISPLAY=:95 ffmpeg -y -f x11grab -video_size 1150x760 -i :95 -frames:v 1 /tmp/app-slice.png
```

Open the PNG with the read tool.

4. Clean up by PID. Done when `pgrep -a Xvfb` shows no `:95` display and `pgrep -a <app>` shows nothing.

```bash
pgrep -a Xvfb   # note the :95 PID, kill it
```

## Gotchas the environment does not confess

- **Capture tool**: Homebrew's ImageMagick `import` has no X11 delegate ("delegate library support not built-in '' (X11)") and `xwd`/`scrot` are absent. ffmpeg x11grab is the one that works.
- **WebKitGTK headless**: needs `GDK_BACKEND=x11` and `LIBGL_ALWAYS_SOFTWARE=1`, or it warns about DRI3/MESA and may not paint.
- **The big X**: Xvfb's default root cursor renders as a large black X in captures. It is the pointer, not a defect; move on.
- **pkill self-match**: `pkill -f "Xvfb :95"` matches the calling shell's own command line (the pattern appears in it) and kills your session. Kill by PID from `pgrep`, or use `pkill -x <exact-name>`.
