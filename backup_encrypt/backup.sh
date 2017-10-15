#!/env/bin bash
# ------------------------------------------------------------------
# Author: Thiago dos Santos
# Backup: Script path must be at /usr/local/bin/backup.sh
# Desc: This script archive files specified as parameters on the command line into a single file
# Usage: bash /usr/local/bin/backup.sh /path/to/filename1 /path/to/filename2 /path/to/filenameN
# ------------------------------------------------------------------

#Get number of parameters and filename passed through cli
numberParameters=$#
cliListFiles=${@:2}

#=================================  Verify Usage ==============================
display_usage() {
  printf "INFO: Backup script that must be run with super-user privileges.\n\n"
	printf "USAGE: bash backup.sh option [filename1 filename2 filenameN]\n\n"
  printf "INFO: Absolute filename path must be supplied if using '--add-to-crontab' option\n\n"
  printf " --archive - archive files\n"
  printf " --compress - optional command line switch for producing a compressed archive\n"
  printf " --encrypt - encrypt the archive\n"
  printf " --add-to-crontab - add entry to /etc/crontab that will run at 21:00 everyday and will keep same files\n"
  printf " --help or -h - show this help menu\n"
}

#====================  Verify CLI parameters ==================================
verify_cli_parameters(){
  # if less than two arguments provided, display usage
  if [  $1 == 0 ]
  then
  	display_usage
  	exit 1
  fi
  }

#====================  Verify User Exists =====================================
verify_user(){
  # display usage if the script is not run as root user
  USER=$(whoami)
  if [[ $USER != "root" ]]; then
  	printf "\nThis script must be run as root!\n\n"
  	exit 1
  fi
}

#====================  Verify Backup Destination ==============================
check_archive_dst() {
#check if backup destination exists, else creates one
  if [ -d "/var/www/backup" ]
  then
    OUTPUT="/var/www/backup"
  else
    mkdir -p /var/www/backup
    OUTPUT="/var/www/backup"
  fi
}

#====================  Verify Parameter isValid ===============================
check_file_exist() {
#check if file passed through cli parameter exists
  for i in "$@"
  do
    if [ ! -e "$i" ] && [ $i -ne "--compress"]
    then
      printf "\n $i ERROR: File not found or does not exist! \n"
      exit 1
    fi
  done
}

#====================  Archive files =========================================
archive_files(){
  #check archive dir
  check_archive_dst
  #Check if file passed through cli parameter exists
  check_file_exist $cliListFiles
  #zip files
  fileArchiveName=$OUTPUT/archive-`date +%Y%m%d`.tar
  tar -cvf $fileArchiveName $@ > /dev/null 2&>1
  printf "INFO: Files archived and saved to $fileArchiveName \n"
}

#====================  Compress archives =====================================
compress_archives(){
  tar -cvzf $fileArchiveName.gz $fileArchiveName > /dev/null 2&>1
  printf "INFO: Archive compressed and saved to $fileArchiveName.gz \n"
}

#====================  Add to crontab ========================================
check_crontab_entry(){
  #Check if backup.sh is present at /etc/crontab, add entries if not present
  grep backup.sh /etc/crontab > /dev/null
  if [ "$?" != 0 ]
  then
    echo "0 21 * * * $USER /usr/local/bin/backup.sh $cliListFiles" >> /etc/crontab
  fi
  printf "INFO: New crontab entry has been added: Please check /etc/crontab\n"
}

#================================== Main ======================================
verify_cli_parameters $numberParameters

#Check command passed via cli
case "$1" in
        "--help")
            display_usage
            exit 1
            ;;
        "-h")
            display_usage
            exit 0
            ;;
        "--archive")
            archive_files $cliListFiles
            ;;
        "--add-to-crontab")
            archive_files $cliListFiles
            check_crontab_entry
            ;;
        "--compress")
            archive_files $cliListFiles
            compress_archives
            ;;
        "--encrypt")
            archive_files $cliListFiles
            printf "INFO: Encrypted $fileArchiveName.enc by calling ./encrypt.sh\n"
            bash encrypt.sh $fileArchiveName
            ;;
esac
