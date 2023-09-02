# JMUX - TMUX wrapper 
- Do not use "ssh user@ip" anymore! Single ssh commands fail if connection is lost to server from remote machine, however, JMUX/TMUX perssists ssh sessions after unwated connection loss, simply replace "ssh user@ip" with "jmux connect user@ip" and after having run jmux connect its only terminated after a "jmux disconnect" is called. Also run as many as upto four ssh sessions in the same window at once with "jmux connect user@ip1 user@ip2 user@ip3 user@ip4" so long its the same username password on all ssh connections...  
### ((Tmux pane navigation is Ctrl+B the arrow key))  
  
     
Current limitations are on the amount of tmux panes (not windows) you can fit verticaly set to four.  
Also jmux itself only takes a max of ten parameters. Caution using jmux command better to syncronise panes...    
  
## To install jmux run...  
### ...this only once to add the required line to your ~./bashrc:  
echo "source ~/jmux.sh" >> ~/.bashrc  
### ...then this as many times you like to initial install jmux:  
curl -o ~/jmux.sh https://raw.githubusercontent.com/jabl3s/jmux/main/jmux.sh && source ~/.bashrc && jmux  
### Note, after doing the above two commands once now the shortcut below is available to do the same without hassle:  
jmux update  
## jmux command: sudo command example  
jmux command [number_of_panes] 'echo "yoursudoerpassword" | sudo -S apt get update'  
## jmux connect: simple example  
jmux connect ubuntu@192.168.1.1 ubuntu@192.168.1.2 ubuntu@192.168.1.3 ubuntu@192.168.1.4  
((prompt appears for the password of the alias user on all servers listed in jmux connect command))  
jmux command 4 echo "wassup from tmux"    
![Alt text](/assets/images/image-1.png)  
  
As you can see I have one remote machine "Jtop", ssh-ing into 4 different servers, all with a pi username same password across these four servers. jmux commands can only be carried out in the first pane i.e. your remote machine, navigate to other panes one by one with tmux navigation keys ((Ctrl+B then the arrow up/down key)) to run commands per server, nav back to the first pane which is default after a connect call is made to run commands across all other panes except your first pane with something like """jmux command [number_of_server_panes_excluding_remote_machine_top_pane] (so in above image 4 not 5 is supplied followed by) desired_server_command"""
  





