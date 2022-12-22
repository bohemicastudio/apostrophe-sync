#!/bin/bash

## Shared resources
scriptdir="$(dirname "$0")"
source $scriptdir/.shared.sh

# Verify available SSH key
SSH_KEY="$(verifySSH)"


## Setup core variables
stamp=$(date +"%Y-%m-%d_%H-%M-%S")
remote_filename="${REMOTE_DB_NAME}_${stamp}$([ "$YOUR_PERSONAL_TAGNAME" ] && echo "_$YOUR_PERSONAL_TAGNAME").mongodump"

remote_file="${REMOTE_MONGO_BACKUPS_FOLDER_PATH}/${remote_filename}"
remote_backup="${REMOTE_MONGO_BACKUPS_FOLDER_PATH}/${remote_filename}.bak"

if [ $LOCAL_MAC_ADRESSES == "true" ]; then
  # echo ":: MAC USER FOUND, DOTS ADDED TO PATHS"
  local_file=".$local_file"
  local_backup=".$local_backup"
fi

remote_address="$REMOTE_USER@$REMOTE_IP"
remote_ssh="-t -p $REMOTE_SSH_PORT $remote_address $SSH_KEY"
remote_uri="mongodb://$REMOTE_DB_USER:$REMOTE_DB_PASS@$REMOTE_IP:$REMOTE_MONGO_PORT/$REMOTE_DB_NAME?$REMOTE_DB_EXTRA"


## Run the script

# List all available snapshots in some pretty format
available=$(ssh $remote_ssh "ls $REMOTE_MONGO_BACKUPS_FOLDER_PATH")

IFS=$'\n'
array=($available)
len=${#array[@]}
IFS=$' '

printf "${Underline_White}Date       Time     | ID | Database                     | Size     | File etx.      (user)${Styling_Off}\n"
for (( j=1; j<"$len"; j++ ))
do
  echo ${array[$j]} $j \
      | awk -F' ' '{ printf "%s_%s_%s\n", $10,$5,$9 }' \
      | awk -F'_' '{ printf "%s %s\n", $0,$6; }' \
      | sed 's/_/ /g' \
      | awk -F' ' '{ split($6,a,"."); $6=a[1]; sub(a[1], "", $7); sub("-",":",$5); sub("-",":",$5); printf "%s\n", $0; }' \
      | awk -F' ' '{ printf "%s %s |%4s| %-28s | %8s | %-14s (%s)\n", $4,$5,$1,$3,$2,$7,$6 }'
done

selected=""

printf "Enter file ID: "
read index
for (( j=0; j<"${#array[@]}"; j++ ))
do
  if [ $j == $index ]
  then
    selected=${array[$j]}
    selected=$( echo "$selected" | awk -F' ' '{ printf "%s",$9 }' )
  fi
done

echo ":: ${selected}"
selected="${REMOTE_MONGO_BACKUPS_FOLDER_PATH}/${selected}"

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


# Create remote backup
echoTitle "Backup remote database" &&
up="--username=$REMOTE_DB_USER --password=$REMOTE_DB_PASS" &&
echoCmd "mongodump ${up} --authenticationDatabase admin --archive --uri=$remote_uri >> $remote_backup" &&

ssh $remote_ssh "mongodump ${up} --authenticationDatabase admin --archive --uri=$remote_uri >> $remote_backup" &&


# Apply changes
echoTitle "Apply archived data to remote" &&
ns="--nsInclude=$REMOTE_DB_NAME.* --nsFrom=$REMOTE_DB_NAME.* --nsTo=$REMOTE_DB_NAME.*" &&
echoCmd "mongorestore ${up} ${ns} --noIndexRestore --drop --archive=$selected" &&

ssh $remote_ssh "mongorestore ${up} ${ns} --noIndexRestore --drop --archive=$selected" &&


echoTitle "DONE"
exit 0
