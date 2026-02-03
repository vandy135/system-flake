{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homeModules.swaylock;
in {
  options.homeModules.swaylock = {
    enable = lib.mkEnableOption "swaylock screen locker";
    
    autoLock = {
      enable = lib.mkEnableOption "automatic screen locking with swayidle";
      timeout = lib.mkOption {
        type = lib.types.int;
        default = 300;
        description = "Seconds of inactivity before locking";
      };
      screenOff = lib.mkOption {
        type = lib.types.int;
        default = 600;
        description = "Seconds of inactivity before turning screen off";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.swaylock = {
      enable = true;
      package = pkgs.swaylock-effects;
      settings = {
        # Catppuccin Mocha colors
        color = "1e1e2e";
        
        # Ring colors
        inside-color = "1e1e2e";
        inside-clear-color = "1e1e2e";
        inside-ver-color = "1e1e2e";
        inside-wrong-color = "1e1e2e";
        
        ring-color = "585b70";
        ring-clear-color = "f5c2e7";
        ring-ver-color = "89b4fa";
        ring-wrong-color = "f38ba8";
        
        line-color = "00000000";
        line-clear-color = "00000000";
        line-ver-color = "00000000";
        line-wrong-color = "00000000";
        
        separator-color = "00000000";
        
        text-color = "cdd6f4";
        text-clear-color = "f5c2e7";
        text-ver-color = "89b4fa";
        text-wrong-color = "f38ba8";
        
        bs-hl-color = "f38ba8";
        key-hl-color = "a6e3a1";
        
        # Layout
        indicator = true;
        indicator-radius = 100;
        indicator-thickness = 7;
        
        # Effects (swaylock-effects)
        clock = true;
        timestr = "%H:%M";
        datestr = "%A, %B %d";
        
        font = "sans-serif";
        font-size = 24;
        
        effect-blur = "7x5";
        effect-vignette = "0.5:0.5";
        
        fade-in = 0.2;
        
        # Security
        ignore-empty-password = true;
        show-failed-attempts = true;
      };
    };

    # swayidle for automatic locking
    services.swayidle = lib.mkIf cfg.autoLock.enable {
      enable = true;
      events = [
        { event = "before-sleep"; command = "${pkgs.swaylock-effects}/bin/swaylock -f"; }
        { event = "lock"; command = "${pkgs.swaylock-effects}/bin/swaylock -f"; }
      ];
      timeouts = [
        {
          timeout = cfg.autoLock.timeout;
          command = "${pkgs.swaylock-effects}/bin/swaylock -f";
        }
        {
          timeout = cfg.autoLock.screenOff;
          command = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
          resumeCommand = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
        }
      ];
    };

    home.packages = with pkgs; [
      swaylock-effects
    ];
  };
}
