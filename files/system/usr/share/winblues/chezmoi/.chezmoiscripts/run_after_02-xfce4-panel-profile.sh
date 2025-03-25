#!/bin/bash

set -euo pipefail

echo "Skipping xfce4-panel-profiles for now"
exit 0

xfce4-panel-profiles load /usr/share/xfce4-panel-profiles/layouts/chicago-95.tar.bz2
