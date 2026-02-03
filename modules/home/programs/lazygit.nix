{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homeModules.lazygit;
in {
  options.homeModules.lazygit = {
    enable = lib.mkEnableOption "lazygit TUI";
  };

  config = lib.mkIf cfg.enable {
    programs.lazygit = {
      enable = true;
      settings = {
        gui = {
          # Catppuccin Mocha inspired theme
          theme = {
            activeBorderColor = ["#cba6f7" "bold"];  # Mauve
            inactiveBorderColor = ["#6c7086"];       # Overlay0
            searchingActiveBorderColor = ["#f9e2af" "bold"];  # Yellow
            optionsTextColor = ["#89b4fa"];          # Blue
            selectedLineBgColor = ["#313244"];       # Surface0
            cherryPickedCommitBgColor = ["#45475a"]; # Surface1
            cherryPickedCommitFgColor = ["#cba6f7"]; # Mauve
            unstagedChangesColor = ["#f38ba8"];      # Red
            defaultFgColor = ["#cdd6f4"];            # Text
          };
          showIcons = true;
          showFileTree = true;
          showRandomTip = false;
          showBottomLine = true;
          nerdFontsVersion = "3";
        };
        git = {
          paging = {
            colorArg = "always";
            pager = "delta --dark --paging=never";
          };
          commit = {
            signOff = false;
          };
          merging = {
            manualCommit = false;
            args = "";
          };
        };
        os = {
          editPreset = "nvim";
        };
        notARepository = "skip";
        disableStartupPopups = true;
      };
    };
  };
}
