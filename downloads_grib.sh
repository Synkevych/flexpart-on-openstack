#!/bin/bash

if [ $# -ne 2 ]; then echo "Usage: $0 YYYYMMDD, Date_To"; exit 1; fi

DATE_FROM=$1
YEAR=`echo $DATE_FROM | awk -F\- '{print $1}'`
MONTH=`echo $DATE_FROM | awk -F\- '{print $2}'`
DAY=`echo $DATE_FROM | awk -F\- '{print $3}'`

DATE_TO=$2
HOUR=(0000 0000 0600 1200 1800)
MINUTE=(000 006 006 006 006)

counter=$((DATE_TO/5))
day_counter=$((DATE_TO-counter*5))

for i in `seq 0 $counter`; do
  for j in `seq 0 4`; do
   echo "day $(($MONTH+i))"
  # echo "gfs_4_"${YEAR}${MONTH}$(($DAY+$i))"_"${HOUR[j]}"_"${MINUTE[j]}".grb2"
  done
  if [ "$i" -eq "$counter" ] && [ "$day_counter" -gt 0 ]; then
    for j in `seq 0 $day_counter`; do
     echo "gfs_4_"${YEAR}${MONTH}$(($DAY+i+1))"_"${HOUR[j]}"_"${MINUTE[j]}".grb2"
    done
  exit 1; fi
done
