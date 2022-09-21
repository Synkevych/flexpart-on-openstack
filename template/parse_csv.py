import logging,os,csv

# ToDo create an object that has all Species - 'name: file_name'
# SPECIES = {species_015: 'I-131', species_016: 'Cs-137'}

logging.basicConfig(filename="main.log", level=logging.INFO,
                    format="%(asctime)s %(message)s")

basename = os.getcwd()

def parse_date(str):
    return str.replace('-', '').replace(':', '')

with open('71.txt', newline='') as csvfile:
    csv_reader = csv.reader(csvfile, delimiter='\t')
    csv_header = next(csv_reader)
    for row in csv_reader: # id = row[3]
        # calc_id, use, m_id, s_id, station, country, s_lat, s_lng, id_nuclide, name_nuclide, date_start, time_start, date_end,time_end, val, sigma = row
        measurement_id = row[2]
        latitude = row[6]
        longitude = row[7]
        # ToDo: change format of date and time
        # ToDo: Solution for changing lat and lon (make them a rectangle)
        start_date = row[10].replace('-', '')
        start_time = row[11].replace(':', '')
        end_date = row[12].replace('-', '')
        end_time = row[13].replace(':', '')
        species_name = row[9]
        comment = "RELEASE " + measurement_id

        logging.info('Parsing ' + comment + ' file')

        # Read in the default RELEASES file
        with open(basename + '/options/RELEASES.back', 'r') as file:
          filedata = file.read()

        # Replace the target string
        filedata = filedata.replace('start_date', start_date)
        filedata = filedata.replace('start_time', start_time)
        filedata = filedata.replace('end_date', end_date)
        filedata = filedata.replace('end_time', end_time)
        filedata = filedata.replace('lat_1', latitude)
        filedata = filedata.replace('lon_1', longitude)
        filedata = filedata.replace('release_comment', comment)

        # Write the file out to the calc dir
        print(measurement_id,measurement_id == 1)
        if measurement_id == '1':
          with open(basename + '/options/RELEASES', 'w') as file:
            file.write(filedata)
        else:
          with open(basename + '/options/RELEASES', 'a') as file:
            file.write(filedata)
