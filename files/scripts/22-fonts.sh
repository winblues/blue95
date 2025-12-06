#!/usr/bin/env bash

set -oeux pipefail

TMPDIR=$(mktemp -d)
cd "$TMPDIR"
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/CascadiaMono.zip
unzip CascadiaMono.zip
mv CaskaydiaMonoNerdFont-Regular.ttf /usr/share/fonts

fc-cache -fv

rm -rf "$TMPDIR"
