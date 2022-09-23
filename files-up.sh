#!/usr/bin/bash

Color_Off='\033[0m'
On_Yellow='\033[43m'
On_Blue='\033[44m'

if [ ! -f ".env" ]
then
   echo ".env file not found!"
   exit 1
fi

source ./.env

server_ssh="$SERVER_USER@$SERVER_IP"


dry=""
if [ "$1" == "-d" ] || [ "$1" == "--dry" ] ||  [ "$2" == "-d" ] || [ "$2" == "--dry" ]
then
    dry="--dry-run"
fi

force=""
if [ "$1" == "-f" ] || [ "$1" == "--force" ] || [ "$2" == "-f" ] || [ "$2" == "--force" ]
then
    printf "${On_Yellow}:: Do you really wish to remove files on the server, to match your directory precisely??${Color_Off}\n:: [YES/no] "
    read affi
    if [ "$affi" == "YES" ] || [ "$affi" == "yes" ] || [ "$affi" == "y" ]
    then
        force="--delete"
    else
        echo -e "${On_Yellow}:: Force command prevented${Color_Off}"
    fi
fi


# Sync script
echo -e "${On_Blue}:: Synchronize /uploads folders${Color_Off}" &&
rsync -av $dry $force -e "ssh -p $SERVER_SSH_PORT" $LOCAL_UPLOAD_FOLDER_PATH/public/ $server_ssh:$SERVER_UPLOAD_FOLDER_PATH/public &&

echo -e "${On_Blue}:: DONE${Color_Off}" &&
exit 0
