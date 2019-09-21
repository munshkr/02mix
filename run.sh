#!/bin/bash
set -euf -o pipefail

TMUX=${TMUX:-"tmux"}
NVIM=${NVIM:-"nvim"}
ARGS=${@:-"-p setup.scd part1.scd part2.scd"}
SESSION=${SESSION:-"sc-02mix"}

$TMUX -2 attach-session -t $SESSION || $TMUX -2 \
  new-session -s $SESSION   \; \
  send-keys -t 0 "$NVIM -p $ARGS" C-m
