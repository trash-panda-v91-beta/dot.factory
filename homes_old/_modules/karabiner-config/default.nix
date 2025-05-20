{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.karabiner-config;
in
{
  options.modules.karabiner-config = {
    enable = lib.mkEnableOption "karabiner-config";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ karabiner-config ];
    xdg.configFile."karabiner/karabiner.json" = {
      source = "${pkgs.karabiner-config}/karabiner.json";
      force = true;
    };
  };
}
