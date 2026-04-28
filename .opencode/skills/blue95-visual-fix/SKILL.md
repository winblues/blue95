---
name: blue95-visual-fix
description: Diagnose and fix visual/theming issues in Blue95 (XFCE, Chicago95 GTK theme, icon themes, xfconf defaults) and wire fixes into the build pipeline
---

## What I Do

Guide the full workflow for diagnosing visual regressions or styling bugs in Blue95,
applying fixes, wiring them into the build pipeline and drafting upstream PRs.

---

## Architecture Refresher

- **Chicago95** is pinned by SHA (`CHICAGO95_SHA`) in `files/scripts/20-chicago95.sh`.
- Patches to Chicago95 live as `.diff` files in `files/scripts/` and are applied in
  `20-chicago95.sh` with `patch -p1`.  Reference: `20-chicago95-xfwm4.diff` (xfwm4 theme),
  `20-chicago95-notifyd.diff` (xfce4-notifyd CSS icon fix).
- **xfconf** defaults:
  - New users: `files/system/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/<channel>.xml`
  - Existing users: `files/system/usr/share/xfconf-profile/default.json`
    (applied by `run_after_01-xfconf-profile.sh` via chezmoi on every login)
- **Static files** in `files/system/` map verbatim onto `/` in the image.
- **chezmoi dotfiles** live in `files/system/usr/share/winblues/chezmoi/` and are applied
  per-user on first login (gate: `~/.local/state/winblues/chezmoi-blue95`).
- Prefer `/usr` over `/etc` for system-wide changes; use chezmoi only for true `$HOME`-only
  settings.

---

## Diagnosis Workflow

1. **Identify the GTK widget and CSS node.**


2. **Identify the icon lookup path (if icon-related).**
   - Check `/usr/share/themes/Chicago95/ and `/usr/share/icons/Chicago95/`.

3. **Identify the xfconf key (if a runtime value issue).**
   - `xfconf-query -c <channel> -lv` lists all keys.
   - Cross-reference with the daemon source in `~/Projects/winblues/xfce-mirror/<daemon>/`
     to find the compiled-in default that xfconf will fall back to if the key is absent.
     If the relevant project is not there, clone it (e.g., from https://github.com/xfce-mirror/xfce4-panel.git)

4. **Live-test the fix.**
   - GTK/CSS: copy the relevant file from `/usr/share/themes/Chicago95/` to
     `~/.themes/Chicago95/` (same relative path), edit there, then restart the relevant
     daemon (e.g. `pkill xfce4-notifyd`).
   - xfconf: `xfconf-query -c <channel> -p <key> -s <value> --create -t <type>`.

---

## Fix Pipeline

### GTK / CSS fix

1. Edit the file in `~/Projects/winblues/Chicago95/` (the pinned upstream clone).
2. Generate the diff:
   ```
   cd ~/Projects/winblues/Chicago95
   git diff > ~/Projects/winblues/blue95/files/scripts/20-chicago95-<name>.diff
   ```
3. Add an `apply_patch` call in `files/scripts/20-chicago95.sh` (follow the existing
   pattern for `20-chicago95-xfwm4.diff` / `20-chicago95-notifyd.diff`).
4. Verify the patch applies cleanly with `patch --dry-run -p1`.

### xfconf defaults fix

1. Edit `files/system/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/<channel>.xml`
   (new users).
2. Edit `files/system/usr/share/xfconf-profile/default.json` (existing users).
   Format: `"<channel>/<key>": "<value>"`.
3. Both files must stay in sync — same key, same value.

### Icon theme fix

- Place new/corrected icons under `files/system/usr/share/icons/Chicago95/` at the
  correct category/size path.
- If this is a Chicago95 upstream issue, include it in the `.diff` file instead.

---

## Upstream PR

After confirming the fix works locally:

1. Commit the change in `~/Projects/winblues/Chicago95` on a branch.
2. Draft a PR against `grassmunk/Chicago95` with:
   - **Title**: concise, imperative, e.g. `xfce-notify: force regular icon rendering to prevent symbolic monochrome`
   - **Body**: what was broken, root cause, fix approach, and (if possible) before/after screenshots.
3. Note the new SHA after the upstream PR merges; update `CHICAGO95_SHA` in
   `20-chicago95.sh` and drop the corresponding `.diff` file.

---

## Key Files Quick Reference

| File | Purpose |
|---|---|
| `files/scripts/20-chicago95.sh` | Builds/patches Chicago95; set `CHICAGO95_SHA` here |
| `files/scripts/20-chicago95-*.diff` | Patch files applied against the Chicago95 clone |
| `files/system/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/` | xfconf XML defaults for new users |
| `files/system/usr/share/xfconf-profile/default.json` | xfconf-profile defaults for existing users |
| `files/system/usr/share/winblues/chezmoi/` | Per-user dotfiles (chezmoi, first-login only) |
| `~/Projects/winblues/Chicago95/` | Pinned Chicago95 clone — edit here, then diff |
| `~/.themes/Chicago95/` | Live user override for testing before committing |
| `~/Projects/winblues/xfce-mirror/` | XFCE daemon sources for reading default values |

---

## Common Pitfalls

- **Don't use modern app icon names** (e.g. `org.mozilla.firefox`) — Chicago95 maps
  legacy names (`firefox` → Netscape globe). Using modern names breaks theming.
- **`-symbolic` icons are always monochrome in GTK3** unless you force
  `-gtk-icon-style: regular` in CSS or provide a non-symbolic fallback.
- **xfconf keys not in `default.json` fall back to daemon compiled-in defaults**, which
  may differ from what you expect — always check the source.
- **Patches must be idempotent** — build scripts run in a fresh container with no state.
