{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.shell.aws;
  scripts = "raycast/scripts";
in
{
  options.modules.shell.aws = {
    enable = lib.mkEnableOption "aws";
    region = lib.mkOption {
      type = lib.types.str;
      default = "us-west-2";
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      programs = {
        awscli = {
          enable = true;
          settings = {
            "default" = {
              inherit (cfg) region;
              output = "json";
            };
          };
        };
        fish = {
          shellAbbrs = {
            aa = "aws_okta_keyman";
          };
        };
      };
      xdg.configFile."${scripts}/authenticate-to-aws.sh" = {
        text = ''
          #!${pkgs.bash}/bin/bash

          # @raycast.schemaVersion 1
          # @raycast.title Authenticate to AWS
          # @raycast.mode inline
          # @raycast.packageName Raycast Scripts
          # @raycast.icon 🔑
          # @raycast.currentDirectoryPath ~
          # @raycast.needsConfirmation false
          # Documentation:
          # @raycast.description Authenticate to AWS using Okta

          echo "Authenticating ..."
          output=$(${config.home.homeDirectory}/usr/local/bin/aws_okta_keyman 2>&1)
          rc=$?

          if [ $rc -eq 0 ]; then
              echo "Authentication successful."
          else
              echo "Authentication failed."
          fi
        '';
        executable = true;
      };
    })
  ];
}
