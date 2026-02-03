{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homeModules.git;
in {
  options.homeModules.git = {
    enable = lib.mkEnableOption "git with delta pager";
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      
      # Settings (merged aliases and extraConfig)
      settings = {
        # Aliases
        alias = {
          st = "status";
          co = "checkout";
          br = "branch";
          ci = "commit";
          lg = "log --oneline --graph --decorate";
          unstage = "reset HEAD --";
          last = "log -1 HEAD";
          amend = "commit --amend --no-edit";
          branches = "branch -a";
          remotes = "remote -v";
          stash-all = "stash save --include-untracked";
          undo = "reset --soft HEAD~1";
          graph = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)'";
        };

        # Core settings
        core = {
          editor = "nvim";
          autocrlf = "input";
        };
        pull = {
          rebase = true;
        };
        init = {
          defaultBranch = "main";
        };
        merge = {
          conflictstyle = "diff3";
        };
        diff = {
          colorMoved = "default";
        };
        rebase = {
          autoStash = true;
        };
        fetch = {
          prune = true;
        };
      };
    };

    # Delta as pager for beautiful diffs
    programs.delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true;
        line-numbers = true;
        side-by-side = false;
        syntax-theme = "Catppuccin Mocha";
        dark = true;
        plus-style = "syntax #1e3a2e";
        minus-style = "syntax #3a1e2e";
        plus-emph-style = "syntax #2e5a3e";
        minus-emph-style = "syntax #5a2e3e";
      };
    };

    # Ensure delta is available
    home.packages = with pkgs; [
      delta
    ];
  };
}
