#!/bin/bash

Styling_Off='\033[0m'
Blue_On='\033[44m'
Bold_On='\033[1m'
Italics_On='\033[3m'
Underline_On='\033[4m'

scriptdir="$(dirname "$0")"

if [ $# -eq 0 ]; then
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
else
  type="$1"
fi

if [ $type -eq 1 ]; then
  echo -e "${Blue_On} :: Sync up database && files ${Styling_Off}"
  echo " :: Run the command? [Yes/No]"
  read go
  if [ "$go" == "y" ] || [ "$go" == "yes" ] || [ "$go" == "Y" ] || [ "$go" == "Yes" ] || [ "$go" == "YES" ]; then
    $scriptdir/sync-up.sh && $scriptdir/files-up.sh && exit 0
  fi
fi

if [ $type -eq 10 ]; then
  echo -e "${Blue_On} :: Sync up database ${Styling_Off}"
  echo " :: Run the command? [Yes/No]"
  read go
  if [ "$go" == "y" ] || [ "$go" == "yes" ] || [ "$go" == "Y" ] || [ "$go" == "Yes" ] || [ "$go" == "YES" ]; then
    $scriptdir/sync-up.sh && exit 0
  fi
fi

if [ $type -eq 11 ]; then
  echo -e "${Blue_On} :: Sync up files ${Styling_Off}"
  echo " :: Run the command? [Yes/No]"
  read go
  if [ "$go" == "y" ] || [ "$go" == "yes" ] || [ "$go" == "Y" ] || [ "$go" == "Yes" ] || [ "$go" == "YES" ]; then
    $scriptdir/files-up.sh && exit 0
  fi
fi

if [ $type -eq 110 ]; then
  echo -e "${Blue_On} :: Sync up files - preview ${Styling_Off}"
  echo " :: Run the command? [Yes/No]"
  read go
  if [ "$go" == "y" ] || [ "$go" == "yes" ] || [ "$go" == "Y" ] || [ "$go" == "Yes" ] || [ "$go" == "YES" ]; then
    $scriptdir/files-up.sh -d && exit 0
  fi
fi

if [ $type -eq 111 ]; then
  echo -e "${Blue_On} :: Sync up files - forced delete ${Styling_Off}"
  echo " :: Run the command? [Yes/No]"
  read go
  if [ "$go" == "y" ] || [ "$go" == "yes" ] || [ "$go" == "Y" ] || [ "$go" == "Yes" ] || [ "$go" == "YES" ]; then
    $scriptdir/files-up.sh -f && exit 0
  fi
fi

if [ $type -eq 2 ]; then
  echo -e "${Blue_On} :: Sync down database && files ${Styling_Off}"
  echo " :: Run the command? [Yes/No]"
  read go
  if [ "$go" == "y" ] || [ "$go" == "yes" ] || [ "$go" == "Y" ] || [ "$go" == "Yes" ] || [ "$go" == "YES" ]; then
    $scriptdir/sync-down.sh && $scriptdir/files-down.sh && exit 0
  fi
fi

if [ $type -eq 20 ]; then
  echo -e "${Blue_On} :: Sync down database ${Styling_Off}"
  echo " :: Run the command? [Yes/No]"
  read go
  if [ "$go" == "y" ] || [ "$go" == "yes" ] || [ "$go" == "Y" ] || [ "$go" == "Yes" ] || [ "$go" == "YES" ]; then
    $scriptdir/sync-down.sh && exit 0
  fi
fi

if [ $type -eq 21 ]; then
  echo -e "${Blue_On} :: Sync down files ${Styling_Off}"
  echo " :: Run the command? [Yes/No]"
  read go
  if [ "$go" == "y" ] || [ "$go" == "yes" ] || [ "$go" == "Y" ] || [ "$go" == "Yes" ] || [ "$go" == "YES" ]; then
    $scriptdir/files-down.sh && exit 0
  fi
fi

if [ $type -eq 210 ]; then
  echo -e "${Blue_On} :: Sync down files - preview ${Styling_Off}"
  echo " :: Run the command? [Yes/No]"
  read go
  if [ "$go" == "y" ] || [ "$go" == "yes" ] || [ "$go" == "Y" ] || [ "$go" == "Yes" ] || [ "$go" == "YES" ]; then
    $scriptdir/files-down.sh -d && exit 0
  fi
fi

exit 1
