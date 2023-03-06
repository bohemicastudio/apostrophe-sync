#!/bin/bash

## Shared resources
scriptdir="$(dirname "$0")"
source $scriptdir/.shared.sh

# Verify available SSH key
SSH_KEY="$(verifySSH)"


## Setup core variables
stamp=$(date +"%Y-%m-%d_%H-%M-%S")
filename="${LOCAL_MONGO_DB_NAME}_${stamp}$([ "$PERSONAL_TAGNAME" ] && echo "_$PERSONAL_TAGNAME").mongodump"
remote_filename="${REMOTE_MONGO_DB_NAME}_${stamp}$([ "$PERSONAL_TAGNAME" ] && echo "_$PERSONAL_TAGNAME").mongodump.bak"

local_file=$LOCAL_BACKUPS_FOLDER_PATH/$filename
remote_bakup=$LOCAL_BACKUPS_FOLDER_PATH/$remote_filename

if $MAC_PATHS; then
  # echo ":: MAC USER FOUND, DOTS ADDED TO PATHS"
  local_file=".$local_file"
  remote_bakup=".$remote_bakup"
fi


## Run the script

# Create local archive
echoTitle "Create local archive" &&
echoCmd "mongodump -d $LOCAL_MONGO_DB_NAME --archive=$local_file" &&

mongodump -d $LOCAL_MONGO_DB_NAME --archive=$local_file &&


# Create remote backup
echoTitle "Backup remote database" &&
echoCmd "mongodump --archive='$remote_bakup' --uri='$REMOTE_MONGO_URI'" &&

mongodump --archive="$remote_bakup" --uri="$REMOTE_MONGO_URI" &&


# Apply local archive to remote
echoTitle "Apply archived data to remote" &&
ns="--nsInclude=$LOCAL_MONGO_DB_NAME.* --nsFrom=$LOCAL_MONGO_DB_NAME.* --nsTo=$REMOTE_MONGO_DB_NAME.*" &&
echoCmd "mongorestore --archive='$local_file' --uri='$REMOTE_MONGO_URI' --noIndexRestore --drop ${ns}" &&

mongorestore --archive="$local_file" --uri="$REMOTE_MONGO_URI" --noIndexRestore --drop ${ns} &&


echoTitle "DONE"
exit 0
