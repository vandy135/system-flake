# System-level NixOS modules
{...}: {
  imports = [
    ./essentials.nix
    ./enhancements.nix
    ./nix-caches.nix
  ];
}
