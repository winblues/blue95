#!/usr/bin/env bash

set -xueo pipefail

# Fetch
cd /tmp
# TODO: add renovate
CHICAGO95_SHA=3f81fedb7626e69cf6ba32e2e0e6a01c5929e9f9
wget https://github.com/grassmunk/Chicago95/archive/${CHICAGO95_SHA}.zip
unzip -q *.zip
mv Chicago95* /usr/src/chicago95
cd /usr/src/chicago95

# Themes
cp -r Theme/Chicago95 /usr/share/themes

# Icons and cursors
cp -r Icons/* Cursors/* /usr/share/icons/

# Custom app icons
ln -s /usr/share/icons/Chicago95/apps/48/{software,bauh}.png
ln -s /usr/share/icons/Chicago95/apps/48/stock_keyring.png /usr/share/icons/Chicago95/apps/scalable/com.onepassword.OnePassword.png
ln -s /usr/share/icons/Chicago95/apps/scalable/internet-mail.svg /usr/share/icons/Chicago95/apps/scalable/epyrus.svg

# Fonts
cp Fonts/vga_font/LessPerfectDOSVGA.ttf /usr/share/fonts
cp -r Fonts/bitmap/cronyx-cyrillic /usr/share/fonts
fc-cache -fv

# Use Qt instead of GTK if possible
mkdir -p /usr/share/qt5ct/colors
cp Extras/Chicago95_qt.conf /usr/share/qt5ct/colors

# Terminal
mkdir -p /etc/skel/.local/share/xfce4/terminal/colorschemes
cp Extras/Chicago95.theme /etc/skel/.local/share/xfce4/terminal/colorschemes

# Sounds
cp -Rf sounds/Chicago95 /usr/share/sounds/
cp -f "Extras/Microsoft Windows 95 Startup Sound.ogg" /usr/share/sounds/Chicago95/startup.ogg

cp -f ./sounds/chicago95-startup.desktop /etc/skel/.config/autostart

# Backgrounds
cp -Rf ./Extras/Backgrounds /usr/share/backgrounds/Chicago95

# Plymouth
cp -Rf Plymouth/Chicago95 /usr/share/plymouth/themes/
plymouth-set-default-theme Chicago95

# Panel config
cd /usr/share/winblues/chezmoi/dot_local/share/xfce-panel-profile
tar cjf /usr/share/xfce4-panel-profiles/layouts/chicago-95.tar.bz2 config.txt launcher-*
