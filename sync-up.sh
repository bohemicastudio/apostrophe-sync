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
filename=$LOCAL_DB-$stamp.mongodump

server_ssh="$SERVER_USER@$SERVER_IP"
remote_ssh="-p $SERVER_SSH_PORT $server_ssh"
server_uri="mongodb://$SERVER_DB_USER:$SERVER_DB_PASS@$SERVER_DB_NAME:27017/$server?$SERVER_DB_EXTRA"


# Create local archive
echo -e "${On_Blue}:: Create local archive${Color_Off}" &&
mongodump -d $LOCAL_DB --archive=./$filename &&

# Transport archive
echo -e "${On_Blue}:: Transport archive${Color_Off}" &&
rsync -av -e "ssh -p $SERVER_SSH_PORT" ./$filename $server_ssh:$SERVER_UPLOAD_FOLDER_PATH/$filename &&

# Remove the local archive
echo -e "${On_Blue}:: Remove the local archive${Color_Off}" &&
rm -rf ./$filename &&

# Backup remote copy
echo -e "${On_Blue}:: Backup remote copy${Color_Off}" &&
ssh $remote_ssh "mongodump --archive --uri=$server_uri >> $SERVER_UPLOAD_FOLDER_PATH/$SERVER_DB_NAME-$stamp.mongodump.bak" &&

# Apply local data to remote
echo -e "${On_Blue}:: Apply local data to remote${Color_Off}" &&
ssh $remote_ssh "mongorestore --username=$SERVER_DB_USER --password=$SERVER_DB_PASS --noIndexRestore --drop --nsInclude=$LOCAL_DB.* --nsFrom=$LOCAL_DB.* --nsTo=$SERVER_DB_NAME.* --archive=$SERVER_UPLOAD_FOLDER_PATH/$filename" &&

# Remove transported archive
echo -e "${On_Blue}:: Remove transported archive${Color_Off}" &&
ssh $remote_ssh "rm -rf $SERVER_UPLOAD_FOLDER_PATH/$filename" &&

echo -e "${On_Blue}:: DONE${Color_Off}" &&
exit 0
