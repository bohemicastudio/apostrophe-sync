#!/bin/bash

## Shared resources
scriptdir="$(dirname "$0")"
source "$scriptdir/.shared.sh"

## Verify available SSH key
SSH_KEY="$(verifySSH)"

remote_address="$REMOTE_SSH_USER@$REMOTE_SSH_IP"
remote_ssh="-t -p $REMOTE_SSH_PORT $remote_address $SSH_KEY"


## Run the script

# Create remote backup
echoTitle "Backup remote database" &&
echoCmd "mongodump --archive --uri=\"$REMOTE_MONGO_URI\" >> \"$REMOTE_BACKUP\"" &&

ssh $remote_ssh "mongodump --archive --uri=\"$REMOTE_MONGO_URI\" >> \"$REMOTE_BACKUP\"" &&


echoTitle "DONE"
exit 0
