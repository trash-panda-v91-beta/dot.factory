{
  inputs,
  config,
  ...
}:
{
  config = {
    sops = {
      defaultSopsFile = inputs.secrets.file;
      secrets = {
        "storage/minio/root-credentials" = {
          owner = config.users.users.minio.name;
          restartUnits = [ "minio.service" ];
        };
        "networking/cloudflare/auth" = {
          owner = config.users.users.acme.name;
        };
        "users/bjw-s/password" = {
          neededForUsers = true;
        };
      };
    };
  };
}
