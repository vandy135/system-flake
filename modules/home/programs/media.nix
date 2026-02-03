{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homeModules.media;
in {
  options.homeModules.media = {
    enable = lib.mkEnableOption "media tools (mpv, imv, grim, slurp)";
  };

  config = lib.mkIf cfg.enable {
    # imv - minimal Wayland image viewer
    programs.imv = {
      enable = true;
      settings = {
        options = {
          background = "#1e1e2e";  # Catppuccin base
          overlay_font = "monospace:12";
          overlay_text_color = "#cdd6f4";  # Catppuccin text
          overlay_background_color = "#313244";  # Catppuccin surface0
          overlay_background_alpha = "cc";
        };
        binds = {
          q = "quit";
          "<Left>" = "prev";
          "<Right>" = "next";
          "<Up>" = "zoom 1";
          "<Down>" = "zoom -1";
          f = "fullscreen";
          r = "reset";
          # Delete to trash (requires trash-cli)
          "<Delete>" = "exec trash-put \"$imv_current_file\"; next";
        };
      };
    };

    # mpv - powerful media player
    programs.mpv = {
      enable = true;
      config = {
        # Video
        profile = "gpu-hq";
        vo = "gpu-next";
        hwdec = "auto-safe";
        
        # Audio
        volume = 70;
        volume-max = 150;
        audio-pitch-correction = "yes";
        
        # Subtitles
        sub-auto = "fuzzy";
        sub-font = "sans-serif";
        sub-font-size = 40;
        sub-color = "#FFFFFFFF";
        sub-border-size = 2;
        sub-border-color = "#FF000000";
        
        # OSD
        osd-font = "sans-serif";
        osd-font-size = 32;
        osd-color = "#CCFFFFFF";
        osd-border-size = 1;
        osd-bar-align-y = -1;
        osd-bar-h = 2;
        osd-bar-w = 60;
        
        # Behavior
        keep-open = "yes";
        save-position-on-quit = "yes";
        autofit-larger = "90%x90%";
        cursor-autohide = 1000;
        
        # Screenshots
        screenshot-format = "png";
        screenshot-directory = "~/Pictures/Screenshots";
        screenshot-template = "%F-%P";
      };
      bindings = {
        "l" = "seek 5";
        "h" = "seek -5";
        "j" = "seek -60";
        "k" = "seek 60";
        "S" = "screenshot";
        "WHEEL_UP" = "add volume 2";
        "WHEEL_DOWN" = "add volume -2";
      };
    };

    # Screenshot and selection tools for Wayland
    home.packages = with pkgs; [
      grim          # Screenshot utility for Wayland
      slurp         # Select region for Wayland
      wl-clipboard  # Clipboard utilities
      trash-cli     # Safe delete (used by imv)
    ];
  };
}
