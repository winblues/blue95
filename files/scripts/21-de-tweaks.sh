#!/usr/bin/env bash

set -oeux pipefail

# Logo for the "About Xfce" app
cp /usr/share/winblues/icons/blue95.png /usr/share/icons/Chicago95/apps/scalable/fedora-logo-icon.png

# TODO: see if we can upstream any of this

# Battery panel icon tweaks (stay on full icon from 100% to 90%)
cd /usr/share/icons/Chicago95
for f in $(find . -name "battery-level-90*"); do
  cd /usr/share/icons/Chicago95/$(dirname $f)
  icon_name=$(basename $f)

  if [[ ! $icon_name == *"charging"* ]]; then
    rm $icon_name
    ln -s ${icon_name/90/100} $icon_name
  fi
done

# Add LibreOffice Flatpak icons
cd /usr/share/icons/Chicago95
declare -A icon_map=(
  ["libreoffice-base"]="org.libreoffice.LibreOffice.base"
  ["libreoffice-calc"]="org.libreoffice.LibreOffice.calc"
  ["libreoffice-draw"]="org.libreoffice.LibreOffice.draw"
  ["libreoffice-impress"]="org.libreoffice.LibreOffice.impress"
  ["libreoffice-main"]="org.libreoffice.LibreOffice.startcenter"
  ["libreoffice-math"]="org.libreoffice.LibreOffice.math"
  ["libreoffice-writer"]="org.libreoffice.LibreOffice.writer"
)

for old_name in "${!icon_map[@]}"; do
  for icon_path in $(find . -name "${old_name}.png"); do
    new_icon_path="${icon_path%/*}/${icon_map[$old_name]}.png"
    if [[ ! -f "$new_icon_path" ]]; then
      ln -s "$(basename "$icon_path")" "$new_icon_path"
    fi
  done
done

# Fix Wifi icons in NetworkManager applet (nm-applet)
for i in 16 24 32 48; do
  j=$i
  if [[ ! -f /usr/share/icons/Chicago95/status/$j/network-cellular-signal-good-symbolic.png ]]; then
    j=32
  fi
  cd /usr/share/icons/Chicago95/status/$j

  cp network-cellular-signal-none-symbolic.png ../../panel/$i/nm-signal-00.png
  cp network-cellular-signal-none-symbolic.png ../../panel/$i/nm-signal-0.png
  cp network-cellular-signal-none-symbolic.png ../../panel/$i/nm-signal-0-secure.png
  cp network-cellular-signal-weak-symbolic.png ../../panel/$i/nm-signal-25.png
  cp network-cellular-signal-weak-symbolic.png ../../panel/$i/nm-signal-25-secure.png
  cp network-cellular-signal-ok-symbolic.png ../../panel/$i/nm-signal-50.png
  cp network-cellular-signal-ok-symbolic.png ../../panel/$i/nm-signal-50-secure.png
  cp network-cellular-signal-good-symbolic.png ../../panel/$i/nm-signal-75.png
  cp network-cellular-signal-good-symbolic.png ../../panel/$i/nm-signal-75-secure.png
  cp network-cellular-signal-excellent-symbolic.png ../../panel/$i/nm-signal-100.png
  cp network-cellular-signal-excellent-symbolic.png ../../panel/$i/nm-signal-100-secure.png
done

# Small MenuLibre icons fix
ln -s /usr/share/icons/Chicago95/places/scalable/folder_open.svg /usr/share/icons/Chicago95/status/scalable/folder-open-symbolic.svg

update-mime-database /usr/share/mime
gdk-pixbuf-query-loaders-64 --update-cache
gtk-update-icon-cache --force --ignore-theme-index /usr/share/icons/Chicago95

# Extra wallpapers
mkdir -p /usr/share/backgrounds/Chicago95/Extras
curl -Lo /usr/share/backgrounds/Chicago95/Extras/clouds.jpg https://i.imgur.com/98qaCGo.jpeg
