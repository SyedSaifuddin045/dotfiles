# SketchyBar Workspace Boundary Colors — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give every AeroSpace workspace item in SketchyBar a visual boundary — translucent accent border when it has apps open, solid accent pill when focused.

**Architecture:** A single idempotent helper `helpers/workspace_style.sh` computes one workspace item's complete visual state (focus + window count) and sets all properties in one `sketchybar --set`. Both existing plugins (`aerospace.sh`, `space_windows.sh`) delegate to it, so event order never produces a stale/conflicting style.

**Tech Stack:** bash + `sketchybar` CLI + `aerospace` CLI. Files live in `~/.config/sketchybar/`.

**Note:** `~/.config/sketchybar` is not a git repo — commit steps are omitted.

---

## File Structure

- **Create:** `~/.config/sketchybar/helpers/workspace_style.sh` — single source of truth for workspace visual state.
- **Modify:** `~/.config/sketchybar/plugins/aerospace.sh` — replace inline highlight with helper delegation.
- **Modify:** `~/.config/sketchybar/plugins/space_windows.sh` — call helper after building each workspace's app-icon strip.
- **Untouched:** `sketchybarrc` — startup already runs `space_windows.sh`, which now styles all workspaces.

---

### Task 1: Create the workspace style helper

**Files:**
- Create: `~/.config/sketchybar/helpers/workspace_style.sh`

- [ ] **Step 1: Write `helpers/workspace_style.sh`**

```bash
#!/usr/bin/env bash

# Sets complete visual state for one workspace item based on focus + window
# count. Idempotent: callers may invoke it any time, in any order.

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"

ws="$1"
focused=$(aerospace list-workspaces --focused 2>/dev/null)

count=0
app_names=$(aerospace list-windows --workspace "$ws" --format '%{app-name}' 2>/dev/null)
[ -n "$app_names" ] && count=$(printf '%s\n' "$app_names" | wc -l | tr -d ' ')

if [ "$ws" = "$focused" ]; then
  sketchybar --set "space.$ws" \
    background.color=0xff89b4fa \
    background.drawing=on \
    background.border_width=0 \
    icon.color=0xff11111b \
    label.color=0xff11111b
elif [ "$count" -gt 0 ]; then
  sketchybar --set "space.$ws" \
    background.color=0x00000000 \
    background.drawing=on \
    background.border_color=0x6689b4fa \
    background.border_width=2 \
    icon.color=0xffcdd6f4 \
    label.color=0xffcdd6f4
else
  sketchybar --set "space.$ws" \
    background.drawing=off \
    background.border_width=0 \
    icon.color=0xffcdd6f4 \
    label.color=0xffcdd6f4
fi
```

- [ ] **Step 2: Make executable and syntax-check**

```bash
chmod +x ~/.config/sketchybar/helpers/workspace_style.sh
bash -n ~/.config/sketchybar/helpers/workspace_style.sh
```

Expected: no output (clean parse).

- [ ] **Step 3: Manual smoke-test with query**

```bash
~/.config/sketchybar/helpers/workspace_style.sh 1
sketchybar --query space.1 | grep -oE '"background":.*|"color": "0x[^"]+"' | head -5
```

Expected: helper runs without error. `space.1` state matches `aerospace list-workspaces --focused`: if ws1 is focused → `background.color` `0xff89b4fa` + drawing `on`; otherwise populated/empty branch per window count.

---

### Task 2: Delegate from `aerospace.sh`

**Files:**
- Modify: `~/.config/sketchybar/plugins/aerospace.sh`

- [ ] **Step 1: Replace whole file content**

```bash
#!/usr/bin/env bash

# Highlights the focused AeroSpace workspace in SketchyBar.
# All styling is owned by the shared workspace_style helper.

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"

exec "$CONFIG_DIR/helpers/workspace_style.sh" "$1"
```

- [ ] **Step 2: Syntax-check**

```bash
bash -n ~/.config/sketchybar/plugins/aerospace.sh
```

