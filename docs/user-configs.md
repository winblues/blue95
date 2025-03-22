# User Config Management

Blue95 has an opinionated design for its desktop environment and includes automated management for user-level Xfce configuration files.
The component responsible for this configuration management is called `winblues-chezmoi`, which utilizes both [chezmoi](https://www.chezmoi.io) and [xfconf-profile](https://github.com/winblues/xfconf-profile) to manage dotfiles in the user's home directories related to Xfce.

Note that although `winblues-chezmoi` is configurable to exclude updating certain dotfiles and `xfconf` properties, this is meant to be
used sparingly. If you want more control over the appearance of the desktop environment, it is suggested to either disable the `winblues-chezmoi` service and manually manage your own dotfiles or use the base [winblues/vauxite](https://github.com/winblues/vauxite) image instead of Blue95.

## Configuring `winblues-chezmoi`

To disable `winblues-chezmoi` completely, run the following:
```bash
systemctl --user disable winblues-chezmoi.service
```

### Excluding files

The Xfce desktop environment stores its configuration files in the user's home directory under `~/.config/xfce4`
