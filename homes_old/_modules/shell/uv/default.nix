{ pkgs, ... }:
{
  config = {
    home.packages = with pkgs.unstable; [
      uv
    ];
    programs.fish = {
      interactiveShellInit = ''
        uv generate-shell-completion fish | source
      '';
    };
  };
}
