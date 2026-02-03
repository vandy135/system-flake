{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homeModules.alacritty;
  theme = config.homeModules.theme;
in {
  options.homeModules.alacritty = {
    enable = lib.mkEnableOption "alacritty terminal";
  };

  config = lib.mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
      settings = {
        # Window settings
        window = {
          padding = {
            x = 8;
            y = 8;
          };
          dynamic_padding = true;
          opacity = 0.95;
          decorations = "full";
          startup_mode = "Windowed";
        };

        # Scrollback
        scrolling = {
          history = 10000;
          multiplier = 3;
        };

        # Font configuration from theme
        font = {
          normal = {
            family = theme.fonts.monospace;
            style = "Regular";
          };
          bold = {
            family = theme.fonts.monospace;
            style = "Bold";
          };
          italic = {
            family = theme.fonts.monospace;
            style = "Italic";
          };
          bold_italic = {
            family = theme.fonts.monospace;
            style = "Bold Italic";
          };
          size = theme.fonts.size;
        };

        # Catppuccin Mocha colors from theme
        colors = {
          primary = {
            background = theme.colors.background;
            foreground = theme.colors.foreground;
            dim_foreground = theme.colors.subtext1;
            bright_foreground = theme.colors.foreground;
          };

          cursor = {
            text = theme.colors.background;
            cursor = theme.colors.cursorColor;
          };

          vi_mode_cursor = {
            text = theme.colors.background;
            cursor = theme.colors.lavender;
          };

          search = {
            matches = {
              foreground = theme.colors.background;
              background = theme.colors.subtext0;
            };
            focused_match = {
              foreground = theme.colors.background;
              background = theme.colors.green;
            };
          };

          hints = {
            start = {
              foreground = theme.colors.background;
              background = theme.colors.yellow;
            };
            end = {
              foreground = theme.colors.background;
              background = theme.colors.subtext0;
            };
          };

          selection = {
            text = theme.colors.background;
            background = theme.colors.accent;
          };

          normal = {
            black = theme.colors.surface1;
            red = theme.colors.red;
            green = theme.colors.green;
            yellow = theme.colors.yellow;
            blue = theme.colors.blue;
            magenta = theme.colors.pink;
            cyan = theme.colors.teal;
            white = theme.colors.subtext1;
          };

          bright = {
            black = theme.colors.surface2;
            red = theme.colors.red;
            green = theme.colors.green;
            yellow = theme.colors.yellow;
            blue = theme.colors.blue;
            magenta = theme.colors.pink;
            cyan = theme.colors.teal;
            white = theme.colors.subtext0;
          };

          dim = {
            black = theme.colors.surface1;
            red = theme.colors.red;
            green = theme.colors.green;
            yellow = theme.colors.yellow;
            blue = theme.colors.blue;
            magenta = theme.colors.pink;
            cyan = theme.colors.teal;
            white = theme.colors.subtext1;
          };

          indexed_colors = [
            { index = 16; color = theme.colors.orange; }
            { index = 17; color = theme.colors.accent; }
          ];
        };

        # Selection
        selection = {
          save_to_clipboard = true;
        };

        # Cursor
        cursor = {
          style = {
            shape = "Block";
            blinking = "On";
          };
          blink_interval = 750;
          unfocused_hollow = true;
        };

        # Terminal settings
        terminal = {
          shell = {
            program = "${pkgs.zsh}/bin/zsh";
          };
        };

        # Keyboard bindings
        keyboard = {
          bindings = [
            { key = "V"; mods = "Control|Shift"; action = "Paste"; }
            { key = "C"; mods = "Control|Shift"; action = "Copy"; }
            { key = "Plus"; mods = "Control"; action = "IncreaseFontSize"; }
            { key = "Minus"; mods = "Control"; action = "DecreaseFontSize"; }
            { key = "Key0"; mods = "Control"; action = "ResetFontSize"; }
          ];
        };
      };
    };
  };
}
