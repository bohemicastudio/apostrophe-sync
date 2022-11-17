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


## Setup core variables
if [ $LOCAL_MAC_ADRESSES == "true" ]; then
  # echo ":: MAC USER FOUND, DOTS ADDED TO PATHS"
  LOCAL_MONGO_BACKUPS_FOLDER_PATH=".$LOCAL_MONGO_BACKUPS_FOLDER_PATH"
fi


## Run the script

# List all available snapshots in some pretty format
available=$(ls $LOCAL_MONGO_BACKUPS_FOLDER_PATH)

array=($available)
len=${#array[@]}

echo -e "${UWhite}Date       Time     | Database                 (user)${Color_Off}"
for (( j=0; j<"$len"; j++ ))
do
  echo ${array[$j]}_$j | awk -F'_' '{ sub("-", ":", $3); sub("-", ":", $3); printf "%s %s | %24s (%s)\n", $2,$3,$1,$4 }' | sed 's/.mongodump//g' | sed 's/.bak//g'
done


exit 0
