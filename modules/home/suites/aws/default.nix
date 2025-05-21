{
  config,
  namespace,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.${namespace}.suites.aws;
in
{
  options.${namespace}.suites.aws = {
    enable = lib.mkEnableOption "AWS development tools";
    region = lib.mkOption {
      type = with lib.types; enum [ "us-west-2" ];
      default = "us-west-2";
      description = "AWS Region";
      example = [
        "us-west-2"
      ];
    };
  };

  config = lib.mkIf cfg.enable {
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
    };
    home = {
      packages = with pkgs; [
        aws-sam-cli
      ];

      shellAliases = {
        aa = "aws_okta_keyman";
      };
    };

    home.sessionVariables = {
      SAM_CLI_TELEMETRY = 0;
    };
  };
}
