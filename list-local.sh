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

printf "${Underline_White}Date       Time     | Database                     | Size     | File etx.      (user)${Styling_Off}\n"
for (( j=1; j<"$len"; j++ ))
do
  echo ${array[$j]} $j \
      | awk -F' ' '{ printf "%s_%s_%s\n", $10,$5,$9 }' \
      | awk -F'_' '{ printf "%s %s\n", $0,$6; }' \
      | sed 's/_/ /g' \
      | awk -F' ' '{ split($6,a,"."); $6=a[1]; sub(a[1], "", $7); sub("-",":",$5); sub("-",":",$5); printf "%s\n", $0; }' \
      | awk -F' ' '{ printf "%s %s | %-28s | %8s | %-14s (%s)\n", $4,$5,$3,$2,$7,$6 }'
done


exit 0
