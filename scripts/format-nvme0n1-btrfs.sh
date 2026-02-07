#!/usr/bin/env bash
set -euo pipefail

# formats nvme0n1 with:
# - 2GiB EFI (FAT32)
# - 32GiB swap
# - remainder btrfs (subvols @, @nix, @home)
# then mounts at /mnt and writes hosts/<host>/hardware-configuration.nix in the system-flake repo.
#
# Usage (from NixOS installer ISO):
#   sudo ./scripts/format-nvme0n1-btrfs.sh --host launchpad
#
# DANGER: This DESTROYS all data on the target disk.

HOST="launchpad"
DISK="/dev/nvme0n1"
MNT="/mnt"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"  # system-flake root

while [[ $# -gt 0 ]]; do
  case "$1" in
    --host)
      HOST="$2"; shift 2 ;;
    --disk)
      DISK="$2"; shift 2 ;;
    --mnt)
      MNT="$2"; shift 2 ;;
    -h|--help)
      sed -n '1,120p' "$0"; exit 0 ;;
    *)
      echo "Unknown arg: $1" >&2; exit 2 ;;
  esac
done

if [[ ! -b "$DISK" ]]; then
  echo "ERROR: disk not found: $DISK" >&2
  exit 1
fi

if [[ "$EUID" -ne 0 ]]; then
  echo "ERROR: run as root (sudo)." >&2
  exit 1
fi

cat <<EOF

=== DANGER ZONE ===
This will ERASE and repartition: ${DISK}
Layout:
  - EFI  (2GiB)  : ${DISK}p1
  - SWAP (32GiB) : ${DISK}p2
  - BTRFS (rest) : ${DISK}p3
Host hardware config target:
  ${REPO_DIR}/hosts/${HOST}/hardware-configuration.nix
Mountpoint:
  ${MNT}
EOF

echo
read -r -p "Type 'ERASE ${DISK}' to continue: " CONFIRM
if [[ "$CONFIRM" != "ERASE ${DISK}" ]]; then
  echo "Aborted."
  exit 1
fi

# Unmount anything currently mounted
set +e
swapoff "${DISK}"p2 2>/dev/null
umount -R "$MNT" 2>/dev/null
set -e

command -v sgdisk >/dev/null || { echo "ERROR: sgdisk not found (package: gptfdisk)" >&2; exit 1; }
command -v parted >/dev/null || { echo "ERROR: parted not found" >&2; exit 1; }
command -v mkfs.fat >/dev/null || { echo "ERROR: mkfs.fat not found (package: dosfstools)" >&2; exit 1; }
command -v mkfs.btrfs >/dev/null || { echo "ERROR: mkfs.btrfs not found (package: btrfs-progs)" >&2; exit 1; }
command -v mkswap >/dev/null || { echo "ERROR: mkswap not found" >&2; exit 1; }

# Wipe partition table + signatures
wipefs -a "$DISK"
sgdisk --zap-all "$DISK"

# Partition
parted -s "$DISK" mklabel gpt
parted -s "$DISK" mkpart ESP fat32 1MiB 2049MiB
parted -s "$DISK" set 1 esp on
parted -s "$DISK" mkpart swap linux-swap 2049MiB 34817MiB
parted -s "$DISK" mkpart root btrfs 34817MiB 100%

# Give kernel a moment to re-read partition table
sleep 1
partprobe "$DISK" || true
sleep 1

EFI_PART="${DISK}p1"
SWAP_PART="${DISK}p2"
ROOT_PART="${DISK}p3"

# Filesystems
mkfs.fat -F 32 -n EFI "$EFI_PART"
mkswap -L swap "$SWAP_PART"
mkfs.btrfs -f -L nixos "$ROOT_PART"

# Mount root and create subvolumes
mkdir -p "$MNT"
mount "$ROOT_PART" "$MNT"

btrfs subvolume create "$MNT/@"
btrfs subvolume create "$MNT/@nix"
btrfs subvolume create "$MNT/@home"

umount "$MNT"

# Remount with subvols
mount -o subvol=@,compress=zstd,noatime "$ROOT_PART" "$MNT"
mkdir -p "$MNT"/{boot,nix,home}
mount -o subvol=@nix,compress=zstd,noatime "$ROOT_PART" "$MNT/nix"
mount -o subvol=@home,compress=zstd,noatime "$ROOT_PART" "$MNT/home"
mount "$EFI_PART" "$MNT/boot"

swapon "$SWAP_PART"

# UUIDs
EFI_UUID="$(blkid -s UUID -o value "$EFI_PART")"
SWAP_UUID="$(blkid -s UUID -o value "$SWAP_PART")"
ROOT_UUID="$(blkid -s UUID -o value "$ROOT_PART")"

if [[ -z "$EFI_UUID" || -z "$SWAP_UUID" || -z "$ROOT_UUID" ]]; then
  echo "ERROR: failed to read UUIDs via blkid" >&2
  exit 1
fi

# Write hardware-configuration.nix into the repo for the host
TARGET_HW="${REPO_DIR}/hosts/${HOST}/hardware-configuration.nix"
if [[ ! -d "${REPO_DIR}/hosts/${HOST}" ]]; then
  echo "ERROR: host directory not found: ${REPO_DIR}/hosts/${HOST}" >&2
  exit 1
fi

cat >"$TARGET_HW" <<EOF
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Root filesystem (Btrfs subvol=@)
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/${ROOT_UUID}";
    fsType = "btrfs";
    options = [ "subvol=@" "compress=zstd" "noatime" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/${ROOT_UUID}";
    fsType = "btrfs";
    options = [ "subvol=@nix" "compress=zstd" "noatime" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/${ROOT_UUID}";
    fsType = "btrfs";
    options = [ "subvol=@home" "compress=zstd" "noatime" ];
  };

  # EFI System Partition
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/${EFI_UUID}";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  # Swap
  swapDevices = [
    { device = "/dev/disk/by-uuid/${SWAP_UUID}"; }
  ];

  # If you plan to hibernate, uncomment:
  # boot.resumeDevice = "/dev/disk/by-uuid/${SWAP_UUID}";
}
EOF

echo
echo "OK: Disk formatted + mounted at ${MNT}"
echo "OK: Wrote hardware config: ${TARGET_HW}"
echo
cat <<EOF
Next:
  1) Ensure this repo is available from the installer environment.
     If you're running this script from inside the system-flake repo on the ISO, you're good.

  2) Run the install:
     nixos-install --flake ${REPO_DIR}#${HOST}

Common flags:
  nixos-install --flake ${REPO_DIR}#${HOST} --no-root-passwd
EOF
