#!/usr/bin/bash

Color_Off='\033[0m'
On_Blue='\033[44m'

if [ ! -f ".env" ]
then
   echo ".env file not found!"
   exit 1
fi

source ./.env

stamp=$(date +"%Y-%m-%d-%H%M")
filename=$LOCAL_DB_NAME-$stamp.mongodump
backup=$SERVER_DB_NAME-$stamp.mongodump.bak

local_file=$LOCAL_MONGO_BAKUPS_FOLDER_PATH/$filename
server_file=$SERVER_MONGO_BAKUPS_FOLDER_PATH/$filename
server_bak=$SERVER_MONGO_BAKUPS_FOLDER_PATH/$backup

server_ssh="$SERVER_USER@$SERVER_IP"
remote_ssh="-p $SERVER_SSH_PORT $server_ssh"
server_uri="mongodb://$SERVER_DB_USER:$SERVER_DB_PASS@$SERVER_DB_NAME:27017/$server?$SERVER_DB_EXTRA"


# Create local archive
echo -e "${On_Blue}:: Create local archive${Color_Off}" &&
mongodump -d $LOCAL_DB_NAME --archive=$local_file &&

# Transport archive
echo -e "${On_Blue}:: Transport archive${Color_Off}" &&
rsync -av -e "ssh -p $SERVER_SSH_PORT" $local_file $server_ssh:$server_file &&

# Remove the local archive
echo -e "${On_Blue}:: Remove the local archive${Color_Off}" &&
rm -rf $local_file &&

# Backup remote copy
echo -e "${On_Blue}:: Backup remote copy${Color_Off}" &&
ssh $remote_ssh "mongodump --archive --uri=$server_uri >> $serve_bak" &&

# Apply local data to remote
echo -e "${On_Blue}:: Apply local data to remote${Color_Off}"
up="--username=$SERVER_DB_USER --password=$SERVER_DB_PASS"
ns="--nsInclude=$LOCAL_DB_NAME.* --nsFrom=$LOCAL_DB_NAME.* --nsTo=$SERVER_DB_NAME.*"
ssh $remote_ssh "mongorestore ${up} ${ns} --noIndexRestore --drop --archive=$server_file" &&

# Remove transported archive
echo -e "${On_Blue}:: Remove transported archive${Color_Off}" &&
ssh $remote_ssh "rm -rf $server_file" &&

echo -e "${On_Blue}:: DONE${Color_Off}" &&
exit 0
