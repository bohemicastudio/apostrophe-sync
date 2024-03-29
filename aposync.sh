#!/bin/bash

## `aposync init` functionality
scriptdir="$(dirname "$0")"
ENV_FILE="aposync.config.json"
printf "scriptdir: ${scriptdir}\n"

if [ $# -eq 1 ] && [ $1 == "init" ]; then
  Blue_On='\033[44m'
  Styling_Off='\033[0m'

  if [ -f "$scriptdir/../../../$ENV_FILE" ]; then
    printf "${Blue_On}:: Aposync config file already exists!${Styling_Off} \n"
    exit 1
  else
    cp "$scriptdir/aposync.config.example.json" "$scriptdir/../../../$ENV_FILE" &&
      printf "${Blue_On}:: Created aposync config file!${Styling_Off} \n"
    exit 0
  fi
fi

## Shared resources
source "$scriptdir/.shared.sh"

## Global variables
instantPass=0

## Handle arguments or list the options
if [ $# -eq 2 ]; then

  if [ $1 == "-y" ]; then
    instantPass=1
    type="$2"
  elif [ $2 == "-y" ]; then
    instantPass=1
    type="$1"
  else
    echoAlert "Unexpected parameters"
    exit 1
  fi

elif [ $# -eq 1 ]; then

  type="$1"

elif $REMOTE_SEPARATE_DATABASE; then
  printf "${Bold_On}:: Upload actions (local → ${Italics_On}remote${Styling_Off}):${Styling_Off}\n"
  printf "   [${Underline_On}1${Styling_Off}] Sync up database && files\n"
  printf "       ↳ [${Underline_On}10${Styling_Off}] Sync up database\n"
  printf "              ↳ [${Underline_On}101${Styling_Off}] Restore from file on local\n"
  printf "              ↳ [${Underline_On}102${Styling_Off}] List all backup files on local\n"
  printf "       ↳ [${Underline_On}11${Styling_Off}] Sync up files\n"
  printf "              ↳ [${Underline_On}110${Styling_Off}] Sync up files - preview\n"
  printf "              ↳ [${Underline_On}111${Styling_Off}] Sync up files - force delete\n"
  printf "\n"
  printf "${Bold_On}:: Actions (remote → ${Italics_On}local${Styling_Off}):${Styling_Off}\n"
  printf "   [${Underline_On}2${Styling_Off}] Sync down database && files\n"
  printf "       ↳ [${Underline_On}20${Styling_Off}] Sync down database\n"
  printf "              ↳ [${Underline_On}201${Styling_Off}] Create backup file on local\n"
  printf "              ↳ [${Underline_On}202${Styling_Off}] List all backup files on local\n"
  printf "       ↳ [${Underline_On}21${Styling_Off}] Sync down files\n"
  printf "              ↳ [${Underline_On}210${Styling_Off}] Sync down files - preview\n"
  printf "Enter code: "

  read type

else
  printf "${Bold_On}:: Upload actions (local → ${Italics_On}remote${Styling_Off}):${Styling_Off}\n"
  printf "   [${Underline_On}1${Styling_Off}] Sync up database && files\n"
  printf "       ↳ [${Underline_On}10${Styling_Off}] Sync up database\n"
  printf "              ↳ [${Underline_On}101${Styling_Off}] Create backup file on remote\n"
  printf "              ↳ [${Underline_On}102${Styling_Off}] Restore from file on remote\n"
  printf "              ↳ [${Underline_On}103${Styling_Off}] List all backup files on remote\n"
  printf "       ↳ [${Underline_On}11${Styling_Off}] Sync up files\n"
  printf "              ↳ [${Underline_On}110${Styling_Off}] Sync up files - preview\n"
  printf "              ↳ [${Underline_On}111${Styling_Off}] Sync up files - force delete\n"
  printf "\n"
  printf "${Bold_On}:: Download actions (remote → ${Italics_On}local${Styling_Off}):${Styling_Off}\n"
  printf "   [${Underline_On}2${Styling_Off}] Sync down database && files\n"
  printf "       ↳ [${Underline_On}20${Styling_Off}] Sync down database\n"
  printf "              ↳ [${Underline_On}201${Styling_Off}] Create backup file on local\n"
  printf "              ↳ [${Underline_On}202${Styling_Off}] Restore from file on local\n"
  printf "              ↳ [${Underline_On}203${Styling_Off}] List all backup files on local\n"
  printf "       ↳ [${Underline_On}21${Styling_Off}] Sync down files\n"
  printf "              ↳ [${Underline_On}210${Styling_Off}] Sync down files - preview\n"
  printf "Enter code: "

  read type
fi

# Sync up/down files
# Sync up database (local to remote) [this should automatically create backup for the local]

# Sync down database (remote to local)
# Create backup file on local
# Restore from file on local

## Run the script

Verify() {
  echoTitle "$1"

  if [ $instantPass == 0 ]; then
    echoCmd "Run the command? ${Styling_Off}[${Bold_On}y${Styling_Off}es/${Bold_On}n${Styling_Off}o] "
    read explicitPass
  fi

  if [ $instantPass == 1 ] || [ $(saysYes "$explicitPass") == "1" ]; then
    return 0
  else
    echoCmd "Action prevented"
    return 1
  fi
}

if $REMOTE_SEPARATE_DATABASE; then
  if [ $type -eq 1 ]; then
    if Verify "Sync up database && files (separate)"; then
      "$scriptdir/db-up-separate.sh" && "$scriptdir/files-up.sh" && exit 0
    fi

  elif [ $type -eq 10 ]; then
    if Verify "Sync up database (separate)"; then
      "$scriptdir/db-up-separate.sh" && exit 0
    fi

  elif [ $type -eq 101 ]; then
    if Verify "Restore from file on local (separate)"; then
      "$scriptdir/restore-remote-separate.sh" && exit 0
    fi

  elif [ $type -eq 11 ]; then
    if Verify "Sync up files"; then
      "$scriptdir/files-up.sh" && exit 0
    fi

  elif [ $type -eq 110 ]; then
    if Verify "Sync up files - preview"; then
      "$scriptdir/files-up.sh" -d && exit 0
    fi

  elif [ $type -eq 111 ]; then
    if Verify "Sync up files - forced delete"; then
      "$scriptdir/files-up.sh" -f && exit 0
    fi

  elif [ $type -eq 2 ]; then
    if Verify "Sync down database && files (separate)"; then
      "$scriptdir/db-down-separate.sh" && "$scriptdir/files-down.sh" && exit 0
    fi

  elif [ $type -eq 20 ]; then
    if Verify "Sync down database (separate)"; then
      "$scriptdir/db-down-separate.sh" && exit 0
    fi

  elif [ $type -eq 201 ]; then
    if Verify "Create backup file on local (separate)"; then
      "$scriptdir/backup-remote-separate.sh" && exit 0
    fi

  elif [ $type -eq 21 ]; then
    if Verify "Sync down files"; then
      "$scriptdir/files-down.sh" && exit 0
    fi

  elif [ $type -eq 210 ]; then
    if Verify "Sync down files - preview"; then
      "$scriptdir/files-down.sh" -d && exit 0
    fi

  elif [ $type -eq 102 ] || [ $type -eq 202 ]; then
    if Verify "List all backup files on local (separate)"; then
      "$scriptdir/list-local.sh" && exit 0
    fi

  else
    echoAlert "Unsupported action"
    exit 2
  fi

else
  if [ $type -eq 1 ]; then
    if Verify "Sync up database && files"; then
      "$scriptdir/db-up.sh" && "$scriptdir/files-up.sh" && exit 0
    fi

  elif [ $type -eq 10 ]; then
    if Verify "Sync up database"; then
      "$scriptdir/db-up.sh" && exit 0
    fi

  elif [ $type -eq 101 ]; then
    if Verify "Create backup file on remote"; then
      "$scriptdir/backup-remote.sh" && exit 0
    fi

  elif [ $type -eq 102 ]; then
    if Verify "Restore from file on remote"; then
      "$scriptdir/restore-remote.sh" && exit 0
    fi

  elif [ $type -eq 103 ]; then
    if Verify "List all backup files on remote"; then
      "$scriptdir/list-remote.sh" && exit 0
    fi

  elif [ $type -eq 11 ]; then
    if Verify "Sync up files"; then
      "$scriptdir/files-up.sh" && exit 0
    fi

  elif [ $type -eq 110 ]; then
    if Verify "Sync up files - preview"; then
      "$scriptdir/files-up.sh" -d && exit 0
    fi

  elif [ $type -eq 111 ]; then
    if Verify "Sync up files - forced delete"; then
      "$scriptdir/files-up.sh" -f && exit 0
    fi

  elif [ $type -eq 2 ]; then
    if Verify "Sync down database && files"; then
      "$scriptdir/db-down.sh" && "$scriptdir/files-down.sh" && exit 0
    fi

  elif [ $type -eq 20 ]; then
    if Verify "Sync down database"; then
      "$scriptdir/db-down.sh" && exit 0
    fi

  elif [ $type -eq 201 ]; then
    if Verify "Create backup file on local"; then
      "$scriptdir/backup-local.sh" && exit 0
    fi

  elif [ $type -eq 202 ]; then
    if Verify "Restore database on local"; then
      "$scriptdir/restore-local.sh" && exit 0
    fi

  elif [ $type -eq 203 ]; then
    if Verify "List all backup files on local"; then
      "$scriptdir/list-local.sh" && exit 0
    fi

  elif [ $type -eq 21 ]; then
    if Verify "Sync down files"; then
      "$scriptdir/files-down.sh" && exit 0
    fi

  elif [ $type -eq 210 ]; then
    if Verify "Sync down files - preview"; then
      "$scriptdir/files-down.sh" -d && exit 0
    fi

  else
    echoAlert "Unsupported action"
    exit 2
  fi
fi
