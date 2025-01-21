#!/usr/bin/env bash

set -xueo pipefail

# TODO: package this in COPR instead of installing dev libraries
dnf install -y libXft-devel libXrender-devel libXcomposite-devel libXdamage-devel libXfixes-devel libXext-devel libXinerama-devel libpng-devel libjpeg-turbo-devel giflib-devel
cd /tmp
git clone https://github.com/felixfung/skippy-xd.git
cd skippy-xd
make
make install
dnf remove -y libXft-devel libXrender-devel libXcomposite-devel libXdamage-devel libXfixes-devel libXext-devel libXinerama-devel libpng-devel libjpeg-turbo-devel giflib-devel

systemctl --global enable skippy-xd.service

echo "KillUserProcesses=yes" >> /usr/lib/systemd/logind.conf