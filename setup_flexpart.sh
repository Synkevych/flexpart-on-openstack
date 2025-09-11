#!/bin/bash

set -e

sudo apt-get update
sudo apt-get -y install g++ gfortran autoconf libtool automake flex make wget openmpi-bin libopenmpi-dev

export CC=gcc
export CXX=g++
export FC=gfortran

# here you can change the default install location
mkdir -p flexpart_lib; cd flexpart_lib;
export DIR=$(pwd)

echo "start installing flexpart" >> installation.log

# dowload all libs from env.kiev.ua
wget http://env.com.ua/~sunkevu4/flexpart/all_libs.tar.gz
tar -xvf all_libs.tar.gz; mkdir tmp; mv all_libs.tar.gz tmp;

# jasper

tar -xvf jasper-1.900.1.tar.gz ; mv jasper-1.900.1.tar.gz tmp;
cd jasper-1.900.1
chmod +x configure
./configure --prefix=$DIR
make clean ; make -j ; make -j check
make install


cd $DIR
echo "jasper istalled" >> installation.log
rm -rf jasper-1.900.1

# grib_api

tar -xvf grib_api-1.26.1-Source.tar.gz ; mv grib_api-1.26.1-Source.tar.gz tmp;
cd grib_api-1.26.1-Source

# Check if GCC is 10 or higher and allow mismatched argument types
gcc_version=$(gcc -dumpversion | cut -d. -f1)
if [ "$gcc_version" -ge 10 ]; then
    export FCFLAGS="-fallow-argument-mismatch -O2"
    export FFLAGS="-fallow-argument-mismatch -O2"
fi

chmod +x configure
./configure --prefix=$DIR --with-jasper=$DIR --disable-shared
make clean ; make -j ; make -j check
make install

cd $DIR
echo "grib_api installed" >> installation.log
rm -rf grib_api-1.26.1-Source

# zlib

tar -zxvf zlib-1.2.11.tar.gz ; mv zlib-1.2.11.tar.gz tmp;
cd zlib-1.2.11
chmod +x configure
./configure --prefix=$DIR
make clean ; make -j ; make -j check
make install


cd $DIR
echo "zlib installed" >> installation.log
rm -rf zlib-1.2.11

# hdf5

tar -zxvf hdf5-1.8.17.tar.gz ; mv hdf5-1.8.17.tar.gz tmp;
cd hdf5-1.8.17/
chmod +x configure
./configure --prefix=$DIR --with-zlib=$DIR
make clean ; make -j ; make check
make install

cd $DIR
echo "hdf5 istalled" >> installation.log
rm -rf hdf5-1.8.17

# netcdf

tar -zxvf netcdf-4.6.1.tar.gz ; mv netcdf-4.6.1.tar.gz tmp;
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
echo "netcdf installed" >> installation.log
rm -rf netcdf-4.6.1

# netcdf-fortran, version depending on netcdf

tar -zxvf netcdf-fortran-4.4.5.tar.gz ; mv netcdf-fortran-4.4.5.tar.gz tmp;
cd  netcdf-fortran-4.4.5
chmod +x configure
./configure --prefix=$DIR \
              CPPFLAGS="-I$DIR/include -O" \
              LDFLAGS="-L$DIR/lib" \
              --enable-shared --disable-doxygen
make clean ; make -j ; make check ; make check # on first launch, one test fails
make install

cd $DIR
echo "netcdf-fortran installed" >> installation.log
rm -rf netcdf-fortran-4.4.5

cat >> bashrc_flexpart << END
export JASPERLIB=\$DIR/lib
export JASPERINC=\$DIR/include
export HWRF=1
export NETCDF=\$DIR
export LD_LIBRARY_PATH=\$DIR/lib:\$LD_LIBRARY_PATH
export LDFLAGS=-L\$DIR/lib
export CPPFLAGS=-I\$DIR/include
export PATH=\$DIR/bin:\$PATH
END
. bashrc_flexpart

# flexpart

tar -xvf flexpart_v10.4.tar.gz -C ../; mv flexpart_v10.4.tar.gz tmp;
cd ../flexpart_v10.4/src

# change ROOT_DIR path in flexpart, provide a path where you install flexpart, by default: /home/ubuntu/flexpart_lib

sed -i 's#/homevip/flexpart#/home/ubuntu/flexpart_lib#g' makefile
sed -i 's#/gcc-5.4.0/include#/include#g' makefile
sed -i 's#/gcc-5.4.0/lib#/lib#g' makefile

# uncomment if you want to work with the larger grid 0.5 degree, 1 degree by default
# sed -i 's/nxmax=361,nymax=181,nuvzmax=138,nwzmax=138,nzmax=138/nxmax=1441,nymax=721,nuvzmax=128,nwzmax=128,nzmax=128/g' par_mod.f90

# ncf=yes - to activate NetCDF support
make -j serial ncf=yes
# make mpi ncf=yes -f makefile
# to use NCF change IOUT parameter to IOUT=9 inside file options/COMMOND

cd $DIR
echo "flexpart installed" >> installation.log

# setup workdir with template folder and basic configuration and downloads_grib script (the same as template folder in this repo)

cd ../
mkdir workdir; cd workdir
cd $DIR
tar -xvf template.tar.gz -C ../workdir ; mv template.tar.gz tmp;
cd ../workdir/template
# create symbolic link to compiled flexpart
ln ../../flexpart_v10.4/src/FLEXPART

echo "please do not change any file inside template folder, there are the initial settings"
echo "copy template folder to any other with the name of your calculation, for example ukraine:"
echo "cp -r template/ ukraine/"
echo "All unzipped files are located in tmp folder, you can remove them if flexpart works"
