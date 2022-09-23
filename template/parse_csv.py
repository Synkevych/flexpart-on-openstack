import logging,os,csv

# ToDo create an object that has all Species - 'name: file_name'
# SPECIES = {species_015: 'I-131', species_016: 'Cs-137'}

logging.basicConfig(filename="main.log", level=logging.INFO,
                    format="%(asctime)s %(message)s")

# folder name the same as a file name
folder_name = os.path.basename(os.getcwd())


def parse_release_file():
  basename = os.getcwd()
  template_header = """***************************************************************************************************************
  *                                                                                                             *
  *                                                                                                             *
  *                                                                                                             *
  *   Input file for the Lagrangian particle dispersion model FLEXPART                                          *
  *                        Please select your options                                                           *
  *                                                                                                             *
  *                                                                                                             *
  *                                                                                                             *
  ***************************************************************************************************************
  &RELEASES_CTRL
  NSPEC      =           1, ! Total number of species
  SPECNUM_REL=          {sn}, ! Species numbers in directory SPECIES
  /
  """.format(sn=species_name)
  template_body = """&RELEASE
  IDATE1  =       {date_1},
  ITIME1  =       {time_1},
  IDATE2  =       {date_2},
  ITIME2  =       {time_2},
  LON1    =        {lon_1},
  LON2    =        {lon_1},
  LAT1    =        {lat_1},
  LAT2    =        {lat_1},
  Z1      =          0.00,
  Z2      =          200.00,
  ZKIND   =              1,
  MASS    =       1.00e-04,
  PARTS   =            10000, ! 10000 < > 600000,
  COMMENT =    "{comment}",
  /
  """.format(date_1=start_date, time_1=start_time, date_2=end_date, time_2=end_time, lon_1=longitude, lat_1=latitude, comment=comment)

  if ( measurement_id == '1'):
    file = open(basename + '/options/RELEASES', 'w')
    file.write(template_header + template_body)
  else:
    file = open(basename + '/options/RELEASES', 'a')
    file.write(template_body)
  file.close()
  logging.info('Parsing RELEASE file compleated.')

with open(folder_name + '.txt', newline='') as csvfile:
    csv_reader = csv.reader(csvfile, delimiter='\t')
    csv_header = next(csv_reader)
    for row in csv_reader:
        # calc_id(0), use(1), m_id(2), s_id(3), station(4), country(5), s_lat(6),s_lng(7),
        # id_nuclide(8), name_nuclide(9), date_start, time_start, date_end, time_end, val, sigma
        measurement_id = row[2]
        latitude = row[6]
        longitude = row[7]
        species_name = row[9]
        # ToDo: Solution for changing lat and lon (make them a rectangle)
        start_date = row[10].replace('-', '')
        start_time = row[11].replace(':', '')
        end_date = row[12].replace('-', '')
        end_time = row[13].replace(':', '')
        comment = "RELEASE " + measurement_id
        parse_release_file()
