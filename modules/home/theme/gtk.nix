# GTK Theming Module
# Configures GTK 2/3/4 themes, icons, and fonts
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
    # GTK configuration
    gtk = {
      enable = true;

      # Theme matching the selected color scheme
      theme = {
        name = colors.gtkTheme;
        package = pkgs.catppuccin-gtk.override {
          accents = ["mauve"];
          variant = "mocha";
        };
      };

      # Icon theme
      iconTheme = {
        name = colors.iconTheme;
        package = pkgs.papirus-icon-theme;
      };

      # Font configuration
      font = {
        name = cfg.fonts.sansSerif;
        size = cfg.fonts.size;
      };

      # GTK 2 specific settings
      gtk2.extraConfig = ''
        gtk-application-prefer-dark-theme=1
      '';

      # GTK 3 specific settings
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
        gtk-decoration-layout = "appmenu:none";
      };

      # GTK 4 specific settings
      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
        gtk-decoration-layout = "appmenu:none";
      };
    };

    # Additional GTK-related packages
    home.packages = with pkgs; [
      # GTK engines and themes
      gnome-themes-extra
      gtk-engine-murrine
      
      # For GTK4 libadwaita apps
      adwaita-icon-theme
    ];

    # dconf settings for GNOME/GTK apps
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        gtk-theme = colors.gtkTheme;
        icon-theme = colors.iconTheme;
        font-name = "${cfg.fonts.sansSerif} ${toString cfg.fonts.size}";
        monospace-font-name = "${cfg.fonts.monospace} ${toString cfg.fonts.size}";
      };
    };
  };
}
