#!/usr/bin/env bash

set -eoux pipefail

IMAGE_TAG=latest
IMAGE_REF=ghcr.io/winblues/blue95
IMAGE_REF="${IMAGE_REF##*://}"

# Configure Live Environment
## Remove packages from liveCD to save space
dnf remove -y google-noto-fonts-all ublue-brew ublue-motd || true

systemctl disable rpm-ostree-countme.service
systemctl disable tailscaled.service
systemctl disable bootloader-update.service
systemctl disable brew-upgrade.timer
systemctl disable brew-update.timer
systemctl disable brew-setup.service
systemctl disable rpm-ostreed-automatic.timer
systemctl disable uupd.timer
systemctl disable ublue-system-setup.service
systemctl disable ublue-guest-user.service
systemctl disable check-sb-key.service
systemctl disable flatpak-preinstall.service
systemctl --global disable ublue-flatpak-manager.service
systemctl --global disable podman-auto-update.timer
systemctl --global disable ublue-user-setup.service

# Configure Anaconda

# Install Anaconda WebUI
SPECS=(
  "libblockdev-btrfs"
  "libblockdev-lvm"
  "libblockdev-dm"
  "anaconda-live"
  "anaconda-webui"
  "firefox"
)
dnf install -y "${SPECS[@]}"

# Anaconda Profile Detection

# blue95
tee /etc/anaconda/profile.d/blue95.conf <<'EOF'
# Anaconda configuration file for blue95 latest

[Profile]
# Define the profile.
profile_id = blue95

[Profile Detection]
# Match os-release values
os_id = blue95

[Network]
default_on_boot = FIRST_WIRED_WITH_LINK

[Bootloader]
efi_dir = fedora
menu_auto_hide = True

[Storage]
default_scheme = BTRFS
btrfs_compression = zstd:1
default_partitioning =
    /     (min 1 GiB, max 70 GiB)
    /home (min 500 MiB, free 50 GiB)
    /var  (btrfs)

[User Interface]
custom_stylesheet = /usr/share/anaconda/pixmaps/fedora.css
hidden_spokes =
    NetworkSpoke
    PasswordSpoke
hidden_webui_pages =
    root-password
    network

[Localization]
use_geolocation = False
EOF

# Configure
. /etc/os-release
echo "blue95 release $VERSION_ID ($VERSION_CODENAME)" >/etc/system-release

sed -i 's/ANACONDA_PRODUCTVERSION=.*/ANACONDA_PRODUCTVERSION=""/' /usr/{,s}bin/liveinst || true
sed -i 's|^Icon=.*|Icon=/usr/share/anaconda/pixmaps/fedora-logo-icon.png|' /usr/share/applications/liveinst.desktop || true

# Interactive Kickstart
tee -a /usr/share/anaconda/interactive-defaults.ks <<EOF
ostreecontainer --url=$IMAGE_REF:$IMAGE_TAG --transport=containers-storage --no-signature-verification
%include /usr/share/anaconda/post-scripts/install-configure-upgrade.ks
%include /usr/share/anaconda/post-scripts/disable-fedora-flatpak.ks
%include /usr/share/anaconda/post-scripts/install-flatpaks.ks
EOF

# Signed Images
tee /usr/share/anaconda/post-scripts/install-configure-upgrade.ks <<EOF
%post --erroronfail
bootc switch --mutate-in-place --enforce-container-sigpolicy --transport registry $IMAGE_REF:$IMAGE_TAG
%end
EOF

# Disable Fedora Flatpak
tee /usr/share/anaconda/post-scripts/disable-fedora-flatpak.ks <<'EOF'
%post --erroronfail
systemctl disable flatpak-add-fedora-repos.service
%end
EOF

# Install Flatpaks
tee /usr/share/anaconda/post-scripts/install-flatpaks.ks <<'EOF'
%post --erroronfail --nochroot
deployment="$(ostree rev-parse --repo=/mnt/sysimage/ostree/repo ostree/0/1/0)"
target="/mnt/sysimage/ostree/deploy/default/deploy/$deployment.0/var/lib/"
mkdir -p "$target"
rsync -aAXUHKP /var/lib/flatpak "$target"
%end
EOF
