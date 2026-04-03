#!/bin/sh

set -eu

agent="${1:-}"

if [ -z "$agent" ]; then
  tmux display-message "Missing AI agent name"
  exit 1
fi

side_width="$(tmux show-option -gqv @ai_agent_side_width)"
pane_path="$(tmux display-message -p "#{pane_current_path}")"

if [ -z "$side_width" ]; then
  side_width="40%"
fi

set -- $agent

if ! command -v "$1" >/dev/null 2>&1; then
  tmux display-message "AI agent command not found: $1"
  exit 1
fi

tmux split-window -h -l "$side_width" -c "$pane_path" "$agent"
