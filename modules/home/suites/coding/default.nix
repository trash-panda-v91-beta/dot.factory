{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib) mkIf types;
  cfg = config.${namespace}.suites.coding;
  languageTools = {
    python = with pkgs; [
      uv
    ];
    rust = with pkgs; [
      cargo
      rustc
    ];

  };
in
{
  options.${namespace}.suites.coding = {
    enable = lib.mkEnableOption "enable coding tools";

    languages = lib.mkOption {
      type = with types; listOf (enum (builtins.attrNames languageTools));
      default = [
        "python"
        "rust"
      ];
      description = "Programming languages to enable support for";
      example = [
        "python"
        "rust"
      ];
    };
  };
  config = mkIf cfg.enable {
    ${namespace}.suits.git.enable = true;
    home = {
      packages =
        with pkgs;
        [
          go-tasks
          ripgrep
        ]
        ++ (lib.flatten (map (lang: languageTools.${lang}) cfg.languages));

      shellAliases =
        {
        }
        // lib.optionalAttrs (builtins.elem "python" cfg.languages) {
          py = "python";
          venv = "python -m venv .venv && source .venv/bin/activate";
        }
        // lib.optionalAttrs (builtins.elem "rust" cfg.languages) {
          cr = "cargo run";
          cb = "cargo build";
          ct = "cargo test";
        };
    };

    programs = {
      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
      fd.enable = true;
    };

    ${namespace}.programs = {
      fzf = {
        enable = true;
      };
    };

    home.sessionVariables = lib.mkMerge [
      (lib.mkIf (builtins.elem "python" cfg.languages) {
        PYTHONDONTWRITEBYTECODE = 1;
      })
      (lib.mkIf (builtins.elem "rust" cfg.languages) {
        CARGO_INCREMENTAL = 1;
      })
    ];
  };
}
