#!/usr/bin/env bash

set -xueo pipefail

cd /usr/src
git clone https://github.com/grassmunk/Chicago95.git chicago95

cd chicago95
cp -r Theme/Chicago95 /usr/share/themes/
cp -r Icons/* /usr/share/icons/
cp Fonts/vga_font/LessPerfectDOSVGA.ttf /usr/share/fonts
fc-cache -fv
