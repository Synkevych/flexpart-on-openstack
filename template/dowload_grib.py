from datetime import datetime
from datetime import timedelta, date
import os, urllib.request

# 2 month equal to 44 Gb / calc speed and time needed to downloads this data

HHMMSS = ['030000', '060000', '090000', '120000',
          '150000', '180000', '210000', '000000']
FILE_HOURS = ['0000', '0000', '0600', '0600', '1200', '1200', '1800', '1800']
FILE_SUFFIX = ['003', '006']
NCEI_DOMEIN = "https://www.ncei.noaa.gov/data/global-forecast-system/access/historical/"
FILE_PREFIX = "gfs_4_"
DOMAIN = NCEI_DOMEIN+"forecast/grid-004-0.5-degree/"
basename = os.getcwd()
DATA_FOLDER = 'grib_data'
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

def parse_available_file(date=None, time=None, file_name=None):
  if date is not None and file_name is not None:
    available_template_body = """{yyyymmdd} {hhmmss}      {file_name}      ON DISC
""".format(yyyymmdd=date.strftime('%Y%m%d'), hhmmss=time, file_name=file_name)
    write_to_file('AVAILABLE', available_template_body, 'a')

def download_grib(date_start=None, date_end=None):
  if date_start and date_end is not None:
    start_date = datetime.strptime(date_start, '%Y%m%d')
    end_date = datetime.strptime(date_end, '%Y%m%d')
    amount_of_days = int((end_date - start_date).days)
    print('amount of days: ', amount_of_days)
    if amount_of_days <= 0:
      print('Error, invalid START or END date')
      return
    create_folder(DATA_FOLDER)
    write_to_file('AVAILABLE', available_template_header)

    for i in range(amount_of_days):
      ddate = start_date + timedelta(days=i)

      # download 8 forecasts for every day
      for j in range(8): # 8 weathers in one day
        file_name = FILE_PREFIX + \
            ddate.strftime('%Y%m%d') + "_" + \
            FILE_HOURS[j] + "_" + FILE_SUFFIX[j % 2] + ".grb2"
        path_to_file = os.path.join(basename + '/' + DATA_FOLDER + '/', file_name)
        # test if file exist
        if os.path.isfile(path_to_file):
          print("File", file_name, " exist.")
          parse_available_file(ddate, HHMMSS[j], file_name)
          continue
        else:
          URL = DOMAIN + ddate.strftime('%Y%m') + '/' + ddate.strftime('%Y%m%d') + '/' + file_name
          urllib.request.urlretrieve(URL, path_to_file)
          parse_available_file(ddate, HHMMSS[j], file_name)


download_grib('20200418', '20200421')
