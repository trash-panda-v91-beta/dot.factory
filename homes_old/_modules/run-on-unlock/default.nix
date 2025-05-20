{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.run-on-unlock;
in
{
  options.modules.run-on-unlock = {
    enable = lib.mkEnableOption "run-on-unlock";
  };
  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.run-on-unlock
    ];
    launchd.agents.run-on-unlock = {
      enable = true;
      config = {
        ProgramArguments = [
          "${pkgs.run-on-unlock}/bin/run-on-unlock"
        ];
        EnvironmentVariables = {
          PATH = "/Users/${config.home.username}/.nix-profile/bin:/etc/profiles/per-user/${config.home.username}/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/usr/bin:/bin:/usr/sbin:/sbin";
        };
        RunAtLoad = true;
        KeepAlive = true;
        WorkingDirectory = "/tmp";
      };
    };
  };
}
