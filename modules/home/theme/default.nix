# Theme Module - Single source of truth for all application colors
#
# Usage:
#   homeModules.theme = {
#     enable = true;
#     name = "catppuccin-mocha";  # Change this to switch themes
#   };
#
# Access colors in other modules:
#   config.homeModules.theme.colors.primary
#   config.homeModules.theme.colors.base00
#   etc.
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homeModules.theme;

  # Available color schemes
  schemes = {
    catppuccin-mocha = import ./schemes/catppuccin-mocha.nix;
    tokyo-night = import ./schemes/tokyo-night.nix;
    everforest = import ./schemes/everforest.nix;
  };

  # Get the selected scheme
  selectedScheme = schemes.${cfg.name} or schemes.catppuccin-mocha;
in {
  imports = [
    ./gtk.nix
    ./qt.nix
    ./cursor.nix
    ./fonts.nix
  ];

  options.homeModules.theme = {
    enable = lib.mkEnableOption "unified theme system";

    name = lib.mkOption {
      type = lib.types.enum (builtins.attrNames schemes);
      default = "catppuccin-mocha";
      description = "Name of the color scheme to use";
      example = "tokyo-night";
    };

    # Expose all colors as options for other modules to consume
    colors = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      readOnly = true;
      default = selectedScheme;
      description = ''
        Color palette from the selected theme.
        Includes base16 colors (base00-base0F), semantic colors,
        and accent colors for consistent theming across applications.
      '';
    };

    # Font configuration exposed for other modules
    fonts = {
      monospace = lib.mkOption {
        type = lib.types.str;
        default = "CaskaydiaCove Nerd Font";
        description = "Primary monospace font";
      };

      sansSerif = lib.mkOption {
        type = lib.types.str;
        default = "Inter";
        description = "Primary sans-serif font";
      };

      serif = lib.mkOption {
        type = lib.types.str;
        default = "Noto Serif";
        description = "Primary serif font";
      };

      size = lib.mkOption {
        type = lib.types.int;
        default = 11;
        description = "Default font size";
      };
    };
  };

  # Note: config section is minimal here - sub-modules handle their own config
  # This module primarily exposes the color scheme for other modules to use
}
