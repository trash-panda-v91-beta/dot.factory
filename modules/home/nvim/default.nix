{
  inputs,
  namespace,
  lib,
  config,
  system,
  ...
}:
let
  cfg = config.${namespace}.nvim;
  nixvim = inputs.codelab.packages.${system}.default.extend {
    inherit (cfg) aiProvider;
  };
  shellAliases = {
    vi = "nvim";
    vim = "nvim";
  };
in
{
  options.${namespace}.nvim = {
    enable = lib.mkEnableOption "nvim";
    aiProvider = lib.mkOption {
      type = lib.types.attrs;
      default = {
        name = "copilot";
        model = null;
      };
    };
    makeDefaultEditor = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = [ nixvim ];
      sessionVariables = {
        EDITOR = lib.mkIf cfg.makeDefaultEditor "nvim";
        MANPAGER = "nvim -c 'set ft=man bt=nowrite noswapfile nobk shada=\\\"NONE\\\" ro noma' +Man! -o -";
      };
    };

    programs = {
      git.extraConfig.core.editor = lib.mkIf cfg.makeDefaultEditor "nvim";
      fish.shellAliases = shellAliases;
      zsh.shellAliases = shellAliases;
      bash.shellAliases = shellAliases;
      nushell.shellAliases = shellAliases;
    };
  };
}
