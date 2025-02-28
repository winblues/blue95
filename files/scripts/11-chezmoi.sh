#!/bin/bash

set -euo pipefail

mkdir -p /usr/share/winblues/chezmoi/dot_local/share/xfconf-profile
cp /usr/share/xfconf-profile/default.json /usr/share/winblues/chezmoi/dot_local/share/winblues-blue95.json
