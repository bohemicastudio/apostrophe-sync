#!/usr/bin/bash

#many script taken directly from https://github.com/CloudRaker/tfp-heartland/blob/master/scripts/sync-up

if [ ! -f ".env" ]
then
   echo ".env file not found!"
   exit 1
fi

source ./.env

## copy local database
stamp=$(date +"%Y-%m-%d-%H%M")
filename=$LOCAL_DB-$stamp.mongodump

### use --gzip

# db.createUser( { user: "myuser", pwd: "password", roles: ["readWrite"] })
mongodump -d $LOCAL_DB --archive=./$filename

SSH_PORT=22
remoteSSH="-p $SSH_PORT $SERVER_ROOT"
rsyncTransport="ssh -p $SSH_PORT"
rsyncDestination="$SERVER_ROOT"

## move and remove archive
rsync -av -e "$rsyncTransport" ./$filename $rsyncDestination:$SERVER_PATH/$filename
rm -rf ./$filename

## backup remote copy
ssh $remoteSSH "mongodump --uri=$SERVER_DB --archive >> $SERVER_PATH/$filename.bak"

## apply new data
ssh $remoteSSH "mongorestore --username=$SERVER_DB_USER --password=$SERVER_DB_PASS --noIndexRestore --drop --nsInclude=$LOCAL_DB.* --nsFrom=$LOCAL_DB.* --nsTo=$SERVER_DB_NAME.* --archive=$SERVER_PATH/$filename"

## remove carried data stuff
ssh $remoteSSH rm -rf $SERVER_PATH/$filename
