#!/bin/bash

set -ouex pipefail

systemctl enable libvirtd.service

# Logo for the "About Xfce" app
cp /usr/share/winblues/icons/blue95.png /usr/share/icons/Chicago95/apps/scalable/fedora-logo-icon.png

# This profile will not actually be used by xfconf-profile. We are
# only moving it to the chezmoi target state because we want to apply
# chezmoi changes if this file changes
mkdir -p /usr/share/winblues/chezmoi/dot_local/share/xfconf-profile
cp /usr/share/xfconf-profile/default.json \
  /usr/share/winblues/chezmoi/dot_local/share/winblues-blue95.json

systemctl --global preset-all
