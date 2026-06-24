#!/bin/bash

set -euo pipefail

[[ -n "${WINBLUES_CHEZMOI_ORIGINAL_ENV_FILE-}" ]] && source "${WINBLUES_CHEZMOI_ORIGINAL_ENV_FILE}"

# New profiles get the win95 theme automatically on first Firefox launch via
# config.js bootstrapping. This script handles the upgrade case: existing
# profiles that predate the theme and won't trigger the bootstrap copy because
# they already have a chrome/ directory with a chrome.manifest.

CHROME_SRC=/usr/lib64/firefox/browser/defaults/profile/chrome

# Firefox uses the XDG path on modern Fedora, legacy path on older systems
PROFILES_DIR=""
for candidate in \
    "${XDG_CONFIG_HOME:-$HOME/.config}/mozilla/firefox" \
    "$HOME/.mozilla/firefox"; do
  if [[ -f "$candidate/profiles.ini" ]]; then
    PROFILES_DIR="$candidate"
    break
  fi
done

if [[ -z "$PROFILES_DIR" ]]; then
  # No profiles yet — first launch will trigger the config.js bootstrap
  exit 0
fi

while IFS='=' read -r key value; do
  [[ "$key" != "Path" ]] && continue
  PROFILE_DIR="$PROFILES_DIR/${value// /}"
  [[ ! -d "$PROFILE_DIR" ]] && continue

  CHROME_DEST="$PROFILE_DIR/chrome"
  UTILS_DEST="$CHROME_DEST/utils"

  if [[ ! -d "$UTILS_DEST" ]]; then
    echo "Applying win95 Firefox theme to profile: $value"
    mkdir -p "$CHROME_DEST"
    cp -r "$CHROME_SRC/." "$CHROME_DEST/"
  fi
done < "$PROFILES_DIR/profiles.ini"
