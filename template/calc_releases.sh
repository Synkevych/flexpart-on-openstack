#!/bin/bash

sed_length=15
startline=15
path=$(pwd)
for i in `seq 1 31`; do
    # replace RELEASES file with begining of the file
    cp options/RELEASES.tmp options/RELEASES
    start=$(( startline * i ))
    if [ "$i" -eq 2 ] ; then
        start=$((start+1))
    elif (( $i > 2 )) ; then
        start=$((start+i-1))
    fi
    end=$(( start + sed_length ))
    # add to RELEASES one RELEASE from
    sed -n "${start},${end}p" options/RELEASES.back >> options/RELEASES
    ./FLEXPART>>allout.txt 2>&1
    mv output/grid_time_20200421000000.nc output/grid_time_20200421000000_$i.nc
    if [ "$i" -eq 1 ] ; then
      echo "#id_obs; path_to_file; pointspec_ind;" >> table_srs_paths.txt
    else
      echo "$i; $(pwd)/output/grid_time_20200421000000_$i.nc; 1">>table_srs_paths.txt
    fi
done
