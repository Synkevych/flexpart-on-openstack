import os
import logging
import csv
import xml.etree.ElementTree as ET
from subprocess import call

logging.basicConfig(filename="parsing.log", level=logging.INFO,
                    format="%(asctime)s %(message)s")

basename = os.getcwd()
template_header = """***************************************************************************************************************
*                                                                                                             *
*   Input file for the Lagrangian particle dispersion model FLEXPART                                           *
*                        Please select your options                                                           *
*                                                                                                             *
***************************************************************************************************************
"""


def write_to_file(file_name, contents, mode='w'):
  file = open(basename + file_name, mode)
  file.write(contents)
  file.close()


def parse_command_file(start_date, start_time, end_date, end_time):
  command_body = """&COMMAND
 LDIRECT=              -1, ! Simulation direction in time   ; 1 (forward) or -1 (backward)
 IBDATE=         {date_1}, ! Start date of the simulation   ; YYYYMMDD: YYYY=year, MM=month, DD=day
 IBTIME=         {time_1}, ! Start time of the simulation   ; HHMISS: HH=hours, MI=min, SS=sec; UTC
 IEDATE=         {date_2}, ! End date of the simulation     ; same format as IBDATE
 IETIME=         {time_2}, ! End  time of the simulation    ; same format as IBTIME
 LOUTSTEP=           3600, ! Interval of model output; average concentrations calculated every LOUTSTEP (s)
 LOUTAVER=           3600, ! Interval of output averaging (s)
 LOUTSAMPLE=         3600, ! Interval of output sampling  (s), higher stat. accuracy with shorter intervals
 ITSPLIT=        99999999, ! Interval of particle splitting (s)
 LSYNCTIME=            60, ! All processes are synchronized to this time interval (s)
 CTL=          -5.0000000, ! CTL>1, ABL time step = (Lagrangian timescale (TL))/CTL, uses LSYNCTIME if CTL<0
 IFINE=                 4, ! Reduction for time step in vertical transport, used only if CTL>1
 IOUT=                  9, ! Output type: [1]mass 2]pptv 3]1&2 4]plume 5]1&4, +8 for NetCDF output
 IPOUT=                 0, ! Particle position output: 0]no 1]every output 2]only at end 3]time averaged
 LSUBGRID=              0, ! Increase of ABL heights due to sub-grid scale orographic variations;[0]off 1]on
 LCONVECTION=           1, ! Switch for convection parameterization;0]off [1]on
 LAGESPECTRA=           0, ! Switch for calculation of age spectra (needs AGECLASSES);[0]off 1]on
 IPIN=                  0, ! Warm start from particle dump (needs previous partposit_end file); [0]no 1]yes
 IOUTPUTFOREACHRELEASE= 1, ! Separate output fields for each location in the RELEASE file; [0]no 1]yes
 IFLUX=                 0, ! Output of mass fluxes through output grid box boundaries
 MDOMAINFILL=           0, ! Switch for domain-filling, if limited-area particles generated at boundary
 IND_SOURCE=            1, ! Unit to be used at the source   ;  [1]mass 2]mass mixing ratio
 IND_RECEPTOR=          1, ! Unit to be used at the receptor; [1]mass 2]mass mixing ratio 3]wet depo. 4]dry depo.
 MQUASILAG=             0, ! Quasi-Lagrangian mode to track individual numbered particles
 NESTED_OUTPUT=         0, ! Output also for a nested domain
 LINIT_COND=            0, ! Output sensitivity to initial conditions (bkw mode only) [0]off 1]conc 2]mmr
 SURF_ONLY=             0, ! Output only for the lowest model layer, used w/ LINIT_COND=1 or 2
 CBLFLAG=               0, ! Skewed, not Gaussian turbulence in the convective ABL, need large CTL and IFINE
 OHFIELDS_PATH= "../../flexin/", ! Default path for OH file
 /
""".format(date_1=start_date, time_1=start_time, date_2=end_date, time_2=end_time)
  write_to_file('/options/COMMAND', template_header + command_body)


def parse_outgrid_file(args):
  outgrid_template = """!*******************************************************************************
!                                                                              *
!      Input file for the Lagrangian particle dispersion model FLEXPART         *
!                       Please specify your output grid                        *
!                                                                              *
! OUTLON0    = GEOGRAPHYICAL LONGITUDE OF LOWER LEFT CORNER OF OUTPUT GRID     *
! OUTLAT0    = GEOGRAPHYICAL LATITUDE OF LOWER LEFT CORNER OF OUTPUT GRID      *
! NUMXGRID   = NUMBER OF GRID POINTS IN X DIRECTION (= No. of cells + 1)       *
! NUMYGRID   = NUMBER OF GRID POINTS IN Y DIRECTION (= No. of cells + 1)       *
! DXOUT      = GRID DISTANCE IN X DIRECTION                                    *
! DYOUN      = GRID DISTANCE IN Y DIRECTION                                    *
! OUTHEIGHTS = HEIGHT OF LEVELS (UPPER BOUNDARY)                               *
!*******************************************************************************
&OUTGRID
 OUTLON0=      {out_lon},
 OUTLAT0=     {out_lat},
 NUMXGRID=      {x_grid},
 NUMYGRID=      {y_grid},
 DXOUT=        {dx_out},
 DYOUT=        {dy_out},
 OUTHEIGHTS=   200.0,
 /
""".format(out_lon=args['out_longitude'],
           out_lat=args['out_latitude'],
           x_grid=args['num_x_grid'].split('.')[0],
           y_grid=args['num_y_grid'].split('.')[0],
           dx_out=args['dx_out'],
           dy_out=args['dy_out'])
  write_to_file('/options/OUTGRID', outgrid_template)


