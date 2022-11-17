#!/bin/bash

## Shared resources
scriptdir="$(dirname "$0")"
source $scriptdir/.shared.sh

# Verify available SSH key
SSH_KEY="$(verifySSH)"


## Setup core variables
stamp=$(date +"%Y-%m-%d_%H-%M-%S")
server_filename="${SERVER_DB_NAME}_${stamp}$([ "$YOUR_PERSONAL_TAGNAME" ] && echo "_$YOUR_PERSONAL_TAGNAME").mongodump"

server_file="${SERVER_MONGO_BACKUPS_FOLDER_PATH}/${server_filename}"
server_backup="${SERVER_MONGO_BACKUPS_FOLDER_PATH}/${server_filename}.bak"

if [ $LOCAL_MAC_ADRESSES == "true" ]; then
  # echo ":: MAC USER FOUND, DOTS ADDED TO PATHS"
  local_file=".$local_file"
  local_backup=".$local_backup"
fi

server_ssh="$SERVER_USER@$SERVER_IP"
remote_ssh="-t -p $SERVER_SSH_PORT $server_ssh $SSH_KEY"
server_uri="mongodb://$SERVER_DB_USER:$SERVER_DB_PASS@$SERVER_IP:$SERVER_MONGO_PORT/$SERVER_DB_NAME?$SERVER_DB_EXTRA"


## Run the script

# List all available snapshots in some pretty format
available=$(ssh $remote_ssh "ls $SERVER_MONGO_BACKUPS_FOLDER_PATH")

array=($available)
len=${#array[@]}

echo -e "${Underline_White}Date       Time     | ID | Database             (user)${Styling_Off}"
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
selected="${SERVER_MONGO_BACKUPS_FOLDER_PATH}/${selected}"

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


# Create server backup
echoTitle "Backup server database" &&
up="--username=$SERVER_DB_USER --password=$SERVER_DB_PASS" &&
echoCmd "mongodump ${up} --authenticationDatabase admin --archive --uri=$server_uri >> $server_backup" &&

ssh $remote_ssh "mongodump ${up} --authenticationDatabase admin --archive --uri=$server_uri >> $server_backup" &&


# Apply changes
echoTitle "Apply archived data to server" &&
ns="--nsInclude=$SERVER_DB_NAME.* --nsFrom=$SERVER_DB_NAME.* --nsTo=$SERVER_DB_NAME.*" &&
echoCmd "mongorestore ${up} ${ns} --noIndexRestore --drop --archive=$selected" &&

ssh $remote_ssh "mongorestore ${up} ${ns} --noIndexRestore --drop --archive=$selected" &&


echoTitle "DONE"
exit 0
