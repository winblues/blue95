#!/usr/bin/env bash

set -xueo pipefail

RELEASE=41


curl -Lo /etc/yum.repos.d/_copr_ledif-blue95.repo https://copr.fedorainfracloud.org/coprs/ledif/skippy-xd/repo/fedora-"${RELEASE}"/ledif-skippy-xd-fedora-"${RELEASE}".repo

dnf install -y skippy-xd
systemctl --global enable skippy-xd.service

echo "KillUserProcesses=yes" >> /usr/lib/systemd/logind.conf
