{
  config,
  namespace,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.${namespace}.programs.run-on-unlock;
  userProfilePath = "${config.home.homeDirectory}/.nix-profile/bin";
  systemPaths = [
    "${userProfilePath}"
    "/etc/profiles/per-user/${config.home.username}/bin"
    "/run/current-system/sw/bin"
    "/nix/var/nix/profiles/default/bin"
    "/usr/bin"
    "/bin"
    "/usr/sbin"
    "/sbin"
  ];
in
{
  options.${namespace}.programs.run-on-unlock = {
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
          PATH = lib.concatStringsSep ":" systemPaths;
        };
        RunAtLoad = true;
        KeepAlive = true;
        WorkingDirectory = "/tmp";
      };
    };
  };
}
