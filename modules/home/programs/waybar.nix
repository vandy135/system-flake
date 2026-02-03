# Waybar - Wayland status bar
# Clean, minimal design with Niri workspace support
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homeModules.waybar;
  colors = config.homeModules.theme.colors;
in {
  options.homeModules.waybar = {
    enable = lib.mkEnableOption "waybar status bar";
  };

  config = lib.mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      
      # ═══════════════════════════════════════════════════════════════════
      # SYSTEMD INTEGRATION
      # Let Niri manage waybar startup instead
      # ═══════════════════════════════════════════════════════════════════
      systemd.enable = false;
      
      # ═══════════════════════════════════════════════════════════════════
      # BAR CONFIGURATION
      # ═══════════════════════════════════════════════════════════════════
      settings = {
        mainBar = {
          # Layer and positioning
          layer = "top";
          position = "top";
          height = 32;
          spacing = 8;
          
          # Modules layout
          modules-left = [
            "niri/workspaces"
            "niri/window"
          ];
          
          modules-center = [
            "clock"
          ];
          
          modules-right = [
            "tray"
            "cpu"
            "memory"
            "pulseaudio"
            "network"
            "battery"
          ];

          # ─────────────────────────────────────────────────────────────────
          # NIRI WORKSPACES
          # ─────────────────────────────────────────────────────────────────
          "niri/workspaces" = {
            format = "{icon}";
            format-icons = {
              active = "●";
              default = "○";
              urgent = "◉";
            };
            on-click = "activate";
          };

          # ─────────────────────────────────────────────────────────────────
          # ACTIVE WINDOW
          # ─────────────────────────────────────────────────────────────────
          "niri/window" = {
            format = "{}";
            max-length = 50;
            rewrite = {
              "(.*) — Mozilla Firefox" = "󰈹 $1";
              "(.*) - Discord" = "󰙯 $1";
              "(.*) - Alacritty" = " $1";
              "Alacritty" = " Terminal";
              "(.*) - Visual Studio Code" = "󰨞 $1";
            };
          };

          # ─────────────────────────────────────────────────────────────────
          # CLOCK
          # ─────────────────────────────────────────────────────────────────
          clock = {
            format = "  {:%H:%M}";
            format-alt = "  {:%A, %B %d, %Y}";
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            calendar = {
              mode = "month";
              weeks-pos = "left";
              on-scroll = 1;
              format = {
                months = "<span color='${colors.foreground}'><b>{}</b></span>";
                days = "<span color='${colors.foreground}'>{}</span>";
                weeks = "<span color='${colors.subtext0}'><b>W{}</b></span>";
                weekdays = "<span color='${colors.primary}'><b>{}</b></span>";
                today = "<span color='${colors.primary}'><b><u>{}</u></b></span>";
              };
            };
          };

          # ─────────────────────────────────────────────────────────────────
          # SYSTEM TRAY
          # ─────────────────────────────────────────────────────────────────
          tray = {
            icon-size = 16;
            spacing = 8;
          };

          # ─────────────────────────────────────────────────────────────────
          # CPU
          # ─────────────────────────────────────────────────────────────────
          cpu = {
            format = " {usage}%";
            tooltip = true;
            interval = 2;
            states = {
              warning = 70;
              critical = 90;
            };
          };

          # ─────────────────────────────────────────────────────────────────
          # MEMORY
          # ─────────────────────────────────────────────────────────────────
          memory = {
            format = " {}%";
            tooltip-format = "RAM: {used:0.1f}GiB / {total:0.1f}GiB";
            interval = 2;
            states = {
              warning = 70;
              critical = 90;
            };
          };

          # ─────────────────────────────────────────────────────────────────
          # VOLUME (PulseAudio/PipeWire)
          # ─────────────────────────────────────────────────────────────────
          pulseaudio = {
            format = "{icon} {volume}%";
            format-bluetooth = "{icon} {volume}%";
            format-bluetooth-muted = "󰖁 ";
            format-muted = "󰖁 ";
            format-icons = {
              headphone = "󰋋";
              hands-free = "󰋎";
              headset = "󰋎";
              phone = "";
              portable = "";
              car = "";
              default = ["" "" ""];
            };
            on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            on-click-right = "pavucontrol";
            tooltip-format = "{desc} | {volume}%";
          };

          # ─────────────────────────────────────────────────────────────────
          # NETWORK
          # ─────────────────────────────────────────────────────────────────
          network = {
            format-wifi = "󰤨 {signalStrength}%";
            format-ethernet = "󰈀 ";
            format-linked = "󰈀 (No IP)";
            format-disconnected = "󰤭 ";
            format-alt = "{ifname}: {ipaddr}/{cidr}";
            tooltip-format = "{essid} | {ifname} via {gwaddr}";
            on-click-right = "nm-connection-editor";
          };

          # ─────────────────────────────────────────────────────────────────
          # BATTERY
          # ─────────────────────────────────────────────────────────────────
          battery = {
            states = {
              good = 80;
              warning = 30;
              critical = 15;
            };
            format = "{icon} {capacity}%";
            format-charging = "󰂄 {capacity}%";
            format-plugged = "󰂄 {capacity}%";
            format-alt = "{icon} {time}";
            format-icons = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
            tooltip-format = "{timeTo} | {power}W";
          };
        };
      };

      # ═══════════════════════════════════════════════════════════════════
      # STYLESHEET (CSS)
      # Clean, minimal design using theme colors
      # ═══════════════════════════════════════════════════════════════════
      style = ''
        /* ─────────────────────────────────────────────────────────────────
         * Global styles
         * ───────────────────────────────────────────────────────────────── */
        * {
          font-family: "CaskaydiaCove Nerd Font", "Font Awesome 6 Free", sans-serif;
          font-size: 13px;
          min-height: 0;
        }

        /* ─────────────────────────────────────────────────────────────────
         * Main bar
         * ───────────────────────────────────────────────────────────────── */
        window#waybar {
          background-color: ${colors.background};
          color: ${colors.foreground};
          border-bottom: 2px solid ${colors.surface0};
        }

        window#waybar.hidden {
          opacity: 0.2;
        }

        /* ─────────────────────────────────────────────────────────────────
         * Tooltips
         * ───────────────────────────────────────────────────────────────── */
        tooltip {
          background-color: ${colors.background};
          border: 2px solid ${colors.primary};
          border-radius: 8px;
        }

        tooltip label {
          color: ${colors.foreground};
          padding: 4px;
        }

        /* ─────────────────────────────────────────────────────────────────
         * All modules base style
         * ───────────────────────────────────────────────────────────────── */
        #workspaces,
        #window,
        #clock,
        #tray,
        #cpu,
        #memory,
        #pulseaudio,
        #network,
        #battery {
          padding: 0 12px;
          margin: 4px 2px;
          border-radius: 6px;
          background-color: ${colors.surface0};
          color: ${colors.foreground};
        }

        /* ─────────────────────────────────────────────────────────────────
         * Workspaces
         * ───────────────────────────────────────────────────────────────── */
        #workspaces {
          padding: 0 4px;
        }

        #workspaces button {
          padding: 0 8px;
          color: ${colors.subtext0};
          background: transparent;
          border: none;
          border-radius: 4px;
          transition: all 0.2s ease;
        }

        #workspaces button:hover {
          background: ${colors.surface0};
          color: ${colors.foreground};
        }

        #workspaces button.active {
          color: ${colors.primary};
        }

        #workspaces button.urgent {
          color: ${colors.red};
        }

        /* ─────────────────────────────────────────────────────────────────
         * Window title
         * ───────────────────────────────────────────────────────────────── */
        #window {
          color: ${colors.foreground};
          font-weight: 500;
        }

        window#waybar.empty #window {
          background-color: transparent;
        }

        /* ─────────────────────────────────────────────────────────────────
         * Clock
         * ───────────────────────────────────────────────────────────────── */
        #clock {
          color: ${colors.foreground};
          font-weight: 600;
        }

        /* ─────────────────────────────────────────────────────────────────
         * System tray
         * ───────────────────────────────────────────────────────────────── */
        #tray {
          padding: 0 8px;
        }

        #tray > .passive {
          -gtk-icon-effect: dim;
        }

        #tray > .needs-attention {
          -gtk-icon-effect: highlight;
        }

        /* ─────────────────────────────────────────────────────────────────
         * CPU & Memory
         * ───────────────────────────────────────────────────────────────── */
        #cpu,
        #memory {
          color: ${colors.foreground};
        }

        #cpu.warning,
        #memory.warning {
          color: ${colors.yellow};
        }

        #cpu.critical,
        #memory.critical {
          color: ${colors.red};
        }

        /* ─────────────────────────────────────────────────────────────────
         * Volume
         * ───────────────────────────────────────────────────────────────── */
        #pulseaudio {
          color: ${colors.foreground};
        }

        #pulseaudio.muted {
          color: ${colors.subtext0};
        }

        /* ─────────────────────────────────────────────────────────────────
         * Network
         * ───────────────────────────────────────────────────────────────── */
        #network {
          color: ${colors.foreground};
        }

        #network.disconnected {
          color: ${colors.red};
        }

        /* ─────────────────────────────────────────────────────────────────
         * Battery
         * ───────────────────────────────────────────────────────────────── */
        #battery {
          color: ${colors.foreground};
        }

        #battery.charging,
        #battery.plugged {
          color: ${colors.green};
        }

        #battery.warning:not(.charging) {
          color: ${colors.yellow};
        }

        #battery.critical:not(.charging) {
          color: ${colors.red};
          animation: blink 1s linear infinite;
        }

        /* ─────────────────────────────────────────────────────────────────
         * Animations
         * ───────────────────────────────────────────────────────────────── */
        @keyframes blink {
          to {
            color: ${colors.foreground};
          }
        }
      '';
    };
  };
}
