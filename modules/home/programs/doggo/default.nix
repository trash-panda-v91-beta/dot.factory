{
  config,
  namespace,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.${namespace}.programs.doggo;
in
{
  options.${namespace}.programs.doggo = {
    enable = lib.mkEnableOption "doggo";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.doggo
    ];
    programs = lib.${namespace}.makeShellAliases { dig = "doggo"; };
  };
}

