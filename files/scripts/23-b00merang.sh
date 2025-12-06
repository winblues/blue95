#!/usr/bin/env bash

set -oeux pipefail

TMPDIR=$(mktemp -d)
cd "$TMPDIR"
wget https://github.com/B00merang-Project/Windows-95/archive/refs/heads/master.zip
unzip master.zip
mv ./Windows-95-master/gtk-4.0 /usr/share/themes/Chicago95/

rm -rf "$TMPDIR"
