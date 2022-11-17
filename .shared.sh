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
