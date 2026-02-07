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
    ../../modules/nixos/hardware   # Hardware (graphics)
  ];

  # Disk partitioning: disko removed. Define fileSystems/swapDevices manually in hardware-configuration.nix.

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

    # Binary caches
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://niri.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
    ];
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
