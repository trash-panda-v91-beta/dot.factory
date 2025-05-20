{
  lib,
  importNpmLock,
  buildNpmPackage,
  ...
}:

buildNpmPackage {
  pname = "karabiner-config";
  version = "0.1.0";
  src = ./src;
  npmDeps = importNpmLock {
    npmRoot = ./src;
  };
  dontNpmBuild = true;
  installPhase = ''
    TARGET_DIR=$HOME/.config/karabiner
    TARGET_FILE=$TARGET_DIR/karabiner.json
    echo "Making target dir $TARGET_DIR"
    mkdir -p $TARGET_DIR
    echo "Creating target file $TARGET_FILE"
    cat <<EOF > $TARGET_FILE
    {
      "profiles": [
        {
          "name": "Default",
          "virtual_hid_keyboard": { "keyboard_type_v2": "ansi" }
        }
      ]
    }
    EOF
    npm run build
    mkdir -p $out/
    cp $TARGET_FILE $out/karabiner.json
  '';
  inherit (importNpmLock) npmConfigHook;
  meta = {
    description = "My Karabiner Elements config";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ trash-panda-v91-beta ];
  };
}
