#!/bin/bash

## Shared resources
scriptdir="$(dirname "$0")"
source $scriptdir/.shared.sh

## Verify available SSH key
SSH_KEY="$(verifySSH)"


## Setup core variables
stamp=$(date +"%Y-%m-%d_%H-%M-%S")
remote_filename="${REMOTE_MONGO_DB_NAME}_${stamp}$([ "$PERSONAL_TAGNAME" ] && echo "_$PERSONAL_TAGNAME").mongodump"

remote_backup="${REMOTE_BACKUPS_FOLDER_PATH}/${remote_filename}.bak"

if [ $MAC_PATHS == "true" ]; then
  # echo ":: MAC USER FOUND, DOTS ADDED TO PATHS"
  local_file=".$local_file"
  local_backup=".$local_backup"
fi

remote_address="$REMOTE_SSH_USER@$REMOTE_SSH_IP"
remote_ssh="-t -p $REMOTE_SSH_PORT $remote_address $SSH_KEY"
remote_uri="mongodb://${REMOTE_MONGO_DB_USER:+$REMOTE_MONGO_DB_USER${REMOTE_MONGO_DB_PASS:+:$REMOTE_MONGO_DB_PASS}@}$REMOTE_MONGO_DB_IP${REMOTE_MONGO_DB_PORT:+:$REMOTE_MONGO_DB_PORT}/$REMOTE_MONGO_DB_NAME${REMOTE_MONGO_URI:+?$REMOTE_MONGO_URI}"


## Run the script

# Create remote backup
echoTitle "Backup remote database" &&
# up="--username=$REMOTE_MONGO_DB_USER --password=$REMOTE_MONGO_DB_PASS" &&
echoCmd "mongodump ${up} --archive --uri='$remote_uri' >> $remote_backup" &&

ssh $remote_ssh "mongodump ${up} --archive --uri='$remote_uri' >> $remote_backup" &&


echoTitle "DONE"
exit 0
