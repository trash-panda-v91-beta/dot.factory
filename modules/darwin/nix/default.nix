{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.nix;
in
{
  imports = [ (lib.snowfall.fs.get-file "modules/shared/nix/default.nix") ];

  config = lib.mkIf cfg.enable {
    nix = {
      extraOptions = ''
        # bail early on missing cache hits
        connect-timeout = 10
        keep-going = true
      '';

      gc = {
        interval = [
          {
            Hour = 3;
            Minute = 15;
            Weekday = 1;
          }
        ];
      };

      optimise.interval = lib.lists.forEach config.nix.gc.interval (e: {
        inherit (e) Minute Weekday;
        Hour = e.Hour + 1;
      });

      settings = {
        build-users-group = "nixbld";

        extra-sandbox-paths = [
          "/System/Library/Frameworks"
          "/System/Library/PrivateFrameworks"
          "/usr/lib"

          "/private/tmp"
          "/private/var/tmp"
          "/usr/bin/env"
        ];

        http-connections = lib.mkForce 25;
        sandbox = lib.mkForce "relaxed";
      };
    };
  };
}
