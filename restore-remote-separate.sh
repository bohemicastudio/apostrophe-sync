#!/bin/bash

## Shared resources
scriptdir="$(dirname "$0")"
source "$scriptdir/.shared.sh"


## Run the script

# List all available snapshots in some pretty format
available=$(ls -lh $LOCAL_BACKUPS_FOLDER_PATH)

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

selected="${LOCAL_BACKUPS_FOLDER_PATH}/${selected}"

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


# Create local backup
echoTitle "Backup remote database" &&
echoCmd "mongodump --archive=\"$LOCAL_BACKUP\" --uri=\"$REMOTE_MONGO_URI\"" &&

mongodump --archive="$LOCAL_BACKUP" --uri="$REMOTE_MONGO_URI" &&


# Apply changes
echoTitle "Apply archived data to remote" &&
ns="--nsInclude=\"$selectedDB.*\" --nsFrom=\"$selectedDB.*\" --nsTo=\"$LOCAL_MONGO_DB_NAME.*\"" &&
echoCmd "mongorestore --archive=\"$selected\" --uri=\"$REMOTE_MONGO_URI\" --noIndexRestore --drop ${ns}" &&

mongorestore --archive="$selected" --uri="$REMOTE_MONGO_URI" --noIndexRestore --drop $ns &&


echoTitle "DONE"
exit 0
