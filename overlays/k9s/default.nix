{
  channels,
  ...
}:

final: prev: {
  inherit (channels.nixpkgs-unstable) k9s;
}
