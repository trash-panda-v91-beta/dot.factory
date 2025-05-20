{
  lib,
  pkgs,
  stdenv,
  ...
}:
stdenv.mkDerivation {
  pname = "run-on-unlock";
  version = "0.1.0";
  src = ./src;
  nativeBuildInputs = with pkgs; [
    swift
  ];
  installPhase = ''
    swiftc run-on-unlock.swift
    mkdir -p $out/bin/
    cp run-on-unlock $out/bin/
  '';

  meta = with lib; {
    description = "Program to run on lock/unlock";
    license = licenses.mit;
  };
}
