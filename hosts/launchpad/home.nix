{
  config,
  pkgs,
  ...
}: {
  imports = [../../modules/home];

  home.username = "titan";
  home.homeDirectory = "/home/titan";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  # ==========================================================================
  # THEME CONFIGURATION
  # Change this ONE variable to switch themes everywhere
  # Options: "catppuccin-mocha" | "tokyo-night" | "everforest"
  # ==========================================================================
  homeModules.theme = {
    enable = true;
    name = "catppuccin-mocha";
  };

  # ==========================================================================
  # DESKTOP ENVIRONMENT
  # ==========================================================================
  homeModules.niri.enable = true;       # Wayland compositor (user config)
  homeModules.fuzzel.enable = true;     # Application launcher
  homeModules.mako.enable = true;       # Notification daemon
  homeModules.waybar.enable = true;     # Status bar

  # ==========================================================================
  # TERMINAL & SHELL
  # ==========================================================================
  homeModules.alacritty.enable = true;  # Terminal emulator
  homeModules.shell.enable = true;      # Zsh + aliases + env vars
  homeModules.starship.enable = true;   # Prompt
  homeModules.zellij.enable = true;     # Terminal multiplexer
  homeModules.cliTools.enable = true;   # eza, bat, fzf, ripgrep, fd, etc.

  # ==========================================================================
  # DEVELOPMENT TOOLS
  # ==========================================================================
  homeModules.neovim.enable = true;     # Editor with LSP
  homeModules.git.enable = true;        # Git + delta
  homeModules.lazygit.enable = true;    # Git TUI
  homeModules.gh.enable = true;         # GitHub CLI
  homeModules.direnv.enable = true;     # nix-direnv

  # ==========================================================================
  # UTILITIES
  # ==========================================================================
  homeModules.swaylock.enable = true;   # Lock screen + swayidle
  homeModules.thunar.enable = true;     # File manager
  homeModules.media.enable = true;      # imv, mpv, grim, slurp
  homeModules.obsidian.enable = true;   # Note-taking & knowledge base

  # ==========================================================================
  # AI TOOLS
  # ==========================================================================
  homeModules.claudeCode.enable = true; # Claude Code CLI (uses npx wrapper)
}
