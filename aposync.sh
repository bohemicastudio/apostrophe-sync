#!/bin/bash

echo "[1] Sync up database && files"
echo "  (10) Sync up database"
echo "  (11) Sync up files"
echo "     (110) Sync up files - preview"
echo "     (111) Sync up files - forced delete"

echo "[2] Download database && files"
echo "  (20) Download database"
echo "  (21) Download files"
echo "     (210) Download files - preview"

if [ $# -eq 0 ]
then
    read type
else
    type="$1"
fi


if [ $type -eq 1 ]
then
    ./sync-up.sh && ./files-up.sh
fi

if [ $type -eq 10 ]
then
    ./sync-up.sh
fi

if [ $type -eq 11 ]
then
    ./files-up.sh
fi

if [ $type -eq 110 ]
then
    ./files-up.sh -d
fi

if [ $type -eq 111 ]
then
    ./files-up.sh -f
fi



if [ $type -eq 2 ]
then
    ./sync-down.sh && ./files-down.sh
fi

if [ $type -eq 20 ]
then
    ./sync-down.sh
fi

if [ $type -eq 21 ]
then
    ./files-down.sh
fi

if [ $type -eq 210 ]
then
    ./files-down.sh -d
fi
