#!/usr/bin/env bash

set -xueo pipefail

diff=$(realpath 20-chicago95.diff)

# Fetch
cd /tmp
# TODO: add renovate
CHICAGO95_SHA=9d9f9bcf8c5f35a8ddd5d5e8b764adf547a17c29
wget https://github.com/grassmunk/Chicago95/archive/${CHICAGO95_SHA}.zip
unzip -q *.zip
mv Chicago95* /usr/src/chicago95
cd /usr/src/chicago95

# TODO: upstream this patch
patch -p1 <$diff

# Themes
cp -r Theme/Chicago95 /usr/share/themes

# Icons and cursors
cp -r Icons/* Cursors/* /usr/share/icons/

# Custom app icons
ln -s /usr/share/icons/Chicago95/apps/48/{software,bauh}.png
ln -s /usr/share/icons/Chicago95/apps/48/stock_keyring.png /usr/share/icons/Chicago95/apps/scalable/1password.png
ln -s /usr/share/icons/Chicago95/apps/scalable/internet-mail.svg /usr/share/icons/Chicago95/apps/scalable/epyrus.svg
ln -s /usr/share/icons/Chicago95/apps/scalable/xfwm4.svg /usr/share/icons/Chicago95/apps/scalable/virt-manager.svg
ln -s /usr/share/icons/Chicago95/apps/scalable/multimedia-video-player.svg /usr/share/icons/Chicago95/apps/scalable/io.mpv.Mpv.svg
ln -s /usr/share/icons/Chicago95/apps/scalable/com.visualstudio.code.svg /usr/share/icons/Chicago95/apps/scalable/org.kde.kate.svg
ln -s /usr/share/icons/Chicago95/emotes/32/face-cool.png /usr/share/icons/Chicago95/apps/scalable/com.tomjwatson.Emote.png

# TODO: upstream these?
cp /usr/share/winblues/icons/napster.svg /usr/share/icons/Chicago95/apps/scalable/com.spotify.Client.svg
cp /usr/share/winblues/icons/obsidian.png /usr/share/icons/Chicago95/apps/scalable/md.obsidian.Obsidian.svg
cp /usr/share/winblues/icons/mirc.svg /usr/share/icons/Chicago95/apps/scalable/com.discordapp.Discord.svg
cp /usr/share/winblues/icons/bob.png /usr/share/icons/Chicago95/apps/scalable/win.blues.Bob.png

# All of the palemoon icons are different for different sizes - just keep the scalable one
find /usr/share/icons/Chicago95/apps/ -name "palemoon*" -not -path "*/scalable/*" -delete

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

# LibreOffice
function install_libreoffice_extension() {
  TOPDIR=/usr/src/chicago95/Extras/libreoffice-chicago95-iconset
  IMAGES_ZIP_SDIR="${TOPDIR}"/iconsets/c95
  EXT_ZIP_SDIR="${TOPDIR}"/Chicago95-theme
  OUTDIR="${TOPDIR}"

  pushd "${IMAGES_ZIP_SDIR}"
  zip -r "${OUTDIR}/images_chicago95.zip" *
  mkdir -p "${EXT_ZIP_SDIR}/iconsets"
  mv -f "${OUTDIR}/images_chicago95.zip" "${EXT_ZIP_SDIR}/iconsets/"
  cd "${EXT_ZIP_SDIR}"
  zip -r "${OUTDIR}/Chicago95-theme-0.0.oxt" *

  mkdir -p /usr/share/libreoffice/extensions
  mv "${OUTDIR}/Chicago95-theme-0.0.oxt" /usr/share/libreoffice/extensions
  rm -rf "${EXT_ZIP_SDIR}/iconsets"
  popd
}

install_libreoffice_extension

# Plymouth
cp -Rf Plymouth/Chicago95 /usr/share/plymouth/themes/
plymouth-set-default-theme Chicago95

# Panel config
cd /usr/share/winblues/chezmoi/dot_local/share/xfce-panel-profile
tar cjf /usr/share/xfce4-panel-profiles/layouts/chicago-95.tar.bz2 config.txt launcher-*
