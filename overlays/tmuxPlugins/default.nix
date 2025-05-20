{
  channels,
  ...
}:

final: prev: {
  tmuxPlugins =
    channels.nixpkgs-unstable.tmuxPlugins
    // prev.tmuxPlugins
    // {
      catppuccin = prev.tmuxPlugins.catppuccin.overrideAttrs (oldAttrs: {
        postInstall =
          (oldAttrs.postInstall or "")
          + ''
            cat >> $out/share/tmux-plugins/catppuccin/themes/catppuccin_cyberdream_tmux.conf << 'END'
            # vim:set ft=tmux:

            # --> Catppuccin (Frappe)
            set -ogq @thm_bg "#1e2124"
            set -ogq @thm_fg "#ffffff"

            # Colors
            set -ogq @thm_rosewater "#5ef1ff"
            set -ogq @thm_flamingo "#ff5ef1"
            set -ogq @thm_pink "#ff5ea0"
            set -ogq @thm_mauve "#ff5ef1"
            set -ogq @thm_red "#ff6e5e"
            set -ogq @thm_maroon "#ff6e5e"
            set -ogq @thm_peach "#ffbd5e"
            set -ogq @thm_yellow "#f1ff5e"
            set -ogq @thm_green "#5eff6c"
            set -ogq @thm_teal "#5ef1ff"
            set -ogq @thm_sky "#5ea1ff"
            set -ogq @thm_sapphire "#5ea1ff"
            set -ogq @thm_blue "#5ea1ff"
            set -ogq @thm_lavender "#ff5ef1"

            # Surfaces and overlays
            set -ogq @thm_subtext_1 "#7b8496"
            set -ogq @thm_subtext_0 "#7b8496"
            set -ogq @thm_overlay_2 "#3c4048"
            set -ogq @thm_overlay_1 "#3c4048"
            set -ogq @thm_overlay_0 "#3c4048"
            set -ogq @thm_surface_2 "#3c4048"
            set -ogq @thm_surface_1 "#3c4048"
            set -ogq @thm_surface_0 "#3c4048"
            set -ogq @thm_mantle "#1e2124"
            set -ogq @thm_crust "#1e2124"
            END
          '';
      });
    };
}
