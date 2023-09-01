#!/bin/bash
#ADD TO BASHRC:
#source /home/ubuntu/jmux.sh
# Define a "class" to manage tmux sessions with SSH connections
function jmuxdiss() {
    tmux kill-session -t jsession
}

function jmuxconn() {
    local username="$1"
    local password="$1"
    shift 2
    tmux new-session -d -s jsession
    for ip in "$@"; do
        tmux split-window -v "sshpass -p $password ssh $username@$ip"
        tmux select-layout even-vertical
    done
    tmux attach-session -t jsession:0.0
    }

function jmuxcomm() {
    local servercount="$1"
    shift
    local cmd="" 
    for word in "$@"; do
        cmd="$cmd $word"
    done
    if [ -z "$cmd" ]; then
        for ((i=1; ; i++)); do
            tmux send-keys -t "jsession:0.$i" "" C-c
            if [ $i -eq $servercount ]; then
                break
            fi
        done
    else
        for ((i=1; ; i++)); do
            # You can add your commands here
            tmux send-keys -t "jsession:0.$i" "$cmd" C-m
            # Add a break condition if needed
            # For example, to stop after 10 iterations
            if [ $i -eq $servercount ]; then
                break
            fi
        done
    fi
    }