{inputs, ...}: let
  mkHost = hostName:
    inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
        pkgs-unstable = import inputs.nixpkgs-unstable {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      };
      modules = [
        inputs.disko.nixosModules.disko
        inputs.sops-nix.nixosModules.sops
        inputs.home-manager.nixosModules.home-manager
        inputs.niri.nixosModules.niri  # Niri NixOS module (system-level)
        ../hosts/${hostName}
      ];
    };
in {
  flake.nixosConfigurations = {
    launchpad = mkHost "launchpad";
    control-tower = mkHost "control-tower";
  };
}
