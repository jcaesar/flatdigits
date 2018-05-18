set -e -u

# prepare to configure options in Makefile.config
cp -f Makefile.config.example Makefile.config

# enable cuDNN acceleration switch
sed -i '/USE_CUDNN/s/^#[[:space:]]//g' Makefile.config

# enable NCCL acceleration switch
# sed -i '/USE_NCCL/s/^#[[:space:]]//g' Makefile.config

# strictly enable I/O dependencies
sed -i '/USE_OPENCV/s/^#[[:space:]]//;/USE_OPENCV/s/0/1/'   Makefile.config
sed -i '/USE_LEVELDB/s/^#[[:space:]]//;/USE_LEVELDB/s/0/1/' Makefile.config
sed -i '/USE_LMDB/s/^#[[:space:]]//;/USE_LMDB/s/0/1/'       Makefile.config
sed -i '/OPENCV_VERSION/s/^#[[:space:]]//g'                 Makefile.config

# use gcc6 (CUDA 9.0 code requires gcc6)
#sed -i '/CUSTOM_CXX/s/^#[[:space:]]//;/CUSTOM_CXX/s/$/-6/' Makefile.config
# we already have gcc6, but it's not symlinked to that name

# set CUDA directory
sed -i '/CUDA_DIR/ s#/usr/local/cuda#/app#' Makefile.config

# remove gpu architectures not supported by CUDA 9.0
sed -i 's/-gencode[[:space:]]arch=compute_20,code=sm_20//' Makefile.config
sed -i 's/-gencode[[:space:]]arch=compute_20,code=sm_21//' Makefile.config

# set OpenBLAS as the BLAS provider and adjust its directories
sed -i '/BLAS[[:space:]]\:=[[:space:]]atlas/s/atlas/open/'                                 Makefile.config
sed -i 's/.*BLAS_INCLUDE[[:space:]]\:=[[:space:]]\/path.*/BLAS_INCLUDE := \/usr\/include/' Makefile.config
sed -i 's/.*BLAS_LIB[[:space:]]\:=[[:space:]]\/path.*/BLAS_LIB := \/usr\/lib/'             Makefile.config

# python3 settings
_py2inc_line="$(sed -n '/PYTHON_INCLUDE[[:space:]]\:=[[:space:]]\/usr\/include\/python2\.7/='  Makefile.config)"
_py3inc_line="$(sed -n '/PYTHON_INCLUDE[[:space:]]\:=[[:space:]]\/usr\/include\/python3\.5m/=' Makefile.config)"
_py3libs_line="$(sed -n '/PYTHON_LIBRARIES/=' Makefile.config)"
sed -i "$((_py2inc_line))s/^/# /"  Makefile.config # comment python2 lines
sed -i "$((_py2inc_line+1))s/^/#/" Makefile.config
sed -i "$((_py3inc_line))s/^#[[:space:]]//"   Makefile.config # uncomment python3 PYTHON_INCLUDE lines
sed -i "$((_py3inc_line+1))s/^#//"            Makefile.config
sed -i "$((_py3libs_line))s/^#[[:space:]]//"  Makefile.config # uncomment PYTHON_LIBRARIES line
sed -i "$((_py3libs_line))s/5/6/"             Makefile.config # change version in PYTHON_LIBRARIES
sed -i "$((_py3inc_line))s/5/6/"              Makefile.config # change version in python3 PYTHON_INCLUDE
sed -i "$((_py3inc_line+1))s/5/6/;$((_py3inc_line+1))s/dist/site/" Makefile.config

# use python layers
sed -i '/WITH_PYTHON_LAYER/s/^#[[:space:]]//g' Makefile.config
