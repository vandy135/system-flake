{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.desktop.greetd;
in {
  options.desktop.greetd = {
    enable = lib.mkEnableOption "greetd with ReGreet";
  };

  config = lib.mkIf cfg.enable {
    # ReGreet greeter
    programs.regreet = {
      enable = true;
      settings = {
        background = {
          fit = "Cover";
        };
        GTK = {
          application_prefer_dark_theme = true;
        };
      };
    };

    # Greetd service
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.cage}/bin/cage -s -- ${pkgs.regreet}/bin/regreet";
          user = "greeter";
        };
      };
    };

    # Keyring integration
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.greetd.enableGnomeKeyring = true;
    security.pam.services.login.enableGnomeKeyring = true;

    # Disable default ssh-agent (gnome-keyring handles it)
    programs.ssh.startAgent = false;
  };
}
