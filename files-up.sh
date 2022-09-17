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

force=""
if [ "$1" == "-f" ] || [ "$1" == "--force" ] || [ "$2" == "-f" ] || [ "$2" == "--force" ]
then
    printf ":: Do you really wish to remove files on the server, to match your directory precisely??\n:: [YES/no] "
    read affi
    if [ "$affi" == "YES" ] || [ "$affi" == "yes" ] || [ "$affi" == "y" ]
    then
        force="--delete"
    else
        echo ":: Force command prevented"
    fi
fi


# Sync script
rsync -av $dry $force -e "ssh -p $SERVER_SSH_PORT" $LOCAL_PATH/public/ $server_ssh:$SERVER_PATH/public
