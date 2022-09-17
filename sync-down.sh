#!/usr/bin/bash

if [ ! -f ".env" ]
then
   echo ".env file not found!"
   exit 1
fi

source ./.env

stamp=$(date +"%Y-%m-%d-%H%M")
filename=$SERVER_DB_NAME-$stamp.mongodump

server_ssh="$SERVER_USER@$SERVER_IP"
remote_ssh="-p $SERVER_SSH_PORT $server_ssh"
server_uri="mongodb://$SERVER_DB_USER:$SERVER_DB_PASS@$SERVER_DB_NAME:27017/$server?$SERVER_DB_EXTRA"


# Create remote archive
ssh $remote_ssh "mongodump --username=$SERVER_DB_USER --password=$SERVER_DB_PASS --authenticationDatabase admin -d $SERVER_DB_NAME --archive >> $SERVER_PATH/$filename"

# Download archive
rsync -av -e "ssh -p $SERVER_SSH_PORT" $server_ssh:$SERVER_PATH/$filename ./$filename 

# Remove remote archive
ssh $remote_ssh "rm -rf $SERVER_PATH/$filename"

# Backup local database
mongodump -d $LOCAL_DB --archive=./$LOCAL_DB-$stamp.mongodump.bak

# Apply remote data to local
mongorestore --noIndexRestore --drop --nsInclude=$SERVER_DB_NAME.* --nsFrom=$SERVER_DB_NAME.* --nsTo=$LOCAL_DB.* --archive=./$filename

# Remove carried archive
rm -rf ./$filename
