{
  config,
  namespace,
  lib,
  ...
}:
let
  cfg = config.${namespace}.programs.bash;
in
{
  options.${namespace}.programs.bash = {
    enable = lib.mkEnableOption "bash";
  };

  config = lib.mkIf cfg.enable {
    programs.bash = {
      enable = true;
    };
  };
}
