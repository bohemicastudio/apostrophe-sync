#!/bin/bash

## Shared resources
scriptdir="$(dirname "$0")"
source $scriptdir/.shared.sh


## Local .env resources
if [ ! -f "$scriptdir/.env" ]; then
  Alert ".env file not found"
  exit 1
else
  echo -e ":: .env file found"
fi

source $scriptdir/.env


## Setup core variables
stamp=$(date +"%Y-%m-%d_%H-%M-%S")
local_filename="${LOCAL_DB_NAME}_${stamp}$([ "$YOUR_PERSONAL_TAGNAME" ] && echo "_$YOUR_PERSONAL_TAGNAME").mongodump"

local_backup="${LOCAL_MONGO_BACKUPS_FOLDER_PATH}/${local_filename}.bak"

if [ $LOCAL_MAC_ADRESSES == "true" ]; then
  # echo ":: MAC USER FOUND, DOTS ADDED TO PATHS"
  local_backup=".$local_backup"
fi


## Run the script

# Create local backup
echoTitle "Backup local database" &&
echoCmd "mongodump -d $LOCAL_DB_NAME --archive=$local_backup" &&

mongodump -d $LOCAL_DB_NAME --archive=$local_backup &&


echoTitle "DONE"
exit 0
