#!/bin/bash

set -ouex pipefail

systemctl enable rpm-ostreed-automatic.timer
