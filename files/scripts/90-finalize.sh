#!/bin/bash
set -ouex pipefail

update-mime-database /usr/share/mime
gdk-pixbuf-query-loaders-64 --update-cache
gtk-update-icon-cache --force --ignore-theme-index /usr/share/icons/Chicago95

systemctl --global preset-all
