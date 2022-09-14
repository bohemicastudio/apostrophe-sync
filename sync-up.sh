#!/usr/bin/bash

if [ ! -f ".env" ]
then
   echo ".env file not found!"
   exit 1
fi

source ./.env

echo "-$SERVER_DB-"
