#!/usr/bin/env bash

set -oeux pipefail

URLS=(
  "https://archive.org/download/microsoft-windows-wallpapers-pictures/1-2.%20Windows%203.1x%20and%20NT%203.x/256color%20%28large%29.bmp"
  "https://archive.org/download/microsoft-windows-wallpapers-pictures/1-2.%20Windows%203.1x%20and%20NT%203.x/Concrete.bmp"
  "https://archive.org/download/microsoft-windows-wallpapers-pictures/1-2.%20Windows%203.1x%20and%20NT%203.x/FLOCK.BMP"
  "https://archive.org/download/microsoft-windows-wallpapers-pictures/1-2.%20Windows%203.1x%20and%20NT%203.x/SLASH.BMP"
  "https://archive.org/download/microsoft-windows-wallpapers-pictures/1-2.%20Windows%203.1x%20and%20NT%203.x/SPOTS.BMP"
  "https://archive.org/download/microsoft-windows-wallpapers-pictures/1-2.%20Windows%203.1x%20and%20NT%203.x/STEEL.BMP"
  "https://archive.org/download/microsoft-windows-wallpapers-pictures/1-2.%20Windows%203.1x%20and%20NT%203.x/TARTAN.BMP"
  "https://archive.org/download/microsoft-windows-wallpapers-pictures/1-2.%20Windows%203.1x%20and%20NT%203.x/arcade.bmp"
  "https://archive.org/download/microsoft-windows-wallpapers-pictures/1-2.%20Windows%203.1x%20and%20NT%203.x/arches.bmp"
  "https://archive.org/download/microsoft-windows-wallpapers-pictures/1-2.%20Windows%203.1x%20and%20NT%203.x/argyle.bmp"
  "https://archive.org/download/microsoft-windows-wallpapers-pictures/1-2.%20Windows%203.1x%20and%20NT%203.x/ball.bmp"
  "https://archive.org/download/microsoft-windows-wallpapers-pictures/1-2.%20Windows%203.1x%20and%20NT%203.x/cars.bmp"
  "https://archive.org/download/microsoft-windows-wallpapers-pictures/1-2.%20Windows%203.1x%20and%20NT%203.x/castle.bmp"
  "https://archive.org/download/microsoft-windows-wallpapers-pictures/1-2.%20Windows%203.1x%20and%20NT%203.x/chitz.bmp"
  "https://archive.org/download/microsoft-windows-wallpapers-pictures/1-2.%20Windows%203.1x%20and%20NT%203.x/egypt.bmp"
  "https://archive.org/download/microsoft-windows-wallpapers-pictures/1-2.%20Windows%203.1x%20and%20NT%203.x/honey.bmp"
  "https://archive.org/download/microsoft-windows-wallpapers-pictures/1-2.%20Windows%203.1x%20and%20NT%203.x/leaves.bmp"
  "https://archive.org/download/microsoft-windows-wallpapers-pictures/1-2.%20Windows%203.1x%20and%20NT%203.x/marble.bmp"
  "https://archive.org/download/microsoft-windows-wallpapers-pictures/1-2.%20Windows%203.1x%20and%20NT%203.x/redbrick.bmp"
  "https://archive.org/download/microsoft-windows-wallpapers-pictures/1-2.%20Windows%203.1x%20and%20NT%203.x/rivets.bmp"
  "https://archive.org/download/microsoft-windows-wallpapers-pictures/1-2.%20Windows%203.1x%20and%20NT%203.x/squares.bmp"
  "https://archive.org/download/microsoft-windows-wallpapers-pictures/1-2.%20Windows%203.1x%20and%20NT%203.x/thatch.bmp"
  "https://archive.org/download/microsoft-windows-wallpapers-pictures/1-2.%20Windows%203.1x%20and%20NT%203.x/winlogo.bmp"
  "https://archive.org/download/microsoft-windows-wallpapers-pictures/1-2.%20Windows%203.1x%20and%20NT%203.x/zigzag.bmp"
  "https://archive.org/download/microsoft-windows-wallpapers-pictures/1-1.%20Windows%203.0/BOXES.BMP"
  "https://archive.org/download/microsoft-windows-wallpapers-pictures/1-1.%20Windows%203.0/CHESS.BMP"
  "https://archive.org/download/microsoft-windows-wallpapers-pictures/1-1.%20Windows%203.0/PAPER.BMP"
  "https://archive.org/download/microsoft-windows-wallpapers-pictures/1-1.%20Windows%203.0/PARTY.BMP"
  "https://archive.org/download/microsoft-windows-wallpapers-pictures/1-1.%20Windows%203.0/PYRAMID.BMP"
  "https://archive.org/download/microsoft-windows-wallpapers-pictures/1-1.%20Windows%203.0/RIBBONS.BMP"
  "https://archive.org/download/microsoft-windows-wallpapers-pictures/1-1.%20Windows%203.0/WEAVE.BMP"
)

TARGET_DIR="/usr/share/backgrounds/Chicago95/Wallpaper"

printf "%s\n" "${URLS[@]}" | xargs -n 1 -P 10 -I{} wget -P "$TARGET_DIR" "{}"
