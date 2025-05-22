{
  namespace,
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  inherit (config.home) username homeDirectory;
  cfg = config.${namespace}.programs.fish;
in
{
  options.modules.shell.fish = {
    enable = lib.mkEnableOption "fish";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      programs.fish = {
        enable = true;
        plugins = [
          {
            name = "puffer";
            inherit (pkgs.fishPlugins.puffer) src;
          }
        ];
        interactiveShellInit = ''
          update_path /nix/var/nix/profiles/default/bin
          update_path /run/current-system/sw/bin
          update_path /etc/profiles/per-user/${username}/bin
          update_path /run/wrappers/bin

          set fish_greeting # Disable greeting
          fish_vi_key_bindings

          set -gx fish_vi_force_cursor 1
          set -gx fish_cursor_default block
          set -gx fish_cursor_insert line blink
          set -gx fish_cursor_visual block
          set -gx fish_cursor_replace_one underscoreeval

          function __auto_auto_activate_venv --on-variable PWD
              auto_activate_venv
          end
        '';

        functions = {
          auto_activate_venv = {
            body = ''
              set REPO_ROOT (git rev-parse --show-toplevel 2>/dev/null)

              if test -z "$REPO_ROOT"; and test -d "$(pwd)/.venv"
                  if [ "$VIRTUAL_ENV" != "$(pwd)/.venv" ]
                      source "$(pwd)/.venv/bin/activate.fish" &>/dev/null
                  end
                  return
              end

              if test -z "$REPO_ROOT"; and test -n "$VIRTUAL_ENV"
                  deactivate
              end

              if [ "$VIRTUAL_ENV" = "$REPO_ROOT/.venv" ]
                  return
              end

              if [ -d "$REPO_ROOT/.venv" ]
                  source "$REPO_ROOT/.venv/bin/activate.fish" &>/dev/null
              end
            '';
            description = "Auto activate/deactivate python venv";
          };
          fish_user_key_bindings = {
            body = ''
              bind --mode insert --sets-mode default jj repaint
              bind --mode insert \cf forward-char
              bind --mode insert \cw forward-word
              bind yy fish_clipboard_copy
              bind Y fish_clipboard_copy
              bind p fish_clipboard_paste
              bind p fish_clipboard_paste
              bind v --mode default 'tmux copy-mode'
            '';
          };
        };
      };
    })

    (lib.mkIf (cfg.enable && isDarwin) {
      programs.fish = {
        functions = {
          flushdns = {
            description = "Flush DNS cache";
            body = builtins.readFile ./functions/flushdns.fish;
          };
        };
      };
    })
  ];
}
