#!/bin/bash

set -euo pipefail

. "${WINBLUES_CHEZMOI_ORIGINAL_ENV_FILE}"

xfconf-profile sync
