{ config, lib, ... }:
let
  cfg = config.modules.security.ssh;
in
{
  options.modules.security.ssh = {
    enable = lib.mkEnableOption "ssh";
  };

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;
    };
  };
}
