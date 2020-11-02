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
cd jasper-1.900.1
chmod +x configure
./configure --prefix=/home/ubuntu/flexpart
make clean
make -j
make -j check
make install

# grib_api
cd /home/ubuntu/flexpart
echo "jasper istalled" >> installation.log

wget https://people.freebsd.org/~sunpoet/sunpoet/grib_api-1.26.1-Source.tar.gz
tar -xvf grib_api-1.26.1-Source.tar.gz
cd grib_api-1.26.1-Source
chmod +x configure
./configure --prefix=/home/ubuntu/flexpart --with-jasper=/home/ubuntu/flexpart --disable-shared
make clean
make -j
make -j check
make install

# zlib

cd /home/ubuntu/flexpart
echo "grib_api istalled" >> installation.log
wget https://zlib.net/fossils/zlib-1.2.11.tar.gz
tar -zxvf zlib-1.2.11.tar.gz
cd zlib-1.2.11
chmod +x configure
./configure --prefix=/home/ubuntu/flexpart
make clean
make -j
make -j check
make install

# hdf5

cd /home/ubuntu/flexpart
echo "zlib istalled" >> installation.log

wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/hdf5-1.8.17/src/hdf5-1.8.17.tar.gz
tar -zxvf hdf5-1.8.17.tar.gz
cd hdf5-1.8.17/
chmod +x configure
./configure --prefix=/home/ubuntu/flexpart --with-zlib=/home/ubuntu/flexpart
make clean
make -j
make check
make install

# netcdf

cd /home/ubuntu/flexpart
echo "hdf5 istalled" >> installation.log

wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.6.1.tar.gz
tar -zxvf netcdf-4.6.1.tar.gz
cd  netcdf-4.6.1
chmod +x configure
./configure --prefix=/home/ubuntu/flexpart CPPFLAGS="-I/home/ubuntu/flexpart/include -O" LDFLAGS="-L/home/ubuntu/flexpart/lib" --enable-shared --enable-netcdf-4 --disable-dap --disable-doxygen
make clean
make -j
make -j check
make install

# netcd-fortran

cd /home/ubuntu/flexpart
echo "netcdf istalled" >> installation.log

wget https://www.gfd-dennou.org/arch/netcdf/unidata-mirror/netcdf-fortran-4.4.5.tar.gz
tar -zxvf netcdf-fortran-4.4.5.tar.gz
cd  netcdf-fortran-4.5.5
chmod +x configure
./configure --prefix=/home/ubuntu/flexpart CPPFLAGS="-I/home/ubuntu/flexpart/include -O" LDFLAGS="-L/home/ubuntu/flexpart/lib" --enable-shared --enable-netcdf-4 --disable-dap --disable-doxygen
make clean
make -j
make -j check
make install

# flexpart

cd /home/ubuntu/flexpart
echo "netcdf-fortran istalled" >> installation.log

wget https://www.flexpart.eu/downloads/66
tar -xvf flexpart10.4.tar.gz
cd flexpart_v10.4/src

sed -i -e 's/"ROOT_DIR = /homevip/flexpart" / "ROOT_DIR = /home/ubuntu/flexpart/include"/g' makefile
sed -i -e 's/"INCPATH1  = ${ROOT_DIR}/gcc-4.9.1/include"/"INCPATH1 = ${ROOT_DIR}/include"/g' makefile

echo "export DIR=/home/roman/lib" >> ~/.bashrc
echo "export LD_LIBRARY_PATH='$LD_LIBRARY_PATH:$NETCDF/lib'" >> ~/.bashrc
echo "export CFLAGS='-L$HDF5/lib -I$HDF5/include -L$NETCDF/lib -I$NETCDF/include'" >> ~/.bashrc
echo "export CXXFLAGS='-L$HDF5/lib -I$HDF5/include -L$NETCDF/lib -I$NETCDF/include'" >> ~/.bashrc
echo "export FCFLAGS='-L$HDF5/lib -I$HDF5/include -L$NETCDF/lib -I$NETCDF/include'" >> ~/.bashrc
echo "export CPPFLAGS='-I${HDF5}/include -I${NETCDF}/include'" >> ~/.bashrc
echo "export LDFLAGS='-L${HDF5}/lib -L${NETCDF}/lib'" >> ~/.bashrc
source ~/.bashrc

make -j serial

cd /home/ubuntu/flexpart
echo "flexpart istalled" >> installation.log
