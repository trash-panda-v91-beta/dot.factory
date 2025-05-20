{
  lib,
  config,
  ...
}:
let
  cfg = config.modules.terminals.wezterm;
in
{
  options.modules.terminals.wezterm = {
    enable = lib.mkEnableOption "wezterm";
  };

  config = lib.mkIf cfg.enable {

    home = {
      sessionVariables = {
        TERM = "xterm-256color";
      };
    };
    programs.wezterm = {
      enable = true;
    };
    xdg.configFile."wezterm/wezterm.lua".source = ./wezterm.lua;
  };
}
