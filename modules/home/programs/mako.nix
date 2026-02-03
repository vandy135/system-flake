# Mako - Wayland notification daemon
# Lightweight notifications with theme integration
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homeModules.mako;
  colors = config.homeModules.theme.colors;
in {
  options.homeModules.mako = {
    enable = lib.mkEnableOption "mako notification daemon";
  };

  config = lib.mkIf cfg.enable {
    services.mako = {
      enable = true;
      
      settings = {
        # ═══════════════════════════════════════════════════════════════════
        # APPEARANCE
        # ═══════════════════════════════════════════════════════════════════
        
        # Font configuration
        font = "CaskaydiaCove Nerd Font 11";
        
        # Colors from theme
        background-color = colors.background;
        text-color = colors.foreground;
        border-color = colors.primary;
        progress-color = "over ${colors.primary}";
        
        # Border configuration
        border-size = 2;
        border-radius = 8;
        
        # Dimensions
        width = 350;
        height = 150;
        
        # Padding
        padding = "12";
        
        # Margin from screen edges
        margin = "12";
        
        # ═══════════════════════════════════════════════════════════════════
        # POSITIONING
        # ═══════════════════════════════════════════════════════════════════
        
        # Position: top-right corner
        anchor = "top-right";
        
        # Layer (overlay appears above all windows)
        layer = "overlay";
        
        # ═══════════════════════════════════════════════════════════════════
        # BEHAVIOR
        # ═══════════════════════════════════════════════════════════════════
        
        # Default timeout (5 seconds)
        default-timeout = 5000;
        
        # Ignore timeout value of 0 (would be infinite)
        ignore-timeout = false;
        
        # Maximum visible notifications
        max-visible = 5;
        
        # Sort by time (newest on top)
        sort = "-time";
        
        # Group notifications from same app
        group-by = "app-name";
        
        # ═══════════════════════════════════════════════════════════════════
        # ICONS
        # ═══════════════════════════════════════════════════════════════════
        
        # Show icons
        icons = true;
        
        # Maximum icon size
        max-icon-size = 48;
        
        # ═══════════════════════════════════════════════════════════════════
        # ACTIONS
        # ═══════════════════════════════════════════════════════════════════
        
        # Show action buttons
        actions = true;
        
        # ═══════════════════════════════════════════════════════════════════
        # FORMAT
        # ═══════════════════════════════════════════════════════════════════
        
        # Markup support
        markup = true;
        
        # Format string for notification text
        format = "<b>%s</b>\\n%b";
      };
      
      # ═══════════════════════════════════════════════════════════════════
      # EXTRA CONFIGURATION
      # Per-app and urgency-based styling
      # ═══════════════════════════════════════════════════════════════════
      
      extraConfig = ''
        # ───────────────────────────────────────────────────────────────────
        # Urgency-based styling
        # ───────────────────────────────────────────────────────────────────
        
        [urgency=low]
        border-color=${colors.subtext0}
        default-timeout=3000
        
        [urgency=normal]
        border-color=${colors.primary}
        default-timeout=5000
        
        [urgency=critical]
        border-color=${colors.red}
        text-color=${colors.red}
        default-timeout=0
        
        # ───────────────────────────────────────────────────────────────────
        # Grouped notification styling
        # ───────────────────────────────────────────────────────────────────
        
        [grouped]
        format=<b>%s</b> (%g)\n%b
        
        # ───────────────────────────────────────────────────────────────────
        # App-specific styling
        # ───────────────────────────────────────────────────────────────────
        
        # Discord
        [app-name="discord"]
        border-color=${colors.blue}
        
        # Spotify
        [app-name="Spotify"]
        border-color=${colors.green}
        default-timeout=3000
        
        # Firefox
        [app-name="Firefox"]
        border-color=${colors.yellow}
        
        # Volume/brightness OSD (short display)
        [category="osd"]
        default-timeout=2000
        border-color=${colors.subtext0}
        
        # System notifications
        [app-name="notify-send"]
        border-color=${colors.blue}
        
        # ───────────────────────────────────────────────────────────────────
        # Hidden notifications (Do Not Disturb style)
        # Uncomment to hide specific apps
        # ───────────────────────────────────────────────────────────────────
        
        # [app-name="Slack"]
        # invisible=1
        
        # [mode=dnd]
        # invisible=1
      '';
    };
  };
}
