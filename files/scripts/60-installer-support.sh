#!/bin/bash

set -uxeo pipefail

sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/ublue-os-staging-fedora-*.repo
dnf5 install -y taidan
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/ublue-os-staging-fedora-*.repo

systemctl enable taidan-initial-setup-reconfiguration.service
