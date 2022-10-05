#!/bin/bash

Styling_Off='\033[0m'
Yellow_On='\033[43m'
Blue_On='\033[44m'

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
filename=$SERVER_DB_NAME-$stamp.mongodump
backup=$LOCAL_DB_NAME-$stamp.mongodump.bak

local_file=$LOCAL_MONGO_BACKUPS_FOLDER_PATH/$filename
local_backup=$LOCAL_MONGO_BACKUPS_FOLDER_PATH/$backup
server_file=$SERVER_MONGO_BAKUPS_FOLDER_PATH/$filename

server_ssh="$SERVER_USER@$SERVER_IP"
remote_ssh="-p $SERVER_SSH_PORT $server_ssh $key"
server_uri="mongodb://$SERVER_DB_USER:$SERVER_DB_PASS@$SERVER_DB_NAME:27017/$server?$SERVER_DB_EXTRA"


# Create remote archive
echo -e "${Blue_On}:: Create local archive${Styling_Off}"
up="--username=$SERVER_DB_USER --password=$SERVER_DB_PASS"
ssh $remote_ssh "mongodump ${up} --authenticationDatabase admin -d $SERVER_DB_NAME --archive >> $server_file"

# Download archive
echo -e "${Blue_On}:: Download archive${Styling_Off}" &&
rsync -av -e "ssh -p $SERVER_SSH_PORT $key" $server_ssh:$server_file .$local_file

# Remove remote archive
# echo -e "${Blue_On}:: Remove remote archive${Styling_Off}" &&
# ssh $remote_ssh "rm -rf $server_file"

# Backup local database
echo -e "${Blue_On}:: Backup local database${Styling_Off}" &&
mongodump -d $LOCAL_DB_NAME --archive=.$local_backup

# Apply remote data to local
echo -e "${Blue_On}:: Apply remote data to local${Styling_Off}" &&
ns="--nsInclude=$SERVER_DB_NAME.* --nsFrom=$SERVER_DB_NAME.* --nsTo=$LOCAL_DB_NAME.*"
mongorestore --noIndexRestore --drop ${ns} --archive=.$local_file

# Remove carried archive
echo -e "${Blue_On}:: Remove transported archive${Styling_Off}" &&
rm -rf .$local_file

echo -e "${Blue_On}:: DONE${Styling_Off}" &&
exit 0
