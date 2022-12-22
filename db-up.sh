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
remote_file=$REMOTE_MONGO_BACKUPS_FOLDER_PATH/$filename
remote_bak=$REMOTE_MONGO_BACKUPS_FOLDER_PATH/$backup

if [ $LOCAL_MAC_ADRESSES == "true" ]; then
  # echo ":: MAC USER FOUND, DOTS ADDED TO PATHS"
  local_file=".$local_file"
fi

remote_address="$REMOTE_USER@$REMOTE_IP"
remote_ssh="-t -p $REMOTE_SSH_PORT $remote_address $SSH_KEY"
remote_uri="mongodb://$REMOTE_DB_USER:$REMOTE_DB_PASS@$REMOTE_IP:$REMOTE_MONGO_PORT/$REMOTE_DB_NAME?$REMOTE_DB_EXTRA"


## Run the script

# Create local archive
echoTitle "Create local archive" &&
echoCmd "mongodump -d $LOCAL_DB_NAME --archive=$local_file" &&

mongodump -d $LOCAL_DB_NAME --archive=$local_file &&


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
echoCmd "ssh $remote_ssh \"mongodump --authenticationDatabase admin --archive --uri=$remote_uri >> $remote_bak\"" &&

ssh $remote_ssh "mongodump --authenticationDatabase admin --archive --uri=$remote_uri >> $remote_bak" &&


# Apply local data to remote
echoTitle "Apply local data to remote" &&
up="--username=$REMOTE_DB_USER --password=$REMOTE_DB_PASS" &&
ns="--nsInclude=$LOCAL_DB_NAME.* --nsFrom=$LOCAL_DB_NAME.* --nsTo=$REMOTE_DB_NAME.*" &&
echoCmd "ssh $remote_ssh \"mongorestore ${up} ${ns} --noIndexRestore --drop --archive=$remote_file\"" &&

ssh $remote_ssh "mongorestore ${up} ${ns} --noIndexRestore --drop --archive=$remote_file" &&


# Remove transported archive
echoTitle "Remove transported archive" &&
echoCmd "ssh $remote_ssh \"rm -rf $remote_file\"" &&

ssh $remote_ssh "rm -rf $remote_file" &&


echoTitle "DONE"
exit 0
