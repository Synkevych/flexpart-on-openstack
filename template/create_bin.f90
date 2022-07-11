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
      character*60 :: file_name, file_id_c

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

      state = nf_inq_varid(ncid,'time',t_id)
      state=nf_get_var_real(ncid,t_id,tvar)
      if (state .ne. nf_noerr) call handle_err(state)
      print*, ' size of time', size(tvar, DIM=1)

      dt = tvar(1) - tvar(2)
      print*, tvar(1), '-', tvar(2), ' dt= ', dt

      state = nf_inq_varid(ncid,'spec001_mr',cvar_id)
      state=nf_get_var_real(ncid,cvar_id,cvar)
      if (state.ne.nf_noerr) call handle_err(state)
      print*, ' spec001_mr infos :'
      print*, ' size of nageclass 1', size(cvar, DIM=1)
      print*, ' size of pointspec 2', size(cvar, DIM=2)
      print*, ' size of time 3', size(cvar, DIM=3)
      print*, ' size of height 4', size(cvar, DIM=4)
      print*, ' size of latitude 5', size(cvar, DIM=5)
      print*, ' size of longitude 6', size(cvar, DIM=6)
      print*, ' value from spec001_me ', cvar(1,1,1,1,1,1)
      srs_size=size(cvar, DIM=2)
      nnt=size(cvar, DIM=4)
      nns=size(cvar, DIM=5)
      allocate(cplot(nns,nnt,nnt))

      ! create grid using long and lat
      OPEN(1000, FILE='grid.dat', STATUS="NEW", ACTION="WRITE")
      do j=1,lat ! latitude
            do i=1,lon ! longitude
                  write(1000,11) xvar(i), yvar(j)
                  11 format(F10.6, F10.6)
            end do
      end do
      CLOSE(1000)

      do file_id=1,size(cvar, DIM=2) ! pointspec 31
        ! transform the integer to character
        write(file_id_c, *) file_id
        OPEN(100, FILE='srs_1.dat', STATUS="REPLACE", ACTION="WRITE")
        ! Construct the filename:
        file_name = 'srs_' // trim(adjustl(file_id_c)) // '.dat'
        open(file_id,file=file_name,status='create',form='formatted',action="write")
        do n3=1,size(cvar, DIM=3)       ! time 72
          do n4=1,size(cvar, DIM=4)     ! height 1
            do n5=1,size(cvar, DIM=5)   ! lon 400
              do n6=1,size(cvar, DIM=6) ! lat 322
                write(100,12) cvar(1,file_id,n3,n4,n5,n6)
                12 format(F10.6)
              end do
            end do
          end do
        end do
        CLOSE(file_id)
        print*,'File ', file_name, 'saved'
      end do
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
