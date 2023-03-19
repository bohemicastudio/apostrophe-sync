#!/bin/bash

## Shared resources
scriptdir="$(dirname "$0")"
source $scriptdir/.shared.sh


## Run the script

# Create local archive
echoTitle "Create local backup archive" &&
echoCmd "mongodump -d \"$LOCAL_MONGO_DB_NAME\" --archive=\"$LOCAL_BACKUP\"" &&

mongodump -d "$LOCAL_MONGO_DB_NAME" --archive="$LOCAL_BACKUP" &&


# Create remote backup
echoTitle "Backup remote database" &&
echoCmd "mongodump --archive=\"$REMOTE_FILE_ON_LOCAL\" --uri=\"$REMOTE_MONGO_URI\"" &&

mongodump --archive="$REMOTE_FILE_ON_LOCAL" --uri="$REMOTE_MONGO_URI" &&

sleep 1

# Apply remote archive to local
echoTitle "Apply archived data to local" &&
ns="--nsInclude=\"$REMOTE_MONGO_DB_NAME.*\" --nsFrom=\"$REMOTE_MONGO_DB_NAME.*\" --nsTo=\"$LOCAL_MONGO_DB_NAME.*\"" &&
echoCmd "mongorestore --noIndexRestore --drop $ns --archive=\"$REMOTE_FILE_ON_LOCAL\"" &&

mongorestore --noIndexRestore --drop $ns --archive="$REMOTE_FILE_ON_LOCAL" &&


echoTitle "DONE"
exit 0
