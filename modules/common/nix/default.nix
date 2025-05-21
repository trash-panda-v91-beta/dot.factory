{
  config,
  inputs,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib.${namespace}) mkBoolOpt mkOpt;

  cfg = config.${namespace}.nix;
in
{
  options.${namespace}.nix = {
    enable = mkBoolOpt true "Whether or not to manage nix configuration.";
    package = mkOpt lib.types.package pkgs.nixVersions.latest "Which nix package to use.";
  };

  config = lib.mkIf cfg.enable {
    documentation = {
      doc.enable = false;
      info.enable = false;
      man.enable = lib.mkDefault true;
    };

    environment = {
      etc =
        with inputs;
        {
          "nix/flake-channels/system".source = self;
          "nix/flake-channels/nixpkgs".source = nixpkgs;
          "nix/flake-channels/home-manager".source = home-manager;
        }
        // lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          "nixos".source = self;
        }
        // lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
          "nix-darwin".source = self;
        };

      systemPackages = with pkgs; [
        git
        nix-prefetch-git
      ];
    };

    nix =
      let
        mappedRegistry = lib.pipe inputs [
          (lib.filterAttrs (_: lib.isType "flake"))
          (lib.mapAttrs (_: flake: { inherit flake; }))
          (
            x:
            x
            // {
              nixpkgs.flake =
                if pkgs.stdenv.hostPlatform.isLinux then inputs.nixpkgs else inputs.nixpkgs-unstable;
            }
          )
          (x: if pkgs.stdenv.hostPlatform.isDarwin then lib.removeAttrs x [ "nixpkgs-unstable" ] else x)
        ];

        users = [
          "root"
          "@wheel"
          "nix-builder"
          config.${namespace}.user.name
        ];
      in
      {
        inherit (cfg) package;

        checkConfig = true;
        distributedBuilds = true;

        gc = {
          automatic = true;
        };

        nixPath = lib.mapAttrsToList (key: _: "${key}=flake:${key}") config.nix.registry;

        optimise.automatic = true;

        registry = mappedRegistry;

        settings = {
          allowed-users = users;
          auto-optimise-store = pkgs.stdenv.hostPlatform.isLinux;
          builders-use-substitutes = true;
          download-buffer-size = 500000000;
          experimental-features = [
            "nix-command"
            "flakes"
            "ca-derivations"
            "auto-allocate-uids"
            "pipe-operators"
            "dynamic-derivations"
          ];
          flake-registry = "/etc/nix/registry.json";
          http-connections = 0;
          keep-derivations = true;
          keep-going = true;
          keep-outputs = true;
          log-lines = 50;
          preallocate-contents = true;
          sandbox = true;
          trusted-users = users;
          warn-dirty = false;

          allowed-impure-host-deps = [
            "/bin/sh"
            "/dev/random"
            "/dev/urandom"
            "/dev/zero"
            "/usr/bin/ditto"
            "/usr/lib/libSystem.B.dylib"
            "/usr/lib/libc.dylib"
            "/usr/lib/system/libunc.dylib"
          ];

          substituters = [
            "https://cache.nixos.org"
            "https://dotsfactory.cachix.org"
            "https://nix-community.cachix.org"
            "https://nixpkgs-unfree.cachix.org"
            "https://numtide.cachix.org"
          ];

          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "dotsfactory.cachix.org-1:Jlj7URSmy7P8/RbUvGAXOPnDIpN7uT8QuXf/3UZmPyk="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
            "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
          ];

          use-xdg-base-directories = true;
        };
      };
  };
}
