#!/bin/bash

set -euo pipefail

[[ -n "${WINBLUES_CHEZMOI_ORIGINAL_ENV_FILE-}" ]] && source "${WINBLUES_CHEZMOI_ORIGINAL_ENV_FILE}"

THEME_SRC=/usr/share/winblues/firefox-theme
PROFILES_INI="$HOME/.mozilla/firefox/profiles.ini"

# Nothing to do if Firefox has never been launched yet (no profiles.ini).
# The script is re-run by chezmoi on each login so it will wire up the theme
# the first time Firefox creates a profile.
if [[ ! -f "$PROFILES_INI" ]]; then
  echo "No Firefox profiles.ini found, skipping theme setup"
  exit 0
fi

# Find the path of the default profile.
# profiles.ini uses INI sections like [Profile0]; the default has Default=1.
PROFILE_REL=$(python3 - <<'EOF'
import configparser, sys
ini = configparser.ConfigParser()
ini.read(sys.argv[1] if len(sys.argv) > 1 else "")
for s in ini.sections():
    if ini.get(s, "Default", fallback="0") == "1":
        print(ini.get(s, "Path", fallback=""))
        sys.exit(0)
EOF
"$PROFILES_INI")

if [[ -z "$PROFILE_REL" ]]; then
  echo "Could not determine default Firefox profile, skipping theme setup"
  exit 0
fi

PROFILE_DIR="$HOME/.mozilla/firefox/$PROFILE_REL"
CHROME_DIR="$PROFILE_DIR/chrome"

echo "Setting up win95 Firefox theme in: $PROFILE_DIR"

mkdir -p "$CHROME_DIR/CSS" "$CHROME_DIR/JS" "$CHROME_DIR/utils"

# fx-autoconfig loader (makes Firefox pick up .uc.css / .uc.mjs files)
cp -f "$THEME_SRC/utils/"* "$CHROME_DIR/utils/"

# Theme CSS and JS
cp -f "$THEME_SRC/CSS/"* "$CHROME_DIR/CSS/"
cp -rf "$THEME_SRC/JS/"* "$CHROME_DIR/JS/"
cp -f "$THEME_SRC/userChrome.css" "$CHROME_DIR/userChrome.css"
