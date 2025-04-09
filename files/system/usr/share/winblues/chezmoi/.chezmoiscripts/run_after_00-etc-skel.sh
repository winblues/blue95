#!/bin/bash

set -euxo pipefail

[[ -n "${WINBLUES_CHEZMOI_ORIGINAL_ENV_FILE-}" ]] && source "${WINBLUES_CHEZMOI_ORIGINAL_ENV_FILE}"

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/winblues"
marker_file="$state_dir/chezmoi-blue95"

# If this is the first time we've run this, disable the service
# and reset the user's configs from /etc/skel
if [[ ! -f "$marker_file" ]]; then
  systemctl --user mask winblues-chezmoi.service

  # Copy pristine user config and apply xfconf-profile
  rsync -av --progress /etc/skel/ $HOME
  xfconf-profile apply --merge=hard /usr/share/xfconf-profile/default.json

  # Remove old state files from other Winblues variants
  rm -f "$state_dir"/chezmoi-*

  mkdir -p "$state_dir"
  touch "$marker_file"
fi
