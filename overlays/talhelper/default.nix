{
  inputs,
  ...
}:

final: prev: {
  talhelper = inputs.talhelper.packages.${prev.system}.default;
}
