# JMUX - TMUX wrapper  
Do not use "ssh user@ip" anymore! Simply replace "ssh user@ip" with "jmux connect user@ip"  
- Reasoning: single ssh commands fail if connection is lost to server from remote machine, however, JMUX/TMUX perssists ssh sessions after unwated connection loss or even if you close your ssh window without first calling "exit"
- Also run as many as upto four ssh sessions in the same window at once with "jmux connect user@ip1 user@ip2 user@ip3 user@ip4", so long its the same username password on all ssh connections...  
- Current limitations are on the amount of tmux panes (not windows) you can fit verticaly set to four.  
Also jmux itself only takes a max of ten parameters. Caution using jmux command better to syncronise panes...    
## Install...  
### ...this only once to add the required line to your ~./bashrc:  
echo "source ~/jmux.sh" >> ~/.bashrc  
### ...then this as many times you like to initial install jmux:  
curl -o ~/jmux.sh https://raw.githubusercontent.com/jabl3s/jmux/stable-release/jmux.sh && source ~/.bashrc && jmux  
### After doing the above two commands now the shortcut below is available to do similar without hassle:  
jmux update   
  
## Usage  
- Tmux pane navigation is Ctrl+B the arrow key.  
- Use "exit" command to terminate any ssh sessions.  
jmux connect ubuntu@192.168.1.1 ubuntu@192.168.1.2 ubuntu@192.168.1.3 ubuntu@192.168.1.4  

![Alt text](/assets/images/jmuxdemo2.gif)  

  






