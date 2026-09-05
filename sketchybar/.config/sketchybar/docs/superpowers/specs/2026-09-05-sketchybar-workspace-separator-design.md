# SketchyBar Workspace Separator + Front-App Pill — Design

Date: 2026-09-05

## Problem

`front_app` (focused-app icon + name) sits directly against the last AeroSpace
workspace item (`space.5`). Both use the app-icon font, so an empty `space.5`
(bare "5") makes the focused app read as another workspace-strip entry and the
boundary is invisible. The focused workspace, which should be the visual
anchor, loses distinction to the adjacent pill.

## Goals

1. Always show an explicit break between the workspace cluster and `front_app`,
   regardless of workspace population.
2. Give `front_app` its own quiet pill so it never reads as a workspace strip.
3. Keep the focused workspace as the strongest visual element (the new pill must
   not compete with the solid focused fill).

## Design

Two changes in `sketchybarrc` only (no plugin changes).

### 1. Separator item `space_sep`

A fixed divider between `space.5` and `front_app`, always drawn.

- Font: default (`JetBrainsMono Nerd Font`), `label="│"`.
- Color: `0xff45475a` (Catppuccin surface1) — dim, visible, non-accent.
- `label.padding_left=2` `label.padding_right=2`.
- No background (transparent), no click action.

Positioning: added `left` after the `space.*` loop. To guarantee final order,
`--reorder space.1..5 space_windows space_sep front_app network ...` (existing
left item chain extended with `space_sep`).

Semantic: the dot/pipe is a scale invariant — present whether or not `space.5`
is bordered. If `space.5` is empty, the divider still terminates the cluster.

### 2. Subtle `front_app` pill

Turn on `front_app` background so the pill reads as one self-contained element:

- `background.drawing=on`
- `background.color=0x127f849c` (~7% alpha of Catppuccin overlay1) — a whisper,
  below any solid workspace fill, so the focused workspace stays dominant.
- Existing corner_radius (6 from defaults), height 24.
- Transparent border (`background.border_width=0`), no shadow.
- Icon/label colors untouched (`0xffcdd6f4`).

State in `front_app.sh` (icon/label swap on `front_app_switched`) is unchanged.

## Resulting hierarchy

`[ 1 2 3 | 4 5 ] │ [app-icon name]`  — cluster ends at divider; app pill reads
as separate element. Focused workspace (solid blue) remains the loudest item.

## Verification

- `sketchybar --reload`.
- Query `space_sep`: exists, label `│`, order between `space.5` and `front_app`.
- Query `front_app`: `background.drawing=on`, `background.color=0x127f849c`.
- Visual: switch all 5 workspaces; empty last workspace no longer looks like it
  contains the focused app.

## Out of scope

- Changing `front_app.sh` logic or text.
- Reordering existing left items relative to each other (`network` etc. keep their relative positions; the reorder list only inserts `space_sep` into the chain).
- Colors beyond the two above.