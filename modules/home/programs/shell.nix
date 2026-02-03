{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homeModules.shell;
in {
  options.homeModules.shell = {
    enable = lib.mkEnableOption "zsh shell configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      # History settings
      history = {
        size = 50000;
        save = 50000;
        path = "${config.xdg.dataHome}/zsh/history";
        ignoreDups = true;
        ignoreAllDups = true;
        ignoreSpace = true;
        extended = true;
        share = true;
      };

      # Shell aliases - modern replacements
      shellAliases = {
        # File listing (eza replaces ls)
        ls = "eza --icons --group-directories-first";
        ll = "eza -la --icons --group-directories-first --git";
        la = "eza -a --icons --group-directories-first";
        lt = "eza --tree --icons --level=2";
        l = "eza -l --icons --group-directories-first";

        # File viewing (bat replaces cat)
        cat = "bat --paging=never";
        less = "bat";

        # Search tools
        grep = "rg";
        find = "fd";

        # Quick navigation
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";

        # Git shortcuts
        g = "git";
        gs = "git status";
        ga = "git add";
        gc = "git commit";
        gp = "git push";
        gl = "git pull";
        gd = "git diff";
        gco = "git checkout";
        gb = "git branch";
        glog = "git log --oneline --graph --decorate";

        # Nix shortcuts
        nrs = "sudo nixos-rebuild switch --flake .";
        nrt = "sudo nixos-rebuild test --flake .";
        hms = "home-manager switch --flake .";

        # Safety
        rm = "rm -i";
        cp = "cp -i";
        mv = "mv -i";

        # Misc
        c = "clear";
        q = "exit";
        path = "echo $PATH | tr ':' '\n'";
      };

      # Init content - shell integrations and hooks
      initContent = ''
        # Zoxide (smart cd) - must be after compinit
        eval "$(${pkgs.zoxide}/bin/zoxide init zsh --cmd cd)"

        # Direnv integration
        eval "$(${pkgs.direnv}/bin/direnv hook zsh)"

        # FZF keybindings
        source ${pkgs.fzf}/share/fzf/key-bindings.zsh
        source ${pkgs.fzf}/share/fzf/completion.zsh

        # Better history search with up/down arrows
        bindkey '^[[A' history-search-backward
        bindkey '^[[B' history-search-forward
        bindkey '^P' history-search-backward
        bindkey '^N' history-search-forward

        # Edit command line in editor
        autoload -U edit-command-line
        zle -N edit-command-line
        bindkey '^X^E' edit-command-line

        # Word navigation
        bindkey '^[[1;5C' forward-word   # Ctrl+Right
        bindkey '^[[1;5D' backward-word  # Ctrl+Left

        # Case-insensitive completion
        zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

        # Colored completion menu
        zstyle ':completion:*' menu select
        zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}

        # SSH agent (use existing from gnome-keyring if available)
        if [ -n "$SSH_AUTH_SOCK" ]; then
          export SSH_AUTH_SOCK
        fi
      '';

      # Profile extra - runs once at login
      profileExtra = ''
        # Wayland environment variables
        export NIXOS_OZONE_WL=1
        export MOZ_ENABLE_WAYLAND=1
        export QT_QPA_PLATFORM=wayland
        export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
        export SDL_VIDEODRIVER=wayland
        export _JAVA_AWT_WM_NONREPARENTING=1
        export GDK_BACKEND=wayland,x11
        export CLUTTER_BACKEND=wayland

        # XDG defaults
        export XDG_SESSION_TYPE=wayland

        # Editor
        export EDITOR=nvim
        export VISUAL=nvim

        # Pager
        export PAGER="bat --style=plain"
        export MANPAGER="sh -c 'col -bx | bat -l man -p'"

        # Less with colors
        export LESS='-R --use-color -Dd+r$Du+b'
      '';

      # Plugins
      plugins = [
        {
          name = "zsh-nix-shell";
          file = "nix-shell.plugin.zsh";
          src = pkgs.zsh-nix-shell;
        }
      ];
    };

    # Set zsh as default shell (handled by NixOS config usually)
    home.sessionVariables = {
      SHELL = "${pkgs.zsh}/bin/zsh";
    };

    # Ensure supporting packages are available
    home.packages = with pkgs; [
      zsh-nix-shell
    ];
  };
}
