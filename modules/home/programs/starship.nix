{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homeModules.starship;
  theme = config.homeModules.theme;
in {
  options.homeModules.starship = {
    enable = lib.mkEnableOption "starship prompt";
  };

  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableZshIntegration = true;

      settings = {
        # Minimal prompt format
        format = lib.concatStrings [
          "$directory"
          "$git_branch"
          "$git_status"
          "$nix_shell"
          "$nodejs"
          "$python"
          "$rust"
          "$golang"
          "$cmd_duration"
          "$line_break"
          "$character"
        ];

        # Right side prompt
        right_format = "$time";

        # Don't add blank line before prompt
        add_newline = true;

        # Character prompt
        character = {
          success_symbol = "[❯](bold ${theme.colors.green})";
          error_symbol = "[❯](bold ${theme.colors.red})";
          vimcmd_symbol = "[❮](bold ${theme.colors.green})";
        };

        # Directory
        directory = {
          style = "bold ${theme.colors.blue}";
          truncation_length = 3;
          truncate_to_repo = true;
          fish_style_pwd_dir_length = 1;
          format = "[$path]($style)[$read_only]($read_only_style) ";
          read_only = " 󰌾";
          read_only_style = "${theme.colors.red}";
        };

        # Git branch
        git_branch = {
          style = "${theme.colors.mauve}";
          format = "[$symbol$branch(:$remote_branch)]($style) ";
          symbol = " ";
          truncation_length = 20;
        };

        # Git status - compact indicators
        git_status = {
          style = "${theme.colors.orange}";
          format = "([$all_status$ahead_behind]($style) )";
          conflicted = "󰞇 ";
          ahead = "⇡$count";
          behind = "⇣$count";
          diverged = "⇕⇡$ahead_count⇣$behind_count";
          untracked = "?$count";
          stashed = "󰆓 ";
          modified = "!$count";
          staged = "+$count";
          renamed = "»$count";
          deleted = "✘$count";
        };

        # Nix shell indicator
        nix_shell = {
          style = "${theme.colors.secondary}";
          format = "[$symbol$state( \\($name\\))]($style) ";
          symbol = "󱄅 ";
          impure_msg = "";
          pure_msg = "pure";
          unknown_msg = "";
        };

        # Node.js
        nodejs = {
          style = "${theme.colors.green}";
          format = "[$symbol($version)]($style) ";
          symbol = "󰎙 ";
          detect_extensions = ["js" "mjs" "cjs" "ts" "mts" "cts"];
          detect_files = ["package.json" ".node-version" ".nvmrc"];
        };

        # Python
        python = {
          style = "${theme.colors.yellow}";
          format = "[$symbol$pyenv_prefix($version)(\\($virtualenv\\))]($style) ";
          symbol = "󰌠 ";
        };

        # Rust
        rust = {
          style = "${theme.colors.orange}";
          format = "[$symbol($version)]($style) ";
          symbol = "󱘗 ";
        };

        # Go
        golang = {
          style = "${theme.colors.cyan}";
          format = "[$symbol($version)]($style) ";
          symbol = "󰟓 ";
        };

        # Command duration
        cmd_duration = {
          style = "${theme.colors.yellow}";
          format = "[$duration]($style) ";
          min_time = 2000; # Show if command takes > 2s
          show_milliseconds = false;
        };

        # Time (right prompt)
        time = {
          disabled = false;
          style = "${theme.colors.overlay1}";
          format = "[$time]($style)";
          time_format = "%H:%M";
        };

        # Disable unused modules for speed
        aws.disabled = true;
        azure.disabled = true;
        gcloud.disabled = true;
        kubernetes.disabled = true;
        docker_context.disabled = true;
        package.disabled = true;
        terraform.disabled = true;
        vagrant.disabled = true;
        zig.disabled = true;
        elixir.disabled = true;
        elm.disabled = true;
        erlang.disabled = true;
        haskell.disabled = true;
        java.disabled = true;
        julia.disabled = true;
        kotlin.disabled = true;
        lua.disabled = true;
        nim.disabled = true;
        ocaml.disabled = true;
        perl.disabled = true;
        php.disabled = true;
        purescript.disabled = true;
        ruby.disabled = true;
        scala.disabled = true;
        swift.disabled = true;
        vlang.disabled = true;
      };
    };
  };
}
