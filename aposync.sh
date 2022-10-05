#!/bin/bash

Styling_Off='\033[0m'
Blue_On='\033[44m'
Bold_On='\033[1m'
Italics_On='\033[3m'
Underline_On='\033[4m'

scriptdir="$(dirname "$0")"
# TODO - yes/no confirmation for each option + show relevant variables
if [ $# -eq 0 ]; then
  echo "${Bold_On}-- Uploads (server ↑):${Styling_Off}"
  echo "   [${Underline_On}1${Styling_Off}] Sync up database && files"
  echo "       ↳ [${Underline_On}10${Styling_Off}] Sync up database"
  echo "              ↳ [${Underline_On}100${Styling_Off}] Restore from file on server (TODO)"
  echo "                      ↳ [${Underline_On}1000${Styling_Off}] List all backup files on server (TODO)"
  echo "       ↳ [${Underline_On}11${Styling_Off}] Sync up files"
  echo "              ↳ [${Underline_On}110${Styling_Off}] Sync up files - preview"
  echo "              ↳ [${Underline_On}111${Styling_Off}] Sync up files - force delete"
  echo ""
  echo "${Bold_On}-- Downloads (local ↓):${Styling_Off}"
  echo "   [${Underline_On}2${Styling_Off}] Sync down database && files"
  echo "       ↳ [${Underline_On}20${Styling_Off}] Sync down database"
  echo "              ↳ [${Underline_On}200${Styling_Off}] Restore from file on local (TODO)"
  echo "                      ↳ [${Underline_On}2000${Styling_Off}] List all backup files on local (TODO)"
  echo "       ↳ [${Underline_On}21${Styling_Off}] Sync down files"
  echo "              ↳ [${Underline_On}210${Styling_Off}] Sync down files - preview"

  read type
else
  type="$1"
fi

if [ $type -eq 1 ]; then
  echo -e "${Blue_On} -- Sync up database && files ${Styling_Off}"
  $scriptdir/sync-up.sh && $scriptdir/files-up.sh && exit 0
fi

if [ $type -eq 10 ]; then
  echo -e "${Blue_On} -- Sync up database ${Styling_Off}"
  $scriptdir/sync-up.sh && exit 0
fi

if [ $type -eq 11 ]; then
  echo -e "${Blue_On} -- Sync up files ${Styling_Off}"
  $scriptdir/files-up.sh && exit 0
fi

if [ $type -eq 110 ]; then
  echo -e "${Blue_On} -- Sync up files - preview ${Styling_Off}"
  $scriptdir/files-up.sh -d && exit 0
fi

if [ $type -eq 111 ]; then
  echo -e "${Blue_On} -- Sync up files - forced delete ${Styling_Off}"
  $scriptdir/files-up.sh -f && exit 0
fi

if [ $type -eq 2 ]; then
  echo -e "${Blue_On} -- Sync down database && files ${Styling_Off}"
  $scriptdir/sync-down.sh && $scriptdir/files-down.sh && exit 0
fi

if [ $type -eq 20 ]; then
  echo -e "${Blue_On} -- Sync down database ${Styling_Off}"
  $scriptdir/sync-down.sh && exit 0
fi

if [ $type -eq 21 ]; then
  echo -e "${Blue_On} -- Sync down files ${Styling_Off}"
  $scriptdir/files-down.sh && exit 0
fi

if [ $type -eq 210 ]; then
  echo -e "${Blue_On} -- Sync down files - preview ${Styling_Off}"
  $scriptdir/files-down.sh -d && exit 0
fi

exit 1
