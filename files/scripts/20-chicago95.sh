#!/usr/bin/env bash

set -xueo pipefail


# Fetch
cd /tmp
wget https://github.com/grassmunk/Chicago95/archive/31a357c.zip
unzip -q *.zip
mv Chicago95* /usr/share/chicago95
cd /usr/share/chicago95

# Themes
mkdir -p /usr/share/blue95/themes
cp -r Theme/Chicago95 /usr/share/blue95/themes
ln -s /usr/share/blue95/themes/Chicago95 /usr/share/themes/Chicago95
flatpak override --filesystem=/usr/share/blue95/themes/
flatpak override --env=GTK_THEME=Chicago95

# Icons and cursors
cp -r Icons/* Cursors/ /usr/share/icons/

# Fonts
cp Fonts/vga_font/LessPerfectDOSVGA.ttf /usr/share/fonts
cp -r Fonts/bitmap/cronyx-cyrillic /usr/share/fonts
fc-cache -fv

# Sounds
cp -Rf sounds/Chicago95 /usr/share/sounds/
cp -f "Extras/Microsoft Windows 95 Startup Sound.ogg" /usr/share/sounds/Chicago95/startup.ogg

cp -f ./sounds/chicago95-startup.desktop /etc/skel/.config/autostart

# Backgrounds
cp -Rf ./Extras/Backgrounds /usr/share/backChicago95Backgrounds


# Plymouth
cp -Rf Plymouth/Chicago95 /usr/share/plymouth/themes/
plymouth-set-default-theme Chicago95
