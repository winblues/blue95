#!/bin/bash

set -ouex pipefail

systemctl enable rpm-ostreed-automatic.timer
systemctl enable libvirtd.service
