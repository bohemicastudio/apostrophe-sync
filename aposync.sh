#!/bin/bash

## Shared resources
scriptdir="$(dirname "$0")"
source $scriptdir/.shared.sh


## Global variables
gopass=0


## Handle arguments or list the options
if [ $# -eq 2 ]; then

  if [ $1 == "-y" ]; then
    gopass=1
    type="$2"
  elif [ $2 == "-y" ]; then
    gopass=1
    type="$1"
  else
    echoAlert "Unexpected parameters"
    exit 1
  fi

elif [ $# -eq 1 ]; then

  type="$1"

else
  printf "${Bold_On}:: Upload actions (to ${Italics_On}server${Styling_Off} ↑):${Styling_Off}\n"
  printf "   [${Underline_On}1${Styling_Off}] Sync up database && files\n"
  printf "       ↳ [${Underline_On}10${Styling_Off}] Sync up database\n"
  printf "              ↳ [${Underline_On}101${Styling_Off}] Create backup file on server\n"
  printf "              ↳ [${Underline_On}102${Styling_Off}] Restore from file on server\n"
  printf "              ↳ [${Underline_On}103${Styling_Off}] List all backup files on server\n"
  printf "       ↳ [${Underline_On}11${Styling_Off}] Sync up files\n"
  printf "              ↳ [${Underline_On}110${Styling_Off}] Sync up files - preview\n"
  printf "              ↳ [${Underline_On}111${Styling_Off}] Sync up files - force delete\n"
  printf "\n"
  printf "${Bold_On}:: Download actions (to ${Italics_On}local${Styling_Off} ↓):${Styling_Off}\n"
  printf "   [${Underline_On}2${Styling_Off}] Sync down database && files\n"
  printf "       ↳ [${Underline_On}20${Styling_Off}] Sync down database\n"
  printf "              ↳ [${Underline_On}201${Styling_Off}] Create backup file on local\n"
  printf "              ↳ [${Underline_On}202${Styling_Off}] Restore from file on local\n"
  printf "              ↳ [${Underline_On}203${Styling_Off}] List all backup files on local\n"
  printf "       ↳ [${Underline_On}21${Styling_Off}] Sync down files\n"
  printf "              ↳ [${Underline_On}210${Styling_Off}] Sync down files - preview\n"

  read type
fi


## Run the script

Verify () {
  echoTitle "$1"

  if [ $gopass == 0 ]; then
    echoCmd "Run the command? ${Styling_Off}[${Bold_On}y${Styling_Off}es/${Bold_On}n${Styling_Off}o] "
    read go
  fi

  if [ $gopass == 1 ] || [ "$go" == "y" ] || [ "$go" == "yes" ] || [ "$go" == "Y" ] || [ "$go" == "Yes" ] || [ "$go" == "YES" ]; then
    return 0
  else
    echoCmd "Action prevented"
    return 1
  fi
}


if [ $type -eq 1 ]; then
  if Verify "Sync up database && files"; then
    $scriptdir/sync-up.sh && $scriptdir/files-up.sh && exit 0
  fi

elif [ $type -eq 10 ]; then
  if Verify "Sync up database"; then
    $scriptdir/sync-up.sh && exit 0
  fi

elif [ $type -eq 101 ]; then
  if Verify "Create backup file on server"; then
    $scriptdir/backup-server.sh && exit 0
  fi

elif [ $type -eq 102 ]; then
  if Verify "Restore from file on server"; then
    $scriptdir/restore-server.sh && exit 0
  fi

elif [ $type -eq 103 ]; then
  if Verify "List all backup files on server"; then
    $scriptdir/list-server.sh && exit 0
  fi

elif [ $type -eq 11 ]; then
  if Verify "Sync up files"; then
    $scriptdir/files-up.sh && exit 0
  fi

elif [ $type -eq 110 ]; then
  if Verify "Sync up files - preview"; then
    $scriptdir/files-up.sh -d && exit 0
  fi

elif [ $type -eq 111 ]; then
  if Verify "Sync up files - forced delete"; then
    $scriptdir/files-up.sh -f && exit 0
  fi

elif [ $type -eq 2 ]; then
  if Verify "Sync down database && files"; then
    $scriptdir/sync-down.sh && $scriptdir/files-down.sh && exit 0
  fi

elif [ $type -eq 20 ]; then
  if Verify "Sync down database"; then
    $scriptdir/sync-down.sh && exit 0
  fi

elif [ $type -eq 201 ]; then
  if Verify "Create backup file on local"; then
    $scriptdir/backup-local.sh && exit 0
  fi

elif [ $type -eq 202 ]; then
  if Verify "Restore database on local"; then
    $scriptdir/restore-local.sh && exit 0
  fi

elif [ $type -eq 203 ]; then
  if Verify "List all backup files on local"; then
    $scriptdir/list-local.sh && exit 0
  fi

elif [ $type -eq 21 ]; then
  if Verify "Sync down files"; then
    $scriptdir/files-down.sh && exit 0
  fi

elif [ $type -eq 210 ]; then
  if Verify "Sync down files - preview"; then
    $scriptdir/files-down.sh -d && exit 0
  fi

else
  echoAlert "Unsupported action"
  exit 2
fi
