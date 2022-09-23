import os
import xml.etree.ElementTree as ET
from subprocess import call

# folder name the same as a file name
folder_name = os.path.basename(os.getcwd())
tree = ET.parse(folder_name + '.xml')
root = tree.getroot()

def parse_date(str):
    # example 2020-04-18 00:00:00
    return str.replace('-', '').replace(':', '')

start_date_time_str = root.find('imin').text
end_date_time_str = root.find('imax').text

start_date, start_time = parse_date(start_date_time_str).split()
end_date, end_time = parse_date(end_date_time_str).split()

# Download grib_data using provided date
print(start_date, start_time, end_date, end_time)
rc=call("./download_grib.sh" + ' ' + start_date + ' ' + end_date, shell=True)

def parse_command_file(IBDATE, IBTIME, IEDATE, IETIME):
  # Parsing date to the COMMAND
  basename = os.getcwd()
  template_header="""***************************************************************************************************************
  *                                                                                                             *
  *      Input file for the Lagrangian particle dispersion model FLEXPART                                        *
  *                           Please select your options                                                        *
  *                                                                                                             *
  ***************************************************************************************************************
  """
  template_body="""&COMMAND
  LDIRECT=               1, ! Simulation direction in time   ; 1 (forward) or -1 (backward)
  IBDATE=       {start_date}, ! Start date of the simulation   ; YYYYMMDD: YYYY=year, MM=month, DD=day
  IBTIME=       {start_time}, ! Start time of the simulation   ; HHMISS: HH=hours, MI=min, SS=sec; UTC
  IEDATE=         {end_date}, ! End date of the simulation     ; same format as IBDATE
  IETIME=         {end_time}, ! End  time of the simulation    ; same format as IBTIME
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
  """.format(start_date=IBDATE, start_time=IBTIME, end_date=IEDATE, end_time=IETIME)

  file = open(basename + '/options/COMMAND', 'w')
  file.write(template_header + template_body)
  file.close()

parse_command_file(start_date, start_time, end_date, end_time)
