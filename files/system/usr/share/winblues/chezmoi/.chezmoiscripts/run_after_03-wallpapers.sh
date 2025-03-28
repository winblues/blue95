#!/bin/bash
set -exuo pipefail

[[ -n "${WINBLUES_CHEZMOI_ORIGINAL_ENV_FILE-}" ]] && source "${WINBLUES_CHEZMOI_ORIGINAL_ENV_FILE}"

# TODO: check user's config to see if they don't want us to manage wallpapers

# Allow setting a different wallpaper per workspace
xfconf-query --create -c 'xfce4-desktop' -p '/backdrop/single-workspace-mode' --type 'bool' --set 'false'

# Workspace 0 is solid teal
xfconf-query --channel xfce4-desktop --list |
  grep workspace0/color-style |
  xargs -I{} xfconf-query --create -c 'xfce4-desktop' -p '{}' --type 'int' --set '0'

xfconf-query --channel xfce4-desktop --list |
  grep workspace0/image-style |
  xargs -I{} xfconf-query --create -c 'xfce4-desktop' -p '{}' --type 'int' --set '0'

xfconf-query --channel xfce4-desktop --list |
  grep workspace0/color-style |
  xargs dirname |
  xargs -I{} xfconf-query --create -c 'xfce4-desktop' -p '{}/rgba1' --type 'double' --set '0' --type 'double' --set '0.50196078431372548' --type 'double' --set '0.50196078431372548' --type 'double' --set '1'

# The rest of the workspaces are tiled images
images=(
  "/usr/share/backgrounds/Chicago95/Wallpaper/Black Thatch.png"
  "/usr/src/chicago95/Extras/Backgrounds/Wallpaper/Carved Stone.png"
  "/usr/share/backgrounds/Chicago95/Wallpaper/Setup.png"
)

workspace_id=1
for image in "${images[@]}"; do
  xfconf-query --channel xfce4-desktop --list |
    grep "workspace${workspace_id}/color-style" |
    xargs -I{} xfconf-query --create -c 'xfce4-desktop' -p {} --type 'int' --set 0

  xfconf-query --channel xfce4-desktop --list |
    grep "workspace${workspace_id}/image-style" |
    xargs -I{} xfconf-query --create -c 'xfce4-desktop' -p {} --type 'int' --set 2

  xfconf-query --channel xfce4-desktop --list |
    grep "workspace${workspace_id}/last-image" |
    xargs -I{} xfconf-query --create -c 'xfce4-desktop' -p {} --type 'string' --set "$image"

  ((workspace_id++))
done
