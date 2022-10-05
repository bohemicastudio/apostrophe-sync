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

force=""
if [ "$1" == "-f" ] || [ "$1" == "--force" ] || [ "$2" == "-f" ] || [ "$2" == "--force" ]; then
  printf "${On_Yellow}:: Do you really wish to remove files on the server, to match your directory precisely??${Color_Off}\n:: [YES/no] "
  read affi
  if [ "$affi" == "YES" ] || [ "$affi" == "yes" ] || [ "$affi" == "y" ]; then
    force="--delete"
  else
    echo -e "${On_Yellow}:: Force command prevented${Color_Off}"
  fi
fi

# Sync script
# private key - ideally use a config file: https://unix.stackexchange.com/a/127355
echo -e "${On_Blue}:: Synchronize /uploads folders${Color_Off}" &&
  echo "-- From: .$LOCAL_UPLOADS_FOLDER_PATH -- To: $server_ssh:$SERVER_SSH_PORT $SERVER_UPLOADS_FOLDER_PATH" &&
  rsync -av $dry $force -e "ssh -p $SERVER_SSH_PORT $key" .$LOCAL_UPLOADS_FOLDER_PATH/ $server_ssh:$SERVER_UPLOADS_FOLDER_PATH &&
  echo -e "${On_Blue}:: DONE${Color_Off}" &&
  exit 0
