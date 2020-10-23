### netCDF (хранилище данных) v4.6.1

NetCDF (network Common Data Form) – это двоичный формат файлов, предназначенный для создания, доступа и публикации научных данных. Он широко используется специалистами метеорологами и океанографами для хранения переменных, как, например, данных о температуре, давлении, скорости ветра и высоте волн.

Данные в файле netCDF хранятся в форме массивов. Например, температура, меняющаяся со временем, хранится в виде одномерного массива. Температура на площади за указанное время хранится в виде двухмерного массива.

Трехмерные данные, например, температура на площади, изменяющаяся со временем, или четырехмерные данные, как то: температура на площади, меняющаяся во времени и с изменением высоты, хранятся в последовательностях двухмерных массивов.

### netCDF requires another library to be installed

For building the NetCDF library it is recommended to first build HDF5 with support for compression (zlib).

### zlib

```bash
tar -xzvf zlib-1.2.8.tar.gz
cd zlib-1.2.8/
./configure [--prefix=<installation path>]
make
make install
```

### hdf5

High-performance data management and storage suite  
Utilize the HDF5 high performance data software library and file format to manage, process, and store your heterogeneous data. HDF5 is built for fast I/O processing and storage.

```bash
tar -xzvf hdf5-1.8.17.tar.gz
cd hdf5-1.8.17/
./configure --with-zlib=<path to zlib>
 [--prefix=<installation path>]
make
make check
make install
```

```bash
wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.6.1.tar.gz
tar -zxvf netcdf-4.6.1.tar.gz
cd netcdf-4.6.1/

wget 'http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD' -O config.guess

wget 'http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD' -O config.sub

./configure --prefix=/disk2/hyf/netcdf-4.6.1 CPPFLAGS="-I/disk2/hyf/lib/hdf5/include -I/diks2/hyf/lib/grib2/include -O3" LDFLAGS="-L/disk2/hyf/lib/hdf5/lib -L/diks2/hyf/lib/grib2/lib" --enable-shared --enable-netcdf-4  --disable-dap --disable-doxygen

# on the ik@meteodell
./configure --prefix=/home/ik/Roman/lib/netcdf CPPFLAGS="-I/home/ik/Roman/lib/hdf5/include -I/home/ik/Roman/lib/zlib/include -O3" LDFLAGS="-L/home/ik/Roman/lib/hdf5/lib -L/home/ik/Roman/lib/zlib/lib" --enable-shared --enable-netcdf-4 --disable-dap --disable-doxygen

./configure --prefix=/home/ik/Roman/lib/netcdf4 CPPFLAGS="-I/home/ik/Roman/lib/hdf5/include -O3" LDFLAGS="-L/home/ik/Roman/lib/hdf5/lib" --enable-shared --enable-netcdf-4
```

 Some influential environment variables:
   CC          C compiler command
   CFLAGS      C compiler flags
   LDFLAGS     linker flags, e.g. -L<lib dir> if you have libraries in a
               nonstandard directory <lib dir>
   LIBS        libraries to pass to the linker, e.g. -l<library>
   CPPFLAGS    (Objective) C/C++ preprocessor flags, e.g. -I<include dir> if
               you have headers in a nonstandard directory <include dir>
   LT_SYS_LIBRARY_PATH
               User-defined run-time library search path.
   CPP         C preprocessor

You should see the output like this:

```text
/# Features
--------
NetCDF-2 API:		yes
HDF4 Support:		no
NetCDF-4 API:		yes
```

Then try to compile:

```bash
make

# you should see
+-------------------------------------------------------------+
| Congratulations! You have successfully installed netCDF!    |
|                                                             |
| You can use script "nc-config" to find out the relevant     |
| compiler options to build your application. Enter           |
|                                                             |
|     nc-config --help                                        |
|                                                             |
| for additional information.                                 |
|                                                             |
| CAUTION:                                                    |
|                                                             |
| If you have not already run "make check", then we strongly  |
| recommend you do so. It does not take very long.            |
|                                                             |
| Before using netCDF to store important data, test your      |
| build with "make check".                                    |
|                                                             |
| NetCDF is tested nightly on many platforms at Unidata       |
| but your platform is probably different in some ways.       |
|                                                             |
| If any tests fail, please see the netCDF web site:          |
| http://www.unidata.ucar.edu/software/netcdf/                |
|                                                             |
| NetCDF is developed and maintained at the Unidata Program   |
| Center. Unidata provides a broad array of data and software |
| tools for use in geoscience education and research.         |
| http://www.unidata.ucar.edu                                 |
+-------------------------------------------------------------+

# then run all tests

make check



make install

# FAIL: nc_test

*** testing nc_get_att_text ... 
        FAILURE at line 10854 of test_get.c: value read not that expected
        ### 1 FAILURES TESTING nc_get_att_text! ###

*** testing nc_get_att ... 
        FAILURE at line 1689 of test_read.c: buf read not that expected
        ### 1 FAILURES TESTING nc_get_att! ###

*** testing nc_put_att ... 
        FAILURE at line 1081 of util.c: nc_get_att_text: unexpected value
 33 good comparisons. 
        ### 1 FAILURES TESTING nc_put_att! ###
*** testing nc_copy_att ...  34 good comparisons. ok
*** testing nc_rename_att ... 
        FAILURE at line 1859 of test_write.c: get_att_text: unexpected value
        ### 1 FAILURES TESTING nc_rename_att! ###


vi~/.bashrc
export PATH="$DIR/netcdf-4.6.1/bin:$PATH"
export NETCDF=$DIR/netcdf-4.6.1
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$NETCDF/lib
export CFLAGS="-L$HDF5/lib -I$HDF5/include -L$NETCDF/lib -I$NETCDF/include"
export CXXFLAGS="-L$HDF5/lib -I$HDF5/include -L$NETCDF/lib -I$NETCDF/include"
export FCFLAGS="-L$HDF5/lib -I$HDF5/include -L$NETCDF/lib -I$NETCDF/include"
export CPPFLAGS="-I${HDF5}/include -I${NETCDF}/include"
export LDFLAGS="-L${HDF5}/lib -L${NETCDF}/lib"
source ~/.bashrc
```
