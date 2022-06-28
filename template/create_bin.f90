C ================================================ C
C //////////////////////////////////////////////// C
C ================================================ C
      program netCDF_rw

      implicit none
      include 'netcdf.inc'

C ------------------------------------------------ C
C ---- VARIABLES and PARAMETERS ------------------ C
C ------------------------------------------------ C

      character path*34,infile*40,outfile*40
      integer x,y,t
      ! file specifics
      integer nx,ny,ndim,nt
      parameter(nx=360,ny=180,nt=361,ndim=3)
      ! dataset variables
      real tvar(nt)         ! dimension variables
      real, allocatable :: yvar(:), xvar(:)
      real cvar(nx,ny,nt)                     ! data from spec001_mr
      ! netcdf 'communication' variables
      integer cvar_id,x_id,y_id,t_id         ! variable IDs
      integer state,ncid                     ! return value and file ID
      integer nrecs,recid,dim,var,gatt,unlim ! for inquire call
      character*(nf_max_name) recname

      integer lat,lon,imx,sizet,sizes

      path='/home/sebastian/research/TIP/data/'  ! path to dataset
      infile='grid_time_20200421000000.nc'       ! dataset name

C ==== Inquire call =============================== C

      print*, 'Info on ', infile
      print*, '===================================='

      ! opening file
      state = nf_open(infile,nf_nowrite,ncid)
      if (state .ne. nf_noerr) call handle_err(state)

      ! inquire call
      state = nf_inq(ncid,dim,var,gatt,unlim)
      if (state .ne. nf_noerr) call handle_err(state)

      state = nf_inq_dim(ncid,1,recname,nt)
      state = nf_inq_dim(ncid,2,recname,lat)
      state = nf_inq_dim(ncid,3,recname,lon)

      allocate(xvar(lon), yvar(lat), tvar(nt))

      print*, 'latitude ', lat, 'longitude ', lon
      print*

C ==== Read existing netCDF file ================== C

      state = nf_inq_varid(ncid,'longitude',x_id)
      state = nf_get_var_real(ncid,x_id,xvar)
      if (state .ne. nf_noerr) call handle_err(state)
      print*, '  (1) Longitudes read', xvar(1)
      print*, ' size of longitude', size(xvar, DIM=1)

      state = nf_inq_varid(ncid,'latitude',y_id)
      state = nf_get_var_real(ncid,y_id,yvar)
      if (state .ne. nf_noerr) call handle_err(state)
      print*, ' size of latitude', size(yvar, DIM=1)
      print*, '  (2) Latitudes read', yvar(1)

      state = nf_inq_varid(ncid,'latitude',y_id)
      state=nf_get_var_real(ncid,y_id,yvar)
      if (state .ne. nf_noerr) call handle_err(state)
      print*, ' size of latitude', size(yvar, DIM=1)

      state = nf_inq_varid(ncid,'time',t_id)
      state=nf_get_var_real(ncid,t_id,tvar)
      if (state .ne. nf_noerr) call handle_err(state)
      print*, ' size of time', size(tvar, DIM=1)
      print*, '  (3) Times read'

      state = nf_inq_varid(ncid,'spec001_mr',cvar_id)
      state=nf_get_var_real(ncid,cvar_id,cvar)
      if (state.ne.nf_noerr) call handle_err(state)
      print*, '  (4) Data variable read'

      print*, '   > Read complete'
      print*

! close file
      state = nf_close(ncid)
              if (state.ne.nf_noerr) call handle_err(state)
              print*, '  > File closed: ', path//outfile
      end

C ================================================== C
C ////////////////////////////////////////////////// C
C ================================================== C

      subroutine handle_err(errcode)
      implicit none
      include 'netcdf.inc'
      integer errcode
      print *, 'Error: ', nf_strerror(errcode)
      stop
      end
