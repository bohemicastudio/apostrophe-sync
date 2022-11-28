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


# Get .env resources
SCRIPT_DIR="$(dirname "$0")"

if [ ! -f "$SCRIPT_DIR/.env" ]; then
  echoAlert ".env file for apostrophe-sync not found!"
  exit 1
else
  echoText ".env file found"
fi

source $SCRIPT_DIR/.env
# This project is an submodule of apostrophe project, get .env from parent git project
if [ $EXTERNAL == "true" ]; then
  echoText "sourcing .env params from parent Git module"
  source $SCRIPT_DIR/../../.env
fi


# Create local mondodumps folder, when it does not exist
# echo ":: mkdir -p $LOCAL_MONGO_BACKUPS_FOLDER_PATH"
mkdir -p $LOCAL_MONGO_BACKUPS_FOLDER_PATH


verifySSH () {
  key=""
  if [ -z "$SERVER_SSH_PRIVATE_KEY_PATH" ]; then
    echoAlert "Private SSH key is not set"
    exit 2
  else
    key="-i $SERVER_SSH_PRIVATE_KEY_PATH"
  fi

  # Create server mondodumps folder, when it does not exist
  server_ssh="$SERVER_USER@$SERVER_IP"
  remote_ssh="-t -p $SERVER_SSH_PORT $server_ssh $key"
  ssh $remote_ssh "mkdir -p $SERVER_MONGO_BACKUPS_FOLDER_PATH"

  echo $key
}
