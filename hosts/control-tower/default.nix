{
  config,
  pkgs,
  inputs,
  pkgs-unstable,
  ...
}: {
  imports = [
    ../../modules/nixos/desktop
    ../../modules/nixos/system     # System essentials (audio, bluetooth, utils)
    ../../modules/nixos/hardware   # Hardware (graphics, disko)
  ];

  # Disk partitioning (disko)
  # ⚠️  CHANGE THIS to your actual disk device before installation!
  hardwareModules.disko = {
    enable = true;
    device = "/dev/sda";  # ← Change this to your disk!
    swapSize = "16G";     # Adjust for your RAM
  };

  # Hardware platform (adjust for your CPU)
  nixpkgs.hostPlatform = "x86_64-linux";
  boot.initrd.availableKernelModules = ["ahci" "xhci_pci" "usb_storage" "sd_mod"];
  boot.kernelModules = ["kvm-intel"];  # Or kvm-amd for AMD

  # Desktop
  desktop.niri.enable = true;
  desktop.greetd.enable = true;

  # System Essentials (PipeWire, Bluetooth, utilities)
  systemModules.essentials.enable = true;

  # System
  system.stateVersion = "25.11";
  nixpkgs.config.allowUnfree = true;

  # Nix settings
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    auto-optimise-store = true;
  };

  # Bootloader (adjust for your system)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "control-tower";
  networking.networkmanager.enable = true;

  # Users
  users.users.titan = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager"];
  };

  # Home Manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {inherit inputs pkgs-unstable;};
    users.titan = import ./home.nix;
  };

  # Basic packages
  environment.systemPackages = with pkgs; [
    git
    vim
  ];
}
