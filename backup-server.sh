#!/bin/bash

## Shared resources
scriptdir="$(dirname "$0")"
source $scriptdir/.shared.sh

Color_Off='\033[0m'
UWhite='\033[4;37m'


## Local .env resources
if [ ! -f "$scriptdir/.env" ]; then
  Alert ".env file not found"
  exit 1
else
  echo -e ":: .env file found"
fi

source $scriptdir/.env


## Verify available SSH key
key=""
if [ -z "$SERVER_SSH_PRIVATE_KEY_PATH" ]; then
  key=""
  Alert "Private SSH key is not set"
else
  key="-i $SERVER_SSH_PRIVATE_KEY_PATH"
fi


## Setup core variables
stamp=$(date +"%Y-%m-%d_%H-%M-%S")
server_filename="${SERVER_DB_NAME}_${stamp}_${YOUR_PERSONAL_TAGNAME}.mongodump"

server_backup="${SERVER_MONGO_BAKUPS_FOLDER_PATH}/${server_filename}.bak"

if [ $LOCAL_MAC_ADRESSES == "true" ]; then
  # echo ":: MAC USER FOUND, DOTS ADDED TO PATHS"
  local_file=".$local_file"
  local_backup=".$local_backup"
fi

server_ssh="$SERVER_USER@$SERVER_IP"
remote_ssh="-p $SERVER_SSH_PORT $server_ssh $key"
server_uri="mongodb://$SERVER_DB_USER:$SERVER_DB_PASS@$SERVER_IP:27017/$SERVER_DB_NAME?$SERVER_DB_EXTRA"


## Run the script

# Create server backup
echoTitle "Backup server database" &&
up="--username=$SERVER_DB_USER --password=$SERVER_DB_PASS" &&
echoCmd "mongodump ${up} --authenticationDatabase admin --archive --uri=$server_uri >> $server_backup" &&

ssh $remote_ssh "mongodump ${up} --authenticationDatabase admin --archive --uri=$server_uri >> $server_backup" &&


echoTitle "DONE"
exit 0
