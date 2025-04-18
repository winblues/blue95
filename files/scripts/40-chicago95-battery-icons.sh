#!/usr/bin/env bash

set -oeux pipefail

cd /usr/share/icons/Chicago95/status/symbolic

declare -A mappings=(
  # 0–10%
  ["battery-level-0-symbolic.png"]="battery-empty-symbolic.png"
  ["battery-level-0-charging-symbolic.png"]="battery-empty-charging-symbolic.png"
  ["battery-level-10-symbolic.png"]="battery-empty-symbolic.png"
  ["battery-level-10-charging-symbolic.png"]="battery-empty-charging-symbolic.png"

  # 20–30%
  ["battery-level-20-symbolic.png"]="battery-low-symbolic.png"
  ["battery-level-20-charging-symbolic.png"]="battery-low-charging-symbolic.png"
  ["battery-level-30-symbolic.png"]="battery-low-symbolic.png"
  ["battery-level-30-charging-symbolic.png"]="battery-low-charging-symbolic.png"

  # 40–60%
  ["battery-level-40-symbolic.png"]="battery-good-symbolic.png"
  ["battery-level-40-charging-symbolic.png"]="battery-good-charging-symbolic.png"
  ["battery-level-50-symbolic.png"]="battery-good-symbolic.png"
  ["battery-level-50-charging-symbolic.png"]="battery-good-charging-symbolic.png"
  ["battery-level-60-symbolic.png"]="battery-good-symbolic.png"
  ["battery-level-60-charging-symbolic.png"]="battery-good-charging-symbolic.png"

  # 70–90%
  ["battery-level-70-symbolic.png"]="battery-full-symbolic.png"
  ["battery-level-70-charging-symbolic.png"]="battery-full-charging-symbolic.png"
  ["battery-level-80-symbolic.png"]="battery-full-symbolic.png"
  ["battery-level-80-charging-symbolic.png"]="battery-full-charging-symbolic.png"
  ["battery-level-90-symbolic.png"]="battery-full-symbolic.png"
  ["battery-level-90-charging-symbolic.png"]="battery-full-charging-symbolic.png"

  # 100%
  ["battery-level-100-symbolic.png"]="battery-full-symbolic.png"
  ["battery-level-100-charged-symbolic.png"]="battery-full-charged-symbolic.png"
)

for target in "${!mappings[@]}"; do
  src="${mappings[$target]}"
  ln -sf "$src" "$target"
done
