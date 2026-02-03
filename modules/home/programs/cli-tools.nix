{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homeModules.cliTools;
  theme = config.homeModules.theme;

  # Helper to strip # from hex colors
  stripHash = color: lib.removePrefix "#" color;
in {
  options.homeModules.cliTools = {
    enable = lib.mkEnableOption "CLI tools configuration";
  };

  config = lib.mkIf cfg.enable {
    # eza - modern ls replacement
    programs.eza = {
      enable = true;
      icons = "auto";
      git = true;
      extraOptions = [
        "--group-directories-first"
        "--header"
      ];
    };

    # bat - modern cat replacement with syntax highlighting
    programs.bat = {
      enable = true;
      config = {
        theme = "Catppuccin Mocha";
        style = "numbers,changes,header";
        italic-text = "always";
        pager = "less -FR";
      };
      themes = {
        "Catppuccin Mocha" = {
          src = pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "bat";
            rev = "d2bbee4f7e7d5bac63c054e4d8efa57a2571c005";
            sha256 = "sha256-x1yqPCWuoBSx/cI94eA+AWwhiSA42cLNUOFJl7qjhmw=";
          };
          file = "themes/Catppuccin Mocha.tmTheme";
        };
      };
    };

    # ripgrep - fast grep replacement
    programs.ripgrep = {
      enable = true;
      arguments = [
        "--smart-case"
        "--hidden"
        "--glob=!.git/*"
        "--colors=line:fg:yellow"
        "--colors=line:style:bold"
        "--colors=path:fg:green"
        "--colors=path:style:bold"
        "--colors=match:fg:red"
        "--colors=match:style:bold"
      ];
    };

    # fd - fast find replacement
    programs.fd = {
      enable = true;
      hidden = true;
      ignores = [
        ".git/"
        "node_modules/"
        "target/"
        ".direnv/"
      ];
    };

    # zoxide - smart cd replacement
    programs.zoxide = {
      enable = true;
      enableZshIntegration = false; # We handle this in shell.nix for proper ordering
      options = [
        "--cmd cd"
      ];
    };

    # btop - system monitor
    programs.btop = {
      enable = true;
      settings = {
        color_theme = "catppuccin_mocha";
        theme_background = false;
        truecolor = true;
        force_tty = false;
        vim_keys = true;
        rounded_corners = true;
        graph_symbol = "braille";
        shown_boxes = "cpu mem net proc";
        update_ms = 1000;
        proc_sorting = "cpu lazy";
        proc_tree = false;
        proc_colors = true;
        proc_gradient = true;
        proc_per_core = false;
        proc_mem_bytes = true;
        proc_filter_kernel = false;
        cpu_graph_upper = "total";
        cpu_graph_lower = "total";
        cpu_invert_lower = true;
        cpu_single_graph = false;
        show_uptime = true;
        check_temp = true;
        show_coretemp = true;
        temp_scale = "celsius";
        show_cpu_freq = true;
        clock_format = "%H:%M";
        background_update = true;
        mem_graphs = true;
        show_swap = true;
        swap_disk = true;
        show_disks = true;
        show_io_stat = true;
        io_mode = false;
        net_download = 100;
        net_upload = 100;
        net_auto = true;
        net_sync = false;
        net_iface = "";
        show_battery = true;
        log_level = "WARNING";
      };
    };

    # btop catppuccin theme
    xdg.configFile."btop/themes/catppuccin_mocha.theme".text = ''
      # Catppuccin Mocha theme for btop
      theme[main_bg]="${theme.colors.background}"
      theme[main_fg]="${theme.colors.foreground}"
      theme[title]="${theme.colors.foreground}"
      theme[hi_fg]="${theme.colors.blue}"
      theme[selected_bg]="${theme.colors.surface0}"
      theme[selected_fg]="${theme.colors.foreground}"
      theme[inactive_fg]="${theme.colors.overlay0}"
      theme[graph_text]="${theme.colors.subtext0}"
      theme[meter_bg]="${theme.colors.surface0}"
      theme[proc_misc]="${theme.colors.subtext0}"
      theme[cpu_box]="${theme.colors.blue}"
      theme[mem_box]="${theme.colors.green}"
      theme[net_box]="${theme.colors.mauve}"
      theme[proc_box]="${theme.colors.orange}"
      theme[div_line]="${theme.colors.surface1}"
      theme[temp_start]="${theme.colors.green}"
      theme[temp_mid]="${theme.colors.yellow}"
      theme[temp_end]="${theme.colors.red}"
      theme[cpu_start]="${theme.colors.blue}"
      theme[cpu_mid]="${theme.colors.lavender}"
      theme[cpu_end]="${theme.colors.mauve}"
      theme[free_start]="${theme.colors.green}"
      theme[free_mid]="${theme.colors.teal}"
      theme[free_end]="${theme.colors.secondary}"
      theme[cached_start]="${theme.colors.secondary}"
      theme[cached_mid]="${theme.colors.blue}"
      theme[cached_end]="${theme.colors.lavender}"
      theme[available_start]="${theme.colors.orange}"
      theme[available_mid]="${theme.colors.yellow}"
      theme[available_end]="${theme.colors.green}"
      theme[used_start]="${theme.colors.green}"
      theme[used_mid]="${theme.colors.yellow}"
      theme[used_end]="${theme.colors.red}"
      theme[download_start]="${theme.colors.green}"
      theme[download_mid]="${theme.colors.teal}"
      theme[download_end]="${theme.colors.secondary}"
      theme[upload_start]="${theme.colors.red}"
      theme[upload_mid]="${theme.colors.orange}"
      theme[upload_end]="${theme.colors.pink}"
      theme[process_start]="${theme.colors.blue}"
      theme[process_mid]="${theme.colors.lavender}"
      theme[process_end]="${theme.colors.mauve}"
    '';

    # fzf - fuzzy finder with theme colors
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "fd --type f --hidden --follow --exclude .git";
      defaultOptions = [
        "--height 40%"
        "--layout=reverse"
        "--border"
        "--inline-info"
        "--color=bg+:${theme.colors.surface0}"
        "--color=bg:${theme.colors.background}"
        "--color=spinner:${theme.colors.accent}"
        "--color=hl:${theme.colors.red}"
        "--color=fg:${theme.colors.foreground}"
        "--color=header:${theme.colors.red}"
        "--color=info:${theme.colors.mauve}"
        "--color=pointer:${theme.colors.accent}"
        "--color=marker:${theme.colors.accent}"
        "--color=fg+:${theme.colors.foreground}"
        "--color=prompt:${theme.colors.mauve}"
        "--color=hl+:${theme.colors.red}"
        "--color=border:${theme.colors.surface1}"
      ];
      fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
      fileWidgetOptions = [
        "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
      ];
      changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
      changeDirWidgetOptions = [
        "--preview 'eza --tree --level=2 --color=always {}'"
      ];
      historyWidgetOptions = [
        "--sort"
        "--exact"
      ];
    };

    # jq - JSON processor
    programs.jq.enable = true;

    # Note: direnv is configured separately in direnv.nix

    # Additional CLI packages
    home.packages = with pkgs; [
      # HTTP client
      xh

      # JSON viewer
      jless

      # Git diff tool
      delta

      # Man page summaries
      tldr

      # Additional utilities
      procs      # Modern ps
      dust       # Disk usage
      duf        # Disk usage/free
      hyperfine  # Benchmarking
      tokei      # Code statistics
      bandwhich  # Network utilization
      bottom     # Alternative to btop (lightweight)
      gping      # Ping with graph
      dogdns     # DNS client
    ];

  };
}
