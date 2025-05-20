#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

is_zoomed=$(tmux display-message -p "#{window_zoomed_flag}")
pane_count=$(tmux list-panes | wc -l)
is_at_bottom=$(tmux display-message -p "#{pane_at_bottom}")


if [ "$pane_count" -eq 1 ]; then
  current_pane_dir=$(tmux display-message -p "#{pane_current_path}")
  tmux split-window -v -l 15 -c "$current_pane_dir"
elif [ "$is_zoomed" = "1" ]; then
  tmux select-pane -D
elif [ "$is_at_bottom" = "1" ]; then
  tmux select-pane -U
  tmux resize-pane -Z
else
  tmux select-pane -U
fi
