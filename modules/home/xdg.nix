# XDG base directories + user dirs
# Ensures config.xdg.* is consistently defined and user directories exist.
{ config, lib, ... }:
{
  xdg = {
    enable = true;
    userDirs.enable = true;
  };

  # Optional: If you want to force base dirs explicitly, uncomment:
  # home.sessionVariables = {
  #   XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
  #   XDG_DATA_HOME = "${config.home.homeDirectory}/.local/share";
  #   XDG_CACHE_HOME = "${config.home.homeDirectory}/.cache";
  #   XDG_STATE_HOME = "${config.home.homeDirectory}/.local/state";
  # };
}
