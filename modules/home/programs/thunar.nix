{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homeModules.thunar;
in {
  options.homeModules.thunar = {
    enable = lib.mkEnableOption "Thunar file manager";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # Thunar and plugins
      xfce.thunar
      xfce.thunar-volman          # Volume management
      xfce.thunar-archive-plugin  # Archive support
      xfce.thunar-media-tags-plugin  # Media tags
      
      # Thumbnail support
      xfce.tumbler                # Thumbnail service
      ffmpegthumbnailer           # Video thumbnails
      webp-pixbuf-loader          # WebP support
      poppler                     # PDF thumbnails
      
      # Archive tools (for archive plugin)
      file-roller
      p7zip
      unzip
      unrar
    ];

    # Thunar configuration via dconf/xfconf
    xdg.configFile."Thunar/uca.xml".text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <actions>
        <action>
          <icon>utilities-terminal</icon>
          <name>Open Terminal Here</name>
          <unique-id>1-1</unique-id>
          <command>alacritty --working-directory %f</command>
          <description>Open terminal in this directory</description>
          <patterns>*</patterns>
          <directories/>
        </action>
        <action>
          <icon>nvim</icon>
          <name>Edit with Neovim</name>
          <unique-id>1-2</unique-id>
          <command>alacritty -e nvim %f</command>
          <description>Edit file with Neovim</description>
          <patterns>*</patterns>
          <text-files/>
        </action>
      </actions>
    '';

    # XDG file associations for Thunar
    xdg.mimeApps.defaultApplications = {
      "inode/directory" = ["thunar.desktop"];
    };
  };
}
