# DCS - Deal.II CMake Superbuild

DCS simplifies the process of building and installing the **deal.II** library along with various third-party dependencies.


## Options

### deal.II Itself
- `DEALII_VERSION`: Specify the deal.II version (default: "master")
- `DEALII_CUSTOM_URL`: If defined, this variable allows you to specify a custom Git URL for deal.II. You can use this to point to a different repository or a specific fork.
- `DEALII_CUSTOM_TAG`: If defined, this variable sets a custom Git tag (commit hash, branch, or release) for deal.II. Use this to select a specific version or snapshot.
- `DEALII_WITH_64BIT`: Build deal.II with 64bit indice support (default: OFF)
- `DEALII_WITH_COMPLEX`: Build deal.II with complex number support (default: OFF)

### Third-Party Libraries

- `-D TPL_ENABLE_<PACKAGE>:BOOL=ON`: Activate third-party librarie.
- `-D <PACKAGE>_VERSION=x.x.x`: Specify the version to install. 
- `<PACKAGE>_DIR=</path.to/folder>`: Provide the path to include already installed libraries.
- `<PACKAGE>_CUSTOM_URL`: If defined, this variable allows you to specify a custom Git URL for <PACKAGE>. You can use this to point to a different repository or a specific fork.
- `<PACKAGE>_CUSTOM_TAG`: If defined, this variable sets a custom Git tag (commit hash, branch, or release) for <PACKAGE>. Use this to select a specific version or snapshot.

### Available Third-Party Libraries
#### BOOST
- `BOOST_DIR`: If Boost is installed on a custom path, the path has to be provided, otherwise deal.II will not find BOOST.

#### (FLAME) BLIS
- `TPL_ENABLE_BLIS`: Enable or disable BLIS (default: OFF)
- `BLIS_VERSION`: Specify the BLIS version (default: "0.9.0")

#### (FLAME) LIBFLAME
- `TPL_ENABLE_LIBFLAME`: Enable or disable LIBFLAME (as LAPACK) (default: OFF)
- `LIBFLAME_VERSION`: Specify the LIBFLAME version (default: "5.2.0")

#### ScaLAPACK
- `TPL_ENABLE_SCALAPACK`: Enable or disable ScaLAPACK (default: ON)
- `SCALAPACK_VERSION`: Specify the ScaLAPACK version (default: "2.2.1")

#### MUMPS
- `TPL_ENABLE_MUMPS`: Enable or disable MUMPS (default: ON)
- `MUMPS_VERSION`: Specify the MUMPS version (default: "5.6.2")

#### SuiteSparse
- `TPL_ENABLE_SUITESPARSE`: Enable or disable SuiteSparse (default: ON)
- `SUITESPARSE_VERSION`: Specify the SuiteSparse version (default: "5.6.2")

##### MPFR (Dependencie for Suitesparse)
- `TPL_ENABLE_MPFR`: Enable or disable MPFR (default: ON)
- `MPFR_VERSION`: Specify the MPFR version (default: "4.2.1")

##### GMP (Dependencie for Suitesparse)
- `TPL_ENABLE_GMP`: Enable or disable MPFR (default: ON)
- `GMP_VERSION`: Specify the GMP version (default: "6.2.1")

#### P4EST
- `TPL_ENABLE_P4EST`: Enable or disable P4EST (default: ON)
- `P4EST_VERSION`: Specify the P4EST version (default: "2.8.5")

#### Trilinos
- `TPL_ENABLE_TRILINOS`: Enable or disable Trilinos (default: ON)
- `TRILINOS_VERSION`: Specify the Trilinos version (default: "15.1.0")


## Usage

To use DCS, follow these steps:

1. Clone this repository:
   ```bash
   git clone https://github.com/kinnewig/dcs2.git
   ```

2. Create a new build directory:
   ```bash
   cd dcs2
   ./dcs -p <path/to/install> -j <Number of threads>
   ```
