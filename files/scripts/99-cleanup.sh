#!/usr/bin/env bash
set -xueo pipefail

sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/tailscale.repo
