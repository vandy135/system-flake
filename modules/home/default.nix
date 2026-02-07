# Home Manager modules
# Imports all user-level program configurations
{...}: {
  imports = [
    # XDG base dirs + user dirs
    ./xdg.nix

    # Theme system (must be first - other modules depend on it)
    ./theme

    # Terminal & Shell
    ./programs/alacritty.nix   # Terminal emulator
    ./programs/shell.nix       # Zsh configuration
    ./programs/starship.nix    # Prompt
    ./programs/zellij.nix      # Terminal multiplexer
    ./programs/cli-tools.nix   # CLI utilities (eza, bat, fzf, etc.)
    ./programs/direnv.nix      # Directory environments

    # Desktop environment
    ./programs/niri.nix        # Niri compositor user config
    ./programs/fuzzel.nix      # Application launcher
    ./programs/mako.nix        # Notification daemon
    ./programs/waybar.nix      # Status bar

    # Development tools
    ./programs/git.nix         # Git configuration
    ./programs/lazygit.nix     # Git TUI
    ./programs/gh.nix          # GitHub CLI
    ./programs/neovim.nix      # Editor
    ./programs/claude-code.nix # Claude Code CLI (AI assistant)

    # Utilities
    ./programs/swaylock.nix    # Lock screen
    ./programs/thunar.nix      # File manager
    ./programs/media.nix       # Media players
    ./programs/obsidian.nix    # Knowledge management
  ];
}
