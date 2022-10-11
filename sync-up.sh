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

key=""
if [ -z "$SERVER_SSH_PRIVATE_KEY_PATH" ]; then
  key=""
  echo -e "${Yellow_On}:: Private SSH key is not set${Styling_Off}"
else
  key="-i $SERVER_SSH_PRIVATE_KEY_PATH"
fi

stamp=$(date +"%Y-%m-%d-%H%M")
filename=$LOCAL_DB_NAME-$stamp.mongodump
backup=$SERVER_DB_NAME-$stamp.mongodump.bak

local_file=$LOCAL_MONGO_BACKUPS_FOLDER_PATH/$filename
server_file=$SERVER_MONGO_BAKUPS_FOLDER_PATH/$filename
server_bak=$SERVER_MONGO_BAKUPS_FOLDER_PATH/$backup

server_ssh="$SERVER_USER@$SERVER_IP"
remote_ssh="-p $SERVER_SSH_PORT $server_ssh $key"
server_uri="mongodb://$SERVER_DB_USER:$SERVER_DB_PASS@$SERVER_IP:27017/$SERVER_DB_NAME?$SERVER_DB_EXTRA"


# Create local archive
echo -e "${Blue_On}:: Create local archive${Styling_Off}" &&
echo -e "$Dots mongodump -d $LOCAL_DB_NAME --archive=.$local_file" &&
mongodump -d $LOCAL_DB_NAME --archive=.$local_file &&

# Transport archive
echo -e "${Blue_On}:: Transport archive${Styling_Off}" &&
echo -e "$Dots rsync -av -e \"ssh -p $SERVER_SSH_PORT $key\" .$local_file $server_ssh:$server_file" &&
rsync -av -e "ssh -p $SERVER_SSH_PORT $key" .$local_file $server_ssh:$server_file &&

# Remove the local archive
# echo -e "${Blue_On}:: Remove the local archive${Styling_Off}" &&
# echo -e "$Dots rm -rf $local_file" &&
# rm -rf $local_file &&

# Backup remote copy
echo -e "${Blue_On}:: Backup remote copy${Styling_Off}" &&
echo -e "$Dots ssh $remote_ssh \"mongodump --archive --uri=$server_uri >> $serve_bak\"" &&
ssh $remote_ssh "mongodump --archive --uri=$server_uri >> $serve_bak" &&

# Apply local data to remote
echo -e "${Blue_On}:: Apply local data to remote${Styling_Off}" &&
up="--username=$SERVER_DB_USER --password=$SERVER_DB_PASS" &&
ns="--nsInclude=$LOCAL_DB_NAME.* --nsFrom=$LOCAL_DB_NAME.* --nsTo=$SERVER_DB_NAME.*" &&
echo -e "$Dots ssh $remote_ssh \"mongorestore ${up} ${ns} --noIndexRestore --drop --archive=$server_file\"" &&
ssh $remote_ssh "mongorestore ${up} ${ns} --noIndexRestore --drop --archive=$server_file" &&

# Remove transported archive
echo -e "${Blue_On}:: Remove transported archive${Styling_Off}" &&
echo -e "$Dots ssh $remote_ssh \"rm -rf $server_file\"" &&
ssh $remote_ssh "rm -rf $server_file" &&

echo -e "${Blue_On}:: DONE${Styling_Off}" &&
exit 0
