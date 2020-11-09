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

cd /home/ubuntu
mkdir flexpart & cd flexpart
echo "starting istallation flexpart" >> installation.log

export DIR=/home/ubuntu/flexpart

wget https://www.ece.uvic.ca/~frodo/jasper/software/jasper-1.900.1.zip
unzip jasper-1.900.1.zip
rm jasper-1.900.1.zip
cd jasper-1.900.1
chmod +x configure
./configure --prefix=/home/ubuntu/flexpart
make clean
make -j
make -j check
make install

cd /home/ubuntu/flexpart
echo "jasper istalled" >> installation.log
rm -rf jasper-1.900.1
# grib_api

wget https://people.freebsd.org/~sunpoet/sunpoet/grib_api-1.26.1-Source.tar.gz
tar -xvf grib_api-1.26.1-Source.tar.gz
rm grib_api-1.26.1-Source.tar.gz
cd grib_api-1.26.1-Source
chmod +x configure
./configure --prefix=/home/ubuntu/flexpart --with-jasper=/home/ubuntu/flexpart --disable-shared
make clean
make -j
make -j check
make install

cd /home/ubuntu/flexpart
echo "grib_api istalled" >> installation.log
rm -rf grib_api-1.26.1-Source

# zlib

wget https://zlib.net/fossils/zlib-1.2.11.tar.gz
tar -zxvf zlib-1.2.11.tar.gz
rm zlib-1.2.11.tar.gz
cd zlib-1.2.11
chmod +x configure
./configure --prefix=/home/ubuntu/flexpart
make clean
make -j
make -j check
make install

cd /home/ubuntu/flexpart
echo "zlib istalled" >> installation.log
rm -rf zlib-1.2.11

# hdf5

wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/hdf5-1.8.17/src/hdf5-1.8.17.tar.gz
tar -zxvf hdf5-1.8.17.tar.gz
rm hdf5-1.8.17.tar.gz
cd hdf5-1.8.17/
chmod +x configure
./configure --prefix=/home/ubuntu/flexpart --with-zlib=/home/ubuntu/flexpart
make clean
make -j
make check
make install

cd /home/ubuntu/flexpart
echo "hdf5 istalled" >> installation.log
rm -rf hdf5-1.8.17

# netcdf

wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.6.1.tar.gz
tar -zxvf netcdf-4.6.1.tar.gz
rm netcdf-4.6.1.tar.gz
cd  netcdf-4.6.1
chmod +x configure
./configure --prefix=/home/ubuntu/flexpart CPPFLAGS="-I/home/ubuntu/flexpart/include -O" LDFLAGS="-L/home/ubuntu/flexpart/lib" --enable-shared --enable-netcdf-4 --disable-dap --disable-doxygen
make clean
make -j
make -j check
make install

cd /home/ubuntu/flexpart
echo "netcdf istalled" >> installation.log
rm -rf netcdf-4.6.1

# netcd-fortran

wget https://www.gfd-dennou.org/arch/netcdf/unidata-mirror/netcdf-fortran-4.4.5.tar.gz
tar -zxvf netcdf-fortran-4.4.5.tar.gz
rm netcdf-fortran-4.4.5.tar.gz
cd  netcdf-fortran-4.4.5
chmod +x configure
./configure --prefix=/home/ubuntu/flexpart CPPFLAGS="-I/home/ubuntu/flexpart/include -O" LDFLAGS="-L/home/ubuntu/flexpart/lib" --enable-shared --enable-netcdf-4 --disable-dap --disable-doxygen
make clean
make -j
make check
make check
make install

cd /home/ubuntu/flexpart
echo "netcdf-fortran istalled" >> installation.log
rm -rf netcdf-fortran-4.4.5

# flexpart

wget https://www.flexpart.eu/downloads/66
tar -xvf 66
cd flexpart_v10.4_3d7eebf/src

sed -i 's#/homevip/flexpart#/home/ubuntu/flexpart#g' makefile
sed -i 's#/gcc-5.4.0/include#/include#g' makefile
sed -i 's#/gcc-5.4.0/lib#/lib#g' makefile

export DIR=/home/ubuntu/flexpart
export LD_LIBRARY_PATH='$LD_LIBRARY_PATH:$NETCDF/lib'
export CFLAGS='-L$HDF5/lib -I$HDF5/include -L$NETCDF/lib -I$NETCDF/include'
export CXXFLAGS='-L$HDF5/lib -I$HDF5/include -L$NETCDF/lib -I$NETCDF/include'
export FCFLAGS='-L$HDF5/lib -I$HDF5/include -L$NETCDF/lib -I$NETCDF/include'
export CPPFLAGS='-I${HDF5}/include -I${NETCDF}/include'
export LDFLAGS='-L${HDF5}/lib -L${NETCDF}/lib'
source ~/.bashrc

make -j serial

cd /home/ubuntu/flexpart
echo "flexpart istalled" >> installation.log
