{
  lib,
  fetchFromGitHub,
  stdenv,
  ...
}:

stdenv.mkDerivation rec {
  pname = "vifari";
  version = "0.0.8";

  src = fetchFromGitHub {
    owner = "dzirtusss";
    repo = "vifari";
    rev = "v${version}";
    hash = "sha256-20yq9S69M6D2gyE5VX1qF3nX4zOPQJHsGSnvcAFfN6s=";
  };
  installPhase = ''
    mkdir $out/
    cp init.lua $out/
  '';

  meta = {
    homepage = "https://github.com/dzirtusss/vifari";
    description = "Vimium/Vimari for Safari without browser extension in pure Lua";
    changelog = "https://github.com/dzirtusss/vifari/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "vifari";
  };
}
