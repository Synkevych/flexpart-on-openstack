#!/bin/bash

if [ $# -ne 2 ]; then echo "Usage: $0 From, To YYYYMMDD YYYYMMDD"; exit 1; fi

FROM_YY=$(date -d "$1" '+%Y'); FROM_MM=$(date -d "$1" '+%m'); FROM_DD=$(date -d "$1" '+%d')
TO_YEAR=$(date -d "$2" '+%Y'); TO_MONTH=$(date -d "$2" '+%m'); TO_DAY=$(date -d "$2" '+%d')

FROM_to_sec=$(date --date="$1" +%s); TO_to_sec=$(date --date="$2" +%s)
AMOUNT_OF_DAYS=$(( (TO_to_sec - FROM_to_sec)/86400))

HHMMSS=(030000 060000 090000 120000 150000 180000 210000 000000)
FILE_HOURS=(0000 0000 0600 0600 1200 1200 1800 1800)
FILE_SUFIX=(003 006)
URL="https://www.ncei.noaa.gov/data/global-forecast-system/access/historical/"

# if YYMM <= 7 month from current date use first link else historical
now=$(date); active_date=$(date --date="$now -7 month" +%s); date_from=$(date --date="$1" +%s)

PREFIX="gfsanl_3_"
if [ $date_from -ge $active_date ]; then
        DOMAIN="${URL}forecast/"
else
        DOMAIN="${URL}analysis/"
fi

# if folder does not exist create them
[ -d grib_data ] || mkdir grib_data
DATA_DIR=$(pwd)/grib_data

echo "YYYYMMDD HHMMSS   name of the file(up to 80 characters)" >> AVAILABLE

for i in `seq 0 $AMOUNT_OF_DAYS`; do
	# if day less than 10 add 0 before
	YYMMDD="${FROM_YY}${FROM_MM}${FROM_DD}"

        # set the date for the next day
        date=$(date --date="$1 + $i day");
        FROM_YY=$(date -d "$date" '+%Y'); FROM_MM=$(date -d "$date" '+%m'); FROM_DD=$(date -d "$date" '+%d')
        YYMMDD="${FROM_YY}${FROM_MM}${FROM_DD}"

        # download 4 forecasts for every day
        for j in `seq 0 7`; do
                # if hour 1800 increment day
		PR_DD=${FROM_DD}
		if [ "$j" -eq 7 ]; then
                        PR_date=$(date -d "$date + 1 day")
                        PR_DD=$(date -d "$PR_date" '+%d')
		fi

                FILE=${PREFIX}${YYMMDD}"_"${FILE_HOURS[j]}"_"${FILE_SUFIX[j%2]}".grb2"
                URL="${DOMAIN}${FROM_YY}${FROM_MM}/${YYMMDD}"

                if [[ -f "$DATA_DIR/${FILE}" ]]; then
                        echo "File ${FILE} exist"
                else
                        wget_output=$(wget -c "${URL}/${FILE}" -P "grib_data")
                        if [ $? -ne 0 ]; then
                                echo "Error loading ${FILE} from ${URL}"  >> grib_data/downloads.log
                        else
                                echo "File ${FILE} saved successfully" >> grib_data/downloads.log
                                echo "${FROM_YY}${FROM_MM}${PR_DD} ${HHMMSS[j]}      ${FILE}     ON DISC" >> AVAILABLE
                        fi
                fi
        done
done
