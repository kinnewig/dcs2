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

#### Dependencies:
- `MPFR` (default version: "4.2.1")
- `GMP` (default version: "6.2.1")

#### BLAS/LAPACK Packages
- `FLAME`: i.e.: `BLIS` (default version: "0.9.0") and `LIBFLAME` (default version: "5.2.0")
- `ScaLAPACK` (default version: "2.2.1")

#### Direct Solver
- `MUMPS` (default version: "5.6.2")
- `SUITESPARSE` (default version: "5.6.2")

#### Graph partitioning
- `P4EST` (default version: "2.8.5")

#### Algebra Packages
- `TRILINOS` (default version: "15.1.0")


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
