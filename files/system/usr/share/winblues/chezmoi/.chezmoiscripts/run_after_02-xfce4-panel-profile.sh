#!/bin/bash

set -euo pipefail

[[ -n "${WINBLUES_CHEZMOI_ORIGINAL_ENV_FILE-}" ]] && source "${WINBLUES_CHEZMOI_ORIGINAL_ENV_FILE}"

IGNORE_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/winblues/chezmoiignore"
CHECK_PATHS=("$HOME/.config/xfce4/panel" "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml")

if [[ -f "$IGNORE_FILE" ]]; then
  while IFS= read -r pattern; do
    # Skip empty lines and comments
    [[ -z "$pattern" || "$pattern" == \#* ]] && continue

    # Check if the pattern matches any of the specified paths
    for path in "${CHECK_PATHS[@]}"; do
      if [[ "$path" == $HOME/$pattern || "$path" == $HOME/$pattern/* ]]; then
        echo "Execution aborted due to user's ignore settings."
        echo "Matched pattern: $pattern"
        exit 0
      fi
    done
  done <"$IGNORE_FILE"
fi

# TODO: also check xfconf-profile exclude settings

xfce4-panel-profiles load /usr/share/xfce4-panel-profiles/layouts/chicago-95.tar.bz2
