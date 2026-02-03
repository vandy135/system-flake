# System Enhancements - Plymouth, XDG portals, firewall, ZRAM, earlyoom
# Performance, security, and polish improvements
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.systemModules.enhancements;
in {
  options.systemModules.enhancements = {
    enable = lib.mkEnableOption "system enhancements (boot splash, security, performance)";

    plymouth = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Plymouth boot splash screen";
      };
      theme = lib.mkOption {
        type = lib.types.str;
        default = "bgrt";
        description = "Plymouth theme (bgrt shows OEM logo, catppuccin-mocha for dark theme)";
      };
    };

    polkitAgent = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Polkit GUI authentication agent";
      };
    };

    networkManagerApplet = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable NetworkManager tray applet";
      };
    };

    xdgPortals = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable XDG desktop portals for Wayland";
      };
    };

    firewall = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable firewall with sensible defaults";
      };
      allowedTCPPorts = lib.mkOption {
        type = lib.types.listOf lib.types.port;
        default = [];
        description = "TCP ports to allow through firewall";
      };
      allowedUDPPorts = lib.mkOption {
        type = lib.types.listOf lib.types.port;
        default = [];
        description = "UDP ports to allow through firewall";
      };
    };

    zram = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable ZRAM swap with zstd compression";
      };
      memoryPercent = lib.mkOption {
        type = lib.types.int;
        default = 50;
        description = "Percentage of RAM to use for ZRAM swap";
      };
    };

    earlyoom = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable earlyoom to prevent OOM freezes";
      };
      freeMemThreshold = lib.mkOption {
        type = lib.types.int;
        default = 5;
        description = "Kill processes when free memory drops below this percentage";
      };
      freeSwapThreshold = lib.mkOption {
        type = lib.types.int;
        default = 10;
        description = "Kill processes when free swap drops below this percentage";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # =========================================================================
    # PLYMOUTH BOOT SPLASH
    # Smooth boot experience with themed splash screen
    # =========================================================================
    boot.plymouth = lib.mkIf cfg.plymouth.enable {
      enable = true;
      theme = cfg.plymouth.theme;
      # Available themes: bgrt (OEM logo), spinner, fade-in, solar, script
      # For catppuccin, install the plymouth theme package separately
    };

    # Silent boot for cleaner Plymouth experience
    boot.consoleLogLevel = lib.mkIf cfg.plymouth.enable 0;
    boot.initrd.verbose = lib.mkIf cfg.plymouth.enable false;
    boot.kernelParams = lib.mkIf cfg.plymouth.enable [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];

    # =========================================================================
    # POLKIT GUI AGENT & NETWORKMANAGER APPLET
    # Graphical authentication dialogs and tray icon for network management
    # =========================================================================
    environment.systemPackages =
      lib.optional cfg.polkitAgent.enable pkgs.polkit_gnome
      ++ lib.optional cfg.networkManagerApplet.enable pkgs.networkmanagerapplet;

    # Systemd user service to auto-start polkit agent
    systemd.user.services.polkit-gnome-agent = lib.mkIf cfg.polkitAgent.enable {
      description = "Polkit GNOME Authentication Agent";
      wantedBy = ["graphical-session.target"];
      wants = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    # nm-applet systemd user service
    systemd.user.services.nm-applet = lib.mkIf cfg.networkManagerApplet.enable {
      description = "NetworkManager Applet";
      wantedBy = ["graphical-session.target"];
      wants = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    # =========================================================================
    # XDG DESKTOP PORTALS
    # File pickers, screen sharing, and other desktop integration for Wayland
    # =========================================================================
    xdg.portal = lib.mkIf cfg.xdgPortals.enable {
      enable = true;

      # Portal implementations
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk    # GTK file pickers, general fallback
        pkgs.xdg-desktop-portal-gnome  # Better integration with GNOME apps
      ];

      # Use GTK portal for file chooser by default
      config = {
        common = {
          default = ["gtk"];
          "org.freedesktop.impl.portal.FileChooser" = ["gtk"];
          "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
        };
      };
    };

    # Ensure D-Bus is properly configured for portals
    services.dbus.enable = lib.mkIf cfg.xdgPortals.enable true;

    # =========================================================================
    # FIREWALL
    # Security with sensible defaults
    # =========================================================================
    networking.firewall = lib.mkIf cfg.firewall.enable {
      enable = true;
      allowedTCPPorts = cfg.firewall.allowedTCPPorts;
      allowedUDPPorts = cfg.firewall.allowedUDPPorts;

      # Log dropped packets for debugging
      logReversePathDrops = true;
      logRefusedConnections = true;

      # Default policies
      rejectPackets = false;  # Drop silently instead of rejecting (more secure)

      # Allow established connections
      checkReversePath = "loose";  # "loose" works better with VPNs
    };

    # =========================================================================
    # ZRAM SWAP
    # Compressed RAM swap for better memory management
    # =========================================================================
    zramSwap = lib.mkIf cfg.zram.enable {
      enable = true;
      algorithm = "zstd";
      memoryPercent = cfg.zram.memoryPercent;
    };

    # =========================================================================
    # EARLYOOM
    # Prevent system freezes from OOM conditions
    # =========================================================================
    services.earlyoom = lib.mkIf cfg.earlyoom.enable {
      enable = true;
      freeMemThreshold = cfg.earlyoom.freeMemThreshold;
      freeSwapThreshold = cfg.earlyoom.freeSwapThreshold;

      # Don't kill important processes
      enableNotifications = true;

      # Extra args for better behavior
      extraArgs = [
        "-g"  # Kill entire process group
        "--avoid"
        "(^|/)(init|systemd|sshd|greetd|niri)$"
      ];
    };

    # =========================================================================
    # GNOME KEYRING ENHANCEMENTS
    # Ensure keyring auto-unlocks on login (complements greetd.nix)
    # =========================================================================
    # SSH agent via keyring (if not using standalone ssh-agent)
    programs.seahorse.enable = true;  # GUI for managing keyring

    # Ensure gnome-keyring handles secrets properly
    services.gnome.gnome-keyring.enable = lib.mkDefault true;

    # PAM integration for auto-unlock
    security.pam.services = {
      # Unlock keyring on console login
      login.enableGnomeKeyring = lib.mkDefault true;
      # Unlock keyring on greetd (display manager)
      greetd.enableGnomeKeyring = lib.mkDefault true;
      # Unlock keyring on sudo (optional, keeps keyring unlocked)
      sudo.enableGnomeKeyring = lib.mkDefault true;
    };
  };
}
