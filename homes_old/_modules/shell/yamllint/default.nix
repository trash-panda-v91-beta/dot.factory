{ config, lib, ... }:
let
  inherit (lib)
    mkIf
    mkEnableOption
    ;

  cfg = config.modules.shell.yamllint;
in
{
  options.modules.shell.yamllint = {
    enable = mkEnableOption "Whether to enable yamllint config";
  };
  config = mkIf cfg.enable {
    xdg.configFile."yamllint/config".text = ''
      extends: default

      rules:
        document-start: disable
    '';
  };
}
