{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib)
    types
    mkIf
    mkDefault
    mkMerge
    ;
  inherit (lib.${namespace}) mkOpt enabled;

  cfg = config.${namespace}.user;

  home-directory =
    if cfg.name == null then
      null
    else if pkgs.stdenv.hostPlatform.isDarwin then
      "/Users/${cfg.name}"
    else
      "/home/${cfg.name}";
in
{
  options.${namespace}.user = {
    enable = mkOpt types.bool false "Whether to configure the user account.";
    email =
      mkOpt types.str "42897550+trash-panda-v91-beta@users.noreply.github.com"
        "The email of the user.";
    home = mkOpt (types.nullOr types.str) home-directory "The user's home directory.";
    icon = mkOpt (types.nullOr types.package) null "The profile picture to use for the user.";
    name = mkOpt (types.nullOr types.str) config.snowfallorg.user.name "The user account.";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = cfg.name != null;
          message = "${namespace}.user.name must be set";
        }
        {
          assertion = cfg.home != null;
          message = "${namespace}.user.home must be set";
        }
      ];

      home = {
        file = lib.optionalAttrs (cfg.icon != null) {
          "Pictures/${cfg.icon.fileName or (builtins.baseNameOf cfg.icon)}".source = cfg.icon;
        };
        homeDirectory = mkDefault cfg.home;
        username = mkDefault cfg.name;
      };
      programs.home-manager = enabled;
    }
  ]);
}
