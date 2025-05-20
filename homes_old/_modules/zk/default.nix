{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.zk;
  nixvim = inputs.editor.packages.${pkgs.system}.default;
in
{
  options.modules.zk = {
    enable = lib.mkEnableOption "zk";
    default_directory = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        The directory where zk stores its notes.
        If null, no directory will be specified and zk will use its default location.
      '';
    };
    author = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        The author name to be used in the notes.
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    home.sessionVariables = lib.mkIf (cfg.default_directory != null) {
      ZK_NOTEBOOK_DIR = cfg.default_directory;
    };
    home.file."${config.xdg.configHome}/zk/templates/" = {
      source = ./templates;
      recursive = true;
    };
    programs = {
      zk = {
        enable = true;
        settings = {
          note = {
            language = "en";
            defaultTitle = "Untitled";
            filename = "{{id}}";
            extension = "md";
            template = "default.md";
            idCharset = "alphanum";
            idLength = 4;
            idCase = "lower";
          };
          extra = {
            author = lib.mkIf (cfg.author != null) cfg.author;
          };
          group = {
            daily = {
              paths = [ "daily" ];
              note = {
                filename = "{{format-date now 'daily/%Y-%m-%d'}}";
                template = "daily.md";
              };
            };
          };
          format = {
            markdown = {
              link-format = "markdown";
              hashtags = true;
            };
          };
          tool = {
            editor = "${nixvim}/bin/nvim";
            shell = "${pkgs.fish}/bin/fish";
            pager = "less -FIRX";
            fzfPreview = "${pkgs.bat}/bin/bat -p --color always {-1}";
          };
          filter = {
            recents = "--sort created- --created-after 'last two weeks'";
          };
          alias = {
            daily = "zk new --group daily";
          };
          lsp = {
            diagnostics = {
              wikiTitle = "hint";
              deadLink = "error";
            };
          };
        };
      };
    };
  };
}
