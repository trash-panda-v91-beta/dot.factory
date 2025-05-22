{
  pkgs,
  config,
  namespace,
  lib,
  ...
}:
let
  cfg = config.${namespace}.programs._1password;
in
{
  options.${namespace}.programs._1password = {
    enable = lib.mkEnableOption "1password";
    enableGui = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable the 1Password GUI";
    };
    sshHosts = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            domain = lib.mkOption {
              type = lib.types.str;
              description = "Domain for SSH connection";
              example = "github.com";
            };

            user = lib.mkOption {
              type = lib.types.str;
              description = "SSH user";
              example = "git";
            };

            identityFile = lib.mkOption {
              type = lib.types.path;
              description = "Path to the SSH identity file";
            };

            identitiesOnly = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Whether to only use the specified identity file";
            };
          };
        }
      );
      default = [ ];
      description = "List of SSH hosts to configure with 1Password integration";
    };

    config = lib.mkIf cfg.enable {
      programs = {
        _1password = {
          enable = true;
          package = pkgs._1password-cli;
        };
        _1password-gui = lib.mkIf cfg.enableGui {
          enable = true;
          package = pkgs._1password-gui;
        };

        ssh = lib.mkIf (cfg.sshHosts != [ ]) {
          matchBlocks = builtins.listToAttrs (
            map (host: {
              name = host.domain;
              value = {
                user = host.user;
                identityFile = host.identityFile;
                identitiesOnly = host.identitiesOnly;
                extraOptions = {
                  identityAgent = "'~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock'";
                };
              };
            }) cfg.sshHosts
          );
        };
      };
    };
  };
}
