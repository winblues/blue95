#!/usr/bin/env bash

set -oeux pipefail

cd $(mktemp -d)
curl -Lo paint.zip https://github.com/winblues/paint/archive/refs/heads/main.zip
unzip paint.zip
cd paint-main
make install

cp /usr/share/icons/hicolor/scalable/apps/win.blues.paint.svg /usr/share/icons/Chicago95/apps/scalable/win.blues.paint.svg
