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
stamp=$(date +"%Y-%m-%d_%H-%M-%S")
local_filename="${LOCAL_DB_NAME}_${stamp}$([ "$YOUR_PERSONAL_TAGNAME" ] && echo "_$YOUR_PERSONAL_TAGNAME").mongodump"

local_file="${LOCAL_MONGO_BACKUPS_FOLDER_PATH}/${local_filename}"
local_backup="${LOCAL_MONGO_BACKUPS_FOLDER_PATH}/${local_filename}.bak"

if [ $LOCAL_MAC_ADRESSES == "true" ]; then
  # echo ":: MAC USER FOUND, DOTS ADDED TO PATHS"
  local_file=".$local_file"
  local_backup=".$local_backup"
fi


## Run the script

# List all available snapshots in some pretty format
available=$(ls $LOCAL_MONGO_BACKUPS_FOLDER_PATH)

array=($available)
len=${#array[@]}

echo -e "${UWhite}Date       Time     | ID | Database             (user)${Color_Off}"
for (( j=0; j<"$len"; j++ ))
do
  echo ${array[$j]}_$j | awk -F'_' '{ sub("-", ":", $3); sub("-", ":", $3); printf "%s %s |%4d| %20s (%s)\n", $2,$3,$5,$1,$4 }' | sed 's/.mongodump//g' | sed 's/.bak//g'
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
echoTitle "Apply archived data to local" &&
ns="--nsInclude=$LOCAL_DB_NAME.* --nsFrom=$LOCAL_DB_NAME.* --nsTo=$LOCAL_DB_NAME.*" &&
echoCmd "mongorestore --noIndexRestore --drop ${ns} --archive=$selected" &&

mongorestore --noIndexRestore --drop ${ns} --archive=$selected &&


echoTitle "DONE"
exit 0
