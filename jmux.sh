#!/bin/bash
#ADD TO BASHRC:
#source /home/ubuntu/jmux.sh
# Define a "class" to manage tmux sessions with SSH connections
function jmuxdiss() {
    tmux kill-session -t jsession
}
function jmuxconn() {
    local option_ssh_copy_id=false
    if [ $# -ge 3 ]; then
        local username="$1"
        local password="$2"
        shift 2
        for arg in "$@"; do
            if [ "$arg" = "-ssh_copy_id" ]; then
                option_ssh_copy_id=true
                break
            fi
        done
    else
        echo "Ideally give ssh_username, ssh_pass then as many ip you want"
    fi
    if [ "$option_ssh_copy_id" = true ]; then
        for ip in "$@"; do
            sshpass -p "$password" ssh-copy-id -i ~/.ssh/id_rsa.pub $username@$ip
            echo "$ip"
        done
        echo "ssh pub keys copied to servers above with credentials provided, quitting..."
    elif [ $# -ge 1 ]; then
        tmux new-session -d -s jsession
        for ip in "$@"; do
            tmux split-window -v "sshpass -p $password ssh $username@$ip"
            tmux select-layout even-vertical
        done
        tmux attach-session -t jsession:0.0
    else
        echo "Provide atleast one ip address"
    fi
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