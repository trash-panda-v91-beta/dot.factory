{
  pkgs,
  config,
  namespace,
  lib,
  ...
}:
let
  cfg = config.${namespace}.suites.git;
  makeCommitMessage = pkgs.writeShellApplication {
    name = "make-commit-message";
    bashOptions = [ ];
    runtimeEnv = {
      "MODEL_NAME" = config.modules.aichat.model;
    };
    runtimeInputs = with pkgs; [
      curl
      fzf
      jq
      aichat
    ];
    text = builtins.readFile ./make-commit-message.sh;
  };
  inherit (pkgs.stdenv) isDarwin;
in
{
  options.${namespace}.suites.git = {
    enable = lib.mkEnableOption "git";
    username = lib.mkOption { type = lib.types.str; };
    email = lib.mkOption { type = lib.types.str; };
    config = lib.mkOption {
      type = lib.types.attrs;
      default = { };
    };
    services = lib.mkOption {
      type = lib.types.attrs;
      default = { };
    };
    includes = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [ ];
    };
    ignores = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      programs = {
        gh = {
          enable = true;
          extensions = [ pkgs.gh-copilot ];
        };
        git = {
          enable = true;

          userName = cfg.username;
          userEmail = cfg.email;

          extraConfig = lib.mkMerge [
            {
              core = {
                autocrlf = "input";
              };
              init = {
                defaultBranch = "main";
              };
              pull = {
                rebase = true;
              };
              rebase = {
                autoStash = true;
              };
            }
            cfg.config
          ];

          inherit (cfg) includes;

          aliases = {
            co = "checkout";
          };
          ignores = [
            ".DS_Store"
            "Thumbs.db"
            ".decrypted~*"
            "*.decrypted.*"
            ".venv"
          ] ++ cfg.ignores;
        };

        lazygit = {
          enable = true;
          settings = {
            gui = {
              showIconns = true;
              nerdFontsVersion = 3;
              border = "rounded";
            };
            customCommands = [
              {
                key = "o";
                command = "gh pr view {{.SelectedLocalBranch.Name}} --web || gh pr create {{.SelectedLocalBranch.Name}} --web";
                context = "remoteBranches";
              }
              {
                key = "<c-c>";
                description = "Pick AI commit";
                context = "files";
                subprocess = true;
                command = "${makeCommitMessage}/bin/make-commit-message";
              }
            ];
            keybinding = {
              commits = {
                moveDownCommit = "J";
                moveUpCommit = "K";
              };
            };
            inherit (cfg) services;
          };
        };
        fish = {
          shellAbbrs = {
            gg = "lazygit";
          };
        };
      };
      home = {
        packages = [
          pkgs.git-filter-repo
        ];
        shellAliases = {
          cdc = "cd ~/repos/corporate";
          cdp = "cd ~/repos/personal";
          lg = "lazygit";
        };
      };

    })
    (lib.mkIf (cfg.enable && isDarwin) {
      programs.git = {
        extraConfig = {
          credential = {
            helper = "osxkeychain";
          };
        };
      };
    })
  ];
}
