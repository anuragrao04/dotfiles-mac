#!/bin/bash
# Dev layout: nvim (75%) | claude (25%)
# Called by sesh as startup_command for new sessions
tmux split-window -h -p 25 -c "$(pwd)" 'claude'
tmux set-environment CLAUDE_PANE "$(tmux display-message -p '#{pane_id}')"
tmux select-pane -L
exec nvim
