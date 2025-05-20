{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.fd;
in
{
  options.modules.fd = {
    enable = lib.mkEnableOption "fd";
  };
  config = lib.mkIf cfg.enable {
    programs = {
      fd = {
        enable = true;
      };
    };
  };
}
