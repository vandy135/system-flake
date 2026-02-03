# Qt Theming Module
# Configures Qt5/Qt6 styling to match GTK theme
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homeModules.theme;
  colors = cfg.colors;
in {
  config = lib.mkIf cfg.enable {
    # Qt platform theming
    qt = {
      enable = true;
      
      # Use kvantum for advanced Qt theming
      platformTheme.name = "kvantum";
      
      style = {
        name = "kvantum";
        package = pkgs.libsForQt5.qtstyleplugin-kvantum;
      };
    };

    # Qt-related packages
    home.packages = with pkgs; [
      # Kvantum theme engine
      libsForQt5.qtstyleplugin-kvantum
      kdePackages.qtstyleplugin-kvantum
      
      # Qt6 wayland support
      kdePackages.qtwayland
      libsForQt5.qtwayland
    ];

    # Configure Kvantum theme
    xdg.configFile = {
      "Kvantum/kvantum.kvconfig".text = ''
        [General]
        theme=Catppuccin-Mocha-Mauve
      '';
    };

    # Environment variables for Qt
    home.sessionVariables = {
      # Ensure Qt uses the correct platform
      QT_QPA_PLATFORMTHEME = "kvantum";
      
      # Enable automatic HiDPI scaling
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      
      # Wayland-native Qt when possible
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    };
  };
}
