build:
  bluebuild build --tempdir /var/tmp recipes/recipe.yml

rebase:
  bluebuild rebase --tempdir /var/tmp recipes/recipe.yml

generate-iso:
  sudo bluebuild generate-iso --iso-name blue95-latest.iso image ghcr.io/ledif/blue95:latest

generate-live-iso:
  #!/bin/bash
  if [ ! -d scratch/titanoboa ]; then
    mkdir -p scratch
    cd scratch
    git clone https://github.com/ublue-os/titanoboa.git
    cd ..
  else
    cd scratch/titanoboa
    git pull
    cd ../../
  fi

  sudo bluebuild build --tempdir /var/tmp recipes/recipe.yml
  cd scratch/titanoboa
  just build localhost/blue95:latest 1 1

# Overwrite xfce4-panel-profile in repo based on current profile
refresh-panel-profile:
  #!/bin/bash
  set -exuo pipefail
  tmptar=$(mktemp -p /tmp blue95-profile.XXXXX)
  xfce4-panel-profiles save $tmptar
  cd files/system/usr/share/winblues/chezmoi/dot_local/share/xfce-panel-profile/
  tar xf $tmptar
  rm $tmptar

test-installer:
  cp files/system/usr/libexec/blue95-installer.py files/system/usr/share/winblues/installer.glade ~/Public/vm-share/
