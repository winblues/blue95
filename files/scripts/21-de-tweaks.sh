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

# Fix Wifi icons in NetworkManager applet (nm-applet)
for i in 16 24 32 48; do
    j=$i
    if [[ ! -f /usr/share/icons/Chicago95/status/$j/network-cellular-signal-good-symbolic.png  ]]; then
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

update-mime-database /usr/share/mime
gdk-pixbuf-query-loaders-64 --update-cache
