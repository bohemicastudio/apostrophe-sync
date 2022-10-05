#!/bin/bash

Color_Off='\033[0m'
On_Blue='\033[44m'

scriptdir="$(dirname "$0")"

if [ $# -eq 0 ]; then
  echo "-- Uploads:"
  echo "[1] Sync up database && files"
  echo "  (10) Sync up database"
  echo "  (11) Sync up files"
  echo "     (110) Sync up files - preview"
  echo "     (111) Sync up files - forced delete"
  echo ""
  echo "-- Downloads:"
  echo "[2] Sync down database && files"
  echo "  (20) Sync down database"
  echo "  (21) Sync down files"
  echo "     (210) Sync down files - preview"

  read type
else
  type="$1"
fi

if [ $type -eq 1 ]; then
  echo -e "${On_Blue} -- Sync up database && files ${Color_Off}"
  $scriptdir/sync-up.sh && $scriptdir/files-up.sh && exit 0
fi

if [ $type -eq 10 ]; then
  echo -e "${On_Blue} -- Sync up database ${Color_Off}"
  $scriptdir/sync-up.sh && exit 0
fi

if [ $type -eq 11 ]; then
  echo -e "${On_Blue} -- Sync up files ${Color_Off}"
  $scriptdir/files-up.sh && exit 0
fi

if [ $type -eq 110 ]; then
  echo -e "${On_Blue} -- Sync up files - preview ${Color_Off}"
  $scriptdir/files-up.sh -d && exit 0
fi

if [ $type -eq 111 ]; then
  echo -e "${On_Blue} -- Sync up files - forced delete ${Color_Off}"
  $scriptdir/files-up.sh -f && exit 0
fi

if [ $type -eq 2 ]; then
  echo -e "${On_Blue} -- Sync down database && files ${Color_Off}"
  $scriptdir/sync-down.sh && $scriptdir/files-down.sh && exit 0
fi

if [ $type -eq 20 ]; then
  echo -e "${On_Blue} -- Sync down database ${Color_Off}"
  $scriptdir/sync-down.sh && exit 0
fi

if [ $type -eq 21 ]; then
  echo -e "${On_Blue} -- Sync down files ${Color_Off}"
  $scriptdir/files-down.sh && exit 0
fi

if [ $type -eq 210 ]; then
  echo -e "${On_Blue} -- Sync down files - preview ${Color_Off}"
  $scriptdir/files-down.sh -d && exit 0
fi

exit 1
