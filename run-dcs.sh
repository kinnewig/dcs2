SOURCE_DIR=</path/to/>dcs2

source /home/ifam/kinnewig/.bashrc

./dcs.sh -p </path/to/>dcs-aocl --cmake-flags \
  "-D AOCL-UTILS_SOURCE_DIR=${SOURCE_DIR}/dcs2/source/aocl-utils-4.2.tar.gz \
   -D BLIS_SOURCE_DIR=${SOURCE_DIR}/dcs2/source/aocl-blas-4.2.tar.gz \ 
   -D DEALII_SOURCE_DIR=${SOURCE_DIR}/dcs2/source/dealii \
   -D GMP_SOURCE_DIR=${SOURCE_DIR}/dcs2/source/gmp-6.2.1.tar.gz \
   -D GMSH_SOURCE_DIR=${SOURCE_DIR}/dcs2/source/gmsh-4.12.2.tar.gz \
   -D LIBFLAME_SOURCE_DIR=${SOURCE_DIR}/dcs2/source/aocl-libflame-4.0.tar.gz \
   -D MPFR_SOURCE_DIR=${SOURCE_DIR}/dcs2/source/mpfr-4.2.1.tar.gz \
   -D MUMPS_SOURCE_DIR=${SOURCE_DIR}/dcs2/source/mumps \
   -D P4EST_SOURCE_DIR=${SOURCE_DIR}/dcs2/source/p4est \
   -D LIBSC_SOURCE_DIR=${SOURCE_DIR}/dcs2/source/libsc-2.8.6.tar.gz \
   -D SCALAPACK_SOURCE_DIR=${SOURCE_DIR}/dcs2/source/scalapack \
   -D SUITESPARSE_SOURCE_DIR=${SOURCE_DIR}/dcs2/source/SuiteSparse-7.7.0 \
   -D TRILINOS_SOURCE_DIR=${SOURCE_DIR}/dcs2/source/Trilinos \
   -D AMD:BOOL=ON"
