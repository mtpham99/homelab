#!/usr/bin/env bash
#
# hciadmin-ssh-agent-wrap.sh
#
# Wrapper script to execute a command with 'hci-admin' ssh key loaded via `ssh-agent`
#
set -euo pipefail
eval "$(ssh-agent -s)" > /dev/null
trap 'ssh-agent -k > /dev/null' EXIT
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

SOPS_FILE="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel)/secrets/hcitest.enc.yaml"
sops --decrypt --extract "['hci_admin_keys']['ssh']['sk']" "$SOPS_FILE" | ssh-add -q -

"$@"
