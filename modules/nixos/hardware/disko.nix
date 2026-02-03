# Declarative disk partitioning with disko
# Layout: EFI + Swap (hibernate) + Btrfs root with subvolumes
{
  config,
  lib,
  ...
}: let
  cfg = config.hardwareModules.disko;
in {
  options.hardwareModules.disko = {
    enable = lib.mkEnableOption "disko disk management";

    device = lib.mkOption {
      type = lib.types.str;
      example = "/dev/nvme0n1";
      description = "Disk device to partition";
    };

    efiSize = lib.mkOption {
      type = lib.types.str;
      default = "2G";
      description = "Size of EFI system partition";
    };

    swapSize = lib.mkOption {
      type = lib.types.str;
      default = "32G";
      description = "Size of swap partition";
    };

    enableHibernate = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable hibernate support (sets resume device)";
    };

    enableSsd = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable SSD optimizations (ssd mount option)";
    };
  };

  config = lib.mkIf cfg.enable {
    # Disko configuration
    disko.devices = {
      disk.main = {
        type = "disk";
        device = cfg.device;
        content = {
          type = "gpt";
          partitions = {
            # EFI System Partition
            ESP = {
              size = cfg.efiSize;
              type = "EF00"; # EFI System
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["defaults" "umask=0077"];
              };
            };

            # Swap partition with hibernate support
            swap = {
              size = cfg.swapSize;
              content = {
                type = "swap";
                discardPolicy = "both";
                resumeDevice = cfg.enableHibernate;
              };
            };

            # Btrfs root with subvolumes
            root = {
              size = "100%"; # Rest of disk
              content = {
                type = "btrfs";
                extraArgs = ["-f"]; # Force overwrite
                subvolumes = let
                  # Common mount options
                  baseOpts = ["compress=zstd" "noatime"];
                  ssdOpts = lib.optionals cfg.enableSsd ["ssd"];
                  mountOpts = baseOpts ++ ssdOpts;
                in {
                  # Root subvolume
                  "@" = {
                    mountpoint = "/";
                    mountOptions = mountOpts;
                  };

                  # Home subvolume
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = mountOpts;
                  };

                  # Nix store subvolume
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = mountOpts;
                  };

                  # Logs subvolume (separate for easy snapshotting exclusion)
                  "@log" = {
                    mountpoint = "/var/log";
                    mountOptions = mountOpts;
                  };
                };
              };
            };
          };
        };
      };
    };

    # NOTE: Hibernate resume is handled by disko when swap.content.resumeDevice = true
    # No need to set boot.resumeDevice manually - disko uses partlabel for reliability
  };
}
