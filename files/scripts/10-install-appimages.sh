#!/usr/bin/env bash

set -xueo pipefail

cd $(mktemp -d)
curl -Lo flatpost.zip https://github.com/GloriousEggroll/flatpost/archive/refs/heads/main.zip
unzip flatpost.zip
cd flatpost-main
PYTHON_SITE_PACKAGES=$(python3 -c "import site; print(site.getsitepackages()[-1].replace('lib64', 'lib'))")
make PYTHON_SITE_PACKAGES=$PYTHON_SITE_PACKAGES DESTDIR=/ install

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
