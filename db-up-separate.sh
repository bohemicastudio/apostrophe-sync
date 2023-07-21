#!/bin/bash

## Shared resources
scriptdir="$(dirname "$0")"
source "$scriptdir/.shared.sh"


## Run the script

# Create local archive
echoTitle "Create local archive" &&
echoCmd "mongodump -d \"$LOCAL_MONGO_DB_NAME\" --archive=\"$LOCAL_FILE\"" &&

mongodump -d "$LOCAL_MONGO_DB_NAME" --archive="$LOCAL_FILE" &&


# Create remote backup
echoTitle "Backup remote database" &&
echoCmd "mongodump --archive=\"$REMOTE_BACKUP_ON_LOCAL\" --uri=\"$REMOTE_MONGO_URI\"" &&

mongodump --archive="$REMOTE_BACKUP_ON_LOCAL" --uri="$REMOTE_MONGO_URI" &&


# Apply local archive to remote
echoTitle "Apply archived data to remote" &&
ns="--nsInclude=\"$LOCAL_MONGO_DB_NAME.*\" --nsFrom=\"$LOCAL_MONGO_DB_NAME.*\" --nsTo=\"$REMOTE_MONGO_DB_NAME.*\"" &&
echoCmd "mongorestore --archive=\"$LOCAL_FILE\" --uri=\"$REMOTE_MONGO_URI\" --noIndexRestore --drop $ns" &&

mongorestore --archive="$LOCAL_FILE" --uri="$REMOTE_MONGO_URI" --noIndexRestore --drop $ns &&


echoTitle "DONE"
exit 0
