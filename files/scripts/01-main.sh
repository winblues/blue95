#!/bin/bash

set -ouex pipefail

systemctl enable libvirtd.service
systemctl --global enable xfconf-profile.service
