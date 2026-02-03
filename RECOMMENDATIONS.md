# NixOS Flake Recommendations

This document outlines recommended improvements, additions, and best practices for the system flake.

---

## 📦 Missing Essentials

### High Priority

| Package/Feature | Why | Module/Location |
|-----------------|-----|-----------------|
| **PipeWire** | Modern audio (replaces PulseAudio) | `modules/nixos/system/essentials.nix` ✅ |
| **Bluetooth** | Wireless devices | `modules/nixos/system/essentials.nix` ✅ |
| **Common utils** | unzip, wget, curl, htop, etc. | `modules/nixos/system/essentials.nix` ✅ |
| **CUPS printing** | Printer support | Create `modules/nixos/services/printing.nix` |
| **Flatpak** | Sandboxed apps fallback | `services.flatpak.enable` |
| **GnuPG** | GPG keys & signing | `programs.gnupg.agent.enable` |

### Medium Priority

| Package/Feature | Why |
|-----------------|-----|
| **Plymouth** | Boot splash screen |
| **systemd-boot** | Already enabled, consider refind for multi-boot |
| **NetworkManager applet** | nm-applet for tray |
| **Polkit agents** | GUI auth dialogs (polkit-kde-agent) |
| **XDG portals** | For Wayland apps (file pickers, etc.) |

---

## 🔒 Security Hardening

### System Level

```nix
# Add to system configuration:
security = {
  # AppArmor (alternative to SELinux, easier)
  apparmor = {
    enable = true;
    killUnconfinedConfinables = true;
  };

  # Audit framework
  auditd.enable = true;

  # Kernel hardening
  protectKernelImage = true;

  # Restrict ptrace (debugging)
  allowSimultaneousMultithreading = true;
};

boot.kernel.sysctl = {
  # Network hardening
  "net.ipv4.conf.all.rp_filter" = 1;
  "net.ipv4.conf.default.rp_filter" = 1;
  "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
  "net.ipv4.conf.all.accept_redirects" = 0;
  "net.ipv6.conf.all.accept_redirects" = 0;
  
  # Kernel hardening
  "kernel.kptr_restrict" = 2;
  "kernel.dmesg_restrict" = 1;
  "kernel.unprivileged_bpf_disabled" = 1;
  "net.core.bpf_jit_harden" = 2;
};

# Firewall
networking.firewall = {
  enable = true;
  allowedTCPPorts = [ ]; # Explicitly list allowed ports
  allowedUDPPorts = [ ];
  logReversePathDrops = true;
};
```

### User Level

```nix
# Firejail for sandboxing untrusted apps
programs.firejail = {
  enable = true;
  wrappedBinaries = {
    firefox = {
      executable = "${pkgs.firefox}/bin/firefox";
      profile = "${pkgs.firejail}/etc/firejail/firefox.profile";
    };
  };
};
```

---

## ⚡ Performance Tweaks

### I/O & Storage

```nix
# Faster boot (parallel startup)
systemd.services."*".serviceConfig.DefaultTimeoutStartSec = "15s";

# Better I/O scheduler for SSDs
services.udev.extraRules = ''
  # Set scheduler for NVMe
  ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
  # Set scheduler for SSDs
  ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
'';

# ZRAM swap (compressed RAM swap)
zramSwap = {
  enable = true;
  algorithm = "zstd";
  memoryPercent = 50;
};

# Faster DNS
networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
```

### Memory & CPU

```nix
# Earlyoom (prevent OOM freezes)
services.earlyoom = {
  enable = true;
  freeMemThreshold = 5;
  freeSwapThreshold = 10;
};

# Ananicy-cpp (auto nice/ionice)
services.ananicy = {
  enable = true;
  package = pkgs.ananicy-cpp;
};

# Preload (preload frequently used apps)
services.preload.enable = true;
```

### Nix-specific

```nix
nix.settings = {
  # Parallel builds
  max-jobs = "auto";
  cores = 0; # Use all cores
  
  # Build optimization
  auto-optimise-store = true;
  
  # Caches
  substituters = [
    "https://cache.nixos.org"
    "https://nix-community.cachix.org"
  ];
  trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];
};
```

---

## 🎮 Gaming (Optional)

```nix
# modules/nixos/gaming/default.nix
{ config, lib, pkgs, ... }: {
  options.gaming.enable = lib.mkEnableOption "gaming support";

  config = lib.mkIf config.gaming.enable {
    # Steam
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
    
    # GameMode
    programs.gamemode = {
      enable = true;
      settings.general.renice = 10;
    };
    
    # Vulkan & OpenGL
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
    
    # Game controllers
    hardware.steam-hardware.enable = true;
    
    # Packages
    environment.systemPackages = with pkgs; [
      mangohud   # Performance overlay
      gamemode   # Optimizations
      protonup-qt # Proton versions
      lutris     # Game launcher
      heroic     # Epic/GOG launcher
    ];
  };
}
```

---

## 🛠️ Development Tools (Optional)

