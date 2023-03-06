#!/bin/bash

## Shared resources
scriptdir="$(dirname "$0")"
source $scriptdir/.shared.sh

## Verify available SSH key
SSH_KEY="$(verifySSH)"


## Setup core variables
stamp=$(date +"%Y-%m-%d_%H-%M-%S")
remote_filename="${REMOTE_MONGO_DB_NAME}_${stamp}$([ "$PERSONAL_TAGNAME" ] && echo "_$PERSONAL_TAGNAME").mongodump"
local_backup="${LOCAL_BACKUPS_FOLDER_PATH}/${remote_filename}.bak"

if $MAC_PATHS; then
  # echo ":: MAC USER FOUND, DOTS ADDED TO PATHS"
  remote_filename=".$remote_filename"
  local_backup=".$local_backup"
fi


## Run the script

# Create remote backup
echoTitle "Backup remote database" &&
echoCmd "mongodump --archive='$local_backup' --uri='$REMOTE_MONGO_URI'" &&

mongodump --archive="$local_backup" --uri="$REMOTE_MONGO_URI" &&


echoTitle "DONE"
exit 0
