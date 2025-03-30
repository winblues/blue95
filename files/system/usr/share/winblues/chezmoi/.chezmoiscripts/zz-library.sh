#!/bin/bash

set -euo pipefail

function exit_if_paths_in_chezmoiignore {
  IGNORE_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/winblues/chezmoiignore"
  CHECK_PATHS="$1"

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
}
