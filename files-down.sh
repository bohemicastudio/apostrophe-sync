#!/usr/bin/bash

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
rsync -av $dry -e "ssh -p $SERVER_SSH_PORT" $server_ssh:$SERVER_PATH/public/ $LOCAL_PATH/public
