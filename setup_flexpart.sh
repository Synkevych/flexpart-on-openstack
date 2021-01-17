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

mkdir flexpart_lib ; cd flexpart_lib
echo "starting istallation flexpart" >> installation.log

# here you can change the default install location
export DIR=/home/ubuntu/flexpart_lib

# dowload all libs from env.kiev.ua
wget http://env.com.ua/~sunkevu4/flexpart/all_lib.tgz
tar -xvf all_lib.tgz; rm all_lib.tgz

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

tar -zxvf netcdf-4.6.1.tar.gz ; rm netcdf-4.6.1.tar.gz
cd  netcdf-4.6.1
chmod +x configure
./configure --prefix=$DIR \
              CPPFLAGS="-I$DIR/include -O" \
              LDFLAGS="-L$DIR/lib" \
              --enable-shared --enable-netcdf-4 \
              --disable-dap --disable-doxygen
make clean ; make -j ; make -j check
make install

cd $DIR
echo "netcdf istalled" >> installation.log
rm -rf netcdf-4.6.1

# netcdf-fortran, version depending on netcdf

tar -zxvf netcdf-fortran-4.4.5.tar.gz ; rm netcdf-fortran-4.4.5.tar.gz
cd  netcdf-fortran-4.4.5
chmod +x configure
./configure --prefix=$DIR \
              CPPFLAGS="-I$DIR/include -O" \
              LDFLAGS="-L$DIR/lib" \
              --enable-shared --disable-doxygen
make clean ; make -j ; make check ; make check # on first launch, one test fails
make install

cd $DIR
echo "netcdf-fortran istalled" >> installation.log
rm -rf netcdf-fortran-4.4.5

# flexpart

tar -xvf flexpart_v10.4.tar.gz -C ../; rm flexpart_v10.4.tar.gz
cd ../flexpart_v10.4/src

# change ROOT_DIR path in flexpart, provide path where you install flexpart, by default: /home/ubuntu/flexpart_lib

sed -i 's#/homevip/flexpart#/home/ubuntu/flexpart_lib#g' makefile
sed -i 's#/gcc-5.4.0/include#/include#g' makefile
sed -i 's#/gcc-5.4.0/lib#/lib#g' makefile

# uncomment if you want to work with the larger grid 0.5 degree, 1 degree by default
# sed -i 's/nxmax=361,nymax=181,nuvzmax=138,nwzmax=138,nzmax=138/nxmax=1441,nymax=721,nuvzmax=128,nwzmax=128,nzmax=128/g' par_mod.f90

# ncf=yes - to activate NetCDF support
make -j serial ncf=yes
# to use NCF change IOUT parameter to IOUT=9 inside file options/COMMOND

cd $DIR
echo "flexpart istalled" >> installation.log

# setup workdir with teplate folder and basic configuration and downloads_grib script (the same as template folder in this repo)

cd ../
mkdir workdir; cd workdir
cd $DIR
tar -xvf template.tar.gz -C ../workdir ; rm template.tar.gz
cd ../workdir/template
# create symbolic link to compiled flexpart
ln ../../flexpart_v10.4/src/FLEXPART

echo "please do not change any file inside template folder, there are the initial settings"
echo "copy twmplate folder to any other with the name of your calculation, for example ukraine:"
echo "cp -r template/ ukraine/"
