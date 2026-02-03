{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.desktop.niri;
in {
  options.desktop.niri = {
    enable = lib.mkEnableOption "niri wayland compositor";
  };

  config = lib.mkIf cfg.enable {
    # Niri compositor (via niri-flake)
    programs.niri.enable = true;

    # Essential Wayland environment variables
    environment.sessionVariables = {
      # Enable Wayland for Electron/Chromium apps
      NIXOS_OZONE_WL = "1";
      # Wayland-native Qt
      QT_QPA_PLATFORM = "wayland";
      # Wayland-native SDL
      SDL_VIDEODRIVER = "wayland";
      # Wayland-native Firefox
      MOZ_ENABLE_WAYLAND = "1";
    };

    # XDG portals for screen sharing, file dialogs, etc.
    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
    };

    # System-level Wayland tools
    environment.systemPackages = with pkgs; [
      wl-clipboard-rs    # Clipboard support
      grim               # Screenshot capture
      slurp              # Region selection for screenshots
      xwayland-satellite # X11 compatibility layer
      swaylock           # Screen locker
      brightnessctl      # Backlight control
      playerctl          # Media player control
    ];

    # Swaylock PAM authentication
    security.pam.services.swaylock = {};
  };
}
