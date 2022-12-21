#!/bin/bash

## Shared resources
scriptdir="$(dirname "$0")"
source $scriptdir/.shared.sh

## Verify available SSH key
SSH_KEY="$(verifySSH)"


## Setup core variables
remote_ssh="$REMOTE_USER@$REMOTE_IP"

if [ $LOCAL_MAC_ADRESSES == "true" ]; then
  # echo ":: MAC USER FOUND, DOTS ADDED TO PATHS"
  LOCAL_UPLOADS_FOLDER_PATH=".$LOCAL_UPLOADS_FOLDER_PATH"
fi


## Handle arguments
dry=""
if [ "$1" == "-d" ] || [ "$1" == "--dry" ] || [ "$2" == "-d" ] || [ "$2" == "--dry" ]; then
  dry="--dry-run"
fi


## Run the script

# Sync script
echoTitle "Synchronize /uploads folders" &&
echoCmd "From: $remote_ssh:$REMOTE_SSH_PORT $REMOTE_UPLOADS_FOLDER_PATH" &&
echoCmd "To: $LOCAL_UPLOADS_FOLDER_PATH" &&

rsync -av $dry -e "ssh -p $REMOTE_SSH_PORT $SSH_KEY" $remote_ssh:$REMOTE_UPLOADS_FOLDER_PATH/ $LOCAL_UPLOADS_FOLDER_PATH &&

echoTitle "DONE" &&
exit 0
