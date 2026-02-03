{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homeModules.direnv;
in {
  options.homeModules.direnv = {
    enable = lib.mkEnableOption "direnv with nix-direnv";
  };

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      
      # nix-direnv for faster nix shell loading
      nix-direnv.enable = true;

      # Silent logging - don't spam the terminal
      silent = true;

      # Optional: even more silent with stdlib override
      stdlib = ''
        # Quieter direnv output
        : ''${DIRENV_LOG_FORMAT:=""}
      '';
    };
  };
}
