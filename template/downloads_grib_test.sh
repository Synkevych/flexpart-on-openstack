#!/bin/bash

if [ $# -ne 2 ]; then echo "Usage: $0 From, To YYYYMMDD YYYYMMDD"; exit 1; fi

FROM_YY=$(date -d "$1" '+%Y'); FROM_MM=$(date -d "$1" '+%m'); FROM_DD=$(date -d "$1" '+%d')
TO_YEAR=$(date -d "$2" '+%Y'); TO_MONTH=$(date -d "$2" '+%m'); TO_DAY=$(date -d "$2" '+%d')

FROM_to_sec=$(date --date="$1" +%s); TO_to_sec=$(date --date="$2" +%s)
AMOUNT_OF_DAYS=$(( (TO_to_sec - FROM_to_sec)/86400))

HOUR=(0600 0600 1200 1200 1800 1800)
SUFIX=(003 006)
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

for i in `seq 0 $AMOUNT_OF_DAYS`; do
	# if day less than 10 add 0 before
	YYMMDD="$(FROM_YY FROM_MM FROM_DD)"

        # set the date for the next day
        date=$(date --date="$1 + $i day");
        FROM_YY=$(date -d "$date" '+%Y'); FROM_MM=$(date -d "$date" '+%m'); FROM_DD=$(date -d "$date" '+%d')

        # download 4 forecasts for every day
        for j in `seq 0 7`; do
                HH="${HOUR[j]}"
		PR_HH="${HOUR[j]}""
                FILE=${PREFIX}${YYMMDD}"_"${HH}"_"${SUFIX[j%2]}".grb2"
                URL="${DOMAIN}${FROM_YY}${FROM_MM}/${YYMMDD}"

                if [[ -f "$DATA_DIR/${FILE}" ]]; then
                        echo "${FILE} exist"
                else
                        wget_output=$(wget -c "${URL}/${FILE}" -P "grib_data")
                        if [ $? -ne 0 ]; then
                                echo "Error loading ${FILE} from ${URL}"  >> grib_data/downloads.log
                        else
                                echo "${URL}/${FILE}" >> grib_data/downloads.log
                                echo "$(FROM_YY FROM_MM FROM_DD PR_HH)00      ${FILE}     ON DISC" >> AVAILABLE
                        fi
                fi
        done
done
