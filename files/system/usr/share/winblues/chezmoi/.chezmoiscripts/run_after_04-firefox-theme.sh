#!/bin/bash

set -euo pipefail

[[ -n "${WINBLUES_CHEZMOI_ORIGINAL_ENV_FILE-}" ]] && source "${WINBLUES_CHEZMOI_ORIGINAL_ENV_FILE}"

# New profiles automatically get the theme via Firefox's default profile
# template at /usr/lib64/firefox/browser/defaults/profile/chrome/.
#
# This script handles the upgrade case only: existing profiles that were
# created before the theme was introduced need the chrome/ files copied in.

CHROME_SRC=/usr/lib64/firefox/browser/defaults/profile/chrome
PROFILES_INI="$HOME/.mozilla/firefox/profiles.ini"

if [[ ! -f "$PROFILES_INI" ]]; then
  # No native Firefox profile yet — new profile will get theme on first launch
  exit 0
fi

# Find all profiles and copy theme files into any that are missing chrome/
while IFS='=' read -r key value; do
  if [[ "$key" == "Path" ]]; then
    PROFILE_DIR="$HOME/.mozilla/firefox/${value// /}"
    CHROME_DEST="$PROFILE_DIR/chrome"
    if [[ -d "$PROFILE_DIR" && ! -d "$CHROME_DEST/utils" ]]; then
      echo "Applying win95 Firefox theme to profile: $value"
      mkdir -p "$CHROME_DEST"
      cp -r "$CHROME_SRC/." "$CHROME_DEST/"
    fi
  fi
done < "$PROFILES_INI"
