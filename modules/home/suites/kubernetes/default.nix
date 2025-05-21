{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib) mkIf types;

  cfg = config.${namespace}.suites.kubernetes;
in
{
  options.${namespace}.suites.kubernetes = {
    enable = lib.mkEnableOption "enable kubernetes tools";
    kubeSecretFile = lib.mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        Path to SOPS encrypted file containing kubeconfig data.
        When provided, this will be decrypted and placed at ~/.kube/config
      '';
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        fluxcd
        helmfile
        kubectl
        talhelper
        talosctl
      ];

      shellAliases = { };
    };

    programs = { };

    sops.secrets.kubeconfig = lib.mkIf (cfg.kubeSecretFile != null) {
      sopsFile = cfg.kubeSecretFile;
      mode = "0400";
      path = config.home.homeDirectory + "/.kube/config";
    };

    ${namespace} = {
      programs = {
        k9s = {
          enable = true;
        };
      };
    };
  };
}
