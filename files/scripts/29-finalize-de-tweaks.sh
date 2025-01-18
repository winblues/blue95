#!/usr/bin/env bash

set -ouex pipefail

update-mime-database /usr/share/mime
gdk-pixbuf-query-loaders-64 --update-cache
