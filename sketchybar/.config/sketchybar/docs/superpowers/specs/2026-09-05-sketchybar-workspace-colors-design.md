# SketchyBar Workspace Boundary Colors — Design

Date: 2026-09-05

## Problem

On the AeroSpace workspace items (`space.1` … `space.5`), the user cannot tell
which workspaces currently have apps open. Only the focused workspace is
highlighted (solid `0xff7f849c` pill via `plugins/aerospace.sh`); populated but
non-focused workspaces look identical to empty ones.

## Goals

1. Visually enclose every workspace that has apps open (a boundary).
2. Identify the current/focused workspace with a distinct, obvious color.
3. Keep empty workspaces visually quiet (unchanged).

## Design

### Colors

| State | Background | Border | Icon/Label text |
|---|---|---|---|
| Focused | `0xff89b4fa` (solid accent) | none (`border_width=0`) | `0xff11111b` (dark) |
| Populated, non-focused | transparent `0x00000000` | `0x6689b4fa` translucent accent, width 2 | `0xffcdd6f4` (light) |
| Empty | drawing off | none | `0xffcdd6f4` |

Rationale: "blue-outlined = has windows; solid blue = you are here".
The `0x66` alpha border reads as a boundary without competing with the solid
focused fill. Border width 2 is sketchybar's default.

### Architecture

Single idempotent style helper that decides the complete visual state of one
workspace item from queried facts (focus + window count), so event order never
matters:

- New file: `helpers/workspace_style.sh`
  - Args: workspace id.
  - Inputs: focused workspace via `aerospace list-workspaces --focused`
    (queried inside the helper, not the `$FOCUSED_WORKSPACE` env — that env
    only reaches scripts subscribed to the change event, so `space_windows.sh`
    polls would otherwise clobber the focus highlight), window count from
    `aerospace list-windows --workspace <id>`.
  - Output: one `sketchybar --set space.<id>` call setting the FULL state:
    `background.color`, `background.drawing`, `border_color`, `border_width`,
    `icon.color`, `label.color`.

Callers (all just delegate):

- `plugins/aerospace.sh` — replaces its inline highlight with a call to the
  helper for the changed workspace.
- `plugins/space_windows.sh` — after building the app-icon strip, calls the
  helper for all 5 workspaces.
- `sketchybarrc` startup — after items are created, run helper once per
  workspace (the `space_windows.sh` call at the end already covers this).

Because every call sets complete state, whichever script runs last produces the
correct combined result. The focused item is always a solid accent pill,
regardless of population.

### Behavioral notes

- Border on a populated item requires `background.drawing=on` — leaving the
  background color transparent gives a clean outline box.
- Empty items keep `background.drawing=off` as today; no border, no fill.
- App-icon label population in `space_windows.sh` is untouched.
- AeroSpace emits no close event; existing `update_freq=10` poll on
  `space_windows` already re-runs the style helper, so closed-app workspaces
drop their border. `aerospace.sh` also re-applies the style on every workspace
change, covering apps opened on the focused workspace via the strip refresh
path.

## Verification

- `sketchybar --restart` / reload with a mix of empty + populated workspaces.
- Focus each workspace, confirm pill follows.
- Open a window on an empty ws (e.g. via `aerospace` app-launch config), confirm
  border appears; close last window, confirm border disappears.

## Out of scope

- Colors beyond the three states above (no per-app colors in strip).
- Workspace reordering / renames.
- Any change to strip content logic.