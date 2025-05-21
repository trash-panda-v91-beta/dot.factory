{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.modules.security._1password;
  personalGithubPubKeyPath = "${config.home.homeDirectory}/.ssh/personal-github.pub";
in
{
  options.modules.security._1password = {
    enable = lib.mkEnableOption "1password";
    configureGithubKeys = lib.mkOption {
      config = lib.mkIf cfg.enable {
        home.packages = [
          pkgs._1password-cli
        ];

        home.file.personalGithubPubKey = lib.mkIf cfg.configureGithubKeys {
          enable = true;
          source = inputs.secrets.publicKeys.personalGithub;
          target = personalGithubPubKeyPath;
        };

        programs.ssh = lib.mkMerge [
          {
          }

          (lib.mkIf cfg.configureGithubKeys {
            matchBlocks."github.com" = {
              user = "git";
              identityFile = personalGithubPubKeyPath;
              identitiesOnly = true;
              extraOptions = {
                identityAgent = "'~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock'";
              };
            };
            matchBlocks."asc.internal" = {
              user = "git";
              identityFile = personalGithubPubKeyPath;
              identitiesOnly = true;
              extraOptions = {
                identityAgent = "'~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock'";
              };
            };
          })
        ];
      };
    };
  };
}