def parse_simflex_input(end_date, end_time):
  dir_name = 'simflex'
  if not os.path.exists(dir_name):
    os.makedirs(dir_name)
  simflex_paths = """#id_obs; path_to_file; srs_ind;
{obs_id}; {path_to_file}; {srs_id}
""".format(obs_id=1, path_to_file=basename+'/grid_time_' + end_date + end_time + '.nc', srs_id=1)
  write_to_file('/' + dir_name + '/table_srs_paths.txt', simflex_paths)


def get_xml_data():
  def remove_hyphens_and_colon(str):
      # example 2020-04-18 00:00:00
      return str.replace('-', '').replace(':', '')

  xml_tree = ET.parse(os.path.basename(basename) + '.xml')
  xml_root = xml_tree.getroot()

  start_date_time_str = xml_root.find('imin').text
  end_date_time_str = xml_root.find('imax').text
  start_date, start_time = remove_hyphens_and_colon(
      start_date_time_str).split()
  end_date, end_time = remove_hyphens_and_colon(end_date_time_str).split()
  args = {
      'out_longitude': xml_root.find('se_lon').text,
      'out_latitude': xml_root.find('se_lat').text,
      'num_x_grid': xml_root.find('nx').text,
      'num_y_grid': xml_root.find('ny').text,
      'dx_out': xml_root.find('dlat').text,
      'dy_out': xml_root.find('dlon').text
  }

  parse_command_file(start_date, start_time, end_date, end_time)
  logging.info('Parsing COMMAND file compleated.')
  parse_outgrid_file(args)
  logging.info('Parsing OUTGRID file compleated.')
  parse_simflex_input(end_date, end_time)
  logging.info('Parsing table_srs_paths.txt file compleated.')

  # Download grib_data using received dates
  rc = call("./download_grib.sh" +
            ' ' + start_date +
            ' ' + end_date, shell=True)


def parse_release_file(args):
  SPECIES_BY_ID = {"O3": '002', "NO": '003', "NO2": '004',
                   "HNO3": '005', "HNO2": '006', "H2O2": '007',
                   "NO2": '008', "HCHO": '009', "PAN": '010',
                   "NH3": '011', "SO4-aero": '012', "NO3-aero": '013',
                   "I2-131": '014', "I-131": '015', "Cs-137": '016',
                   "Y-91": '017', "Ru-106": '018', "Kr-85": '019',
                   "Sr-90": '020', "Xe-133": '021', "CO": '022',
                   "SO2": '023', "AIRTRACER": '024', "AERO-TRACE": '025',
                   "CH4": '026', "C2H6": '027', "C3H8": '028',
                   "PCB28": '031', "G-HCH": '034', "BC": '040'}
  species_id = int(SPECIES_BY_ID.get(args['species_name']))
  release_header = """&RELEASES_CTRL
 NSPEC      =           1, ! Total number of species
 SPECNUM_REL=          {sn}, ! Species numbers in directory SPECIES
 /
""".format(sn=species_id)

  release_body = """&RELEASE
  IDATE1  =     {date_1},
  ITIME1  =       {time_1},
  IDATE2  =     {date_2},
  ITIME2  =       {time_2},
  LON1    =        {lon_1},
  LON2    =        {lon_2},
  LAT1    =        {lat_1},
  LAT2    =        {lat_2},
  Z1      =          0.00,
  Z2      =          200.00,
  ZKIND   =              1,
  MASS    =       {mass},
  PARTS   =          10000, ! >= 10000, <=600000,
  COMMENT =    "{comment}",
  /
""".format(date_1=args['start_date'],
           time_1=args['start_time'],
           date_2=args['end_date'],
           time_2=args['end_time'],
           lon_1=args['longitude_1'],
           lon_2=args['longitude_2'],
           lat_1=args['latitude_1'],
           lat_2=args['latitude_2'],
           mass=args['mass'],
           comment=args['comment'])

  if args['id'] == '1':
    write_to_file('/options/RELEASES', template_header +
                  release_header + release_body)
  else:
    write_to_file('/options/RELEASES', release_body, 'a')


def get_data_from_txt_file():
  with open(os.path.basename(basename) + '.txt', newline='') as csvfile:
      csv_reader = csv.reader(csvfile, delimiter='\t')
      csv_header = next(csv_reader)
      for row in csv_reader:
          # calc_id(0), use(1), m_id(2), s_id(3), station(4), country(5), s_lat(6),s_lng(7),
          # id_nuclide(8), name_nuclide(9), date_start(10), time_start(11), date_end(12), time_end(13), val(14), sigma
          measurement_id = row[2]
          latitude_1 = float(row[6])
          longitude_1 = float(row[7])
          species_mass = "{:e}".format(int(row[14]))
          args = {
              'id': measurement_id,
              'latitude_1': latitude_1,
              'longitude_1': longitude_1,
              'latitude_2': round(latitude_1+0.10, 2),
              'longitude_2': round(longitude_1+0.10, 2),
              'species_name': row[9],
              'start_date': row[10].replace('-', ''),
              'start_time': row[11].replace(':', ''),
              'end_date': row[12].replace('-', ''),
              'end_time': row[13].replace(':', ''),
              'mass': species_mass,
              'comment': "RELEASE " + measurement_id
          }

          parse_release_file(args)
          logging.info('Parsing RELEASE file compleated.')


get_xml_data()
get_data_from_txt_file()
