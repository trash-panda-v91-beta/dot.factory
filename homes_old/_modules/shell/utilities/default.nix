{ pkgs, ... }:
{
  config = {
    home.packages = with pkgs; [
      binutils
      coreutils
      curl
      du-dust
      envsubst
      findutils
      fish
      gawk
      gnused
      gum
      jo
      jq
      vim
      wget
      yq-go
    ];
  };
}
