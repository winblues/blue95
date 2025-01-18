#!/usr/bin/env python3

from pathlib import Path
import cairosvg

# This script is meant to add missing icons for some sizes
SIZES_TO_PROCESS = ["48"]

base = Path("/usr/share/icons/Chicago95")

# Get all icon sizes
all_sizes = set()
for category_dir in base.iterdir():
  if not category_dir.is_dir():
    continue

  for d in category_dir.iterdir():
    if d.name[0].isdigit():
      all_sizes.add(d.name)


for category_dir in base.iterdir():
  if not category_dir.is_dir():
    continue

  # Create set of icons for all sizes in this category
  icons_for_all_sizes = set()
  for size in all_sizes:
    size_dir = category_dir / size
    if size_dir.is_dir():
        for icon in size_dir.iterdir():
            icons_for_all_sizes.add(icon.name)

  # For each size, check which sizes don't exist in this category
  for size in SIZES_TO_PROCESS:
    size_dir = category_dir / size
    if not size_dir.is_dir():
        size_dir.mkdir()

    for icon in icons_for_all_sizes:
      out_png = size_dir / icon
      in_svg = Path(category_dir / "scalable" / f"{Path(icon).stem}.svg")

      if not out_png.exists() and in_svg.exists():
        print(f"-- Creating {out_png}")
        cairosvg.svg2png(url=str(in_svg), write_to=str(out_png), output_width=int(size), output_height=int(size))

