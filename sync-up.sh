#!/bin/bash

## Shared resources
scriptdir="$(dirname "$0")"
source $scriptdir/.shared.sh


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
filename="${LOCAL_DB_NAME}_${stamp}_${YOUR_PERSONAL_TAGNAME}.mongodump"
backup="${SERVER_DB_NAME}_${stamp}_${YOUR_PERSONAL_TAGNAME}.mongodump.bak"

local_file=$LOCAL_MONGO_BACKUPS_FOLDER_PATH/$filename
server_file=$SERVER_MONGO_BAKUPS_FOLDER_PATH/$filename
server_bak=$SERVER_MONGO_BAKUPS_FOLDER_PATH/$backup

if [ $LOCAL_MAC_ADRESSES == "true" ]; then
  # echo ":: MAC USER FOUND, DOTS ADDED TO PATHS"
  local_file=".$local_file"
fi

server_ssh="$SERVER_USER@$SERVER_IP"
remote_ssh="-p $SERVER_SSH_PORT $server_ssh $key"
server_uri="mongodb://$SERVER_DB_USER:$SERVER_DB_PASS@$SERVER_IP:27017/$SERVER_DB_NAME?$SERVER_DB_EXTRA"


## Run the script

# Create local archive
echoTitle "Create local archive" &&
echoCmd "mongodump -d $LOCAL_DB_NAME --archive=$local_file" &&

mongodump -d $LOCAL_DB_NAME --archive=$local_file &&


# Transport archive
echoTitle "Transport archive" &&
echoCmd "rsync -av -e \"ssh -p $SERVER_SSH_PORT $key\" $local_file $server_ssh:$server_file" &&

rsync -av -e "ssh -p $SERVER_SSH_PORT $key" $local_file $server_ssh:$server_file &&


# Remove the local archive
# echoTitle "Remove the local archive" &&
# echoCmd "rm -rf $local_file" &&
# rm -rf $local_file &&


# Backup remote copy
echoTitle "Backup remote copy" &&
echoCmd "ssh $remote_ssh \"mongodump --archive --uri=$server_uri >> $serve_bak\"" &&

ssh $remote_ssh "mongodump --archive --uri=$server_uri >> $serve_bak" &&


# Apply local data to remote
echoTitle "Apply local data to remote" &&
up="--username=$SERVER_DB_USER --password=$SERVER_DB_PASS" &&
ns="--nsInclude=$LOCAL_DB_NAME.* --nsFrom=$LOCAL_DB_NAME.* --nsTo=$SERVER_DB_NAME.*" &&
echoCmd "ssh $remote_ssh \"mongorestore ${up} ${ns} --noIndexRestore --drop --archive=$server_file\"" &&

ssh $remote_ssh "mongorestore ${up} ${ns} --noIndexRestore --drop --archive=$server_file" &&


# Remove transported archive
echoTitle "Remove transported archive" &&
echoCmd "ssh $remote_ssh \"rm -rf $server_file\"" &&

ssh $remote_ssh "rm -rf $server_file" &&


echoTitle "DONE"
exit 0
