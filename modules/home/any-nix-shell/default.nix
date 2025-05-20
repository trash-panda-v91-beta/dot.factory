{
  config,
  namespace,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.${namespace}.any-nix-shell;
in
{
  options.${namespace}.any-nix-shell = {
    enable = lib.mkEnableOption "any-nix-shell";
  };
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.any-nix-shell ];
    programs.fish.interactiveShellInit = ''
      any-nix-shell fish --info-right | source
    '';

  };
}
