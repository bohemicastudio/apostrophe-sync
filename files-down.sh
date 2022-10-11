#!/bin/bash

Styling_Off='\033[0m'
Yellow_On='\033[43m'
Blue_On='\033[44m'
Dots="${Blue_On}::${Styling_Off}"

scriptdir="$(dirname "$0")"

if [ ! -f "$scriptdir/.env" ]; then
  echo -e "${Yellow_On}:: .env file not found${Styling_Off}"
  exit 1
else
  echo -e ":: .env file found"
fi

source $scriptdir/.env

server_ssh="$SERVER_USER@$SERVER_IP"

key=""
if [ -z "$SERVER_SSH_PRIVATE_KEY_PATH" ]; then
  key=""
  echo -e "${Yellow_On}:: Private SSH key is not set${Styling_Off}"
else
  key="-i $SERVER_SSH_PRIVATE_KEY_PATH"
fi

dry=""
if [ "$1" == "-d" ] || [ "$1" == "--dry" ]; then
  dry="--dry-run"
fi

# Sync script
echo -e "${Blue_On}:: Synchronize /uploads folders${Styling_Off}" &&
echo -e "$Dots From: $server_ssh:$SERVER_SSH_PORT $SERVER_UPLOADS_FOLDER_PATH" &&
echo -e "$Dots To: $scriptdir/$LOCAL_UPLOADS_FOLDER_PATH" &&

rsync -av $dry -e "ssh -p $SERVER_SSH_PORT $key" $server_ssh:$SERVER_UPLOADS_FOLDER_PATH/ $scriptdir/$LOCAL_UPLOADS_FOLDER_PATH &&

echo -e "${Blue_On}:: DONE${Styling_Off}" &&
exit 0
