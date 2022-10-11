#!/bin/bash

## Shared resources
scriptdir="$(dirname "$0")"
source $scriptdir/.shared.sh

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
  echo -e "${Bold_On}:: Uploads (server ↑):${Styling_Off}"
  echo -e "   [${Underline_On}1${Styling_Off}] Sync up database && files"
  echo -e "       ↳ [${Underline_On}10${Styling_Off}] Sync up database"
  # echo -e "              ↳ [${Underline_On}100${Styling_Off}] Restore from file on server (TODO)"
  # echo -e "                      ↳ [${Underline_On}1000${Styling_Off}] List all backup files on server (TODO)"
  echo -e "       ↳ [${Underline_On}11${Styling_Off}] Sync up files"
  echo -e "              ↳ [${Underline_On}110${Styling_Off}] Sync up files - preview"
  echo -e "              ↳ [${Underline_On}111${Styling_Off}] Sync up files - force delete"
  echo -e ""
  echo -e "${Bold_On}:: Downloads (local ↓):${Styling_Off}"
  echo -e "   [${Underline_On}2${Styling_Off}] Sync down database && files"
  echo -e "       ↳ [${Underline_On}20${Styling_Off}] Sync down database"
  # echo -e "              ↳ [${Underline_On}200${Styling_Off}] Restore from file on local (TODO)"
  # echo -e "                      ↳ [${Underline_On}2000${Styling_Off}] List all backup files on local (TODO)"
  echo -e "       ↳ [${Underline_On}21${Styling_Off}] Sync down files"
  echo -e "              ↳ [${Underline_On}210${Styling_Off}] Sync down files - preview"

  read type
fi


## Run the script

if [ $type -eq 1 ]; then
  echoTitle "Sync up database && files"
  if [ $gopass == 0 ]; then
    echoCmd "Run the command? [Yes/No]"
    read go
  fi
  if [ $gopass == 1 ] || [ "$go" == "y" ] || [ "$go" == "yes" ] || [ "$go" == "Y" ] || [ "$go" == "Yes" ] || [ "$go" == "YES" ]; then
    $scriptdir/sync-up.sh && $scriptdir/files-up.sh && exit 0
  fi


elif [ $type -eq 10 ]; then
  echoTitle "Sync up database"
  if [ $gopass == 0 ]; then
    echoCmd "Run the command? [Yes/No]"
    read go
  fi
  if [ $gopass == 1 ] || [ "$go" == "y" ] || [ "$go" == "yes" ] || [ "$go" == "Y" ] || [ "$go" == "Yes" ] || [ "$go" == "YES" ]; then
    $scriptdir/sync-up.sh && exit 0
  fi


elif [ $type -eq 11 ]; then
  echoTitle "Sync up files"
  if [ $gopass == 0 ]; then
    echoCmd "Run the command? [Yes/No]"
    read go
  fi
  if [ $gopass == 1 ] || [ "$go" == "y" ] || [ "$go" == "yes" ] || [ "$go" == "Y" ] || [ "$go" == "Yes" ] || [ "$go" == "YES" ]; then
    $scriptdir/files-up.sh && exit 0
  fi


elif [ $type -eq 110 ]; then
  echoTitle "Sync up files - preview"
  if [ $gopass == 0 ]; then
    echoCmd "Run the command? [Yes/No]"
    read go
  fi
  if [ $gopass == 1 ] || [ "$go" == "y" ] || [ "$go" == "yes" ] || [ "$go" == "Y" ] || [ "$go" == "Yes" ] || [ "$go" == "YES" ]; then
    $scriptdir/files-up.sh -d && exit 0
  fi


elif [ $type -eq 111 ]; then
  echoTitle "Sync up files - forced delete"
  if [ $gopass == 0 ]; then
    echoCmd "Run the command? [Yes/No]"
    read go
  fi
  if [ $gopass == 1 ] || [ "$go" == "y" ] || [ "$go" == "yes" ] || [ "$go" == "Y" ] || [ "$go" == "Yes" ] || [ "$go" == "YES" ]; then
    $scriptdir/files-up.sh -f && exit 0
  fi


elif [ $type -eq 2 ]; then
  echoTitle "Sync down database && files"
  if [ $gopass == 0 ]; then
    echoCmd "Run the command? [Yes/No]"
    read go
  fi
  if [ $gopass == 1 ] || [ "$go" == "y" ] || [ "$go" == "yes" ] || [ "$go" == "Y" ] || [ "$go" == "Yes" ] || [ "$go" == "YES" ]; then
    $scriptdir/sync-down.sh && $scriptdir/files-down.sh && exit 0
  fi


elif [ $type -eq 20 ]; then
  echoTitle "Sync down database"
  if [ $gopass == 0 ]; then
    echoCmd "Run the command? [Yes/No]"
    read go
  fi
  if [ $gopass == 1 ] || [ "$go" == "y" ] || [ "$go" == "yes" ] || [ "$go" == "Y" ] || [ "$go" == "Yes" ] || [ "$go" == "YES" ]; then
    $scriptdir/sync-down.sh && exit 0
  fi


elif [ $type -eq 21 ]; then
  echoTitle "Sync down files"
  if [ $gopass == 0 ]; then
    echoCmd "Run the command? [Yes/No]"
    read go
  fi
  if [ $gopass == 1 ] || [ "$go" == "y" ] || [ "$go" == "yes" ] || [ "$go" == "Y" ] || [ "$go" == "Yes" ] || [ "$go" == "YES" ]; then
    $scriptdir/files-down.sh && exit 0
  fi


elif [ $type -eq 210 ]; then
  echoTitle "Sync down files - preview"
  if [ $gopass == 0 ]; then
    echoCmd "Run the command? [Yes/No]"
    read go
  fi
  if [ $gopass == 1 ] || [ "$go" == "y" ] || [ "$go" == "yes" ] || [ "$go" == "Y" ] || [ "$go" == "Yes" ] || [ "$go" == "YES" ]; then
    $scriptdir/files-down.sh -d && exit 0
  fi


else
  echoAlert "Unsupported action"
  exit 2
fi
