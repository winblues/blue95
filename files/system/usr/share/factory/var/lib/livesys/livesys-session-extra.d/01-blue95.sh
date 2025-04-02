#!/bin/bash

usermod -c "Chandler Bong" liveuser

function create_desktop_icon {
  app=$1
  rename=$2
  cp /usr/share/applications/${app}.desktop /home/liveuser/Desktop/${app}.desktop
  chmod +x /home/liveuser/Desktop/${app}.desktop
  sed -i "s/^Name=.*$/Name=$rename/" /home/liveuser/Desktop/${app}.desktop
  DESKTOP_CHECKSUM="$(sha256sum /home/liveuser/Desktop/${app}.desktop | awk '{print $1}')"
  sudo -u liveuser dbus-launch gio set -t string /home/liveuser/Desktop/${app}.desktop metadata::xfce-exe-checksum ${DESKTOP_CHECKSUM}
}

create_desktop_icon audacious "Winamp"
create_desktop_icon bauh "Flathub"