Expected: no output (clean parse).

- [ ] **Step 3: Trigger the live path**

```bash
sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=2
sleep 0.5
sketchybar --query space.2 | grep -oE '"color": "0x[^"]+"' | head -3
```

Expected: no script errors. Helper queries live aerospace focus itself (ignores the env override), so rendered state always mirrors `aerospace list-workspaces --focused` regardless of trigger env — idempotency check: after the event, `space_windows.sh` re-runs the helper and the state stays consistent.

---

### Task 3: Delegate from `space_windows.sh`

**Files:**
- Modify: `~/.config/sketchybar/plugins/space_windows.sh`

- [ ] **Step 1: Add helper call after strip update, inside the loop**

Current loop body (lines 8-18) becomes:

```bash
for ws in 1 2 3 4 5; do
  apps=$(aerospace list-windows --workspace "$ws" --format '%{app-name}' 2>/dev/null)
  strip=""
  if [ -n "$apps" ]; then
    while read -r app; do
      [ -n "$app" ] && strip+=" $("$CONFIG_DIR/helpers/icon_map.sh" "$app")"
    done <<<"$apps"
    sketchybar --set "space.$ws" label="$strip" label.padding_left=4 label.padding_right=8
  else
    sketchybar --set "space.$ws" label="" label.padding_left=0 label.padding_right=0
  fi
  "$CONFIG_DIR/helpers/workspace_style.sh" "$ws"
done
```

The added line is `"$CONFIG_DIR/helpers/workspace_style.sh" "$ws"` directly after the `if/else`.

- [ ] **Step 2: Syntax-check**

```bash
bash -n ~/.config/sketchybar/plugins/space_windows.sh
```

Expected: no output (clean parse).

---

### Task 4: Reload and verify end-to-end

**Files:**
- None

- [ ] **Step 1: Reload SketchyBar**

```bash
sketchybar --reload
```

Expected: bar re-renders, no plugin errors printed to the session log (`tail -f /tmp/sketchybar_* 2>/dev/null` or `log show --predicate 'process == "sketchybar"' --last 1m` as needed).

- [ ] **Step 2: Verify three states toggling**

For each workspace, check current state via query:

```bash
for ws in 1 2 3 4 5; do
  echo "space.$ws:"
  sketchybar --query space.$ws | grep -oE '(background\.(color|drawing))":"?[^",]*|background\.border_color":"?[^",]*|background\.border_width":[0-9]*'
done
```

Expected mapping:
- Focused workspace → `background.color=0xff89b4fa`, `background.drawing=on`, light border hidden (`background.border_width=0`)
- Populated non-focused workspace → `background.color=0x00000000`, `background.drawing=on`, `background.border_color=0x6689b4fa`, `background.border_width=2`
- Empty workspace → `background.drawing=off`, `background.border_width=0`

- [ ] **Step 3: Live-open a window on empty workspace**

Open any window on an empty workspace (e.g. `open -a Finder` if space is configured to hold it, or move a window via `aerospace` binding). Wait ≤10s (poll interval).

Expected: workspace gains accent border. Close last window; expected: border clears within ~10s.

- [ ] **Step 4: Visual check**

Switch across all 5 workspaces (`aerospace workspace 1..5`).

Expected: focused workspace is solid blues-accent; populated peers are blue-outlined; empty are bare text.

---

## Self-Review

- **Spec coverage:** Colors table (Task 1 helper branches) ✓; idempotent shared helper (Tasks 1-3) ✓; empty unchanged (Task 1 else branch) ✓; border-on-populated with `background.drawing=on` (Task 1) ✓; close-event gap covered by existing 10s poll (Task 4 Step 3) ✓.
- **Placeholder scan:** all steps contain concrete code/commands ✓.
- **Type consistency:** `workspace_style.sh` is the single setter everywhere; focus self-queried via `aerospace list-workspaces --focused`, `$ws` / `space.$ws` naming consistent across tasks ✓.