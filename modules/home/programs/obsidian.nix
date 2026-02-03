# Obsidian - Knowledge management and note-taking
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homeModules.obsidian;
in {
  options.homeModules.obsidian = {
    enable = lib.mkEnableOption "Obsidian note-taking app";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      obsidian
    ];

    # Create default vault directory
    home.file.".local/share/obsidian/.keep".text = "";

    # XDG desktop entry override (optional, for custom icon/categories)
    xdg.desktopEntries.obsidian = {
      name = "Obsidian";
      genericName = "Knowledge Base";
      comment = "A powerful knowledge base that works on local Markdown files";
      exec = "obsidian %u";
      icon = "obsidian";
      terminal = false;
      type = "Application";
      categories = ["Office" "TextEditor" "Utility"];
      mimeType = ["x-scheme-handler/obsidian"];
    };
  };
}
