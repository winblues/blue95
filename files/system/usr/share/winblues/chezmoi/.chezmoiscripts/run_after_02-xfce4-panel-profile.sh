#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/zz-library.sh"

[[ -n "${WINBLUES_CHEZMOI_ORIGINAL_ENV_FILE-}" ]] && source "${WINBLUES_CHEZMOI_ORIGINAL_ENV_FILE}"

CHECK_PATHS=("$HOME/.config/xfce4/panel" "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml")
exit_if_paths_in_chezmoiignore "$CHECK_PATHS"

# TODO: also check xfconf-profile exclude settings

xfce4-panel-profiles load /usr/share/xfce4-panel-profiles/layouts/chicago-95.tar.bz2
