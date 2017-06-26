#/bin/bash

#check if boot partition is greater than 85%

#Check /boot partition space

boot=$(df -h | awk '/boot/{print $5}' | sed -e 's/%//')

if [ $boot -gt 80 ]
      then
         clear;
         echo "Boot partition has reached 100%! Lets clean it up ..."
         echo "Checking installed kernel images in this host ..."
         
	 echo -ne '#####                     (33%)\r'
	 sleep 1
	 echo -ne '#############             (66%)\r'
	 sleep 1
	 echo -ne '#######################   (100%)\r'
	 echo -ne '\n'

         sleep 1 && clear;   
         #Select the current version of kernel
         kversion=`uname -r`
         echo -e "The current kernel version in host is" $kversion. "\nSe bellow the list of unsed kernel images\n"

         #Print the kernel versions that will be deleted, except the current image
         dpkg -l | grep linux-image | awk '/ii/{print $2}' | egrep -v "(linux-image-$(uname -r)|linux-image-extra-$(uname -r)|linux-image-generic)"
         echo -e "\n"
         
         read -p "Would you like to delete the list above? (Y/n)" askyn 
	 case "$askyn" in 
  	 y|Y ) 
         
         #sleep 1 && clear;
  	
        #Remove the kernel images installed in the host, except the current kernel image 
        dpkg -l | grep linux-image | awk '/ii/{print $2}' | egrep -v "(linux-image-$(uname -r)|linux-image-extra-$(uname -r)|linux-image-generic)" \
        | while read kimage
          do
 	       sudo dpkg --configure -a > /dev/null 2>&1
               sudo apt-get -y remove $kimage > /dev/null 2>&1
               sudo dpkg --configure -a > /dev/null 2>&1 
               sudo apt-get install -f > /dev/null 2>&1
               sudo apt-get autoremove > /dev/null 2>&1
               sudo apt-get autoclean > /dev/null 2>&1
               echo Removed $kimage 
          done;;
 
         n|N ) 

             exit 1;;


         * ) echo "Invalid option";;
         esac

       #Show the new partition
       boot=$(df -h | awk '/boot/{print $5}')
       echo "The boot partition has now $boot% usage!"
       unset boot

   else
      clear
      echo -e "Boot partition has only $boot% usage. Exiting ...\n"
      unset boot

fi
