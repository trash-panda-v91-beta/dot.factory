{
  config,
  namespace,
  lib,
  ...
}:
let
  cfg = config.${namespace}.programs.bat;
in
{
  options.${namespace}.programs.bat = {
    enable = lib.mkEnableOption "bat";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      bat = {
        enable = true;
      };
    } // lib.${namespace}.mkShellAliases {
      cat = "bat";
    };
  };
}
