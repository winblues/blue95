build:
  bluebuild build --tempdir /var/tmp recipes/recipe.yml

rebase:
  bluebuild rebase --tempdir /var/tmp recipes/recipe.yml

generate-iso:
  sudo bluebuild generate-iso --iso-name blue95-latest.iso image ghcr.io/ledif/blue95:latest

generate-live-iso tag="":
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

  if [[ -z {{ tag }} ]]; then
    image=localhost/blue95:latest
    cp files/system/etc/ublue-os/system-flatpaks.list scratch/titanoboa/src/flatpaks.example.txt
    sudo bluebuild build --tempdir /var/tmp recipes/recipe.yml
  else
    image=ghcr.io/winblues/blue95:{{ tag }}
    sudo podman pull $image
    sudo podman run cat /etc/ublue-os/system-flatpaks.list > scratch/titanoboa/src/flatpaks.example.txt
  fi
  cd scratch/titanoboa
  just build $image 1 1

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
