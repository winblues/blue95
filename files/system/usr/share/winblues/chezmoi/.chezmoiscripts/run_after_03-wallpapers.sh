#!/bin/bash
set -exuo pipefail

[[ -n "${WINBLUES_CHEZMOI_ORIGINAL_ENV_FILE-}" ]] && source "${WINBLUES_CHEZMOI_ORIGINAL_ENV_FILE}"

# TODO: check user's config to see if they don't want us to manage wallpapers

function set_solid_color_background {
  workspace_id=$1
  xfconf-query --channel xfce4-desktop --list |
    grep workspace${workspace_id}/color-style |
    xargs -I{} xfconf-query --create -c 'xfce4-desktop' -p '{}' --type 'int' --set '0'

  xfconf-query --channel xfce4-desktop --list |
    grep workspace${workspace_id}/image-style |
    xargs -I{} xfconf-query --create -c 'xfce4-desktop' -p '{}' --type 'int' --set '0'

  xfconf-query --channel xfce4-desktop --list |
    grep workspace${workspace_id}/color-style |
    xargs dirname |
    xargs -I{} xfconf-query --create -c 'xfce4-desktop' -p '{}/rgba1' --type 'double' --set '0' --type 'double' --set '0.50196078431372548' --type 'double' --set '0.50196078431372548' --type 'double' --set '1'
}

function set_tiled_background {
  workspace_id=$1
  image=$2
  xfconf-query --channel xfce4-desktop --list |
    grep "workspace${workspace_id}/color-style" |
    xargs -I{} xfconf-query --create -c 'xfce4-desktop' -p {} --type 'int' --set 0

  xfconf-query --channel xfce4-desktop --list |
    grep "workspace${workspace_id}/image-style" |
    xargs -I{} xfconf-query --create -c 'xfce4-desktop' -p {} --type 'int' --set 2

  xfconf-query --channel xfce4-desktop --list |
    grep "workspace${workspace_id}/last-image" |
    xargs -I{} xfconf-query --create -c 'xfce4-desktop' -p {} --type 'string' --set "$image"
}

function set_stretched_background {
  workspace_id=$1
  image=$2
  xfconf-query --channel xfce4-desktop --list |
    grep "workspace${workspace_id}/color-style" |
    xargs -I{} xfconf-query --create -c 'xfce4-desktop' -p {} --type 'int' --set 0

  xfconf-query --channel xfce4-desktop --list |
    grep "workspace${workspace_id}/image-style" |
    xargs -I{} xfconf-query --create -c 'xfce4-desktop' -p {} --type 'int' --set 3

  xfconf-query --channel xfce4-desktop --list |
    grep "workspace${workspace_id}/last-image" |
    xargs -I{} xfconf-query --create -c 'xfce4-desktop' -p {} --type 'string' --set "$image"
}

# Allow setting a different wallpaper per workspace
xfconf-query --create -c 'xfce4-desktop' -p '/backdrop/single-workspace-mode' --type 'bool' --set 'false'

set_solid_color_background 0
set_tiled_background 1 "/usr/share/backgrounds/Chicago95/Wallpaper/Black Thatch.png"
set_stretched_background 2 "/usr/share/backgrounds/Chicago95/Extras/clouds.jpg"
set_tiled_background 3 "/usr/share/backgrounds/Chicago95/Wallpaper/Setup.png"
