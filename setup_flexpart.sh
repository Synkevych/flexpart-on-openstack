#!/bin/bash
# you need to tun this script as a sudo user

# exit on the first error
set -e

sudo apt-get update
sudo apt-get -y install g++ gfortran autoconf libtool automake flex make

export CC=gcc
export CXX=g++
export FC=gfortran

# jasper

mkdir flexpart ; cd flexpart
echo "starting istallation flexpart" >> installation.log

# here you can change the default install location
export DIR=/home/ubuntu/flexpart

wget https://www.ece.uvic.ca/~frodo/jasper/software/jasper-1.900.1.zip ;
unzip jasper-1.900.1.zip ; rm jasper-1.900.1.zip
cd jasper-1.900.1
chmod +x configure
./configure --prefix=$DIR
make clean ; make -j ; make -j check
make install

cd $DIR
echo "jasper istalled" >> installation.log
rm -rf jasper-1.900.1

# grib_api

wget https://people.freebsd.org/~sunpoet/sunpoet/grib_api-1.26.1-Source.tar.gz ;
tar -xvf grib_api-1.26.1-Source.tar.gz ; rm grib_api-1.26.1-Source.tar.gz
cd grib_api-1.26.1-Source
chmod +x configure
./configure --prefix=$DIR --with-jasper=$DIR --disable-shared
make clean ; make -j ; make -j check
make install

cd $DIR
echo "grib_api istalled" >> installation.log
rm -rf grib_api-1.26.1-Source

# zlib

wget https://zlib.net/fossils/zlib-1.2.11.tar.gz ;
tar -zxvf zlib-1.2.11.tar.gz ; rm zlib-1.2.11.tar.gz
cd zlib-1.2.11
chmod +x configure
./configure --prefix=$DIR
make clean ; make -j ; make -j check
make install

cd $DIR
echo "zlib istalled" >> installation.log
rm -rf zlib-1.2.11

# hdf5

wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/hdf5-1.8.17/src/hdf5-1.8.17.tar.gz ;
tar -zxvf hdf5-1.8.17.tar.gz ; rm hdf5-1.8.17.tar.gz
cd hdf5-1.8.17/
chmod +x configure
./configure --prefix=$DIR --with-zlib=$DIR
make clean ; make -j ; make check
make install

cd $DIR
echo "hdf5 istalled" >> installation.log
rm -rf hdf5-1.8.17

# netcdf

wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.6.1.tar.gz ;
tar -zxvf netcdf-4.6.1.tar.gz ; rm netcdf-4.6.1.tar.gz
cd  netcdf-4.6.1
chmod +x configure
./configure --prefix=$DIR \
CPPFLAGS="-I$DIR/include -O" \
LDFLAGS="-L$DIR/lib" --enable-shared --enable-netcdf-4 --disable-dap --disable-doxygen
make clean ; make -j ; make -j check
make install

cd $DIR
echo "netcdf istalled" >> installation.log
rm -rf netcdf-4.6.1

# netcd-fortran

wget https://www.gfd-dennou.org/arch/netcdf/unidata-mirror/netcdf-fortran-4.4.5.tar.gz ;
tar -zxvf netcdf-fortran-4.4.5.tar.gz ; rm netcdf-fortran-4.4.5.tar.gz
cd  netcdf-fortran-4.4.5
chmod +x configure
./configure --prefix=$DIR \
CPPFLAGS="-I$DIR/include -O" \
LDFLAGS="-L$DIR/lib" --enable-shared --disable-doxygen
make clean ; make -j ; make check ; make check # on first launch, one test fails
make install

cd $DIR
echo "netcdf-fortran istalled" >> installation.log
rm -rf netcdf-fortran-4.4.5

# flexpart

wget --content-disposition https://www.flexpart.eu/downloads/66
tar -xvf flexpart_v10.4.tar
cd flexpart_v10.4_3d7eebf/src

# change parameter in flexpart

sed -i 's#/homevip/flexpart#/home/ubuntu/flexpart#g' makefile
sed -i 's#/gcc-5.4.0/include#/include#g' makefile
sed -i 's#/gcc-5.4.0/lib#/lib#g' makefile
sed -i 's/nxmax=361,nymax=181,nuvzmax=138,nwzmax=138,nzmax=138/nxmax=1441,nymax=721,nuvzmax=64,nwzmax=64,nzmax=64/g' par_mod.f90
# or integer,parameter :: nxmax=721,nymax=361,nuvzmax=64,nwzmax=64,nzmax=64

export LD_LIBRARY_PATH='$LD_LIBRARY_PATH:$DIR/lib'
export CFLAGS='-L$HDF5/lib -I$HDF5/include -L$NETCDF/lib -I$NETCDF/include'
export CXXFLAGS='-L$HDF5/lib -I$HDF5/include -L$NETCDF/lib -I$NETCDF/include'
export FCFLAGS='-L$HDF5/lib -I$HDF5/include -L$NETCDF/lib -I$NETCDF/include'
export CPPFLAGS='-I${HDF5}/include -I${NETCDF}/include'
export LDFLAGS='-L${HDF5}/lib -L${NETCDF}/lib'

export PATH=$GRIB_API_BIN:$PATH
export GRIB_API=$DIR/grib_api/
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$GRIB_API/lib
export GRIB_API_BIN=$GRIB_API/bin
export GRIB_API_LIB=$GRIB_API/lib
export GRIB_API_INCLUDE=$GRIB_API/include

source ~/.bashrc

# ncf=yes - to activate NetCDF support
make -j serial ncf=yes
# to use NCF change IOUT parameter to IOUT=9 inside file options/COMMOND

cd $DIR
echo "flexpart istalled" >> installation.log