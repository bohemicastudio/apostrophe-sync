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



# Get config.json file
SCRIPT_DIR="$(dirname "$0")"
ENV_FILE="aposync.config.json"

findConfigFile () {
  if [ ! -f "$SCRIPT_DIR/../../../$ENV_FILE" ]; then
    if [ ! -f "$SCRIPT_DIR/$ENV_FILE" ]; then
      echoAlert "No config file found."
      exit 1
    else
      echoText "Config file found inside the package folder."
      ENV_FILE="$SCRIPT_DIR/$ENV_FILE"
    fi
  else
    echoText "Config file found inside the project folder."
    ENV_FILE="$SCRIPT_DIR/../../../$ENV_FILE"
  fi
}

findConfigFile;



# Consume config.json files
loadConfigObject () {
  if ! [ "$(jq -r "$1.LOCAL|tostring" $ENV_FILE)" == "null" ]; then
    for s in $(jq -r "$1.LOCAL|to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]" $ENV_FILE); do
      export "LOCAL_$s"
    done
  else
    echo "NO LOCAL SETTINGS OBJECT FOUND IN $ENV_FILE"
  fi

  if ! [ "$(jq -r "$1.REMOTE|tostring" $ENV_FILE)" == "null" ]; then
    for s in $(jq -r "$1.REMOTE|to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]" $ENV_FILE); do
      export "REMOTE_$s"
    done
  else
    echo "NO REMOTE SETTINGS OBJECT FOUND IN $ENV_FILE"
  fi


  if [ $REMOTE_SEPARATE_DATABASE == "true" ]; then
    REMOTE_SEPARATE_DATABASE=true
  else
    REMOTE_SEPARATE_DATABASE=false
  fi

  if [ $MAC_PATHS == "true" ]; then
    MAC_PATHS=true
  else
    MAC_PATHS=false
  fi
}

loadConfig () {
  local DEFAULT=$(jq -r ".DEFAULT|tostring" $ENV_FILE)

  MAC_PATHS=$(jq -r ".MAC_PATHS|tostring" $ENV_FILE)
  PERSONAL_TAGNAME=$(jq -r ".PERSONAL_TAGNAME|tostring" $ENV_FILE)

  if [ "$DEFAULT" == "null" ]; then
    loadConfigObject;
  else
    loadConfigObject ".$DEFAULT";
  fi
}

loadConfig;



currentBackups="$LOCAL_BACKUPS_FOLDER_PATH"
if MAC_PATHS; then
  currentBackups=".$currentBackups"
fi;

# Create local mondodumps folder, when it does not exist
if [ ! -d "$currentBackups" ]; then
  mkdir -p "$currentBackups"

  if ! [ "$?" == 0 ]; then
    echo "FAILED TO CREATE $currentBackups"
    exit 16
  fi
fi



# Validate SSH connection to file system
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



# Helper for user input verification
saysYes () {
  if [ "$1" == "y" ] || [ "$1" == "Y" ] || [ "$1" == "ye" ] || [ "$1" == "Ye" ]  || [ "$1" == "YE" ] || [ "$1" == "yes" ] || [ "$1" == "Yes" ] || [ "$1" == "YEs" ] || [ "$1" == "YES" ]; then
    echo "1"
    return 1
  fi
  echo "0"
  return 0
}



# Build remote URI
if $REMOTE_SEPARATE_DATABASE; then
  REMOTE_MONGO_URI="mongodb+srv://$REMOTE_MONGO_DB_USER:$REMOTE_MONGO_DB_PASS@$REMOTE_MONGO_DB_IP/$REMOTE_MONGO_DB_NAME"
else
  REMOTE_MONGO_URI="mongodb://${REMOTE_MONGO_DB_USER:+$REMOTE_MONGO_DB_USER${REMOTE_MONGO_DB_PASS:+:$REMOTE_MONGO_DB_PASS}@}$REMOTE_MONGO_DB_IP${REMOTE_MONGO_DB_PORT:+:$REMOTE_MONGO_DB_PORT}/$REMOTE_MONGO_DB_NAME${REMOTE_MONGO_URI_EXTRAS:+?$REMOTE_MONGO_URI_EXTRAS}"
fi
