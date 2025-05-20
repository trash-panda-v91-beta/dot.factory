{ inputs, lib, ... }:
{
  modules = {
    shell = {
      atuin.enable = lib.mkForce false;
    };
    desktop.hyprland.enable = lib.mkForce true;
    browsers.firefox.enable = lib.mkForce true;
    terminals.wezterm.enable = lib.mkForce true;
    kubernetes = {
      enable = lib.mkForce true;
      kubeconfig = inputs.secrets.kubeconfig;
    };
    kbs.anytype.enable = lib.mkForce true;
  };
}
