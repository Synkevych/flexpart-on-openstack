import logging,os,csv

logging.basicConfig(filename="main.log", level=logging.INFO,
                    format="%(asctime)s %(message)s")

path_to_data_files = '/data/calculations/'
basename = os.path.basename(os.getcwd())

with open('measurem.csv', newline='') as csvfile:
    csv_reader = csv.reader(csvfile, delimiter=';')
    csv_header = next(csv_reader)
    for row in csv_reader:
        calc_folder_id = basename + '_' + row[1]
        path_to_calc_dir = path_to_data_files + calc_folder_id
        lat = row[5]
        lon = row[6]
        start_date = row[7].replace('.', '')
        start_time = row[8].replace(':', '')
        end_date = row[9].replace('.', '')
        end_time = row[10].replace(':', '')
        comment = "RELEASE " + row[1]
        print('comment ', comment)
        print('comment ', calc_folder_id)
        print('path_to_data_files', path_to_calc_dir)

        if not os.path.exists(path_to_calc_dir):
            os.makedirs(path_to_calc_dir)
            logging.info('Folder ' + calc_folder_id + ' created')
        logging.info('Parsing ' + comment + ' file')

        # Read in the default RELEASES file
        with open('/data/opt/RELEASES.back', 'r') as file:
          filedata = file.read()

        # Replace the target string
        filedata = filedata.replace('start_date', start_date)
        filedata = filedata.replace('start_time', start_time)
        filedata = filedata.replace('end_date', end_date)
        filedata = filedata.replace('end_time', end_time)
        filedata = filedata.replace('lat_1', lat)
        filedata = filedata.replace('lon_1', lon)
        filedata = filedata.replace('release_comment', comment)

        # Write the file out to the calc dir
        with open(path_to_calc_dir+'/'+'RELEASES', 'w') as file:
          file.write(filedata)
