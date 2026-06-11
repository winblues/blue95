#!/usr/bin/env bash

set -xueo pipefail

TMPDIR=$(mktemp -d)
cd "$TMPDIR"
curl -Lo palemoon.tar.xz "https://www.palemoon.org/download.php?mirror=us&bits=64&type=linuxgtk3"
mkdir -p /usr/opt
cd /usr/opt
tar xf "$TMPDIR/palemoon.tar.xz"
ln -s /usr/opt/palemoon/palemoon /usr/bin/palemoon

cd "$TMPDIR"
EPYRUS_URL=$(curl -s http://www.epyrus.org/download.html \
  | grep -o 'http://www\.epyrus\.org/epyrus-[^"]*linux-x86_64-gtk3\.tar\.xz')
curl -Lo epyrus.tar.xz "$EPYRUS_URL"
cd /usr/opt
tar xf "$TMPDIR/epyrus.tar.xz"
ln -s /usr/opt/epyrus/epyrus /usr/bin/epyrus

rm -rf "$TMPDIR"
