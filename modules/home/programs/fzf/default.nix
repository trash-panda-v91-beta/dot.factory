{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.programs.fzf;
in
{
  options.${namespace}.programs.fzf = {
    enable = lib.mkEnableOption "fzf";
  };

  config = mkIf cfg.enable {
    programs = {
      fzf = {
        enable = true;
      };
      fish = {
        plugins = [
          {
            name = "fzf-fish";
            inherit (pkgs.fishPlugins.fzf-fish) src;
          }
        ];
      };
    };
  };
}
