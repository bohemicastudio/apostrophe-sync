#!/bin/bash

## Shared resources
scriptdir="$(dirname "$0")"
source $scriptdir/.shared.sh

# Verify available SSH key
SSH_KEY="$(verifySSH)"


## Setup core variables
stamp=$(date +"%Y-%m-%d_%H-%M-%S")
filename="${LOCAL_MONGO_DB_NAME}_${stamp}$([ "$PERSONAL_TAGNAME" ] && echo "_$PERSONAL_TAGNAME").mongodump"
backup="${REMOTE_MONGO_DB_NAME}_${stamp}$([ "$PERSONAL_TAGNAME" ] && echo "_$PERSONAL_TAGNAME").mongodump.bak"

local_file=$LOCAL_BACKUPS_FOLDER_PATH/$filename
remote_file=$REMOTE_BACKUPS_FOLDER_PATH/$filename
remote_bak=$REMOTE_BACKUPS_FOLDER_PATH/$backup

if [ $MAC_PATHS == "true" ]; then
  # echo ":: MAC USER FOUND, DOTS ADDED TO PATHS"
  local_file=".$local_file"
fi

remote_address="$REMOTE_SSH_USER@$REMOTE_SSH_IP"
remote_ssh="-t -p $REMOTE_SSH_PORT $remote_address $SSH_KEY"


## Run the script

# Create local archive
echoTitle "Create local archive" &&
echoCmd "mongodump -d $LOCAL_MONGO_DB_NAME --archive=$local_file" &&

mongodump -d $LOCAL_MONGO_DB_NAME --archive=$local_file &&


# Transport archive
echoTitle "Transport archive" &&
echoCmd "rsync -av -e \"ssh -p $REMOTE_SSH_PORT $SSH_KEY\" $local_file $remote_address:$remote_file" &&

rsync -av -e "ssh -p $REMOTE_SSH_PORT $SSH_KEY" $local_file $remote_address:$remote_file &&


# Remove the local archive
# echoTitle "Remove the local archive" &&
# echoCmd "rm -rf $local_file" &&
# rm -rf $local_file &&


# Backup remote copy
echoTitle "Backup remote copy" &&
echoCmd "ssh $remote_ssh \"mongodump --archive --uri='$REMOTE_MONGO_URI' >> $remote_bak\"" &&

ssh $remote_ssh "mongodump --archive --uri='$REMOTE_MONGO_URI' >> $remote_bak" &&


# Apply local data to remote
echoTitle "Apply local data to remote" &&
up="--username=$REMOTE_MONGO_DB_USER --password=$REMOTE_MONGO_DB_PASS" &&
ns="--nsInclude=$LOCAL_MONGO_DB_NAME.* --nsFrom=$LOCAL_MONGO_DB_NAME.* --nsTo=$REMOTE_MONGO_DB_NAME.*" &&
echoCmd "ssh $remote_ssh \"mongorestore ${up} ${ns} --noIndexRestore --drop --archive=$remote_file\"" &&

ssh $remote_ssh "mongorestore ${up} ${ns} --noIndexRestore --drop --archive=$remote_file" &&


# Remove transported archive
echoTitle "Remove transported archive" &&
echoCmd "ssh $remote_ssh \"rm -rf $remote_file\"" &&

ssh $remote_ssh "rm -rf $remote_file" &&


echoTitle "DONE"
exit 0
