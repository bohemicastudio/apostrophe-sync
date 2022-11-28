#!/bin/bash

## Shared resources
scriptdir="$(dirname "$0")"
source $scriptdir/.shared.sh

## Verify available SSH key
SSH_KEY="$(verifySSH)"


## Setup core variables
stamp=$(date +"%Y-%m-%d_%H-%M-%S")
server_filename="${SERVER_DB_NAME}_${stamp}$([ "$YOUR_PERSONAL_TAGNAME" ] && echo "_$YOUR_PERSONAL_TAGNAME").mongodump"

server_backup="${SERVER_MONGO_BACKUPS_FOLDER_PATH}/${server_filename}.bak"

if [ $LOCAL_MAC_ADRESSES == "true" ]; then
  # echo ":: MAC USER FOUND, DOTS ADDED TO PATHS"
  local_file=".$local_file"
  local_backup=".$local_backup"
fi

server_ssh="$SERVER_USER@$SERVER_IP"
remote_ssh="-t -p $SERVER_SSH_PORT $server_ssh $SSH_KEY"
server_uri="mongodb://$SERVER_DB_USER:$SERVER_DB_PASS@$SERVER_IP:$SERVER_MONGO_PORT/$SERVER_DB_NAME?$SERVER_DB_EXTRA"


## Run the script

# Create server backup
echoTitle "Backup server database" &&
# up="--username=$SERVER_DB_USER --password=$SERVER_DB_PASS" &&
echoCmd "mongodump ${up} --authenticationDatabase admin --archive --uri=$server_uri >> $server_backup" &&

ssh $remote_ssh "mongodump ${up} --authenticationDatabase admin --archive --uri=$server_uri >> $server_backup" &&


echoTitle "DONE"
exit 0
