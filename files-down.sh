#!/bin/bash

## Shared resources
scriptdir="$(dirname "$0")"
source $scriptdir/.shared.sh

## Verify available SSH key
SSH_KEY="$(verifySSH)"


## Setup core variables
server_ssh="$SERVER_USER@$SERVER_IP"

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
echoCmd "From: $server_ssh:$SERVER_SSH_PORT $SERVER_UPLOADS_FOLDER_PATH" &&
echoCmd "To: $LOCAL_UPLOADS_FOLDER_PATH" &&

rsync -av $dry -e "ssh -p $SERVER_SSH_PORT $SSH_KEY\" $server_ssh:$SERVER_UPLOADS_FOLDER_PATH/ $LOCAL_UPLOADS_FOLDER_PATH &&

echoTitle "DONE" &&
exit 0
