{
  config,
  pkgs,
  lib,
  ...
}:
{
  modules = {
    deployment.nix.enable = true;
    editor = {
      vscode = {
        enable = true;
        userSettings = lib.importJSON ../config/editor/vscode/settings.json;
      };
    };
    kubernetes.enable = true;
    shell = {
      git = { };
    };
  };
}
