'''
description:    Download weather forecasts from GFS for flexpart
license:        APACHE 2.0
author:         Synkevych Roman, (synkevych.roman@gmail.com)
https://www.ncei.noaa.gov/data/global-forecast-system/access/
grid-003-1.0-degree/forecast
/202205
/20220511
/gfs_3_20220511_0000_000.grb2

//www.ncei.noaa.gov/data/global-forecast-system/access/
grid-003-1.0-degree/analysis/202004/20200418/gfs_3_20200418_0000_000.grb2
'''

from pygfs.utils import *
import shutil
import os
import requests
path_to_csv_file=''
path_to_default_files=''

number_of_calculations=0
calc_folder_name=''

# Create simlink for simflex and flexpart

# provide start_data and end_date for download forecast
# and create AVAILABLE
# this script should test if file available before downloading

# create a series_id.log that saves info about each calculations


class gfs:
    site_url = "https://www.ncei.noaa.gov/data/global-forecast-system/access/"

    def download(self, date, fcsthours, resolution):
        self.date = date
        self.fcsthours = fcsthours
        self.resolution = resolution
        self.check_fcsthours()
        self.build_filelist()
        self.download_files()

    def build_filelist(self):
        self.filelist = [self.get_filename(fcsthour)
                         for fcsthour in self.fcsthours]

    def get_filename(self, fcsthour):
        int_, dec = (str(float(self.resolution))).split('.')
        yr = str(self.date.year).zfill(4)
        mnth = str(self.date.month).zfill(2)
        day = str(self.date.day).zfill(2)
        baseurl = 'https://rda.ucar.edu/data/ds084.1/'
        fpath = os.path.join(yr, yr + mnth + day, 'gfs.' +
                             int_ + 'p' + dec.zfill(2) + '.' +
                             yr + mnth + day + '00.f' +
                             str(fcsthour).zfill(3) + '.grib2')
        return (os.path.join(baseurl, fpath))

    def download_files(self):
        '''
        Download the actual files
        '''
        [self.download_file(fl) for fl in self.filelist]

    def download_file(self, url):
        '''
        Stream download url to localfile
        '''
        local_filename = url.split('/')[-1]
        with self.session.get(url, stream=True) as r:
            with open(local_filename, 'wb') as f:
                shutil.copyfileobj(r.raw, f)
        #check_gribfile(local_filename)
        return local_filename

def parse_releases():
    # csv file name
    # row line
    # releases template file name and location
