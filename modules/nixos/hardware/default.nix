# Hardware-related NixOS modules
{ ... }: {
  imports = [
    ./graphics.nix
    ./disko.nix
  ];
}
