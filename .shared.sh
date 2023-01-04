#!/bin/bash

# Styling
Styling_Off='\033[0m'

Bold_On='\033[1m'
Italics_On='\033[3m'
Underline_On='\033[4m'
Underline_White='\033[4;37m'

Yellow_On='\033[43m'
Blue_On='\033[44m'


# "UI"
echoTitle () {
  printf "${Blue_On}:: ${1} ${Styling_Off}\n"
}

echoAlert () {
  printf "${Yellow_On}:: ${1} ${Styling_Off}\n"
}

echoCmd () {
  printf "${Blue_On}::${Styling_Off} ${1}\n"
}

echoText () {
  printf ":: ${1}\n"
}


# Get local settings file
SCRIPT_DIR="$(dirname "$0")"
ENV_FILE="aposync.config.json"

if [ ! -f "$SCRIPT_DIR/../../$ENV_FILE" ]; then
  # echoAlert "Root config file for apostrophe-sync not found!"
  
  if [ ! -f "$SCRIPT_DIR/$ENV_FILE" ]; then
    echoAlert "Root and stand-alone config file for apostrophe-sync not found!"
    exit 1
  else
    echoText "Stand-alone config file found"
  fi
else
  echoText "Root config file found"
fi


# Import local settings
for s in $(jq -r "to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]" $ENV_FILE); do
  export $s
done
unset $LOCAL
unset $REMOTE

for s in $(jq -r ".LOCAL|to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]" $ENV_FILE); do
  export "LOCAL_$s"
done

for s in $(jq -r ".REMOTE|to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]" $ENV_FILE); do
  export "REMOTE_$s"
done


# Create local mondodumps folder, when it does not exist
# echo ":: mkdir -p $LOCAL_BACKUPS_FOLDER_PATH"
mkdir -p $LOCAL_BACKUPS_FOLDER_PATH


verifySSH () {
  key=""
  if [ -z "$REMOTE_SSH_KEY" ]; then
    echoAlert "Private SSH key is not set"
    exit 2
  else
    key="-i $REMOTE_SSH_KEY"
  fi

  # Create remote mondodumps folder, when it does not exist
  remote_address="$REMOTE_SSH_USER@$REMOTE_SSH_IP"
  remote_ssh="-t -p $REMOTE_SSH_PORT $remote_address $key"
  ssh $remote_ssh "mkdir -p $REMOTE_BACKUPS_FOLDER_PATH"

  echo $key
}
