# System Essentials - Core utilities and hardware support
# PipeWire, Bluetooth, and commonly-needed packages
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.systemModules.essentials;
in {
  options.systemModules.essentials = {
    enable = lib.mkEnableOption "system essentials (audio, bluetooth, utilities)";

    audio = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable PipeWire audio with WirePlumber";
      };
    };

    bluetooth = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Bluetooth support with Blueman GUI";
      };
    };

    utilities = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable common system utilities";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # =========================================================================
    # PIPEWIRE AUDIO
    # Modern audio server with ALSA and PulseAudio compatibility
    # =========================================================================
    services.pipewire = lib.mkIf cfg.audio.enable {
      enable = true;

      # ALSA support
      alsa.enable = true;
      alsa.support32Bit = true;

      # PulseAudio compatibility (for apps that expect PulseAudio)
      pulse.enable = true;

      # JACK compatibility (for pro audio apps)
      jack.enable = true;

      # WirePlumber session manager (recommended over pipewire-media-session)
      wireplumber.enable = true;
    };

    # RealtimeKit for PipeWire
    security.rtkit.enable = lib.mkIf cfg.audio.enable true;

    # =========================================================================
    # BLUETOOTH
    # =========================================================================
    hardware.bluetooth = lib.mkIf cfg.bluetooth.enable {
      enable = true;
      powerOnBoot = true;

      settings = {
        General = {
          # Enable A2DP sink (for high-quality audio)
          Enable = "Source,Sink,Media,Socket";
          # Fast connect (remember devices)
          FastConnectable = true;
        };
      };
    };

    # Blueman GUI for Bluetooth management
    services.blueman.enable = lib.mkIf cfg.bluetooth.enable true;

    # =========================================================================
    # COMMON UTILITIES
    # Packages that are often missing but frequently needed
    # =========================================================================
    environment.systemPackages = lib.mkIf cfg.utilities.enable (with pkgs; [
      # Archive utilities
      unzip
      zip
      p7zip
      unrar

      # Network utilities
      wget
      curl

      # System monitoring
      htop
      btop
      lsof

      # File utilities
      tree
      file
      ncdu  # NCurses Disk Usage

      # Hardware info
      usbutils    # lsusb
      pciutils    # lspci
      lm_sensors  # sensors
      dmidecode   # Hardware info

      # Filesystem support
      ntfs3g      # NTFS read/write
      exfat       # exFAT support

      # Documentation
      man-pages
      man-pages-posix

      # Networking
      inetutils   # telnet, ftp, etc.
      dnsutils    # dig, nslookup
      traceroute

      # Text processing
      jq          # JSON processor

      # Misc essentials
      killall
      psmisc      # fuser, killall, pstree
      which
    ]);

    # Enable man-db for man pages
    documentation = lib.mkIf cfg.utilities.enable {
      enable = true;
      man.enable = true;
      man.generateCaches = true;
      info.enable = true;
      doc.enable = true;
    };

    # =========================================================================
    # NETWORKING (NetworkManager)
    # Usually already enabled, but ensure it's configured properly
    # =========================================================================
    networking.networkmanager = {
      enable = lib.mkDefault true;

      # DNS configuration
      dns = lib.mkDefault "systemd-resolved";

      # WiFi backend (iwd is faster and more reliable than wpa_supplicant)
      wifi.backend = lib.mkDefault "wpa_supplicant";

      # Ethernet configuration
      ethernet.macAddress = lib.mkDefault "preserve";
    };

    # Systemd-resolved for DNS caching
    services.resolved = {
      enable = lib.mkDefault true;
      dnssec = "allow-downgrade";
      fallbackDns = [
        "1.1.1.1"
        "8.8.8.8"
      ];
    };

    # =========================================================================
    # FIRMWARE
    # Enable non-free firmware for better hardware support
    # =========================================================================
    hardware.enableRedistributableFirmware = lib.mkDefault true;

    # =========================================================================
    # POWER MANAGEMENT
    # Basic power management for laptops
    # =========================================================================
    services.upower.enable = lib.mkDefault true;
    services.thermald.enable = lib.mkDefault true;

    # =========================================================================
    # SECURITY
    # Basic security settings
    # =========================================================================
    security = {
      # Polkit for GUI privilege escalation
      polkit.enable = true;

      # Allow wheel group to use sudo
      sudo = {
        enable = true;
        wheelNeedsPassword = true;
      };
    };
  };
}
