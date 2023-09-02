# jmux - ((tmux wrapper)) 
Current limmitations are on the amount of tmux panes (not windows) you can fit verticaly set to four...  

## To install jmux run below command)
curl -o ~/jmux.sh https://raw.githubusercontent.com/jabl3s/jmux/main/jmux.sh \
&& echo "source ~/jmux" >> ~/.bashrc \
&& source ~/.bashrc
## Sudo commands)
e.g.) jmux command [number_of_panes] 'echo "yourpassword" | sudo -S apt get update'
## One example use case)
1.e.g.) jmux connect ubuntu@192.168.1.1 ubuntu@192.168.1.2 ubuntu@192.168.1.3 ubuntu@192.168.1.4  
2.e.g.) jmux command 4 echo "wassup from tmux"    
![Alt text](/assets/images/image-1.png)  
  





