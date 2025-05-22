{
  config,
  namespace,
  lib,
  ...
}:
let
  cfg = config.${namespace}.programs.btop;
in
{
  options.${namespace}.programs.btop = {
    enable = lib.mkEnableOption "btop";
  };
  config = lib.mkIf cfg.enable {
    programs.btop = {
      enable = true;
    };

    home.shellAliases = {
      top = lib.getExe config.programs.btop.package;
    };
  };
}
