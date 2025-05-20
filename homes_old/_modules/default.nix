{ pkgs, ... }:
{
  imports = [
    ./mutability.nix
    ./secrets.nix

    ./aichat
    ./any-nix-shell
    ./browsers
    ./desktop
    ./deployment
    ./editor
    ./fd
    ./fzf
    ./hammerspoon-config
    ./karabiner-config
    ./kbs
    ./kubernetes
    ./security
    ./raycast
    ./run-on-unlock
    ./rust-development
    ./shell
    ./terminals
    ./themes
    ./virtualisation
    ./zk
  ];

  config = {
    home.stateVersion = "23.11";

    programs = {
      home-manager.enable = true;
    };

    xdg.enable = true;

    home.packages = [ pkgs.home-manager ];
  };
}
