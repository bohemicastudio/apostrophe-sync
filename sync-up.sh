#!/usr/bin/bash

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
mongodump -d $LOCAL_DB --archive=./$filename &&

# Transport archive
rsync -av -e "ssh -p $SERVER_SSH_PORT" ./$filename $server_ssh:$SERVER_UPLOAD_FOLDER_PATH/$filename &&

rm -rf ./$filename &&

# Backup remote copy
ssh $remote_ssh "mongodump --archive --uri=$server_uri >> $SERVER_UPLOAD_FOLDER_PATH/$SERVER_DB_NAME-$stamp.mongodump.bak" &&

# Apply local data to remote
ssh $remote_ssh "mongorestore --username=$SERVER_DB_USER --password=$SERVER_DB_PASS --noIndexRestore --drop --nsInclude=$LOCAL_DB.* --nsFrom=$LOCAL_DB.* --nsTo=$SERVER_DB_NAME.* --archive=$SERVER_UPLOAD_FOLDER_PATH/$filename" &&

ssh $remote_ssh "rm -rf $SERVER_UPLOAD_FOLDER_PATH/$filename" &&

# Remove carried archive
exit 0
