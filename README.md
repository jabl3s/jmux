# jmux - ((tmux wrapper)) 
current limmitations are on the amount of panes you can fit verticaly...  

  
## Step1) ((Install dependencies))  
sudo apt install sshpass tmux ssh-askpass ssh_copy_id -y      
## Step2) Add line below to ~/.bashrc  
source /path/to/jmux.sh  
## Step3) Reload bashrc with  
source ~./bashrc  
## Step4...) OPTIONS    
### 4.1) jmuxconnect x y z -ssh_copy_id
jmuxconnect ssh_username ssh_password ssh_ip_adresses:LIST_THEM_WITH_SPACES     
### 4.2) jmuxcommand x y   
jmuxcommand tmux_panes_number command  
N.B.:For-sudo:((jmuxcomm tmux_panes_number 'echo "ssh_password" | sudo -S apt update'))  
((To send a Ctrl+C just specify tmux_panes_number followed by no command.))  
### 4.3) jmuxmigrate x y z -install_tmux     
jmuxmigrate ssh_username ssh_password ssh_ip 
### 4.4) jumuxclose     
jmuxdisconnect ((Kills-the-jmuxconn-and-tmux-session))  
  
  
4.1.e.g.) jmuxconnect ubuntu rootpassword 192.168.1.1 192.168.1.2 192.168.1.3 192.168.1.4  
4.2.e.g.) jmuxcommand 4 echo "wassup from tmux"  
![Alt text](/assets/images/image-1.png)  
  





