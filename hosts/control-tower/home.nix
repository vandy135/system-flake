{
  config,
  pkgs,
  ...
}: {
  imports = [../../modules/home];

  home.username = "titan";
  home.homeDirectory = "/home/titan";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  # Terminal
  homeModules.alacritty.enable = true;
}
