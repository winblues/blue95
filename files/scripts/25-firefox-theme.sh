#!/usr/bin/env bash

set -xueo pipefail

# win95-themes: Windows 95 browser chrome for Firefox
# fx-autoconfig: userscript/CSS loader required by win95-themes
#
# Pinned SHAs — bump these together when Firefox breaks the theme.
# win95-themes tracks Nightly so breakage is usually caught and fixed quickly.
WIN95_SHA=d1d459c78939370beb524f845cccd46094ea3704   # v2.3.0
FXAC_SHA=54f88294ea70f1d13ded482351da068d5f21c004

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TMPDIR=$(mktemp -d)
cd "$TMPDIR"

# ---------------------------------------------------------------------------
# Build win95-themes CSS
# ---------------------------------------------------------------------------
dnf install -y nodejs

wget -q "https://github.com/ricewind012/win95-themes/archive/${WIN95_SHA}.zip" -O win95.zip
unzip -q win95.zip
WIN95_DIR="win95-themes-${WIN95_SHA}"
cd "$WIN95_DIR"
npm install --prefer-offline
npm run build firefox agent
npm run build firefox author
npm run build firefox global
cd "$TMPDIR"

# ---------------------------------------------------------------------------
# Fetch fx-autoconfig
# ---------------------------------------------------------------------------
wget -q "https://github.com/MrOtherGuy/fx-autoconfig/archive/${FXAC_SHA}.zip" -O fxac.zip
unzip -q fxac.zip
FXAC_DIR="fx-autoconfig-${FXAC_SHA}"

# ---------------------------------------------------------------------------
# Install fx-autoconfig program files → overlay onto Firefox install
# These make Firefox load userscripts/CSS from any profile's chrome/ dir
# ---------------------------------------------------------------------------
cp "$SCRIPT_DIR/25-firefox-theme.js" /usr/lib64/firefox/config.js
mkdir -p /usr/lib64/firefox/defaults/pref
cp "$FXAC_DIR/program/defaults/pref/config-prefs.js" \
   /usr/lib64/firefox/defaults/pref/config-prefs.js

# ---------------------------------------------------------------------------
# Install theme files into Firefox's default profile template.
# Firefox copies this directory into every new profile on first launch,
# so the theme is applied automatically without any per-user setup.
# The chezmoi script handles the upgrade case (existing profiles).
# ---------------------------------------------------------------------------
PROFILE_TEMPLATE=/usr/lib64/firefox/browser/defaults/profile
CHROME_DEST="$PROFILE_TEMPLATE/chrome"
mkdir -p "$CHROME_DEST/CSS/colors" "$CHROME_DEST/JS/userscript" "$CHROME_DEST/utils"

# Compiled CSS
cp "$WIN95_DIR/dist/firefox_agent.css"  "$CHROME_DEST/CSS/win95_agent.uc.css"
cp "$WIN95_DIR/dist/firefox_global.css" "$CHROME_DEST/CSS/firefox_global.uc.css"
# Color theme files (imported by firefox_global.uc.css as relative "colors/..." paths)
cp "$WIN95_DIR/src/shared/colors/"*.css "$CHROME_DEST/CSS/colors/"
# userChrome.css: loaded by Firefox natively (not via fx-autoconfig) from the chrome root.
# Its relative @import "./CSS/firefox_global.uc.css" resolves correctly from here.
# Do NOT also place firefox_author.css in CSS/ — fx-autoconfig would load it via a chrome://
# URL where the same relative import resolves to a nonexistent double-nested path.
cp "$WIN95_DIR/dist/firefox_author.css" "$CHROME_DEST/userChrome.css"
# Blue95: bump UI font size from Win95's original 11px to 14px for readability
# on modern displays. This overrides --text-ui-size via cascade (later :root wins).
cat >> "$CHROME_DEST/userChrome.css" << 'CSSEOF'

/* Blue95: increase UI font size for readability on modern displays */
:root { --text-ui-size: 14px; }
CSSEOF

# JS userscript and its imports
cp "$WIN95_DIR/src/firefox/win95_main.uc.mjs"          "$CHROME_DEST/JS/"
cp "$WIN95_DIR/src/firefox/userscript/prefs.js"        "$CHROME_DEST/JS/userscript/"
cp "$WIN95_DIR/src/firefox/userscript/resizer.js"      "$CHROME_DEST/JS/userscript/"

# fx-autoconfig profile utils (the actual script loader)
cp "$FXAC_DIR/profile/chrome/utils/"* "$CHROME_DEST/utils/"

# ---------------------------------------------------------------------------
# System-wide Firefox preferences
# Applied to all profiles; user.js written by chezmoi can still override.
# ---------------------------------------------------------------------------
cat > /usr/lib64/firefox/browser/defaults/preferences/blue95-firefox.js << 'EOF'
// Blue95: enable userChrome.css and userscripts
pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// Win95 theme requirements
pref("ui.prefersReducedMotion", 1);
pref("widget.gtk.overlay-scrollbars.enabled", false);
pref("widget.non-native-theme.scrollbar.size.override", 16);
pref("widget.non-native-theme.scrollbar.style", 4);
pref("browser.tabs.tabMinWidth", 120);
pref("browser.theme.dark-private-windows", false);
pref("browser.urlbar.trimURLs", false);
pref("identity.fxaccounts.enabled", false);

// Required for sidebar theming; may be removed by Mozilla eventually
pref("sidebar.revamp", true);

// Win95 color theme (controls which colors/ CSS is loaded)
pref("win95.colors", "win2000");

// Let xfwm4/Chicago95 draw the Win95-style WM title bar instead of Firefox CSD
pref("browser.tabs.inTitlebar", 0);

// Show text labels on toolbar buttons (classic Win95 IE style)
pref("win95.navbar-button-labels", true);
EOF

# ---------------------------------------------------------------------------
# Clean up — nodejs should not be in the final image
# ---------------------------------------------------------------------------
dnf remove -y nodejs
dnf autoremove -y
rm -rf "$TMPDIR"
