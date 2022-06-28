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
      print*, ' size of data', cvar(1,1,1,1,1,1)
      nnt=size(cvar, DIM=4)
      nns=size(cvar, DIM=5)

      OPEN(1000, FILE='srs_1.bin',FORM='UNFORMATTED')
      write(1000)lat,lon

      do j=1,nns
        do i=1,nnt
                write(1000)cvar(:,:,1,i,j,1)
        end do
      end do

      CLOSE(1000)

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
