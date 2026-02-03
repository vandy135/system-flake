{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homeModules.zellij;
  theme = config.homeModules.theme;
in {
  options.homeModules.zellij = {
    enable = lib.mkEnableOption "zellij terminal multiplexer";
  };

  config = lib.mkIf cfg.enable {
    programs.zellij = {
      enable = true;
      enableZshIntegration = false; # Don't auto-start, we'll use it manually
    };

    # Zellij config in KDL format
    xdg.configFile."zellij/config.kdl".text = ''
      // Zellij Configuration
      // Theme: Catppuccin Mocha (from home-manager theme)

      // Use non-conflicting keybindings (Ctrl+Space as leader instead of Ctrl+b)
      keybinds clear-defaults=true {
          // Normal mode
          normal {
              // Leader key: Ctrl+Space
              bind "Ctrl Space" { SwitchToMode "tmux"; }
          }

          // Tmux-like mode (triggered by leader)
          tmux {
              bind "Esc" "Ctrl c" { SwitchToMode "Normal"; }

              // Pane management
              bind "h" { MoveFocus "Left"; SwitchToMode "Normal"; }
              bind "j" { MoveFocus "Down"; SwitchToMode "Normal"; }
              bind "k" { MoveFocus "Up"; SwitchToMode "Normal"; }
              bind "l" { MoveFocus "Right"; SwitchToMode "Normal"; }

              bind "Left" { MoveFocus "Left"; SwitchToMode "Normal"; }
              bind "Down" { MoveFocus "Down"; SwitchToMode "Normal"; }
              bind "Up" { MoveFocus "Up"; SwitchToMode "Normal"; }
              bind "Right" { MoveFocus "Right"; SwitchToMode "Normal"; }

              // Splits - use | and - like vim
              bind "|" { NewPane "Right"; SwitchToMode "Normal"; }
              bind "-" { NewPane "Down"; SwitchToMode "Normal"; }
              bind "v" { NewPane "Right"; SwitchToMode "Normal"; }
              bind "s" { NewPane "Down"; SwitchToMode "Normal"; }

              // Pane operations
              bind "x" { CloseFocus; SwitchToMode "Normal"; }
              bind "z" { ToggleFocusFullscreen; SwitchToMode "Normal"; }
              bind "f" { ToggleFloatingPanes; SwitchToMode "Normal"; }

              // Tab management
              bind "c" { NewTab; SwitchToMode "Normal"; }
              bind "n" { GoToNextTab; SwitchToMode "Normal"; }
              bind "p" { GoToPreviousTab; SwitchToMode "Normal"; }
              bind "1" { GoToTab 1; SwitchToMode "Normal"; }
              bind "2" { GoToTab 2; SwitchToMode "Normal"; }
              bind "3" { GoToTab 3; SwitchToMode "Normal"; }
              bind "4" { GoToTab 4; SwitchToMode "Normal"; }
              bind "5" { GoToTab 5; SwitchToMode "Normal"; }
              bind "6" { GoToTab 6; SwitchToMode "Normal"; }
              bind "7" { GoToTab 7; SwitchToMode "Normal"; }
              bind "8" { GoToTab 8; SwitchToMode "Normal"; }
              bind "9" { GoToTab 9; SwitchToMode "Normal"; }
              bind "," { SwitchToMode "RenameTab"; TabNameInput 0; }

              // Session management
              bind "d" { Detach; }
              bind "w" { SwitchToMode "Session"; }

              // Resize mode
              bind "r" { SwitchToMode "Resize"; }

              // Scroll/search
              bind "[" { SwitchToMode "Scroll"; }
              bind "/" { SwitchToMode "EnterSearch"; SearchInput 0; }

              // Copy mode
              bind "Space" { SwitchToMode "Scroll"; }
          }

          // Resize mode
          resize {
              bind "Esc" "Ctrl c" { SwitchToMode "Normal"; }
              bind "h" "Left" { Resize "Increase Left"; }
              bind "j" "Down" { Resize "Increase Down"; }
              bind "k" "Up" { Resize "Increase Up"; }
              bind "l" "Right" { Resize "Increase Right"; }
              bind "H" { Resize "Decrease Left"; }
              bind "J" { Resize "Decrease Down"; }
              bind "K" { Resize "Decrease Up"; }
              bind "L" { Resize "Decrease Right"; }
              bind "=" { Resize "Increase"; }
              bind "-" { Resize "Decrease"; }
          }

          // Scroll mode
          scroll {
              bind "Esc" "Ctrl c" "q" { SwitchToMode "Normal"; }
              bind "j" "Down" { ScrollDown; }
              bind "k" "Up" { ScrollUp; }
              bind "Ctrl d" { HalfPageScrollDown; }
              bind "Ctrl u" { HalfPageScrollUp; }
              bind "d" { HalfPageScrollDown; }
              bind "u" { HalfPageScrollUp; }
              bind "g" { ScrollToTop; }
              bind "G" { ScrollToBottom; }
              bind "/" { SwitchToMode "EnterSearch"; SearchInput 0; }
          }

          // Search mode
          search {
              bind "Esc" "Ctrl c" { SwitchToMode "Normal"; }
              bind "n" { Search "down"; }
              bind "N" { Search "up"; }
              bind "j" "Down" { ScrollDown; }
              bind "k" "Up" { ScrollUp; }
          }

          entersearch {
              bind "Esc" "Ctrl c" { SwitchToMode "Scroll"; }
              bind "Enter" { SwitchToMode "Search"; }
          }

          // Session mode
          session {
              bind "Esc" "Ctrl c" { SwitchToMode "Normal"; }
              bind "d" { Detach; }
              bind "w" {
                  LaunchOrFocusPlugin "session-manager" {
                      floating true
                      move_to_focused_tab true
                  };
                  SwitchToMode "Normal"
              }
          }

          // Rename tab mode
          renametab {
              bind "Esc" "Ctrl c" { UndoRenameTab; SwitchToMode "Normal"; }
              bind "Enter" { SwitchToMode "Normal"; }
          }

          // Shared bindings across all modes
          shared_except "normal" {
              bind "Enter" { SwitchToMode "Normal"; }
          }

          shared_except "locked" {
              bind "Ctrl q" { Quit; }
          }
      }

      // Default mode
      default_mode "normal"

      // Mouse support
      mouse_mode true
      scroll_buffer_size 10000
      copy_on_select true

      // Pane frames
      pane_frames false

      // Simplified UI
      simplified_ui false
      default_shell "zsh"

      // Session serialization
      session_serialization true
      serialize_pane_viewport true

      // Theme definition using colors from home-manager theme
      themes {
          catppuccin-mocha {
              fg "${theme.colors.foreground}"
              bg "${theme.colors.background}"
              black "${theme.colors.surface1}"
              red "${theme.colors.red}"
              green "${theme.colors.green}"
              yellow "${theme.colors.yellow}"
              blue "${theme.colors.blue}"
              magenta "${theme.colors.pink}"
              cyan "${theme.colors.teal}"
              white "${theme.colors.subtext1}"
              orange "${theme.colors.orange}"
          }
      }

      theme "catppuccin-mocha"

      // UI settings
      ui {
          pane_frames {
              rounded_corners true
          }
      }

      // Default layout
      default_layout "compact"
    '';

    # Default layout file
    xdg.configFile."zellij/layouts/compact.kdl".text = ''
      layout {
          default_tab_template {
              pane size=1 borderless=true {
                  plugin location="compact-bar"
              }
              children
          }
          tab name="main"
      }
    '';
  };
}
