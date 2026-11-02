#!/usr/bin/env bash
#
# 01-ceph-mon.sh
#
set -euo pipefail
CEPH_TMPDIR=$(mktemp -d)
trap 'rm -rf "${CEPH_TMPDIR}"' EXIT

CEPH_MON_ID=$(hostname -s)
install -d -o ceph -g ceph -m 0750 /var/lib/ceph/mon
CEPH_MON_DATADIR="/var/lib/ceph/mon/ceph-${CEPH_MON_ID}"
CEPH_MON_BOOTSTRAP_KEYRING=${CEPH_MON_BOOTSTRAP_KEYRING:-/run/secrets/rendered/ceph.mon.keyring} # sops-nix managed keyring

if [[ -r "${CEPH_MON_DATADIR}/keyring" ]]; then
    printf '%s\n' "ceph-mon already bootstrapped. nothing to do. goodbye..."
    exit 0
fi

printf '%s\n' "attempting to retrieve monmap from existing cluster..."
CEPH_TIMEOUT=5
if ceph --connect-timeout $CEPH_TIMEOUT mon getmap -o "${CEPH_TMPDIR}/monmap" 2>/dev/null; then
    printf '%s\n' "retrieved monmap from existing cluster..."
else
    printf '%s\n' "existing monitor map not found. creating initial monmap..."

    CEPH_FSID=$(ceph-conf --lookup fsid)
    IFS=', ' read -ra CEPH_MON_HOSTS <<< "$(ceph-conf --lookup mon_initial_members)"
    IFS=', ' read -ra CEPH_MON_IPS <<< "$(ceph-conf --lookup mon_host)"

    monmap_args=()
    for i in "${!CEPH_MON_HOSTS[@]}"; do
        monmap_args+=(
            "--addv"
            "${CEPH_MON_HOSTS[i]}"
            "[v2:${CEPH_MON_IPS[i]}:3300,v1:${CEPH_MON_IPS[i]}:6789]"
        )
    done
    monmaptool --create --fsid "${CEPH_FSID}" "${monmap_args[@]}" "${CEPH_TMPDIR}/monmap"
fi

printf '%s\n' "initializing mon.${CEPH_MON_ID}..."
install -d -o ceph -g ceph -m 0750 "${CEPH_MON_DATADIR}"
ceph-mon --mkfs -i "${CEPH_MON_ID}" --monmap "${CEPH_TMPDIR}/monmap" --keyring "${CEPH_MON_BOOTSTRAP_KEYRING}"
chown -R ceph:ceph "${CEPH_MON_DATADIR}"

printf '%s\n' "starting ceph-mon-${CEPH_MON_ID}..."
systemctl start "ceph-mon-${CEPH_MON_ID}"
printf '%s\n' "ceph-mon-${CEPH_MON_ID} bootstrapped and running !"

