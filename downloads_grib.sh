#!/bin/bash

if [ $# -ne 2 ]; then echo "Usage: $0 From, To YYYYMMDD YYYYMMDD"; exit 1; fi

FROM_YY=$(date -d "$1" '+%Y'); FROM_MM=$(date -d "$1" '+%m'); FROM_DD=$(date -d "$1" '+%d')
TO_YEAR=$(date -d "$2" '+%Y'); TO_MONTH=$(date -d "$2" '+%m'); TO_DAY=$(date -d "$2" '+%d')

AMOUNT_OF_DAYS=$((10#$TO_DAY - 10#$DAY))
HOUR=(0000 0600 1200 1800 0000)

# if YYMM <= 7 month from this date use first link else historical
now=$(date); active_date=$(date --date="$now -7 month" +%s); date_from=$(date --date="$1" +%s)
if [ $date_from -ge $active_date ]; then
        DOMAIN="https://www.ncei.noaa.gov/data/global-forecast-system/access/grid-004-0.5-degree/analysis/"
        PREFIX="gfs_4_"
else
        DOMAIN="https://www.ncei.noaa.gov/data/global-forecast-system/access/historical/analysis/"
        PREFIX="gfsanl_4_"
fi

# if folder does not exist create them
[ -d grib_data ] || mkdir grib_data

for i in `seq 0 $AMOUNT_OF_DAYS`; do
	# if day less than 10 add 0 before
	YYMMDD="${FROM_YY}${FROM_MM}${FROM_DD}"

        # at first step download 0000_000 forecast
        if [ "$i" -eq 0 ]; then
                FILE=${PREFIX}${YYMMDD}"_0000_000.grb2"
                URL="${DOMAIN}${FROM_YY}${FROM_MM}/${YYMMDD}"

                wget -c "${URL}/${FILE}" -P "grib_data"
                echo "${URL}/${FILE}" >> grib_data/file_for_downloads.txt
                echo "${YYMMDD} 000000      ${FILE}     ON DISC" >> AVAILABLE

		# change COMMAND/RELEASES start date
		sed -i "s/STRYMMDD/${YYMMDD}/g" options/COMMAND
		sed -i "s/STRYMMDD/${YYMMDD}/g" options/RELEASES
        fi
        # here we need test date, it is exist in this month or not
        date=$(date --date="$1 + $i day");
        FROM_YY=$(date -d "$date" '+%Y'); FROM_MM=$(date -d "$date" '+%m'); FROM_DD=$(date -d "$date" '+%d')
        YYMMDD="${FROM_YY}${FROM_MM}${FROM_DD}"
        # download 4 forecasts for every day

        for j in `seq 0 3`; do
                # if hour 1800 increment day
		PR_DD=${FROM_DD}
		if [ "$j" -eq 3 ]; then
                        PR_DD=$(date -d "$date +1" '+%d')
		fi

                HH="${HOUR[j]}"
		iterator=$((j+1))
		PR_HH="${HOUR[iterator]}"
                FILE=${PREFIX}${YYMMDD}"_"${HH}"_006.grb2"
                URL="${DOMAIN}${FROM_YY}${FROM_MM}/${YYMMDD}"

                wget -c "${URL}/${FILE}" -P "grib_data"
                echo "${URL}/${FILE}" >> grib_data/file_for_downloads.txt
                echo "${FROM_YY}${FROM_MM}${PR_DD} ${PR_HH}00      ${FILE}     ON DISC" >> AVAILABLE
        done
done

sed -i "s/ENDYMMDD/${YYMMDD}/g" options/COMMAND
sed -i "s/ENDYMMDD/${YYMMDD}/g" options/RELEASES
