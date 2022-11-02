#!/bin/bash

## Shared resources
scriptdir="$(dirname "$0")"
source $scriptdir/.shared.sh

Color_Off='\033[0m'
UWhite='\033[4;37m'


## Local .env resources
if [ ! -f "$scriptdir/.env" ]; then
  Alert ".env file not found"
  exit 1
else
  echo -e ":: .env file found"
fi

source $scriptdir/.env


## Verify available SSH key
key=""
if [ -z "$SERVER_SSH_PRIVATE_KEY_PATH" ]; then
  key=""
  Alert "Private SSH key is not set"
else
  key="-i $SERVER_SSH_PRIVATE_KEY_PATH"
fi


## Setup core variables
stamp=$(date +"%Y-%m-%d_%H-%M-%S")
local_filename="${LOCAL_DB_NAME}_${stamp}_${YOUR_PERSONAL_TAGNAME}.mongodump"
server_filename="${SERVER_DB_NAME}_${stamp}_${YOUR_PERSONAL_TAGNAME}.mongodump"

local_file=$LOCAL_MONGO_BACKUPS_FOLDER_PATH/$local_filename
local_backup="${LOCAL_MONGO_BACKUPS_FOLDER_PATH}/${local_filename}.bak"
server_file=$SERVER_MONGO_BAKUPS_FOLDER_PATH/$server_filename
server_backup="${SERVER_MONGO_BAKUPS_FOLDER_PATH}/${server_filename}.bak"

if [ $LOCAL_MAC_ADRESSES == "true" ]; then
  # echo ":: MAC USER FOUND, DOTS ADDED TO PATHS"
  local_file=".$local_file"
fi

server_ssh="$SERVER_USER@$SERVER_IP"
remote_ssh="-p $SERVER_SSH_PORT $server_ssh $key"
server_uri="mongodb://$SERVER_DB_USER:$SERVER_DB_PASS@$SERVER_IP:27017/$SERVER_DB_NAME?$SERVER_DB_EXTRA"


## Run the script

# Ask for local or server files

# List all available snapshots in some pretty format
available=$(ls $LOCAL_MONGO_BACKUPS_FOLDER_PATH)

array=($available)
len=${#array[@]}

echo -e "${UWhite}Date       Time     | ID | Database             (user)${Color_Off}"
for (( j=0; j<"$len"; j++ ))
do
  echo ${array[$j]}_$j | awk -F'_' '{ printf "%s %s |%4d| %20s (%s)\n", $2,$3,$5,$1,$4 }' | sed 's/.mongodump//g' | sed 's/.bak//g'
done

selected=""
read index
for (( j=0; j<"${#array[@]}"; j++ ))
do
  if [ $j == $index ]
  then
    selected=${array[$j]}
  fi
done

echo ":: ${selected}"
selected="${LOCAL_MONGO_BACKUPS_FOLDER_PATH}/${selected}"

printf "${Yellow_On}:: Do you really wish to restore to this snapshot??${Styling_Off}\n:: [${Bold_On}y${Styling_Off}es/${Bold_On}n${Styling_Off}o] "
read affi
if [ "$affi" == "YES" ] || [ "$affi" == "yes" ] || [ "$affi" == "y" ]; then
  # pass
  echo ""
else
  echoAlert "Command prevented"
  # echoTitle "DONE"
  exit 0
fi


# Create local backup
echoTitle "Backup local database" &&
echoCmd "mongodump -d $LOCAL_DB_NAME --archive=$local_backup" &&

mongodump -d $LOCAL_DB_NAME --archive=$local_backup &&


# Apply changes
echoTitle "Apply remote data to local" &&
ns="--nsInclude=$LOCAL_DB_NAME.* --nsFrom=$LOCAL_DB_NAME.* --nsTo=$LOCAL_DB_NAME.*" &&
echoCmd "mongorestore --noIndexRestore --drop ${ns} --archive=$selected" &&

mongorestore --noIndexRestore --drop ${ns} --archive=$selected &&


echoTitle "DONE"
exit 0
