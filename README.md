# OpenaccBuildScript

usage :

git clone https://github.com/RodrigoOt/OpenaccBuildScript.git

cd OpenaccBuildScript

./OpenaccSetup.sh 

#Wait a lot :P

./StartWorking.sh


Build package:

./OpenaccSetup.sh --makebinrelease

Help:

.OpenaccSetup.sh --help

Testing:

StartWorking.sh

cd example

gcc -fopenacc -foffload="-misa=sm_20 -O2" calcpi.c -o calcpi && time ./calcpi


References:

https://www.openmp.org/  and  https://www.openacc.org/

https://gcc.gcc.gnu.narkive.com/W93in4yj/how-to-use-old-gpu-fermi-in-gcc-with-openacc
https://kristerw.blogspot.com/2017/04/building-gcc-with-support-for-nvidia.html
https://gist.github.com/matthiasdiener/e318e7ed8815872e9d29feb3b9c8413f
https://github.com/tschwinge/gcc-playground/tree/big-offload/openacc-gcc-8-branch/master

https://www.hahnjo.de/blog/2018/10/08/clang-7.0-openmp-offloading-nvidia.html
