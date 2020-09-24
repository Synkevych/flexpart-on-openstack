#!/bin/bash

mkdir -p newFolder

now="$(date)"
computer_name="$(hostname)"

# create new file with current date

FILEPATH=newFolder/results-`date --utc +%Y%m%d%H%M`.txt

# send information to the file

echo "Current date and time : $now" >> $FILEPATH
echo "Computer name : $computer_name" >> $FILEPATH
echo "User name : $USER" >> $FILEPATH

# download some data from server

wget -qO - http://t.ukr.pw/bat.txt >> $FILEPATH
