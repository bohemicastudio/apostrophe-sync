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
filename=$SERVER_DB_NAME-$stamp.mongodump
backup=$LOCAL_DB-$stamp.mongodump.bak

server_ssh="$SERVER_USER@$SERVER_IP"
remote_ssh="-p $SERVER_SSH_PORT $server_ssh"
server_uri="mongodb://$SERVER_DB_USER:$SERVER_DB_PASS@$SERVER_DB_NAME:27017/$server?$SERVER_DB_EXTRA"


# Create remote archive
echo -e "${On_Blue}:: Create local archive${Color_Off}"
up="--username=$SERVER_DB_USER --password=$SERVER_DB_PASS"
ssh $remote_ssh "mongodump ${up} --authenticationDatabase admin -d $SERVER_DB_NAME --archive >> $SERVER_UPLOAD_FOLDER_PATH/$filename"

# Download archive
echo -e "${On_Blue}:: Download archive${Color_Off}" &&
rsync -av -e "ssh -p $SERVER_SSH_PORT" $server_ssh:$SERVER_UPLOAD_FOLDER_PATH/$filename ./$filename 

# Remove remote archive
echo -e "${On_Blue}:: Remove remote archive${Color_Off}" &&
ssh $remote_ssh "rm -rf $SERVER_UPLOAD_FOLDER_PATH/$filename"

# Backup local database
echo -e "${On_Blue}:: Backup local database${Color_Off}" &&
mongodump -d $LOCAL_DB --archive=./$backup

# Apply remote data to local
echo -e "${On_Blue}:: Apply remote data to local${Color_Off}" &&
mongorestore --noIndexRestore --drop --nsInclude=$SERVER_DB_NAME.* --nsFrom=$SERVER_DB_NAME.* --nsTo=$LOCAL_DB.* --archive=./$filename

# Remove carried archive
echo -e "${On_Blue}:: Remove transported archive${Color_Off}" &&
rm -rf ./$filename

echo -e "${On_Blue}:: DONE${Color_Off}" &&
exit 0
