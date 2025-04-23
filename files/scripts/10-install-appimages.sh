#!/usr/bin/env bash

set -xueo pipefail

cd /tmp
curl -Lo palemoon.tar.xz "https://www.palemoon.org/download.php?mirror=us&bits=64&type=linuxgtk3"
mkdir -p /usr/opt
cd /usr/opt
tar xf /tmp/palemoon.tar.xz
ln -s /usr/opt/palemoon/palemoon /usr/bin/palemoon

cd /tmp
curl -Lo epyrus.tar.xz https://www.addons.epyrus.org/download/epyrus-2.1.3.linux-x86_64-gtk3.tar.xz
cd /usr/opt
tar xf /tmp/epyrus.tar.xz
ln -s /usr/opt/epyrus/epyrus /usr/bin/epyrus
