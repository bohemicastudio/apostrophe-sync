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

force=""
if [ "$1" == "-f" ] || [ "$1" == "--force" ] || [ "$2" == "-f" ] || [ "$2" == "--force" ]; then
  printf "${Yellow_On}:: Do you really wish to remove files on the server, to match your directory precisely??${Styling_Off}\n:: [${Bold_On}y${Styling_Off}es/${Bold_On}n${Styling_Off}o] "
  read affi
  if [ "$affi" == "YES" ] || [ "$affi" == "yes" ] || [ "$affi" == "y" ]; then
    force="--delete"
  else
    echoAlert "Force command prevented"
  fi
fi


## Run the script

# Sync script
# private SSH_KEY - ideally use a config file: https://unix.stackexchange.com/a/127355
echoTitle "Synchronize /uploads folders" &&
echoCmd "From: $LOCAL_UPLOADS_FOLDER_PATH" &&
echoCmd "To: $server_ssh:$SERVER_SSH_PORT $SERVER_UPLOADS_FOLDER_PATH" &&

rsync -av $dry $force -e "ssh -p $SERVER_SSH_PORT $SSH_KEY" $LOCAL_UPLOADS_FOLDER_PATH/ $server_ssh:$SERVER_UPLOADS_FOLDER_PATH &&

echoTitle "DONE" &&
exit 0
