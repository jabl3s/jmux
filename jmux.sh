#!/bin/bash
function jmux() {
    if [ $# -lt 1 ]; then
        echo ""
        echo "======================================================================"
        echo "JMUX is a TMUX wrapper, see uses below" 
        echo ""
        echo "jmux connect      user@ip user@ip user@ip user@ip (limmited to four tmux ssh panes at a time)"
        echo "jmux command      [number_of_panes] then enter most types of commands here like normal, or as string, be sure to pipe password in for sudo commands, leave blank to send ctrl+c"
        echo "jmux hide         (Hides the current jmux connect ssh/tmux session, it is still active even if connection goes down)"        
        echo "jmux show         (Shows the session)"        
        echo "jmux close        (Closes all ssh sessions then closes jmux session)"
        echo ""
        echo "jmux dependencies (after first ever jmux.sh download run this to get everything needed for jmux to work)"
        echo "jmux update       (gets the latest jmux from jabl3s git)"
        echo "jmux migrate      user@ip (work in progress)"
        echo "jmux rke"
        echo "jmux ssh_copy_id  user@ip user@ip user@ip... (work in progress)"
        echo "jmux help"
        echo "======================================================================"
        echo ""
        echo "Unlike ssh commands, jmux connect can still keep ssh sessions alive without connection..."
        echo "...just reconnect with jmux show"
    else
        local param="$1"
        local reached="false"
        shift
        if [ $param = "dependencies" ]; then $reached = "true"; jmux_dependencies; fi
        if [ $param = "update" ]; then $reached = "true"; jmux_update; fi
        if [ $param = "rke" ]; then $reached = "true"; jmux_rke; fi
        if [ $param = "help" ]; then $reached = "true"; jmux; fi
        if [ $param = "close" ]; then $reached = "true"; jmux_close; fi
        if [ $param = "connect" ]; then $reached = "true"; jmux_connect $#; fi
        if [ $param = "command" ]; then $reached = "true"; jmux_command $#; fi
        if [ $param = "migrate" ]; then $reached = "true"; jmux_migrate $#; fi
        if [ $param = "ssh_copy_id" ]; then $reached = "true"; jmux_ssh_copy_id $#; fi
        if [ $reached = "true" ]; then echo ""; else echo ""; fi
    fi
}
function jmux_dependencies() {
    sudo apt install curl sshpass tmux ssh-askpass ssh_copy_id git -y
}
function jmux_update(){
    # Define the line to check for
    line_to_check="source ~/jmux"
    # Check if the line is already in ~/.bashrc
    if grep -qF "$line_to_check" ~/.bashrc; then
        echo "The line is already in ~/.bashrc."
    else
        # Append the line to ~/.bashrc if it's not present
        echo "$line_to_check" >> ~/.bashrc
        echo "Added the line to ~/.bashrc."
    fi
    curl -o ~/jmux https://raw.githubusercontent.com/jabl3s/jmux/main/jmux.sh && source ~/.bashrc
}
function jmux_rke(){
        # Specify the path to the YAML file
        yaml_file="~/jmuxrkeconfig.yaml"
        # Prompt the user for the number of servers
        read -p "Enter the number of servers you want to cluster (master=1 + workers>=1): " server_count
        read -p "Enter the user thats on both master and workers" host_user
        # Check if the YAML file exists; if not, create it with initial content
        if [ ! -f "$yaml_file" ]; then
            rm -R ~/jmuxrkeconfig.yaml
        fi
        echo "ssh_key_path: ~/.ssh/id_rsa" > "$yaml_file"
        echo "nodes:" >> "$yaml_file"
        # Loop to generate the server blocks and append them to the YAML file
        for ((i=1; i<=$server_count; i++)); do
            read -p "Enter the address for HOST_$i: " host_address
            echo "  - address: $host_address" >> "$yaml_file"
            echo "    user: ${host_user}" >> "$yaml_file"
            echo "    role:" >> "$yaml_file"
            echo "      - worker" >> "$yaml_file"
        done
        echo "YAML content has been updated in $yaml_file."
}
function jmux_close() { #USE LIKE: jmuxclose
    tmux kill-session -t jsession
}
function jmux_connect() { #USE LIKE: jmuxconnect user@ip..user@ip -ssh_copy_id
    local option_ssh_copy_id=false
    if [ $# -lt 1 ] && [ $number -gt 4 ]; then
        echo "Atleast one user@ip and up to four for typical screen vertical space limits..."
        echo "...as well as to prevent loops in this command from being too large."
        echo "e.g.1. jmux connect user@ip" 
        echo "e.g.2. jmux connect user@ip user@ip user@ip user@ip" 
    else
        read -p "Enter the password being used on all these servers:" password
        for arg in "$@"; do
            if [ "$arg" = "-ssh_copy_id" ]; then option_ssh_copy_id=true; break; fi
        done
        if [ "$option_ssh_copy_id" = true ]; then
            for ip in "$@"; do
                sshpass -p "$password" ssh-copy-id -i ~/.ssh/id_rsa.pub $ip
                echo "$ip"
            done
            echo "ssh pub keys copied to servers above with credentials provided, quitting..."   
        else
            tmux new-session -d -s jsession
            for ip in "$@"; do
                tmux split-window -v "sshpass -p $password ssh $ip"
                tmux select-layout even-vertical
            done
            tmux attach-session -t jsession:0.0
        fi
    fi
}
function jmux_command() { #USE LIKE: jmuxcommand x y..y
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
function jmux_migrate() { #USE LIKE: jmuxmigrate x y z -install_tmux
    local option_install_tmux=false
    if [ $# -e 1 ]; then
        read -p "Enter the password being used on all these servers:" password
        tmux attach-session -t jsession:0.0
        tmux new-window -v -n jmigrate "sshpass -p $password ssh $ip"
        tmux send-keys -t "jsession:jmigrate" "echo $password | sudo -S apt-get install -y tmux" C-m
        tmux kill-window -t "jsession:jmigrate"
        echo "Assuming tmux installed on remote host ok..."
    else
        echo "TRY::: jmux migrate user@ip"
    fi
}

