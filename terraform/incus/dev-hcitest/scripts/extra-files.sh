#!/usr/bin/env bash
#
# extra-files.sh
#
# This script is used by the 'nixos-anywhere' terraform module config 'extra_files_script'.
# It is used to create the 'extra_files' directory whose contents are copied into the installation.
#
# See: https://github.com/nix-community/nixos-anywhere/blob/bad98b0685cf47eaeadcaf6787da8b51cf025693/terraform/all-in-one.md?plain=1#L210
#
set -euo pipefail

# stage host's sops/age key
# host age key is stored in sops: "${hostname}_host_keys.age.sk"
install --directory --mode=0755 ./var/lib
install --directory --mode=0700 ./var/lib/sops
(
	umask 0177
	sops --decrypt --extract "['${NODE}_host_keys']['age']['sk']" "$SOPS_FILE" > ./var/lib/sops/keys.txt
	umask 0022
)

# verify host's sops/age key can decrypt secrets
SOPS_AGE_KEY_FILE=./var/lib/sops/keys.txt sops --decrypt "$SOPS_FILE" > /dev/null || exit 1
