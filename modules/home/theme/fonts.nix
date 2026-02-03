# Fonts Module
# Installs and configures fonts for the system
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homeModules.theme;
in {
  config = lib.mkIf cfg.enable {
    # Install fonts
    home.packages = with pkgs; [
      # Primary monospace - CascadiaCode Nerd Font
      nerd-fonts.caskaydia-cove
      
      # Additional Nerd Fonts for fallback/variety
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      
      # Sans-serif fonts
      inter
      roboto
      
      # Serif fonts
      noto-fonts-cjk-serif
      noto-fonts
      
      # Emoji support
      noto-fonts-color-emoji
      
      # Icon fonts
      font-awesome
    ];

    # Fontconfig settings
    fonts.fontconfig = {
      enable = true;
      
      defaultFonts = {
        monospace = [cfg.fonts.monospace "JetBrainsMono Nerd Font"];
        sansSerif = [cfg.fonts.sansSerif "Roboto"];
        serif = [cfg.fonts.serif "Noto Serif"];
        emoji = ["Noto Color Emoji"];
      };
    };

    # XDG fontconfig for apps that read it directly
    xdg.configFile."fontconfig/fonts.conf".text = ''
      <?xml version="1.0"?>
      <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
      <fontconfig>
        <!-- Default fonts -->
        <alias>
          <family>monospace</family>
          <prefer>
            <family>${cfg.fonts.monospace}</family>
            <family>JetBrainsMono Nerd Font</family>
          </prefer>
        </alias>
        <alias>
          <family>sans-serif</family>
          <prefer>
            <family>${cfg.fonts.sansSerif}</family>
            <family>Roboto</family>
          </prefer>
        </alias>
        <alias>
          <family>serif</family>
          <prefer>
            <family>${cfg.fonts.serif}</family>
            <family>Noto Serif</family>
          </prefer>
        </alias>
        
        <!-- Emoji fallback -->
        <match target="pattern">
          <edit name="family" mode="append">
            <string>Noto Color Emoji</string>
          </edit>
        </match>
        
        <!-- Enable antialiasing -->
        <match target="font">
          <edit name="antialias" mode="assign">
            <bool>true</bool>
          </edit>
          <edit name="hinting" mode="assign">
            <bool>true</bool>
          </edit>
          <edit name="hintstyle" mode="assign">
            <const>hintslight</const>
          </edit>
          <edit name="rgba" mode="assign">
            <const>rgb</const>
          </edit>
          <edit name="lcdfilter" mode="assign">
            <const>lcddefault</const>
          </edit>
        </match>
      </fontconfig>
    '';
  };
}
