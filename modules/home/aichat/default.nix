{
  config,
  namespace,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.${namespace}.aichat;
  yaml = pkgs.formats.yaml { };
  aiChatConfig = {
    stream = false;
    inherit (cfg) model;
    clients = [
      {
        type = "openai-compatible";
        name = "copilot";
        api_base = "https://api.githubcopilot.com";
        patch = {
          chat_completions = {
            ".*" = {
              headers = {
                "Copilot-Integration-Id" = "vscode-chat";
                "Editor-Version" = "aichat/0.1.0";
              };
            };
          };
        };
      }
    ];
  };
in
{
  options.${namespace}.aichat = {
    enable = mkEnableOption "aichat";
    model = mkOption {
      type = types.str;
      default = "copilot:claude-3.7-sonnet";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      aichat
    ];
    xdg.configFile."aichat/config.yaml" = {
      source = yaml.generate "config.yaml" aiChatConfig;
      enable = true;
    };
  };
}
