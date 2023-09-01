# jmux - ((tmux wrapper))  
  
## Step1) ((Install dependencies))  
sudo apt-get install sshpass tmux ssh-askpass  
## Step2) Add line below to ~/.bashrc  
source /path/to/jmux.sh  
## Step3) Reload bashrc with  
source ~./bashrc  
## Step4...) OPTIONS    
### 4.1) jmuxconn  
jmuxconn ssh_username ssh_password ipadresses:LIST_THEM_WITH_SPACES     
### 4.2) jmuxcomm  
jmuxcomm tmux_panes_number command  
N.B.:For-sudo:((jmuxcomm tmux_panes_number 'echo "ssh_password" | sudo -S apt update'))  
((To send a Ctrl+C just specify tmux_panes_number followed by no command.))  
### 4.3) jumuxdiss  
jmuxdiss ((Kills-the-jmuxconn-and-tmux-session))  
  
  
4.1.e.g.) jmuxconn ubuntu rootpassword 192.168.1.1 192.168.1.2 192.168.1.3 192.168.1.4  
4.2.e.g.) jmuxcomm 4 echo "wassup from tmux"  
![Alt text](/assets/images/image-1.png)  
  





