{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  inherit (config.home) username homeDirectory;
  cfg = config.modules.shell.fish;
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
        shellAbbrs = {
          cdc = {
            expansion = "cd ~/repos/corporate/%";
            setCursor = true;
          };
          cdp = {
            expansion = "cd ~/repos/personal/%";
            setCursor = true;
          };

          va = "auto_activate_venv";
        };
        interactiveShellInit = ''
          function remove_path
            if set -l index (contains -i $argv[1] $PATH)
              set --erase --universal fish_user_paths[$index]
            end
          end

          function update_path
            if test -d $argv[1]
              fish_add_path -m $argv[1]
            else
              remove_path $argv[1]
            end
          end

          # Paths are in reverse priority order
          update_path /opt/homebrew/bin
          update_path /nix/var/nix/profiles/default/bin
          update_path /run/current-system/sw/bin
          update_path /etc/profiles/per-user/${username}/bin
          update_path /run/wrappers/bin
          update_path ${homeDirectory}/go/bin
          update_path ${homeDirectory}/.cargo/bin
          update_path ${homeDirectory}/.local/bin

          set fish_greeting # Disable greeting
          fish_vi_key_bindings

          set -gx fish_vi_force_cursor 1
          set -gx fish_cursor_default block
          set -gx fish_cursor_insert line blink
          set -gx fish_cursor_visual block
          set -gx fish_cursor_replace_one underscoreeval
          set -gx PIP_REQUIRE_VIRTUALENV true
          set -gx PATH $PATH $HOME/.krew/bin

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
