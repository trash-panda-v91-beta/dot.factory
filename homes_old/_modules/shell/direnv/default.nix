{ lib, ... }:
{
  config = {
    programs.direnv = {
      enable = lib.mkForce true;
    };
  };
}
