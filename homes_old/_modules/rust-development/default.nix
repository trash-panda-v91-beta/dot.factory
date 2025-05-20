{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.rust-development;
in
{
  options.modules.rust-development = {
    enable = lib.mkEnableOption "rust-development";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      cargo
      rustc
    ];
  };
}
