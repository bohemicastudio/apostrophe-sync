#!/bin/bash

## Shared resources
scriptdir="$(dirname "$0")"
source $scriptdir/.shared.sh

# Verify available SSH key
SSH_KEY="$(verifySSH)"


## Setup core variables
stamp=$(date +"%Y-%m-%d_%H-%M-%S")
filename="${LOCAL_DB_NAME}_${stamp}$([ "$YOUR_PERSONAL_TAGNAME" ] && echo "_$YOUR_PERSONAL_TAGNAME").mongodump"
backup="${REMOTE_DB_NAME}_${stamp}$([ "$YOUR_PERSONAL_TAGNAME" ] && echo "_$YOUR_PERSONAL_TAGNAME").mongodump.bak"

local_file=$LOCAL_MONGO_BACKUPS_FOLDER_PATH/$filename
local_backup=$LOCAL_MONGO_BACKUPS_FOLDER_PATH/$backup
remote_file=$REMOTE_MONGO_BACKUPS_FOLDER_PATH/$filename

if [ $LOCAL_MAC_ADRESSES == "true" ]; then
  # echo ":: MAC USER FOUND, DOTS ADDED TO PATHS"
  local_file=".$local_file"
  local_backup=".$local_backup"
fi

remote_ssh="$REMOTE_USER@$REMOTE_IP"
remote_ssh="-t -p $REMOTE_SSH_PORT $remote_ssh $SSH_KEY"
remote_uri="mongodb://$REMOTE_DB_USER:$REMOTE_DB_PASS@$REMOTE_IP:$REMOTE_MONGO_PORT/$REMOTE_DB_NAME?$REMOTE_DB_EXTRA"


## Run the script

# Create remote archive
echoTitle "Create remote archive" &&
# up="--username=$REMOTE_DB_USER --password=$REMOTE_DB_PASS" &&
echoCmd "ssh $remote_ssh \"mongodump ${up} --authenticationDatabase admin --uri=$remote_uri --archive >> $remote_file\"" &&

ssh $remote_ssh "mongodump ${up} --authenticationDatabase admin --uri=$remote_uri --archive >> $remote_file" &&


# Download archive
echoTitle "Download archive" &&
echoCmd "rsync -av -e \"ssh -p $REMOTE_SSH_PORT $SSH_KEY\" $remote_ssh:$remote_file $local_file" &&

rsync -av -e "ssh -p $REMOTE_SSH_PORT $SSH_KEY" $remote_ssh:$remote_file $local_file &&


# Remove remote archive
# echoTitle "Remove remote archive" &&
# echoCmd "ssh $remote_ssh \"rm -rf $remote_file\"" &&
# ssh $remote_ssh "rm -rf $remote_file" &&


# Backup local database
echoTitle "Backup local database" &&
echoCmd "mongodump -d $LOCAL_DB_NAME --archive=$local_backup" &&

mongodump -d $LOCAL_DB_NAME --archive=$local_backup &&


# Apply remote data to local
echoTitle "Apply remote data to local" &&
ns="--nsInclude=$REMOTE_DB_NAME.* --nsFrom=$REMOTE_DB_NAME.* --nsTo=$LOCAL_DB_NAME.*" &&
echoCmd "mongorestore --noIndexRestore --drop ${ns} --archive=$local_file" &&

mongorestore --noIndexRestore --drop ${ns} --archive=$local_file &&


# Remove carried archive
echoTitle "Remove transported archive" &&
echoCmd "rm -rf $local_file" &&

rm -rf .$local_file &&


echoTitle "DONE" &&
exit 0
