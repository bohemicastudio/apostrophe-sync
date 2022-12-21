#!/bin/bash

## Shared resources
scriptdir="$(dirname "$0")"
source $scriptdir/.shared.sh

## Verify available SSH key
SSH_KEY="$(verifySSH)"


## Setup core variables
stamp=$(date +"%Y-%m-%d_%H-%M-%S")
remote_filename="${REMOTE_DB_NAME}_${stamp}$([ "$YOUR_PERSONAL_TAGNAME" ] && echo "_$YOUR_PERSONAL_TAGNAME").mongodump"

remote_backup="${REMOTE_MONGO_BACKUPS_FOLDER_PATH}/${remote_filename}.bak"

if [ $LOCAL_MAC_ADRESSES == "true" ]; then
  # echo ":: MAC USER FOUND, DOTS ADDED TO PATHS"
  local_file=".$local_file"
  local_backup=".$local_backup"
fi

remote_ssh="$REMOTE_USER@$REMOTE_IP"
remote_ssh="-t -p $REMOTE_SSH_PORT $remote_ssh $SSH_KEY"
remote_uri="mongodb://$REMOTE_DB_USER:$REMOTE_DB_PASS@$REMOTE_IP:$REMOTE_MONGO_PORT/$REMOTE_DB_NAME?$REMOTE_DB_EXTRA"


## Run the script

# Create remote backup
echoTitle "Backup remote database" &&
# up="--username=$REMOTE_DB_USER --password=$REMOTE_DB_PASS" &&
echoCmd "mongodump ${up} --authenticationDatabase admin --archive --uri=$remote_uri >> $remote_backup" &&

ssh $remote_ssh "mongodump ${up} --authenticationDatabase admin --archive --uri=$remote_uri >> $remote_backup" &&


echoTitle "DONE"
exit 0
