#!/usr/bin/env bash

set -xueo pipefail

curl -Lo /usr/bin/bauh https://github.com/vinifmor/bauh/releases/download/0.10.7/bauh-0.10.7-x86_64.AppImage
chmod +x /usr/bin/bauh
