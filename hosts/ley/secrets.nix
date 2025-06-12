{
  config,
  inputs,
  ...
}:
{
  config = {
    sops = {
      defaultSopsFile = inputs.secrets.file;
      secrets = {
        "users/c4300n/password" = {
          neededForUsers = true;
        };
      };
    };
  };
}
