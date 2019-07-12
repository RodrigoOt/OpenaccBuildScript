#!/bin/sh

install_dir=$PWD/install

export PATH=$install_dir/bin:$PATH
export LD_LIBRARY_PATH=$install_dir/lib64:$LD_LIBRARY_PATH

export ACC_DEVICE_TYPE=NVIDIA
export ACC_DEVICE_NUM=0

export GOMP_DEBUG=1
export GOMP_OPENACC_DIM=16:16:32

export OpenAcc="OpenACC" 

clear
echo Start coding with openACC

if [ ! -e "$PWD/.bash_history" ] ; then 
	touch .bash_history
fi

bash --init-file .bashrc


