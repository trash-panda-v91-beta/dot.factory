{
  config,
  lib,
  namespace,
  ...
}:
let
  inherit (lib) types mkIf;
  inherit (lib.${namespace}) mkOpt;

  cfg = config.${namespace}.user;
in
{
  options.${namespace}.user = {
    name = mkOpt types.str "trash-panda-v91-beta" "The user account.";
    email =
      mkOpt types.str "42897550+trash-panda-v91-beta@users.noreply.github.com"
        "The email of the user.";
    uid = mkOpt (types.nullOr types.int) 501 "The uid for the user account.";
  };

  config = {
    users.users.${cfg.name} = {
      uid = mkIf (cfg.uid != null) cfg.uid;
    };
  };
}
