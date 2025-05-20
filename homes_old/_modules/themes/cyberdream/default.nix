{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.modules.themes.cyberdream;
in
{
  options.modules.themes.cyberdream = {
    enable = lib.mkEnableOption "cyberdream";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      fira-code
      jetbrains-mono
    ];

    fonts.fontconfig.enable = true;
    programs.fzf.colors = {
      "bg+" = "#3c4048";
      fg = "#ffffff";
      "fg+" = "#ffffff";
      header = "#f1ff5e";
      hl = "#ff6e5e";
      "hl+" = "#5eff6c";
      info = "#f1ff5e";
      marker = "#5ea1ff";
      pointer = "#ff6e5e";
      prompt = "#bd5eff";
      spinner = "#5ef1ff";
    };

    programs.tmux.plugins = with pkgs.unstable.tmuxPlugins; [
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavor 'cyberdream'
          set -g @catppuccin_status_background "none"
          set -g @catppuccin_window_status_style "none"
          set -g @catppuccin_pane_status_enabled "off"
          set -g @catppuccin_pane_border_status "off"
          set -g @catppuccin_status_background "none"

          # status left look and feel
          set -g status-left-length 100
          set -g status-left ""
          set -ga status-left "#{?client_prefix,#{#[bg=default,fg=#{@thm_bg},bold]  #S },#{#[bg=default,fg=#{@thm_green}]  #S }}"
          set -ga status-left "#{?#{==:#{=/-32/...:#{s|$USER|~|:#{b:pane_current_path}}},#{s|_|.|:session_name}},, #[bg=default,fg=#{@thm_overlay_0},none]│}"
          set -ga status-left "#{?#{==:#{=/-32/...:#{s|$USER|~|:#{b:pane_current_path}}},#{s|_|.|:session_name}},,#[bg=default,fg=#{@thm_yellow}]  #{=/-32/...:#{s|$USER|~|:#{b:pane_current_path}}} }"
          set -ga status-left "#[bg=default,fg=#{@thm_overlay_0},none]#{?window_zoomed_flag,│,}"
          set -ga status-left "#[bg=default,fg=#{@thm_maroon}]#{?window_zoomed_flag,   ,}"

          # status right look and feel
          set -g status-right-length 60
          set -g status-right " "
          set -ga status-right "#[bg=default,fg=#{@thm_overlay_0}, none]"

          set -g status-position top
          set -g status-style "bg=default"
          set -g status-justify "right"

          setw -g pane-border-format ""
          setw -g pane-active-border-style "bg=#{@thm_bg},fg=#{@thm_overlay_0}"
          setw -g pane-border-style "bg=#{@thm_bg},fg=#{@thm_surface_0}"
          setw -g pane-border-lines single

          set -g window-status-format " #I "
          set -g window-status-style "bg=default,fg=#{@thm_peach}"
          set -g window-status-last-style "bg=default,fg=#{@thm_peach}"
          set -g window-status-activity-style "bg=#{@thm_red},fg=#{@thm_bg}"
          set -g window-status-bell-style "bg=#{@thm_red},fg=#{@thm_bg},bold"
          set -gF window-status-separator "#[bg=default,fg=#{@thm_overlay_0}]│"

          set -g window-status-current-style "bg=#{@thm_peach},fg=#{@thm_bg},bold"

          set-hook -g window-linked "if -F '#{==:#{session_windows},1}' 'set -g window-status-current-format \"\"' 'set -g window-status-current-format \" #I \"'"
          set-hook -g window-unlinked "if -F '#{==:#{session_windows},1}' 'set -g window-status-current-format \"\"' 'set -g window-status-current-format \" #I \"'"

        '';
      }
    ];

  };
}
