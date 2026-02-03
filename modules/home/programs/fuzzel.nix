# Fuzzel - Wayland application launcher
# Keyboard-first launcher with theme integration
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homeModules.fuzzel;
  colors = config.homeModules.theme.colors;
  
  # Strip '#' from hex colors for fuzzel format
  stripHash = color: lib.removePrefix "#" color;
in {
  options.homeModules.fuzzel = {
    enable = lib.mkEnableOption "fuzzel application launcher";
  };

  config = lib.mkIf cfg.enable {
    programs.fuzzel = {
      enable = true;
      settings = {
        # ═══════════════════════════════════════════════════════════════════
        # MAIN CONFIGURATION
        # ═══════════════════════════════════════════════════════════════════
        main = {
          # Font configuration - uses theme font
          font = "CaskaydiaCove Nerd Font:size=13";
          
          # Use DPI-aware sizing
          dpi-aware = "yes";
          
          # Icon theme (follows system)
          icon-theme = "Papirus-Dark";
          
          # Show icons in results
          icons-enabled = "yes";
          
          # Number of visible lines
          lines = 12;
          
          # Width as percentage of screen
          width = 35;
          
          # Horizontal padding
          horizontal-pad = 20;
          
          # Vertical padding  
          vertical-pad = 12;
          
          # Inner padding between elements
          inner-pad = 8;
          
          # Prompt text
          prompt = "❯ ";
          
          # Terminal for running terminal apps
          terminal = "alacritty -e";
          
          # Match mode: exact, prefix, or fuzzy
          match-mode = "fuzzy";
          
          # Show application categories
          show-actions = "no";
          
          # Layer (for Wayland stacking)
          layer = "overlay";
        };

        # ═══════════════════════════════════════════════════════════════════
        # COLOR SCHEME
        # Colors use format: RRGGBBaa (hex without #, with alpha)
        # ═══════════════════════════════════════════════════════════════════
        colors = {
          # Background color
          background = "${stripHash colors.background}ee";
          
          # Text color
          text = "${stripHash colors.foreground}ff";
          
          # Prompt text color
          prompt = "${stripHash colors.primary}ff";
          
          # Placeholder text color (when empty)
          placeholder = "${stripHash colors.subtext0}ff";
          
          # Input text color
          input = "${stripHash colors.foreground}ff";
          
          # Match highlight color (matched characters)
          match = "${stripHash colors.primary}ff";
          
          # Selection background
          selection = "${stripHash colors.surface0}ff";
          
          # Selection text
          selection-text = "${stripHash colors.foreground}ff";
          
          # Selection match highlight
          selection-match = "${stripHash colors.primary}ff";
          
          # Counter text (showing result count)
          counter = "${stripHash colors.subtext0}ff";
          
          # Border color
          border = "${stripHash colors.primary}ff";
        };

        # ═══════════════════════════════════════════════════════════════════
        # BORDER CONFIGURATION
        # ═══════════════════════════════════════════════════════════════════
        border = {
          # Border width in pixels
          width = 2;
          
          # Border radius for rounded corners
          radius = 8;
        };

        # ═══════════════════════════════════════════════════════════════════
        # KEYBOARD NAVIGATION
        # ═══════════════════════════════════════════════════════════════════
        key-bindings = {
          # Cancel and close
          cancel = "Escape Control+c Control+g";
          
          # Execute selected
          execute = "Return KP_Enter";
          
          # Execute or open if no match
          execute-or-next = "none";
          
          # Cursor movement
          cursor-left = "Left Control+b";
          cursor-left-word = "Control+Left Alt+b";
          cursor-right = "Right Control+f";
          cursor-right-word = "Control+Right Alt+f";
          cursor-home = "Home Control+a";
          cursor-end = "End Control+e";
          
          # Text deletion
          delete-prev = "BackSpace";
          delete-prev-word = "Control+BackSpace Control+w";
          delete-next = "Delete Control+d";
          delete-next-word = "Control+Delete Alt+d";
          delete-line = "Control+u";
          
          # Result navigation (vim-style + standard)
          prev = "Up Control+p Control+k";
          prev-page = "Page_Up";
          next = "Down Control+n Control+j Tab";
          next-page = "Page_Down";
          
          # Jump to first/last
          first = "Control+Home";
          last = "Control+End";
          
          # Custom actions (not typically used)
          custom-1 = "none";
          custom-2 = "none";
          custom-3 = "none";
          custom-4 = "none";
          custom-5 = "none";
        };
      };
    };
  };
}
