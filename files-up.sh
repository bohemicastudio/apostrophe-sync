#!/bin/bash

## Shared resources
scriptdir="$(dirname "$0")"
source "$scriptdir/.shared.sh"

## Verify available SSH key
SSH_KEY="$(verifySSH)"

remote_address="$REMOTE_SSH_USER@$REMOTE_SSH_IP"


## Handle arguments
dry=""
if [ "$1" == "-d" ] || [ "$1" == "--dry" ] || [ "$2" == "-d" ] || [ "$2" == "--dry" ]; then
  dry="--dry-run"
fi

force=""
if [ "$1" == "-f" ] || [ "$1" == "--force" ] || [ "$2" == "-f" ] || [ "$2" == "--force" ]; then
  printf "${Yellow_On}:: Do you really wish to remove files on the remote, to match your directory precisely??${Styling_Off}\n:: [${Bold_On}y${Styling_Off}es/${Bold_On}n${Styling_Off}o] "
  read affi
  if [ $(saysYes "$affi") == "1" ]; then
    force="--delete"
  else
    echoAlert "Force command prevented"
  fi
fi


## Run the script

# Sync script
# private SSH_KEY - ideally use a config file: https://unix.stackexchange.com/a/127355
echoTitle "Synchronize /uploads folders" &&
echoCmd "From: $LOCAL_UPLOADS_FOLDER_PATH/" &&
echoCmd "To: $remote_address:$REMOTE_UPLOADS_FOLDER_PATH" &&

rsync -av $dry $force -e "ssh -p $REMOTE_SSH_PORT $SSH_KEY" $LOCAL_UPLOADS_FOLDER_PATH/ $remote_address:$REMOTE_UPLOADS_FOLDER_PATH &&

echoTitle "DONE" &&
exit 0
