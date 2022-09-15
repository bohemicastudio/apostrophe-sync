#!/usr/bin/bash

if [ ! -f ".env" ]
then
   echo ".env file not found!"
   exit 1
fi

source ./.env

stamp=$(date +"%Y-%m-%d-%H%M")
filename=$LOCAL_DB-$stamp.mongodump

remote_ssh="-p $SERVER_SSH_PORT $SERVER"
server_ssh="$SERVER_USER@$SERVER_IP"
server_uri="mongodb://$SERVER_DB_USER:$SERVER_DB_PASS@$SERVER_DB_NAME:27017/$server?$SERVER_DB_EXTRA"


# Create local archive
mongodump -d $LOCAL_DB --archive=./$filename

# Transport archive and remove local
rsync -av -e "ssh -p $SERVER_SSH_PORT" ./$filename $server_ssh:$SERVER_PATH/$filename
rm -rf ./$filename

# Backup remote copy
ssh $remote_ssh "mongodump --uri=$server_uri --archive >> $SERVER_PATH/$filename.bak"

# Apply local data to remote
ssh $remote_ssh "mongorestore --username=$SERVER_DB_USER --password=$SERVER_DB_PASS --noIndexRestore --drop --nsInclude=$LOCAL_DB.* --nsFrom=$LOCAL_DB.* --nsTo=$SERVER_DB_NAME.* --archive=$SERVER_PATH/$filename"

# Remove carried archive
ssh $remote_ssh "rm -rf $SERVER_PATH/$filename"
