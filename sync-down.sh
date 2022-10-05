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

key=""
if [ -z "$SERVER_SSH_PRIVATE_KEY_PATH" ]; then
  key=""
  echo -e "${On_Yellow}:: Private SSH key is not set${Color_Off}"
else
  key="-i $SERVER_SSH_PRIVATE_KEY_PATH"
fi

stamp=$(date +"%Y-%m-%d-%H%M")
filename=$SERVER_DB_NAME-$stamp.mongodump
backup=$LOCAL_DB_NAME-$stamp.mongodump.bak

local_file=$LOCAL_MONGO_BACKUPS_FOLDER_PATH/$filename
local_bak=$LOCAL_MONGO_BACKUPS_FOLDER_PATH/$backup
server_file=$SERVER_MONGO_BAKUPS_FOLDER_PATH/$filename

server_ssh="$SERVER_USER@$SERVER_IP"
remote_ssh="-p $SERVER_SSH_PORT $server_ssh $key"
server_uri="mongodb://$SERVER_DB_USER:$SERVER_DB_PASS@$SERVER_DB_NAME:27017/$server?$SERVER_DB_EXTRA"


# Create remote archive
echo -e "${On_Blue}:: Create local archive${Color_Off}"
up="--username=$SERVER_DB_USER --password=$SERVER_DB_PASS"
ssh $remote_ssh "mongodump ${up} --authenticationDatabase admin -d $SERVER_DB_NAME --archive >> $server_file"

# Download archive
echo -e "${On_Blue}:: Download archive${Color_Off}" &&
rsync -av -e "ssh -p $SERVER_SSH_PORT" $server_ssh:$server_file $local_file

# Remove remote archive
echo -e "${On_Blue}:: Remove remote archive${Color_Off}" &&
ssh $remote_ssh "rm -rf $server_file"

# Backup local database
echo -e "${On_Blue}:: Backup local database${Color_Off}" &&
mongodump -d $LOCAL_DB_NAME --archive=$local_bak

# Apply remote data to local
echo -e "${On_Blue}:: Apply remote data to local${Color_Off}" &&
ns="--nsInclude=$SERVER_DB_NAME.* --nsFrom=$SERVER_DB_NAME.* --nsTo=$LOCAL_DB_NAME.*"
mongorestore --noIndexRestore --drop ${ns} --archive=$local_file

# Remove carried archive
echo -e "${On_Blue}:: Remove transported archive${Color_Off}" &&
rm -rf $local_file

echo -e "${On_Blue}:: DONE${Color_Off}" &&
exit 0
