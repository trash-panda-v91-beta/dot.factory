{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.modules.kbs.anytype;
in
{
  options.modules.kbs.anytype = {
    enable = lib.mkEnableOption "anytype";
  };

  config = lib.mkIf cfg.enable { home.packages = with pkgs.unstable; [ anytype ]; };
}
