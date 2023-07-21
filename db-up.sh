#!/bin/bash

## Shared resources
scriptdir="$(dirname "$0")"
source "$scriptdir/.shared.sh"

# Verify available SSH key
SSH_KEY="$(verifySSH)"

remote_address="$REMOTE_SSH_USER@$REMOTE_SSH_IP"
remote_ssh="-t -p $REMOTE_SSH_PORT $remote_address $SSH_KEY"


## Run the script

# Create local archive
echoTitle "Create local archive" &&
echoCmd "mongodump -d \"$LOCAL_MONGO_DB_NAME\" --archive=\"$LOCAL_FILE\"" &&

mongodump -d "$LOCAL_MONGO_DB_NAME" --archive="$LOCAL_FILE" &&


# Transport archive
echoTitle "Transport archive" &&
echoCmd "rsync -av -e \"ssh -p $REMOTE_SSH_PORT $SSH_KEY\" \"$LOCAL_FILE\" \"$remote_address:$REMOTE_FILE\"" &&

rsync -av -e "ssh -p $REMOTE_SSH_PORT $SSH_KEY" "$LOCAL_FILE" "$remote_address:$REMOTE_FILE" &&


# Remove the local archive
# echoTitle "Remove the local archive" &&
# echoCmd "rm -rf $LOCAL_FILE" &&
# rm -rf $LOCAL_FILE &&


# Backup remote copy
echoTitle "Backup remote copy" &&
echoCmd "ssh $remote_ssh \"mongodump --archive --uri=\"$REMOTE_MONGO_URI\" >> \"$REMOTE_BACKUP\"" &&

ssh $remote_ssh "mongodump --archive --uri=\"$REMOTE_MONGO_URI\" >> \"$REMOTE_BACKUP\"" &&


# Apply local data to remote
echoTitle "Apply local data to remote" &&
up="--username=\"$REMOTE_MONGO_DB_USER\" --password=\"$REMOTE_MONGO_DB_PASS\"" &&
ns="--nsInclude=\"$LOCAL_MONGO_DB_NAME.*\" --nsFrom=\"$LOCAL_MONGO_DB_NAME.*\" --nsTo=\"$REMOTE_MONGO_DB_NAME.*\"" &&
echoCmd "ssh $remote_ssh \"mongorestore $up $ns --noIndexRestore --drop --archive=$REMOTE_FILE\"" &&

ssh $remote_ssh "mongorestore $up $ns --noIndexRestore --drop --archive=$REMOTE_FILE" &&


# Remove transported archive
echoTitle "Remove transported archive" &&
echoCmd "ssh $remote_ssh \"rm -rf $REMOTE_FILE\"" &&

ssh $remote_ssh "rm -rf $REMOTE_FILE" &&


echoTitle "DONE"
exit 0
