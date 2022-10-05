#!/bin/bash

Color_Off='\033[0m'
On_Yellow='\033[43m'
On_Blue='\033[44m'

scriptdir="$(dirname "$0")"

if [ ! -f "$scriptdir/.env" ]; then
  echo -e "${On_Yellow}:: .env file not found${Color_Off}"
  exit 1
else
  echo -e "${On_Yellow}:: .env file found${Color_Off}"
fi

source $scriptdir/.env

server_ssh="$SERVER_USER@$SERVER_IP"

key=""
if [ -z "$SERVER_SSH_PRIVATE_KEY_PATH" ]; then
  key=""
  echo -e "${On_Yellow}:: Private SSH key is not set${Color_Off}"
else
  key="-i $SERVER_SSH_PRIVATE_KEY_PATH"
fi

dry=""
if [ "$1" == "-d" ] || [ "$1" == "--dry" ] || [ "$2" == "-d" ] || [ "$2" == "--dry" ]; then
  dry="--dry-run"
fi

# Sync script
echo -e "${On_Blue}:: Synchronize /uploads folders${Color_Off}" &&
  echo "-- From: $server_ssh:$SERVER_SSH_PORT $SERVER_UPLOADS_FOLDER_PATH -- To: .$LOCAL_UPLOADS_FOLDER_PATH" &&
  rsync -av $dry -e "ssh -p $SERVER_SSH_PORT $key" $server_ssh:$SERVER_UPLOADS_FOLDER_PATH/ .$LOCAL_UPLOADS_FOLDER_PATH &&
  echo -e "${On_Blue}:: DONE${Color_Off}" &&
  exit 0
