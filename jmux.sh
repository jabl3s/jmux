#!/bin/bash
# Declare an associative array to store key-value pairs
declare -A command_descriptions
# Define the key-value pairs (commands as keys and descriptions as values)
command_descriptions["connect"]="user@ip user@ip user@ip user@ip (limited to four tmux ssh panes at a time.)"
command_descriptions["command"]="[must_provide_number_of_panes] ...then leave blank to send ctrl+c to number of panes, ...pipe password in for sudo commands, see example of this in read me."
command_descriptions["hide"]="(jmux hide keeps ssh panes active, reconnect with empty jmux connect"
command_descriptions["disconnect"]="(All ssh panes connections end and jmux session ends, i.e. returning the console back to normal)"
command_descriptions["dependencies"]="(after first-ever jmux.sh download run this to get everything needed for jmux to work)"
command_descriptions["update"]="(gets the latest jmux from jabl3s git)"
command_descriptions["more"]="(Extend this prompt with more commands and additional info like current the limitations of jmux)"
command_descriptions["rke"]="(work in progress)"
command_descriptions["migrate"]="user@ip (work in progress)"
command_descriptions["ssh_copy_id"]="user@ip user@ip user@ip... (work in progress)"
function jmux_print_prompt() {
    local description_width=$(tput cols)-20
    # Loop through provided commands
    for command in "$@"; do
        if [ -n "${command_descriptions[$command]}" ]; then
            description="${command_descriptions[$command]}"
            local descriptionlength="${#description}"
            for ((trunkstart = 0; trunkstart < descriptionlength; trunkstart += description_width)); do
                local truncated_part="${description:trunkstart:description_width}"
                if [ $trunkstart = 0 ]; then
                    printf "jmux %-13s %s\n" "$command:" "$truncated_part"
                else
                    printf "%-18s %s\n" " " "${truncated_part}"
                fi
            done
        fi
    done
}
function jmux() {
    if [ $# -lt 1 ] || [ $# -gt 10 ]; then
        echo ""
        printf "%*s\n" "$(tput cols)" | tr ' ' "="
        echo "JMUX is a TMUX wrapper, see uses below" 
        echo ""
        jmux_print_prompt connect commant hide disconnect
        echo ""
        jmux_print_prompt dependencies update
        echo ""
        jmux_print_prompt more
        echo "."
        echo "."
        echo "."
        printf "%*s\n" "$(tput cols)" | tr ' ' "="
    else
        local param="$1"
        shift
        local reached="false"
        if [ $param = "connect" ]; then $reached = "true"; jmux_connect "$@"; fi
        if [ $param = "command" ]; then $reached = "true"; jmux_command "$@"; fi
        if [ $param = "hide" ]; then $reached = "true"; jmux_hide; fi
        if [ $param = "close" ]; then $reached = "true"; jmux_disconnect; fi
        if [ $param = "dependencies" ]; then $reached = "true"; jmux_dependencies; fi
        if [ $param = "update" ]; then $reached = "true"; jmux_update; fi
        if [ $param = "migrate" ]; then $reached = "true"; jmux_migrate "$@"; fi
        if [ $param = "rke" ]; then $reached = "true"; jmux_rke "$@"; fi
        if [ $param = "ssh_copy_id" ]; then $reached = "true"; jmux_ssh_copy_id "$@"; fi
        if [ $param = "more" ]; then $reached = "true"; jmux_more; fi
        if [ $reached = "true" ]; then echo ""; else echo ""; fi
    fi
}
function jmux_connect() { #USE LIKE: jmuxconnect user@ip..user@ip -ssh_copy_id
    if tmux has-session -t jsession 2>/dev/null; then
        jmux_show
    elif [ $# -lt 1 ] && [ $number -gt 4 ]; then
        echo "No current session to connect to..."
        echo "Start a jmux connect session with at least one input of user@ip (up to limmit of four)"
        echo "Min: jmux connect user@ip" 
        echo "Max: jmux connect user@ip user@ip user@ip user@ip" 
    else
        read -s -p "Enter the password being used on all these servers:" serverpass  
        tmux new-session -d -s jsession
        for ip in "$@"; do
            tmux split-window -v "sshpass -p $serverpass ssh $ip"
            tmux select-layout even-vertical
        done
        jmux_show
    fi
}
function jmux_command() { #USE LIKE: jmux_command x y..y
    local servercount="$1"
    shift
    local cmd="" 
    for word in "$@"; do
        cmd="$cmd $word"
    done
    if [ -z "$cmd" ]; then
        for ((i=1; i<= $server_count; i++)); do
            tmux send-keys -t "jsession:0.$i" "" C-c
        done
    else
        for ((i=1; i<= $server_count; i++)); do
            tmux send-keys -t "jsession:0.$i" "$cmd" C-m
        done
    fi
}
function jmux_hide() { #USE LIKE: jmux_hide 
    tmux detach-client
}
function jmux_show() { #USE LIKE: jmux_show
    tmux attach-session -t jsession:0.0
}
function jmux_disconnect() { #USE LIKE: jmux_disconnect
    tmux kill-session -t jsession
}
function jmux_dependencies() {
    sudo apt install curl sshpass tmux ssh-askpass ssh_copy_id git -y
}
function jmux_update(){
    # Define the line to check for
    local line_to_check="source ~/jmux.sh"
    # Check if the line is already in ~/.bashrc
    if grep -qF "$line_to_check" ~/.bashrc; then
        echo "The line is already in ~/.bashrc."
    else
        # Append the line to ~/.bashrc if it's not present
        echo "$line_to_check" >> ~/.bashrc
        echo "Added the line to ~/.bashrc."
    fi
    curl -H "Cache-Control: no-cache" -o ~/jmux.sh https://raw.githubusercontent.com/jabl3s/jmux/main/jmux.sh && source ~/.bashrc
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
function jmux_ssh_copy_id(){
    if [ $# -lt 1 ] && [ $number -gt 4 ]; then
        echo "Atleast one user@ip and up to four"
    else
        for ip in "$@"; do
            sshpass -p "$password" ssh-copy-id -i ~/.ssh/id_rsa.pub $ip
            echo "$ip"
        done
        echo "ssh pub keys copied to servers above with credentials provided, quitting..." 
    fi
}
function jmux_more(){
    jmux_print_prompt rke migrate ssh_copy_id
    printf "%*s\n" "$(tput cols)" | tr ' ' "="
    echo "Unlike ssh commands, jmux can still keep ssh sessions alive"
    echo "even without connection and stays active until jmux close is called."
    echo "Just reconnect to any lost session or from a jmux hide call with an empty jmux connect"
    echo ""
    echo "jmux function itself can take up to 10 parameters max" 
    echo "if you need more, for example, when using jmux command, "
    echo "consider making the whole command a string of one parameter"
    echo "e.g. jmux command 1 pwd && ls -a "
    echo "becomes three jmux parameters instead of six by using quotes around the 'sent' command..."
    echo "jmux command 1 'pwd && ls -a'"
    echo ""
}

