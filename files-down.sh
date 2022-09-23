#!/usr/bin/bash

Color_Off='\033[0m'
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


# Sync script
echo -e "${On_Blue}:: Synchronize /uploads folders${Color_Off}" &&
rsync -av $dry -e "ssh -p $SERVER_SSH_PORT" $server_ssh:$SERVER_UPLOAD_FOLDER_PATH/public/ $LOCAL_UPLOAD_FOLDER_PATH/public &&

echo -e "${On_Blue}:: DONE${Color_Off}" &&
exit 0
