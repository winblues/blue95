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
systemctl --user mask winblues-chezmoi.service
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

[xfconf-profile](https://github.com/winblues/xfconf-profile) is a command-line tool developed specifically for Blue95 and other Xfce-based desktop images in the Winblues organization. The JSON profile that Blue95 uses is stored at `/usr/share/xfconf-profile/default.json` and defines properties for the Blue95 environment, such as:
```json
{
  "properties": {
    "xsettings": {
      "/Net/ThemeName": "Chicago95",
      "/Net/IconThemeName": "Chicago95",
      "/Net/EnableEventSounds": true,
      "/Net/EnableInputFeedbackSounds": true,
      "/Net/SoundThemeName": "Chicago95"
    },
    "xfwm4": {
      "/general/theme": "Chicago95"
    },
    "xfce4-keyboard-shortcuts": {
      "/commands/custom/Super_L": "/usr/bin/xfce4-popup-whiskermenu"
    },
    "xfce4-notifyd": {
      "/theme": "Chicago95",
      "/notify-location": "bottom-right"
    }
}
```

The final step of `winblues-chezmoi` is to call `xfconf-profile` on this JSON profile to update the user's Xfce settings (i.e., `xfconf` properties). You can configure `xfconf-profile` to ignore changes to specific properties and specify the merge strategy between the user's current properties and the defined properties in Blue95. See [Configuration of xfconf-profile](https://github.com/winblues/xfconf-profile/tree/main?tab=readme-ov-file#configuration) for more information.
