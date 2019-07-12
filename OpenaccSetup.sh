#!/bin/sh

#
# Build GCC with support for offloading to NVIDIA GPUs.
#

#fix PATH
export PATH=$(echo $PATH | sed -e "s,/usr/local/bin:,,"):/usr/local/bin

dest_dir=""
work_dir="$PWD/wrk"
prefix_dir="$PWD/install"

# Location of the installed CUDA toolkit
cuda=/usr/local/cuda

echo "OpenACC build script for NVIDIA GPUs patched to suport sm_20 (Fermi GPUs)"


if [ "$1" == "--help" ] ; then
	echo " Usage:"
	echo "  $0 --help for help"
	echo "  $0 --pull to pull from git and force install"
	echo "  $0 --forcemake to force make files an install"
	echo "  $0 --forceinstall"
	echo "  $0 --makeporteusxzm"
	echo "  $0 --makeslackware"
	echo "  $0 --makebinrelease"
	exit 0
fi

if [ $1 == "--makeporteusxzm" -o $1 == "--makeslackware" -o $1 == "--makebinrelease"  ] ; then
	dest_dir="$PWD/package"
	work_dir="$PWD/wrk"
	prefix_dir="/usr"
	rm -fr $work_dir/build-* 
	echo " Building package to $dest_dir$prefix_dir"
fi

echo " Checking cuda dir $cuda"
if [ -e $cuda ] ; then
	echo "ok."
else
	echo "Cuda dir not found, please fix cuda dir."
	exit -1
fi

echo " 	Installed gcc version:"
gcc -v

echo
echo "Ctrl-c to stop (continuing in 5 secs)"
sleep 5

mkdir -p $work_dir
cd $work_dir

echo " Downloading Patched Sources..."

if [ ! -e nvptx-tools ] ; then
	git clone https://github.com/RodrigoOt/nvptx-tools
elif [ "$1" == "--pull" ] then
	cd nvptx-tools 
	git pull
 	cd ..	
fi
if [ ! -e nvptx-newlib ] ; then
	git clone https://github.com/RodrigoOt/nvptx-newlib
elif [ "$1" == "--pull" ] then
	cd nvptx-newlib
	git pull
 	cd ..	
fi
if [ ! -e gcc-9.1.0 ] ; then
	git clone https://github.com/RodrigoOt/gcc-9.1.0
elif [ "$1" == "--pull" ] then
	cd gcc-9.1.0 
	git pull
 	cd ..	
fi

echo  10 seconds to continue
sleep 10

echo "  Building: "

if [ ! -e build-nvptx-tools/config.cache ] ; then
	mkdir build-nvptx-tools
	cd build-nvptx-tools
	../nvptx-tools/configure \
	    --with-cuda-driver-include=$cuda/include \
	    --with-cuda-driver-lib=$cuda/lib64 \
	    --prefix=$prefix_dir
	make
	make install DESTDIR=${dest_dir}
	cd ..
elif [ "$1" == "--forceinstall" -o "$1" == "--pull"] ;then
	cd build-nvptx-tools
	make install DESTDIR=${dest_dir}
	cd ..
else
	echo Continuing...
fi

if [ -e gcc-9.1.0 ] ; then
	echo  Set up the GCC source tree
	cd gcc-9.1.0
	if [ ! -e gmp-4.3.2.tar.bz2  ] ; then
		./contrib/download_prerequisites
	fi
	ln -s ../nvptx-newlib/newlib newlib
	cd ..
fi

target=$(gcc-9.1.0/config.guess)

if [ ! -e build-nvptx-gcc ] ; then
	mkdir build-nvptx-gcc
	cd build-nvptx-gcc
	../gcc-9.1.0/configure \
	    --target=nvptx-none --with-build-time-tools=${dest_dir}/$prefix_dir/nvptx-none/bin \
	    --enable-as-accelerator-for=$target \
	    --disable-sjlj-exceptions \
	    --enable-newlib-io-long-long \
	    --enable-languages="c,c++,lto" \
	    --prefix=$prefix_dir
	make -j4
	make install DESTDIR=${dest_dir}
	cd ..
fi
if [ -e build-nvptx-gcc -a "$1" == "--forcemake" ] ; then
	echo Make Forced in build-nvptx-gcc
	cd build-nvptx-gcc
	make -j4
	make install DESTDIR=${dest_dir}
	cd ..
elif [ "$1" == "--forceinstall" -o "$1" == "--pull"] ;then
	cd build-nvptx-gcc
	make install DESTDIR=${dest_dir}
	cd ..
fi

if [ ! -e build-host-gcc ] ; then
	mkdir build-host-gcc
	cd  build-host-gcc
	../gcc-9.1.0/configure \
	    --enable-offload-targets=nvptx-none \
	    --with-cuda-driver-include=$cuda/include \
	    --with-cuda-driver-lib=$cuda/lib64 \
	    --disable-libstdcxx \
	    --disable-bootstrap \
	    --disable-multilib \
	    --enable-languages="c,c++,lto" \
	    --prefix=$prefix_dir
	make -j4
	make install DESTDIR=${dest_dir}
	cd ..
fi
if [ -e build-host-gcc -a "$1" == "--forcemake" ] ; then
	echo Make Forced in build-host-gcc
	cd  build-host-gcc
	make -j4
	make install DESTDIR=${dest_dir}
	cd ..
elif [ "$1" == "--forceinstall" -o "$1" == "--pull"] ;then
	cd  build-host-gcc
	make install DESTDIR=${dest_dir}
	cd ..
fi

cd ..


if [ $1 == "--makeporteusxzm" ] ; then
	dir2xzm package Gcc-9.1.0-nvptx-x86_64.xzm
fi
if [ $1 == "--makeslackware" ] ; then
	cp slackware/* package
	dir2txz package gcc-9.1.0-nvptx-x86_64.tar.gz
fi
if [ $1 == "--makebinrelease"  ] ; then
	cd package
	tar xzvf ../gcc-9.1.0-nvptx-x86_64.tar.gz *
	cd ..
fi



