test-local:
  bluebuild rebase --tempdir /var/tmp recipes/recipe.yml

generate-iso:
  sudo bluebuild generate-iso --iso-name blue95-latest.iso image ghcr.io/ledif/blue95:latest

# Overwrite xfce4-panel-profile in repo based on current profile
refresh-panel-profile:
  #!/bin/bash
  set -exuo pipefail
  tmptar=$(mktemp -p /tmp blue95-profile.XXXXX)
  xfce4-panel-profiles save $tmptar
  cd files/system/usr/share/winblues/chezmoi/dot_local/share/xfce-panel-profile/
  tar xf $tmptar
  rm $tmptar

