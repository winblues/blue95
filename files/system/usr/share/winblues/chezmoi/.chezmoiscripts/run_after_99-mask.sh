#!/bin/bash

set -euxo pipefail

[[ -n "${WINBLUES_CHEZMOI_ORIGINAL_ENV_FILE-}" ]] && source "${WINBLUES_CHEZMOI_ORIGINAL_ENV_FILE}"

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/winblues"
marker_file="$state_dir/chezmoi-blue95"

if [[ ! -f "$marker_file" ]]; then
  systemctl --user mask winblues-chezmoi.service

  # Remove old state files from other Winblues variants
  rm -f "$state_dir"/chezmoi-*

  mkdir -p "$state_dir"
  touch "$marker_file"
fi
