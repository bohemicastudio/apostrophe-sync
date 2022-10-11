#!/bin/bash

Styling_Off='\033[0m'
Yellow_On='\033[43m'
Blue_On='\033[44m'
Bold_On='\033[1m'
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
    echo -e "${Yellow_On}:: Force command prevented${Styling_Off}"
  fi
fi

# Sync script
# private key - ideally use a config file: https://unix.stackexchange.com/a/127355
echo -e "${Blue_On}:: Synchronize /uploads folders${Styling_Off}" &&
echo -e "$Dots From: .$LOCAL_UPLOADS_FOLDER_PATH" &&
echo -e "$Dots From: To: $server_ssh:$SERVER_SSH_PORT $SERVER_UPLOADS_FOLDER_PATH" &&

rsync -av $dry $force -e "ssh -p $SERVER_SSH_PORT $key" .$LOCAL_UPLOADS_FOLDER_PATH/ $server_ssh:$SERVER_UPLOADS_FOLDER_PATH &&

echo -e "${Blue_On}:: DONE${Styling_Off}" &&
exit 0
