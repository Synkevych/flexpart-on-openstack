import csv
import os
import logging
import xml.etree.ElementTree as ET
from subprocess import call

tree = ET.parse('71.xml')
root = tree.getroot()

def parse_date(str):
    return str.replace('-', '').replace(':', '')

start_date_time_str = root.find('imin').text # 2020-04-18 00:00:00
end_date_time_str = root.find('imax').text   # 2020-04-21 00:00:00

IBDATE, IBTIME = parse_date(start_date_time_str).split()
IEDATE, IETIME = parse_date(end_date_time_str).split()

# Download grib_data using provided date
print(IBDATE, IBTIME, IEDATE, IETIME)
rc=subprocess.call("./download_grib.sh" + ' ' + IBDATE + ' ' + IEDATE, shell=True)

# Parsing date to the COMMAND

basename = os.path.basename(os.getcwd())

# Read in the default RELEASES file
with open(basename + '/options/COMMAND.back', 'r') as file:
  filedata = file.read()

# Replace the target string
filedata = filedata.replace('start_date', start_date)
filedata = filedata.replace('start_time', start_time)
filedata = filedata.replace('end_date', end_date)
filedata = filedata.replace('end_time', end_time)

# Write the file out to the calc dir
with open(basename+'/options/COMMAND', 'w') as file:
  file.write(filedata)
