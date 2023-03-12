#!/bin/bash

## Shared resources
scriptdir="$(dirname "$0")"
source $scriptdir/.shared.sh

# Verify available SSH key
SSH_KEY="$(verifySSH)"

remote_address="$REMOTE_SSH_USER@$REMOTE_SSH_IP"
remote_ssh="-t -p $REMOTE_SSH_PORT $remote_address $SSH_KEY"


## Run the script

# Create remote archive
echoTitle "Create remote archive" &&
echoCmd "ssh $remote_ssh \"mongodump --archive --uri='$REMOTE_MONGO_URI' >> $REMOTE_FILE\"" &&

ssh $remote_ssh "mongodump --archive --uri='$REMOTE_MONGO_URI' >> $REMOTE_FILE" &&


# Download archive
echoTitle "Download archive" &&
echoCmd "rsync -av -e \"ssh -p $REMOTE_SSH_PORT $SSH_KEY\" \"$remote_address:$REMOTE_FILE\" \"$REMOTE_FILE_ON_LOCAL\"" &&

rsync -av -e "ssh -p $REMOTE_SSH_PORT $SSH_KEY" "$remote_address:$REMOTE_FILE" "$REMOTE_FILE_ON_LOCAL" &&


# Remove remote archive
# echoTitle "Remove remote archive" &&
# echoCmd "ssh $remote_ssh \"rm -rf $REMOTE_FILE\"" &&
# ssh $remote_ssh "rm -rf $REMOTE_FILE" &&


# Backup local database
echoTitle "Backup local database" &&
echoCmd "mongodump -d \"$LOCAL_MONGO_DB_NAME\" --archive=\"$LOCAL_BACKUP\"" &&

mongodump -d "$LOCAL_MONGO_DB_NAME" --archive="$LOCAL_BACKUP" &&


# Apply remote data to local
echoTitle "Apply remote data to local" &&
ns="--nsInclude=\"$REMOTE_MONGO_DB_NAME.*\" --nsFrom=\"$REMOTE_MONGO_DB_NAME.*\" --nsTo=\"$LOCAL_MONGO_DB_NAME.*\"" &&
echoCmd "mongorestore --noIndexRestore --drop $ns --archive=\"$REMOTE_FILE_ON_LOCAL\"" &&

mongorestore --noIndexRestore --drop $ns --archive="$REMOTE_FILE_ON_LOCAL" &&


# Remove carried archive
echoTitle "Remove transported archive" &&
echoCmd "rm -rf \"$REMOTE_FILE_ON_LOCAL\"" &&

rm -rf "$REMOTE_FILE_ON_LOCAL" &&


echoTitle "DONE" &&
exit 0
