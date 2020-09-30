# flexpart

FLEXPART (“FLEXible PARTicle dispersion model”) is a Lagrangian transport and dispersion model suitable for the simulation of a large range of atmospheric
transport processes. Apart from transport and turbulent diffusion, it is able to simulate dry and wet deposition, decay, linear chemistry;  
it can be used in forward or backward mode, with defined sources or in a domain-filling setting. It can be used from local to global scale.

## System requirements

FLEXPART is developed using gfortran.

```bash 
sudo apt-get update
sudo apt-get install g++ gfortran

# Some other libraries and tools

sudo apt-get install autoconf libtool automake flex bison
sudo apt-get install cmake
sudo apt-get install python-dev python-pip git-core vim
```

## Installation guide

### jasper

IF JPG compression is needed to decode the input meteorological winds

```bash
curl https://www.ece.uvic.ca/~frodo/jasper/software/jasper-1.900.1.zip --output jasper-1.900.1.zip
mkdir ~/lib/
cp jasper-1.900.1.zip ~/lib
cd %HOME%/lib
unzip %JASPER%.zip
cd %JASPER%
./configure --prefix=~/lib/jasper

# указывает где будет установлена библиотека, нам она нужна будет для линковки

make
make check
sudo make install
```

После установки появится новая папка lib/jasper

### grib_api

```bash
mkdir ~/lib/src/
 cp %GRIB%.tar.gz ~/lib/
 cp %GRIB%.tar.gz ~/lib/src/
 cd ~/lib/src/
 tar -xvf %GRIB%.tar.gz
./configure --prefix=~/lib/grib_api --with-jasper=~/lib/jasper --disable-shared

make
make check
sudo make install
```
После установки появится новая папка lib/grib-api

At the end of the command execution you will see:

Libraries have been installed in:
   /home/roman/lib//grib_api/lib

If you ever happen to want to link against installed libraries
in a given directory, LIBDIR, you must either use libtool, and
specify the full pathname of the library, or use the `-LLIBDIR'
flag during linking and do at least one of the following:
   - add LIBDIR to the `LD_LIBRARY_PATH' environment variable
     during execution
   - add LIBDIR to the `LD_RUN_PATH' environment variable
     during linking
   - use the `-Wl,-rpath -Wl,LIBDIR' linker flag
   - have your system administrator add LIBDIR to `/etc/ld.so.conf'

Add the following lines to the .bashrc-file of your home directory:

```bash
 edit ~/.bashrc # (e.g. vi or emacs)
 export GRIB_API_BIN=“/%HOME/lib/%GRIB%/bin“
 export GRIB_API_LIB=“/%HOME/lib/%GRIB%/lib“
 export GRIB_API_INCLUDE=“/%HOME/lib/%GRIB%/include“
 export PATH=$GRIB_API_BIN:$PATH
 export JASPER=$DIR/jasper-1.900.1
 export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$JASPER/lib
```

Testing whether Grib-API installation has been successful: read out Grib-file:
`grib_ls %FILENAME% with extension grib

[Link to grib examples](http://download.ecmwf.org/test-data/grib_api/grib_api_test_data.tar.gz)

### emos (optional, for future versions)

### flexpart

```bash
tar -xvf flexpart10.4.tar.gz
cp makefile.%(version)% makefile
vim makefile # (e.g. vi or emacs)
```

Edit the library path variable in the makefile according to the position of libeccodes (or libgrib_api) and libjasper. Change lines to:

```bash
INCPATH=/lib/%GRIB%/include
LIBPATH1=/lib/%GRIB%/lib
LIBPATH2=/lib/%JASPER%/lib
```
