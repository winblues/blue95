# Desktop Environment Configuration

Blue95 has an opinionated design for its desktop environment and includes automated management for user-level Xfce configuration files.
The component responsible for this configuration management is called `winblues-chezmoi`, which utilizes both [chezmoi](https://www.chezmoi.io) and [xfconf-profile](https://github.com/winblues/xfconf-profile) to manage dotfiles in the user's home directories related to Xfce.

Note that although `winblues-chezmoi` is configurable to exclude updating certain dotfiles and `xfconf` properties, this is meant to be
used sparingly. If you want more control over the appearance of the desktop environment, it is suggested to either disable the `winblues-chezmoi` service and manually manage your own dotfiles or use the base [winblues/vauxite](https://github.com/winblues/vauxite) image instead of Blue95.

## Configuring `winblues-chezmoi`

> [!IMPORTANT]  
> Some of the following configuration settings for `winblues-chezmoi` have not been fully implemented. If you do not want any level of config file management, you can disable the service for the time being.

To disable `winblues-chezmoi` completely, run the following:
```bash
systemctl --user disable winblues-chezmoi.service
```

### Excluding Files

The Xfce desktop environment stores its configuration files in the user's home directory under `~/.config/xfce4`. These files are managed by `winblues-chezmoi`. To configure `winblues-chezmoi` to not manage certain files, create a file called `~/.config/winblues/chezmoiignore`

```bash
# Exclude changes to the terminal config file
.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-terminal.xml 

# Exclude changes to GTK theme overrides
.config/gtk-3.0/gtk.css

# Exclude changes to most files
.config/xfce4/xfconf/xfce-perchannel-xml/*
```
The format of this file can be found in chezmoi's documentation for [.chezmoiignore](https://www.chezmoi.io/reference/special-files/chezmoiignore/).


### Excluding Properties

TODO: xfconf-proile
