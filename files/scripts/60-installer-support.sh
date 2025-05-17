#!/bin/bash

set -oue pipefail

systemctl enable taidan-initial-setup-reconfiguration.service
