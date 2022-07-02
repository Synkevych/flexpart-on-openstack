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
      ! dataset variables
      real, allocatable :: yvar(:), xvar(:),tvar(:)  ! dimension variables
      real, allocatable :: cvar(:,:,:,:,:,:)  ! data from spec001_mr
      ! netcdf 'communication' variables
      integer cvar_id,x_id,y_id,t_id         ! variable IDs
      integer state,ncid                     ! return value and file ID
      integer nrecs,recid,dim,var,gatt,unlim ! for inquire call
      character*(nf_max_name) recname

      integer lat,lon,imx,sizet,sizes
      integer nageclass, pointspec, height, nnt, nns, j, t
      parameter(nageclass=1,pointspec=31,height=1)
      real dt

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
      allocate(cvar(nageclass,pointspec,nt,height,lat,lon))

      print*, ' time ', nt, 'latitude ', lat, 'longitude ', lon
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

      dt = tvar(1) - tvar(2)
      print*, tvar(1), '-', tvar(2), ' dt= ', dt

      state = nf_inq_varid(ncid,'spec001_mr',cvar_id)
      state=nf_get_var_real(ncid,cvar_id,cvar)
      if (state.ne.nf_noerr) call handle_err(state)
      print*, ' size of spec001_mr 1', size(cvar, DIM=1)
      print*, ' size of spec001_mr 2', size(cvar, DIM=2)
      print*, ' size of spec001_mr 3', size(cvar, DIM=3)
      print*, ' size of spec001_mr 4', size(cvar, DIM=4)
      print*, ' size of spec001_mr 5', size(cvar, DIM=5)
      print*, ' size of spec001_mr 6', size(cvar, DIM=6)
      print*, ' value from spec001_me ', cvar(1,1,1,1,1,1)
      srs_size=size(cvar, DIM=2)
      nnt=size(cvar, DIM=4)
      nns=size(cvar, DIM=5)

      ! create grid using long and lat
      OPEN(1000, FILE='grid.dat',STATUS="NEW",ACTION="WRITE")

      do j=1,size(yvar, DIM=1) ! latitude
            do i=1,size(xvar, DIM=1) ! longitude
                  write(1000,11) xvar(i), yvar(j)
                  11 format(F10.6, F10.6)
            end do
      end do
      CLOSE(1000)

      print*, '   > Read complete'
      print*

! close file
      state = nf_close(ncid)ls
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
