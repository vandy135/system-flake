{
  config,
  pkgs,
  inputs,
  pkgs-unstable,
  ...
}: {
  imports = [
    ./hardware-configuration.nix  # Generate with nixos-generate-config
    ../../modules/nixos/desktop
    ../../modules/nixos/system     # System essentials (audio, bluetooth, utils)
    ../../modules/nixos/hardware   # Hardware (graphics, NVIDIA)
  ];

  # Disk partitioning: disko removed. Define fileSystems/swapDevices manually in hardware-configuration.nix.

  # Desktop
  desktop.niri.enable = true;
  desktop.greetd.enable = true;

  # System Essentials (PipeWire, Bluetooth, utilities)
  systemModules.essentials.enable = true;

  # System Enhancements (Plymouth, firewall, ZRAM, earlyoom, polkit agent)
  systemModules.enhancements.enable = true;

  # Graphics (OpenGL, Vulkan, NVIDIA)
  hardwareModules.graphics = {
    enable = true;
    nvidia = {
      enable = true;
      open = true;  # Use open kernel modules (RTX 20-series+)
      # For laptops with hybrid graphics, configure PRIME:
      # prime = {
      #   enable = true;
      #   mode = "offload";  # or "sync" for always-on
      #   intelBusId = "PCI:0:2:0";
      #   nvidiaBusId = "PCI:1:0:0";
      # };
    };
  };

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
  networking.hostName = "launchpad";
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
