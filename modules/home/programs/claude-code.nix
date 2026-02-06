# Claude Code - Anthropic's AI assistant CLI
# Installed via npm as @anthropic-ai/claude-code
#
# SECURITY NOTE: npx auto-install removed due to supply-chain risk.
# The wrapper now requires claude to be installed globally first.
# Install manually: npm install -g @anthropic-ai/claude-code
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homeModules.claudeCode;

  # Wrapper that uses globally installed claude-code
  # Does NOT auto-install via npx (supply-chain risk)
  claudeWrapper = pkgs.writeShellScriptBin "claude" ''
    # Ensure Node.js is available
    export PATH="${pkgs.nodejs}/bin:$PATH"
    
    # Check common install locations
    for dir in "$HOME/.npm-global/bin" "$HOME/.local/bin" "/usr/local/bin"; do
      if [[ -x "$dir/claude" ]]; then
        exec "$dir/claude" "$@"
      fi
    done
    
    # Check if in PATH
    if command -v claude &> /dev/null; then
      exec claude "$@"
    fi
    
    echo "Error: claude-code not installed." >&2
    echo "Install with: npm install -g @anthropic-ai/claude-code" >&2
    exit 1
  '';

  # Alternative: Build as a proper Node.js package
  claudeCodePkg = pkgs.buildNpmPackage rec {
    pname = "claude-code";
    version = "2.1.29";

    src = pkgs.fetchFromGitHub {
      owner = "anthropics";
      repo = "claude-code";
      rev = "v${version}";
      hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder - needs actual hash
    };

    npmDepsHash = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB="; # Placeholder

    # Skip build if no build script
    dontNpmBuild = true;

    meta = with lib; {
      description = "Anthropic's AI assistant CLI";
      homepage = "https://github.com/anthropics/claude-code";
      license = licenses.unfree;
      maintainers = [];
    };
  };
in {
  options.homeModules.claudeCode = {
    enable = lib.mkEnableOption "Claude Code CLI";

    package = lib.mkOption {
      type = lib.types.package;
      default = claudeWrapper;
      description = "The Claude Code package to use";
    };

    installMethod = lib.mkOption {
      type = lib.types.enum ["wrapper" "global"];
      default = "wrapper";
      description = ''
        Installation method:
        - wrapper: Wrapper script that finds globally installed claude (default)
        - global: Also triggers npm global install via home.activation
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      # Core dependencies
      pkgs.nodejs
      pkgs.git  # Claude Code needs git

      # The wrapper script
      cfg.package
    ];

    # Install globally if requested
    home.activation.installClaudeCode = lib.mkIf (cfg.installMethod == "global") (
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        # Install claude-code globally via npm if not present
        if ! command -v claude &> /dev/null; then
          $DRY_RUN_CMD ${pkgs.nodejs}/bin/npm install -g @anthropic-ai/claude-code
        fi
      ''
    );

    # Environment variables Claude Code might need
    home.sessionVariables = {
      # ANTHROPIC_API_KEY should be set elsewhere (sops-nix, etc.)
    };

    # Shell completion (if available)
    programs.zsh.initContent = lib.mkIf config.programs.zsh.enable ''
      # Claude Code completions (if installed globally)
      if command -v claude &> /dev/null; then
        eval "$(claude --completion zsh 2>/dev/null || true)"
      fi
    '';
  };
}
