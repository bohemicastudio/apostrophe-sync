#!/bin/bash

## Shared resources
scriptdir="$(dirname "$0")"
source $scriptdir/.shared.sh

## Verify available SSH key
SSH_KEY="$(verifySSH)"


## Setup core variables
server_ssh="$SERVER_USER@$SERVER_IP"
remote_ssh="-p $SERVER_SSH_PORT $server_ssh $SSH_KEY"


## Run the script

# List all available snapshots in some pretty format
available=$(ssh $remote_ssh "ls $SERVER_MONGO_BACKUPS_FOLDER_PATH")

array=($available)
len=${#array[@]}

printf "${Underline_White}Date       Time     | Database                 (user)${Styling_Off}\n"
for (( j=0; j<"$len"; j++ ))
do
  echo ${array[$j]}_$j | awk -F'_' '{ sub("-", ":", $3); sub("-", ":", $3); printf "%s %s | %24s (%s)\n", $2,$3,$1,$4 }' | sed 's/.mongodump//g' | sed 's/.bak//g'
done


exit 0
