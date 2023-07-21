#!/bin/bash

## Shared resources
scriptdir="$(dirname "$0")"
source "$scriptdir/.shared.sh"

# Verify available SSH key
SSH_KEY="$(verifySSH)"

remote_address="$REMOTE_SSH_USER@$REMOTE_SSH_IP"
remote_ssh="-t -p $REMOTE_SSH_PORT $remote_address $SSH_KEY"


## Run the script

# List all available snapshots in some pretty format
available=$(ssh $remote_ssh "ls $REMOTE_BACKUPS_FOLDER_PATH")

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

selectedDB=${selected%%[_.]*}

selected="${REMOTE_BACKUPS_FOLDER_PATH}/${selected}"

printf "${Yellow_On}:: Do you really wish to restore to this snapshot??${Styling_Off}\n:: [${Bold_On}y${Styling_Off}es/${Bold_On}n${Styling_Off}o] "
read affi
if [ $(saysYes "$affi") == "1" ]; then
  # pass
  echo ""
else
  echoAlert "Command prevented"
  # echoTitle "DONE"
  exit 0
fi


# Create remote backup
echoTitle "Backup remote database" &&
up="--username=\"$REMOTE_MONGO_DB_USER\" --password=\"$REMOTE_MONGO_DB_PASS\"" &&
echoCmd "mongodump $up --archive --uri\"$REMOTE_MONGO_URI\" >> \"$REMOTE_BACKUP\"" &&

ssh $remote_ssh "mongodump $up --archive --uri=\"$REMOTE_MONGO_URI\" >> \"$REMOTE_BACKUP\"" &&


# Apply changes
echoTitle "Apply archived data to remote" &&
ns="--nsInclude=\"$selectedDB.*\" --nsFrom=\"$selectedDB.*\" --nsTo=\"$REMOTE_MONGO_DB_NAME.*\"" &&
echoCmd "mongorestore $up $ns --noIndexRestore --drop --archive=\"$selected\"" &&

ssh $remote_ssh "mongorestore $up $ns --noIndexRestore --drop --archive=\"$selected\"" &&


echoTitle "DONE"
exit 0
