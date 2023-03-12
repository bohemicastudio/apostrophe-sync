#!/bin/bash

## Shared resources
scriptdir="$(dirname "$0")"
source $scriptdir/.shared.sh


## Run the script

# Create local backup
echoTitle "Backup local database" &&
echoCmd "mongodump -d \"$LOCAL_MONGO_DB_NAME\" --archive=\"$LOCAL_BACKUP\"" &&

mongodump -d "$LOCAL_MONGO_DB_NAME" --archive="$LOCAL_BACKUP" &&


echoTitle "DONE"
exit 0
