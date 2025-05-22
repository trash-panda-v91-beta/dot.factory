{ config, lib, ... }:
{
  config = {
    programs.eza = {
      enable = true;

      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushIntegration = true;

      extraOptions = [
        "--group-directories-first"
        "--header"
        "--hyperlink"
        "--follow-symlinks"
      ];

      git = true;
      icons = "auto";
    };
    home.shellAliases = {
      la = "${lib.getExe config.programs.eza.package} -lah --tree";
      tree = "${lib.getExe config.programs.eza.package} --tree --icons=always";
    };
  };
}
