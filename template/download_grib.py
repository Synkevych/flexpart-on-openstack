from datetime import datetime
from datetime import timedelta, date
import os, urllib.request

# 2 month equal to 44 Gb / calc speed and time needed to downloads this data

HHMMSS = ['030000', '060000', '090000', '120000',
          '150000', '180000', '210000', '000000']
FILE_HOURS = ['0000', '0000', '0600', '0600', '1200', '1200', '1800', '1800']
FILE_SUFFIX = ['003', '006']
NCEI_URL = "https://www.ncei.noaa.gov/data/global-forecast-system/access/historical/"
FILE_PREFIX = "gfs_4_"
DOMAIN = NCEI_URL + "forecast/grid-004-0.5-degree/"
basename = os.getcwd()
DATA_FOLDER = '/data/grib_data/'
available_template_header = """XXXXXX EMPTY LINES XXXXXXXXX
XXXXXX EMPTY LINES XXXXXXXX
YYYYMMDD HHMMSS      name of the file(up to 80 characters)
"""

def write_to_file(file_name, contents, mode='w'):
  file = open(basename + '/' + file_name, mode)
  file.write(contents)
  file.close()

def create_folder(directory=None):
   if not os.path.exists(directory):
     os.makedirs(directory)

def parse_available_file(date=None, file_name=None):
  if date is not None and file_name is not None:
    available_template_body = """{yyyymmdd} {hhmmss}      {file_name}      ON DISC
""".format(yyyymmdd=date.strftime('%Y%m%d'),
           hhmmss=date.strftime('%H%M%S'),
           file_name=file_name)
    write_to_file('AVAILABLE', available_template_body, 'a')

def download_grib(date_start=None, date_end=None):
  if date_start and date_end is not None:
    # dates should ends with hours that divides to 3
    start_date = date_start - timedelta(hours = date_start.hour % 3)
    end_date = date_end

    # download last dataset using end date
    if end_date.hour % 3 == 1:
      end_date = date_end + timedelta(hours=2)
    elif end_date.hour% 3 == 2:
      end_date = date_end + timedelta(hours=1)
    else:
      end_date = date_end + timedelta(hours=3)

    days, seconds = (
        end_date - start_date).days, (end_date - start_date).seconds
    hours = (days * 24 + seconds / 3600) // 8
    print('amount of datasets: ',  hours)
    if hours <= 0:
      print('Error, invalid START or END date')
      return

    create_folder(DATA_FOLDER)
    write_to_file('AVAILABLE', available_template_header)

    end_forecast_date = start_forecast_date = start_date
    while(end_forecast_date < end_date):
      forecast_suffix = ''
      if end_forecast_date.hour % 6 == 0:
        # start_forecast_date - in Available
        start_forecast_date = end_forecast_date - timedelta(hours = 6)
        forecast_suffix = FILE_SUFFIX[1]
      elif end_forecast_date.hour % 6 == 3:
        start_forecast_date = end_forecast_date - timedelta(hours = 3)
        forecast_suffix = FILE_SUFFIX[0]
      file_name = FILE_PREFIX + \
          start_forecast_date.strftime('%Y%m%d_%H%M_') + forecast_suffix + ".grb2"
      path_to_file = os.path.join(DATA_FOLDER + '/', file_name)
      # test if file exist
      print('file_name', file_name)
      if os.path.isfile(path_to_file):
        print("File", file_name, " exist.")
        parse_available_file(end_forecast_date, file_name)
        end_forecast_date = start_forecast_date = end_forecast_date + timedelta(hours=3)
        continue
      else:
        URL = DOMAIN + end_forecast_date.strftime('%Y%m/%Y%m%d/') + file_name
        urllib.request.urlretrieve(URL, path_to_file)
        parse_available_file(end_forecast_date, file_name)
      end_forecast_date = start_forecast_date = end_forecast_date + \
          timedelta(hours=3)
