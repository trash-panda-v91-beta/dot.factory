{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.kubernetes;
  inherit (config.home) homeDirectory;
in
{
  options.modules.kubernetes = {
    enable = lib.mkEnableOption "kubernetes";
    kubeconfig = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        The path to the kubeconfig file.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      (with pkgs; [ talhelper ])
      ++ (with pkgs.unstable; [
        fluxcd
        helmfile
        kubectl
        talosctl
      ]);

    programs.k9s = {
      enable = true;
      package = pkgs.unstable.k9s;

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
          liveViewAutoRefresh = false;
          refreshRate = 2;
          maxConnRetry = 5;
          readOnly = false;
          noExitOnCtrlC = false;
          ui = {
            enableMouse = false;
            headless = false;
            logoless = false;
            crumbsless = false;
            reactive = false;
            noIcons = false;
          };
          skipLatestRevCheck = false;
          disablePodCounting = false;
          shellPod = {
            image = "busybox";
            namespace = "default";
            limits = {
              cpu = "100m";
              memory = "100Mi";
            };
          };
          imageScans = {
            enable = false;
            exclusions = {
              namespaces = [ ];
              labels = { };
            };
          };
          logger = {
            tail = 100;
            buffer = 5000;
            sinceSeconds = -1;
            fullScreen = false;
            textWrap = false;
            showTime = false;
          };
          thresholds = {
            cpu = {
              critical = 90;
              warn = 70;
            };
            memory = {
              critical = 90;
              warn = 70;
            };
          };
        };
      };
    };

    sops.secrets.kubeconfig = lib.mkIf (cfg.kubeconfig != null) {
      sopsFile = cfg.kubeconfig;
      mode = "0400";
      path = homeDirectory + "/.kube/config";
    };
    programs.fish = {
      interactiveShellInit = ''
        fish_add_path $HOME/.krew/bin
      '';

      functions = { };
      shellAliases = {
        k = "kubectl";
      };
    };
  };
}
