# Graphics and NVIDIA driver configuration
{ config, lib, pkgs, ... }:

let
  cfg = config.hardwareModules.graphics;
in {
  options.hardwareModules.graphics = {
    enable = lib.mkEnableOption "graphics support (OpenGL/Vulkan)";

    nvidia = {
      enable = lib.mkEnableOption "NVIDIA proprietary drivers";

      package = lib.mkOption {
        type = lib.types.package;
        default = config.boot.kernelPackages.nvidiaPackages.stable;
        defaultText = lib.literalExpression "config.boot.kernelPackages.nvidiaPackages.stable";
        description = "The NVIDIA driver package to use";
      };

      open = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Use NVIDIA open source kernel modules (Turing+ GPUs).
          Recommended for RTX 20-series and newer.
        '';
      };

      powerManagement = {
        enable = lib.mkEnableOption "NVIDIA power management (saves VRAM on suspend)";
        finegrained = lib.mkEnableOption "fine-grained power management (Turing+ only)";
      };

      prime = {
        enable = lib.mkEnableOption "PRIME hybrid graphics (laptops with iGPU + dGPU)";

        mode = lib.mkOption {
          type = lib.types.enum [ "offload" "sync" "reverse-sync" ];
          default = "offload";
          description = ''
            PRIME mode:
            - offload: GPU sleeps unless explicitly called (best battery)
            - sync: Always use dGPU (best performance, higher power)
            - reverse-sync: Experimental reverse PRIME
          '';
        };

        intelBusId = lib.mkOption {
          type = lib.types.str;
          default = "";
          example = "PCI:0:2:0";
          description = "Bus ID of the Intel iGPU (use `lspci | grep VGA`)";
        };

        amdBusId = lib.mkOption {
          type = lib.types.str;
          default = "";
          example = "PCI:6:0:0";
          description = "Bus ID of the AMD iGPU (use `lspci | grep VGA`)";
        };

        nvidiaBusId = lib.mkOption {
          type = lib.types.str;
          default = "";
          example = "PCI:1:0:0";
          description = "Bus ID of the NVIDIA dGPU (use `lspci | grep VGA`)";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    # Base graphics support (OpenGL/Vulkan)
    {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;  # For Steam/Wine/32-bit games
      };
    }

    # NVIDIA configuration
    (lib.mkIf cfg.nvidia.enable {
      # Load NVIDIA driver for Xorg and Wayland
      services.xserver.videoDrivers = [ "nvidia" ];

      hardware.nvidia = {
        # Modesetting is required for Wayland
        modesetting.enable = true;

        # Power management settings
        powerManagement.enable = cfg.nvidia.powerManagement.enable;
        powerManagement.finegrained = cfg.nvidia.powerManagement.finegrained;

        # Open source kernel modules (Turing+)
        open = cfg.nvidia.open;

        # NVIDIA settings GUI
        nvidiaSettings = true;

        # Driver package
        package = cfg.nvidia.package;
      };

      # Useful packages for NVIDIA users
      environment.systemPackages = with pkgs; [
        nvtopPackages.nvidia  # GPU monitoring
        vulkan-tools          # vulkaninfo
        mesa-demos            # glxinfo, glxgears
      ];
    })

    # PRIME hybrid graphics configuration
    (lib.mkIf (cfg.nvidia.enable && cfg.nvidia.prime.enable) {
      # Add modesetting driver for iGPU
      services.xserver.videoDrivers = lib.mkBefore [ "modesetting" ];

      hardware.nvidia.prime = {
        # Set bus IDs
        intelBusId = lib.mkIf (cfg.nvidia.prime.intelBusId != "") cfg.nvidia.prime.intelBusId;
        amdgpuBusId = lib.mkIf (cfg.nvidia.prime.amdBusId != "") cfg.nvidia.prime.amdBusId;
        nvidiaBusId = cfg.nvidia.prime.nvidiaBusId;

        # Mode selection
        offload = lib.mkIf (cfg.nvidia.prime.mode == "offload") {
          enable = true;
          enableOffloadCmd = true;  # Provides `nvidia-offload` command
        };
        sync.enable = lib.mkIf (cfg.nvidia.prime.mode == "sync") true;
        reverseSync.enable = lib.mkIf (cfg.nvidia.prime.mode == "reverse-sync") true;
      };
    })
  ]);
}
