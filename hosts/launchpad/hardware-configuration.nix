# PLACEHOLDER - Replace with actual hardware configuration
# Generate with: nixos-generate-config --show-hardware-config > hardware-configuration.nix
#
# NOTE: When using disko (hardwareModules.disko.enable = true), filesystems are
# defined by disko, so do NOT define fileSystems here. Only add hardware-specific
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

  # NOTE: Filesystems are managed by disko (hardwareModules.disko)
  # Do not define fileSystems here when using disko!

  # Hardware settings
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
