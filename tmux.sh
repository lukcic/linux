#!/bin/zsh

SESSION="test"

tmux has-session -t $SESSION 2>/dev/null
tmux attach-session -t $SESSION

if [ $? != 0 ]; then
    tmux new-session -d -s $SESSION -n zsh
    tmux send-keys -t $SESSION "cd /$HOME/lukcic/projects" C-m
    tmux select-window -t $SESSION:zsh

    tmux set-option -t $SESSION status on
    tmux set-option -t $SESSION status-style fg=white,bg=black
    tmux set-option -t $SESSION status-left-length 40
    tmux set-option -t $SESSION status-right "#[fg=cyan]%d %b %R"
fi

tmux attach session -t $SESSION




# tmux new-window -n test_window_2

# tmux send-keys "tmux ls" C-m

# tmux new-window -n test_window_3
# tmux send-keys "ifconfig" C-m

# HIGHLIGHT_COLOR="cyan"
# BG_COLOR="black"
# ACTIVE_COLOR="red"

# tmux set-option -t test_window_1 status-style fg=white,bg=$BG_COLOR
# ---
# Tmux ressurect
