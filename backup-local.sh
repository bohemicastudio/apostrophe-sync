#!/bin/bash

## Shared resources
scriptdir="$(dirname "$0")"
source $scriptdir/.shared.sh


## Setup core variables
stamp=$(date +"%Y-%m-%d_%H-%M-%S")
local_filename="${LOCAL_MONGO_DB_NAME}_${stamp}$([ "$PERSONAL_TAGNAME" ] && echo "_$PERSONAL_TAGNAME").mongodump"

local_backup="${LOCAL_BACKUPS_FOLDER_PATH}/${local_filename}.bak"

if [ $MAC_PATHS == "true" ]; then
  # echo ":: MAC USER FOUND, DOTS ADDED TO PATHS"
  local_backup=".$local_backup"
fi


## Run the script

# Create local backup
echoTitle "Backup local database" &&
echoCmd "mongodump -d $LOCAL_MONGO_DB_NAME --archive=$local_backup" &&

mongodump -d $LOCAL_MONGO_DB_NAME --archive=$local_backup &&


echoTitle "DONE"
exit 0
