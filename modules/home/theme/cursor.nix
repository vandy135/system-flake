# Cursor Theme Module
# Configures cursor theme across X11 and Wayland
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homeModules.theme;
  colors = cfg.colors;

  # Choose cursor package based on theme
  cursorPackage =
    if builtins.match ".*catppuccin.*" colors.cursorTheme != null
    then pkgs.catppuccin-cursors.mochaDark
    else pkgs.bibata-cursors;

  cursorName =
    if builtins.match ".*catppuccin.*" colors.cursorTheme != null
    then "catppuccin-mocha-dark-cursors"
    else "Bibata-Modern-Classic";
in {
  config = lib.mkIf cfg.enable {
    # Unified cursor configuration for X11 and Wayland
    home.pointerCursor = {
      name = cursorName;
      package = cursorPackage;
      size = 24;
      
      # Enable for both X11 and GTK
      x11.enable = true;
      gtk.enable = true;
    };

    # Environment variables for consistent cursor theming
    home.sessionVariables = {
      XCURSOR_SIZE = "24";
      XCURSOR_THEME = cursorName;
    };
  };
}
