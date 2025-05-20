{
  config,
  lib,
  pkgs,
  ...
}:

let
  config_folder = ".hammerspoon";
  cfg = config.modules.hammerspoon-config;
in
{
  options.modules.hammerspoon-config = {
    enable = lib.mkEnableOption "hammerspoon-config";
  };
  config = lib.mkIf cfg.enable {
    home.file."${config_folder}/init.lua" = {
      text = ''
        hs.loadSpoon("Vifari")
        spoon.Vifari:start()
      '';
    };
    home.file."${config_folder}/Spoons/Vifari.spoon/init.lua" = {
      source = "${pkgs.vifari}/init.lua";
    };
  };
}
