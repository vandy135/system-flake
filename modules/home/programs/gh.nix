{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homeModules.gh;
in {
  options.homeModules.gh = {
    enable = lib.mkEnableOption "GitHub CLI";
  };

  config = lib.mkIf cfg.enable {
    programs.gh = {
      enable = true;
      
      settings = {
        # Use nvim for editing
        editor = "nvim";
        
        # SSH is more secure and convenient with keys
        git_protocol = "ssh";
        
        # Prompt settings
        prompt = "enabled";
        
        # Aliases for common operations
        aliases = {
          co = "pr checkout";
          pv = "pr view";
          pc = "pr create";
          pl = "pr list";
          ps = "pr status";
          rv = "repo view";
          rc = "repo clone";
          il = "issue list";
          ic = "issue create";
          iv = "issue view";
        };
      };

      # GitHub CLI extensions
      extensions = with pkgs; [
        gh-dash      # Dashboard for PRs and issues
      ];
    };
  };
}