```nix
# modules/home/programs/dev-tools.nix
{ config, lib, pkgs, ... }: {
  options.homeModules.devTools.enable = lib.mkEnableOption "development tools";

  config = lib.mkIf config.homeModules.devTools.enable {
    home.packages = with pkgs; [
      # Languages
      rustup
      go
      python3
      nodejs
      
      # Build tools
      gnumake
      cmake
      ninja
      meson
      
      # Containers
      docker-compose
      podman
      
      # Database clients
      postgresql
      sqlite
      
      # API tools
      httpie
      postman
      
      # K8s
      kubectl
      k9s
      helm
    ];
    
    # Docker (rootless)
    services.docker.enable = true;
  };
}
```

---

## 🔐 Secrets Management

### Option 1: sops-nix (Recommended)

Already in flake inputs! Usage:

```nix
# hosts/launchpad/default.nix
{
  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    
    age.keyFile = "/home/titan/.config/sops/age/keys.txt";
    
    secrets = {
      "user/password" = {
        neededForUsers = true;
      };
      "api/anthropic" = {
        owner = "titan";
      };
    };
  };
  
  # Use secrets
  users.users.titan.hashedPasswordFile = config.sops.secrets."user/password".path;
}
```

Setup:
```bash
# Generate age key
nix shell nixpkgs#age -c age-keygen -o ~/.config/sops/age/keys.txt

# Create .sops.yaml in repo root
cat > .sops.yaml << EOF
keys:
  - &titan age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
creation_rules:
  - path_regex: secrets/.*\.yaml$
    key_groups:
      - age:
          - *titan
EOF

# Create encrypted secrets
nix shell nixpkgs#sops -c sops secrets/secrets.yaml
```

### Option 2: agenix

Simpler but less flexible:

```nix
# flake.nix inputs
agenix.url = "github:ryantm/agenix";

# Configuration
age.secrets.anthropic-api = {
  file = ./secrets/anthropic-api.age;
  owner = "titan";
};
```

---

## 📁 Modular Improvements

### Suggested Directory Structure

```
system-flake/
├── flake.nix
├── flake.lock
├── RECOMMENDATIONS.md
│
├── hosts/
│   ├── launchpad/
│   │   ├── default.nix
│   │   ├── home.nix
│   │   ├── hardware-configuration.nix
│   │   └── secrets/           # sops-encrypted secrets
│   │       └── secrets.yaml
│   └── control-tower/
│       └── ...
│
├── modules/
│   ├── nixos/
│   │   ├── desktop/           # Desktop environment
│   │   │   ├── default.nix
│   │   │   ├── niri.nix
│   │   │   └── greetd.nix
│   │   ├── system/            # System essentials ✅
│   │   │   ├── default.nix
│   │   │   └── essentials.nix
│   │   ├── services/          # System services (NEW)
│   │   │   ├── default.nix
│   │   │   ├── printing.nix
│   │   │   └── virtualization.nix
│   │   ├── security/          # Security hardening (NEW)
│   │   │   ├── default.nix
│   │   │   └── hardening.nix
│   │   └── gaming/            # Gaming support (NEW)
│   │       └── default.nix
│   │
│   └── home/
│       ├── default.nix
│       ├── theme/
│       └── programs/
│           ├── alacritty.nix
│           ├── obsidian.nix   # ✅ Added
│           ├── claude-code.nix # ✅ Added
│           └── ...
│
├── lib/                       # Helper functions (NEW)
│   └── default.nix
│
├── overlays/                  # Package overlays (NEW)
│   └── default.nix
│
└── packages/                  # Custom packages (NEW)
    └── default.nix
```

### Host-Agnostic Modules

Create option-driven modules that work across hosts:

```nix
# Example: modules/nixos/profiles/laptop.nix
{ config, lib, ... }: {
  options.profiles.laptop = lib.mkEnableOption "laptop optimizations";

  config = lib.mkIf config.profiles.laptop {
    services.tlp.enable = true;
    services.thermald.enable = true;
    hardware.bluetooth.enable = true;
    # ... laptop-specific settings
  };
}
```

---

## 📋 Checklist

### Immediate Actions
- [x] Add PipeWire audio
- [x] Add Bluetooth support
- [x] Add common system utilities
- [x] Create essentials module
- [x] Add Obsidian to home-manager
- [x] Create Claude Code module
- [ ] Enable essentials in host config

### Short-term
- [ ] Set up sops-nix for secrets
- [ ] Add XDG portal configuration
- [ ] Create gaming module (if needed)
- [ ] Add printing support
- [ ] Configure firewall rules

### Long-term
- [ ] Security hardening module
- [ ] Backup solution (restic/borg)
- [ ] Monitoring (prometheus/grafana or simple)
- [ ] Automatic updates configuration
- [ ] Multi-host secrets management

---

## 🔗 Useful Resources

- [NixOS Wiki](https://wiki.nixos.org/)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.html)
- [NixOS Options Search](https://search.nixos.org/options)
- [Nix Packages Search](https://search.nixos.org/packages)
- [sops-nix Guide](https://github.com/Mic92/sops-nix)
- [nix-community/awesome-nix](https://github.com/nix-community/awesome-nix)
