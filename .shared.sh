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
  echo -e "${Blue_On}:: ${1} ${Styling_Off}"
}

echoAlert () {
  echo -e "${Yellow_On}:: ${1} ${Styling_Off}"
}

echoCmd () {
  echo -e "${Blue_On}::${Styling_Off} ${1}"
}

echoText () {
  echo -e ":: ${1}"
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


verifySSH () {
  key=""
  if [ -z "$SERVER_SSH_PRIVATE_KEY_PATH" ]; then
    echoAlert "Private SSH key is not set"
    exit 2
  else
    key="-i $SERVER_SSH_PRIVATE_KEY_PATH"
  fi
  echo $key
}