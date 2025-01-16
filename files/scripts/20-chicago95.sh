#!/usr/bin/env bash

set -xueo pipefail

cd /usr/src
git clone https://github.com/grassmunk/Chicago95.git chicago95

cd chicago95
cp -r Theme/Chicago95 /usr/share/themes/

# Icons and cursors
cp -r Icons/* Cursors/ /usr/share/icons/

# Fonts
cp Fonts/vga_font/LessPerfectDOSVGA.ttf /usr/share/fonts
cp -r Fonts/bitmap/cronyx-cyrillic /usr/share/fonts
fc-cache -fv

flatpak override --env=GTK_THEME=Chicago95

# Plymouth
cp -Rf Plymouth/Chicago95 /usr/share/plymouth/themes/
update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/Chicago95/Chicago95.plymouth 100
update-alternatives --set default.plymouth /usr/share/plymouth/themes/Chicago95/Chicago95.plymouth
