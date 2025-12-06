#!/bin/bash
set -ouex pipefail

update-mime-database /usr/share/mime
gdk-pixbuf-query-loaders-64 --update-cache
gtk-update-icon-cache /usr/share/icons/hicolor
gtk-update-icon-cache --force --ignore-theme-index /usr/share/icons/Chicago95

systemctl --global preset-all

# Clean up temporary files and build artifacts
find /tmp -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null || true
find /var/tmp -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null || true

rm -rf /var/cache/dnf/* 2>/dev/null || true
rm -rf /var/lib/dnf/* 2>/dev/null || true

rm -rf /run/* 2>/dev/null || true

# No idea where these come from, but try to remove them here to fix broken installer
rm -f /nvim.root 2>/dev/null || true
rm -f /dnf 2>/dev/null || true
rm -rf /selinux-policy 2>/dev/null || true

cd /
for file in .wget-hsts* .wget-hpkp* .wh.* .*_lck_*; do
  rm -rf "$file" 2>/dev/null || true
done
