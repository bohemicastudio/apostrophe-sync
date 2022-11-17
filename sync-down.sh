#!/bin/bash

## Shared resources
scriptdir="$(dirname "$0")"
source $scriptdir/.shared.sh

# Verify available SSH key
SSH_KEY="$(verifySSH)"


## Setup core variables
stamp=$(date +"%Y-%m-%d_%H-%M-%S")
filename="${LOCAL_DB_NAME}_${stamp}$([ "$YOUR_PERSONAL_TAGNAME" ] && echo "_$YOUR_PERSONAL_TAGNAME").mongodump"
backup="${SERVER_DB_NAME}_${stamp}$([ "$YOUR_PERSONAL_TAGNAME" ] && echo "_$YOUR_PERSONAL_TAGNAME").mongodump.bak"

local_file=$LOCAL_MONGO_BACKUPS_FOLDER_PATH/$filename
local_backup=$LOCAL_MONGO_BACKUPS_FOLDER_PATH/$backup
server_file=$SERVER_MONGO_BACKUPS_FOLDER_PATH/$filename

if [ $LOCAL_MAC_ADRESSES == "true" ]; then
  # echo ":: MAC USER FOUND, DOTS ADDED TO PATHS"
  local_file=".$local_file"
  local_backup=".$local_backup"
fi

server_ssh="$SERVER_USER@$SERVER_IP"
remote_ssh="-t -p $SERVER_SSH_PORT $server_ssh $SSH_KEY"
server_uri="mongodb://$SERVER_DB_USER:$SERVER_DB_PASS@$SERVER_DB_NAME:27017/$server?$SERVER_DB_EXTRA"


## Run the script

# Create remote archive
echoTitle "Create local archive" &&
up="--username=$SERVER_DB_USER --password=$SERVER_DB_PASS" &&
echoCmd "ssh $remote_ssh \"mongodump ${up} --authenticationDatabase admin -d $SERVER_DB_NAME --archive >> $server_file\"" &&

ssh $remote_ssh "mongodump ${up} --authenticationDatabase admin -d $SERVER_DB_NAME --archive >> $server_file" &&


# Download archive
echoTitle "Download archive" &&
echoCmd "rsync -av -e \"ssh -p $SERVER_SSH_PORT $SSH_KEY\" $server_ssh:$server_file $local_file" &&

rsync -av -e "ssh -p $SERVER_SSH_PORT $SSH_KEY" $server_ssh:$server_file $local_file &&


# Remove remote archive
# echoTitle "Remove remote archive" &&
# echoCmd "ssh $remote_ssh \"rm -rf $server_file\"" &&
# ssh $remote_ssh "rm -rf $server_file" &&


# Backup local database
echoTitle "Backup local database" &&
echoCmd "mongodump -d $LOCAL_DB_NAME --archive=$local_backup" &&

mongodump -d $LOCAL_DB_NAME --archive=$local_backup &&


# Apply remote data to local
echoTitle "Apply remote data to local" &&
ns="--nsInclude=$SERVER_DB_NAME.* --nsFrom=$SERVER_DB_NAME.* --nsTo=$LOCAL_DB_NAME.*" &&
echoCmd "mongorestore --noIndexRestore --drop ${ns} --archive=$local_file" &&

mongorestore --noIndexRestore --drop ${ns} --archive=$local_file &&


# Remove carried archive
echoTitle "Remove transported archive" &&
echoCmd "rm -rf $local_file" &&

rm -rf .$local_file &&


echoTitle "DONE" &&
exit 0
