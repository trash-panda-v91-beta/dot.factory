{
  pkgs,
  lib,
  config,
  inputs,
  hostname,
  ...
}:
{
  imports = [
    ../_modules
    ./hosts/${hostname}.nix
  ];

  modules = {
    editor = {
      nvim = {
        enable = true;
        makeDefaultEditor = true;
      };

      vscode = {
        userSettings = lib.importJSON ./config/editor/vscode/settings.json;
        extensions =
          let
            inherit (inputs.nix-vscode-extensions.extensions.${pkgs.system}) vscode-marketplace;
          in
          with vscode-marketplace;
          [
            # Language support
            golang.go
            hashicorp.terraform
            helm-ls.helm-ls
            jnoortheen.nix-ide
            mrmlnc.vscode-json5
            ms-azuretools.vscode-docker
            ms-python.python
            redhat.ansible
            redhat.vscode-yaml
            tamasfe.even-better-toml

            # Formatters
            esbenp.prettier-vscode

            # Linters
            davidanson.vscode-markdownlint

            # Remote development
            ms-vscode-remote.remote-containers
            ms-vscode-remote.remote-ssh

            # Other
            eamodio.gitlens
            gruntfuggly.todo-tree
            ionutvmi.path-autocomplete
            ms-kubernetes-tools.vscode-kubernetes-tools
            signageos.signageos-vscode-sops
          ];
      };
    };

    security = {
      ssh = {
        enable = true;
        matchBlocks = {
          "asc.internal" = {
            port = 22;
            user = "c4300n";
            forwardAgent = true;
          };
        };
      };
    };

    shell = {
      atuin = {
        enable = true;
        package = pkgs.unstable.atuin;
        flags = [ "--disable-up-arrow" ];
        settings = {
          sync_address = "https://atuin.${inputs.secrets.domain}";
          key_path = config.sops.secrets.atuin_key.path;
          auto_sync = true;
          sync_frequency = "1m";
          search_mode = "fuzzy";
          sync = {
            records = true;
          };
        };
      };

      fish.enable = true;

      git = {
        enable = true;
        username = "aka-raccoon";
        email = "42897550+aka-raccoon@users.noreply.github.com";
      };

      go-task.enable = true;
    };

    themes = {
      cyberdream = {
        enable = true;
      };
    };
  };
}
