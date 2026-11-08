#!/usr/bin/env bash
#
# 03-ceph-osd.sh
#
set -euo pipefail
CEPH_TMPDIR=$(mktemp -d)
trap 'rm -rf "${CEPH_TMPDIR}"' EXIT

usage() {
    cat << EOF
usage: 03-ceph-osd.sh --osd-id <ID> --device <DEVICE>

options:
    -i, --osd-id <ID>       osd id
    -d, --device <DEVICE>   block device path
    -h, --help              display this help message and exit
EOF
}

CEPH_OSD_ID=
CEPH_OSD_DEVICE=
while (( $# )); do
    case $1 in
        -i | --osd-id)
            CEPH_OSD_ID=$2
            shift 2
            ;;
        -d | --device)
            CEPH_OSD_DEVICE=$2
            shift 2
            ;;
        -h | --help)
            usage
            exit 0
            ;;
        *)
            printf '%s\n\n' "invalid argument: '$1'" >&2
            usage >&2
            exit 2
            ;;
    esac
done

install -d -o ceph -g ceph -m 0750 /var/lib/ceph/osd
CEPH_OSD_DATADIR="/var/lib/ceph/osd/ceph-${CEPH_OSD_ID}"
install -d -o ceph -g ceph -m 0750 /var/lib/ceph/bootstrap-osd
CEPH_BOOTSTRAP_OSD_DATADIR=/var/lib/ceph/bootstrap-osd

if [[ -r "${CEPH_OSD_DATADIR}/keyring" ]]; then
    printf '%s\n' "ceph-osd-${CEPH_OSD_ID} already bootstrapped. nothing to do. goodbye..."
    exit 0
fi

if [[ -z ${CEPH_OSD_ID:-} || -z "${CEPH_OSD_DEVICE:-}" ]]; then
    usage >&2
    exit 2
fi
if [[ ! ${CEPH_OSD_ID} =~ ^(0|[1-9][0-9]*)$  ]]; then
    printf '%s\n' "invalid osd id: ${CEPH_OSD_ID}"
    exit 1
fi
if [[ ! -b "${CEPH_OSD_DEVICE}" ]]; then
    printf '%s\n' "${CEPH_OSD_DEVICE} is not a block device. goodbye..." >&2
    exit 1
fi

printf '%s\n' "retrieving bootstrap-osd keyring from cluster..."
ceph auth get client.bootstrap-osd -o "${CEPH_TMPDIR}/ceph.keyring"
install -o ceph -g ceph -m 0600 "${CEPH_TMPDIR}/ceph.keyring" "${CEPH_BOOTSTRAP_OSD_DATADIR}/ceph.keyring"

# '--no-systemd': services are managed by nixos ('ceph-volume-activate' & 'ceph-osd-<id>')
# see: https://docs.ceph.com/en/latest/ceph-volume/lvm/#ceph-volume-lvm
printf '%s\n' "creating osd.${CEPH_OSD_ID} on ${CEPH_OSD_DEVICE}..."
ceph-volume lvm create --osd-id "${CEPH_OSD_ID}" --data "${CEPH_OSD_DEVICE}" --no-systemd --objectstore bluestore

printf '%s\n' "starting ceph-osd-${CEPH_OSD_ID}..."
systemctl start "ceph-osd-${CEPH_OSD_ID}"
printf '%s\n' "ceph-osd-${CEPH_OSD_ID} bootstrapped and running !"

