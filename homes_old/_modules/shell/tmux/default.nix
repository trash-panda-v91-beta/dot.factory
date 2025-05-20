{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.modules.shell.tmux;
  toggleTmuxPane = pkgs.writeShellApplication {
    name = "toggle-tmux-pane";
    bashOptions = [ ];
    runtimeInputs = with pkgs; [
      tmux
    ];
    text = builtins.readFile ./toggle-tmux-pane.sh;
  };
in
{
  options.modules.shell.tmux = {
    enable = lib.mkEnableOption "tmux";
    package = lib.mkPackageOption pkgs "tmux" { };
  };
  config = lib.mkIf cfg.enable {
    programs.tmux = {
      baseIndex = 1;
      enable = true;
      inherit (cfg) package;
      mouse = true;
      keyMode = "vi";
      sensibleOnTop = false;
      shell = "${pkgs.fish}/bin/fish";
      plugins = with pkgs.tmuxPlugins; [
        {
          plugin = resurrect;
          extraConfig = ''
            # Save and restore session
            set -g @resurrect-save 'S'
            set -g @resurrect-restore 'R'

            set -g @resurrect-strategy-nvim 'session'
          '';
        }
        vim-tmux-navigator
        continuum
      ];
      extraConfig = ''
        # Set terminal colors
        set -g default-terminal "tmux-256color"
        set -as terminal-overrides ',xterm*:sitm=\E[3m'

        set-window-option -g pane-base-index 1
        set-option -g renumber-windows on
        set -sg escape-time 0

        # kill pane
        bind-key x kill-pane

        # Pane resizing
        bind -n M-h resize-pane -L
        bind -n M-l resize-pane -R
        bind -n M-k resize-pane -U
        bind -n M-j resize-pane -D

        # Use visual selection mode as vi
        bind-key -T copy-mode-vi v send-keys -X begin-selection
        bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
        bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

        bind-key -n M-t run-shell "${toggleTmuxPane}/bin/toggle-tmux-pane"
        bind-key -T copy-mode M-t run-shell "${toggleTmuxPane}/bin/toggle-tmux-pane"
        bind-key -T copy-mode-vi M-t run-shell "${toggleTmuxPane}/bin/toggle-tmux-pane"
        bind-key -T copy-mode Escape send-keys -X cancel
        bind-key -T copy-mode-vi Escape send-keys -X cancel

        set-option -g focus-events on

        set -gu default-command
        set -g default-shell "$SHELL"

        bind-key "w" run-shell "sesh connect \"$(
          sesh list --icons --hide-duplicates | fzf-tmux -p 80%,50% --no-border \
            --ansi \
            --list-border \
            --no-sort --prompt '⚡  ' \
            --color 'list-border:6,input-border:3,preview-border:4,header-bg:-1,header-border:6' \
            --input-border \
            --header-border \
            --bind 'tab:down,btab:up' \
            --bind 'ctrl-b:abort' \
            --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
            --bind 'ctrl-t:change-prompt(  )+reload(sesh list -t --icons)' \
            --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
            --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
            --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
            --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
            --preview-window 'right:70%' \
            --preview 'sesh preview {}' \
        )\""

        set -g detach-on-destroy off
        bind -N "last-session (via sesh) " n run-shell "sesh last"
        bind -N "switch to root session (via sesh) " 9 run-shell "sesh connect --root \'$(pwd)\'"
      '';
    };
    home.packages = with pkgs; [
      fd
      unstable.fzf
      unstable.sesh
      zoxide

    ];
    xdg.configFile."sesh/sesh.toml".text = ''
      [default_session]
      startup_command = "nvim -c ':lua Snacks.picker.smart()'"
      preview_command = "eza --all --git --icons --color=always {}"

      [[session]]
      name = "Downloads"
      path = "~/Downloads"
      startup_command = "yazi"
    '';
  };
}
