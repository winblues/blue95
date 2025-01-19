#!/usr/bin/env bash

set -oeux pipefail

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

# TODO: remove when https://github.com/grassmunk/Chicago95/pull/362 is merged
# Fix missing icons in xfce4-notifyd for volume
cd /usr/share/icons/Chicago95/status/32
for icon in audio-volume-*; do
  cd ../symbolic
  ln -s ../32/$icon $icon
done

update-mime-database /usr/share/mime
gdk-pixbuf-query-loaders-64 --update-cache
