{
  lib,
  ...
}:
{
  modules = {
    deployment.nix.enable = true;
    editor = {
      vscode = {
        enable = false;
      };
    };
    security._1password.enable = true;
    kubernetes = {
      enable = false;
    };
    shell = {
      atuin.enable = lib.mkForce false;
    };
    browsers.firefox.enable = lib.mkForce false;
    terminals.wezterm.enable = lib.mkForce false;
    terminals.ghostty.enable = lib.mkForce true;
  };
}
