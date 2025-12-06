#!/bin/bash
set -ouex pipefail

update-mime-database /usr/share/mime
gdk-pixbuf-query-loaders-64 --update-cache
gtk-update-icon-cache /usr/share/icons/hicolor
gtk-update-icon-cache --force --ignore-theme-index /usr/share/icons/Chicago95

systemctl --global preset-all

# Clean up
rm -rf /tmp/* /tmp/.* 2>/dev/null || true
rm -rf /var/tmp/* /var/tmp/.* 2>/dev/null || true
rm -rf /var/cache/dnf/* 2>/dev/null || true
