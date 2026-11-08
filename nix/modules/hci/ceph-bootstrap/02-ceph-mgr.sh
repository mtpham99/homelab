#!/usr/bin/env bash
#
# 02-ceph-mgr.sh
#
set -euo pipefail
CEPH_TMPDIR=$(mktemp -d)
trap 'rm -rf "${CEPH_TMPDIR}"' EXIT

CEPH_MGR_ID=$(hostname -s)
install -d -o ceph -g ceph -m 0750 /var/lib/ceph/mgr
CEPH_MGR_DATADIR="/var/lib/ceph/mgr/ceph-${CEPH_MGR_ID}"

if [[ -r "${CEPH_MGR_DATADIR}/keyring" ]]; then
    printf '%s\n' "ceph-mgr already bootstrapped. nothing to do. goodbye..."
    exit 0
fi

printf '%s\n' "creating (or retrieving) keyring for mgr.${CEPH_MGR_ID}..."
ceph auth get-or-create "mgr.${CEPH_MGR_ID}" \
    mon 'allow profile mgr' \
    osd 'allow *' \
    mds 'allow *' \
    -o "${CEPH_TMPDIR}/keyring"

install -d -o ceph -g ceph -m 0750 "${CEPH_MGR_DATADIR}"
install -o ceph -g ceph -m 0600 "${CEPH_TMPDIR}/keyring" "${CEPH_MGR_DATADIR}/keyring"

printf '%s\n' "starting ceph-mgr-${CEPH_MGR_ID}..."
systemctl start "ceph-mgr-${CEPH_MGR_ID}"
printf '%s\n' "ceph-mgr-${CEPH_MGR_ID} bootstrapped and running !"

