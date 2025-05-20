{
  ...
}:

final: prev: {
  karabiner-elements = prev.karabiner-elements.overrideAttrs (oldAttrs: {
    version = "14.13.0";
    src = prev.fetchurl {
      inherit (oldAttrs.src) url;
      hash = "sha256-gmJwoht/Tfm5qMecmq1N6PSAIfWOqsvuHU8VDJY8bLw=";
    };
  });
}
