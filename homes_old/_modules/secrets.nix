{
  inputs,
  pkgs,
  config,
  ...
}:
let
  ageKeyFile = "${config.xdg.configHome}/age/keys.txt";
  sshKey = "${config.home.homeDirectory}/.ssh/id_ed25519";
in
{
  config = {
    home.packages = [
      pkgs.sops
      pkgs.age
    ];

    sops = {
      defaultSopsFile = inputs.secrets.file;
      age = {
        keyFile = ageKeyFile;
        generateKey = true;
        sshKeyPaths = [
          sshKey
        ];
      };

      secrets = {
        atuin_key = { };
      };
    };

    home.sessionVariables = {
      SOPS_AGE_KEY_FILE = ageKeyFile;
    };
  };
}
