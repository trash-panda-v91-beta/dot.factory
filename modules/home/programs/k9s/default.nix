{
  config,
  lib,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.programs.k9s;
in
{
  options.${namespace}.programs.k9s = {
    enable = mkEnableOption "k9s";
  };

  config = mkIf cfg.enable {
    programs.k9s = {
      enable = true;
      aliases = {
        aliases = {
          dp = "deployments";
          sec = "v1/secrets";
          jo = "jobs";
          cr = "clusterroles";
          crb = "clusterrolebindings";
          ro = "roles";
          rb = "rolebindings";
          np = "networkpolicies";
        };
      };
      settings = {
        k9s = {
          liveViewAutoRefresh = true;
          refreshRate = 1;
          maxConnRetry = 3;
          ui = {
            enableMouse = false;
          };
        };
      };
    };
  };
}
