#!/bin/bash

## Shared resources
scriptdir="$(dirname "$0")"
source $scriptdir/.shared.sh

## Verify available SSH key
SSH_KEY="$(verifySSH)"

remote_address="$REMOTE_SSH_USER@$REMOTE_SSH_IP"


## Handle arguments
dry=""
if [ "$1" == "-d" ] || [ "$1" == "--dry" ] || [ "$2" == "-d" ] || [ "$2" == "--dry" ]; then
  dry="--dry-run"
fi


## Run the script

# Sync script
echoTitle "Synchronize /uploads folders" &&
echoCmd "From: $remote_address:$REMOTE_UPLOADS_FOLDER_PATH/" &&
echoCmd "To: $LOCAL_UPLOADS_FOLDER_PATH" &&

rsync -av $dry -e "ssh -p $REMOTE_SSH_PORT $SSH_KEY" $remote_address:$REMOTE_UPLOADS_FOLDER_PATH/ $LOCAL_UPLOADS_FOLDER_PATH &&

echoTitle "DONE" &&
exit 0
