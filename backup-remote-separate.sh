#!/bin/bash

## Shared resources
scriptdir="$(dirname "$0")"
source $scriptdir/.shared.sh


## Run the script

# Create remote backup
echoTitle "Backup remote database" &&
echoCmd "mongodump --archive=\"$REMOTE_BACKUP_ON_LOCAL\" --uri=\"$REMOTE_MONGO_URI\"" &&

mongodump --archive="$REMOTE_BACKUP_ON_LOCAL" --uri="$REMOTE_MONGO_URI" &&


echoTitle "DONE"
exit 0
