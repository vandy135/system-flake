# PLACEHOLDER - Replace with actual hardware configuration
# Generate with: nixos-generate-config --show-hardware-config > hardware-configuration.nix
#
# NOTE: Disk management is manual (disko removed).
# Define fileSystems and swapDevices here.
# settings like kernel modules, CPU microcode, etc.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [];

  # Placeholder boot configuration
  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usb_storage" "sd_mod"];
  boot.kernelModules = ["kvm-intel"];

  # NOTE: Define fileSystems and swapDevices here (disko removed).

  # Hardware settings
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
