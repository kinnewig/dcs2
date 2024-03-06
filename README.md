# DCS - Deal.II CMake Superbuild

DCS simplifies the process of building and installing the **deal.II** library along with various third-party dependencies.

## Options

### Third-Party Libraries

Activate third-party libraries using the following format:
```bash
-D TPL_ENABLE_<PACKAGE>:BOOL=ON
```

Specify the version to install with `-D <PACKAGE>_VERSION=x.x.x`.
To include already installed libraries, provide the path via `<PACKAGE>_DIR=</path.to/folder>`.

#### BLIS
- `TPL_ENABLE_BLIS`: Enable or disable LAPACK as a third-party library (default: OFF)
- `BLIS_VERSION`: Specify the BLIS version (default: "0.9.0")

#### ScaLAPACK
- `TPL_ENABLE_SCALAPACK`: Enable or disable ScaLAPACK (default: ON)
- `SCALAPACK_VERSION`: Specify the ScaLAPACK version (default: "2.2.1")

#### MUMPS
- `TPL_ENABLE_MUMPS`: Enable or disable MUMPS (default: ON)
- `MUMPS_VERSION`: Specify the MUMPS version (default: "5.6.2")

#### P4EST
- `TPL_ENABLE_P4EST`: Enable or disable P4EST (default: ON)
- `P4EST_VERSION`: Specify the P4EST version (default: "2.8.5")

#### Trilinos
- `TPL_ENABLE_TRILINOS`: Enable or disable Trilinos (default: ON)
- `TRILINOS_VERSION`: Specify the Trilinos version (default: "15.1.0")
- `TRILINOS_WITH_COMPLEX`: Build deal.II with complex number support (default: OFF)

### deal.II Itself
- `DEALII_VERSION`: Specify the deal.II version (default: "master")
- `DEALII_CUSTOM_URL`: If defined, this variable allows you to specify a custom Git URL for deal.II. You can use this to point to a different repository or a specific fork.
- `DEALII_CUSTOM_TAG`: If defined, this variable sets a custom Git tag (commit hash, branch, or release) for deal.II. Use this to select a specific version or snapshot.

## Usage

To use DCS, follow these steps:

1. Clone this repository:
   ```bash
   git clone https://github.com/kinnewig/dcs2.git
   ```

2. Create a new build directory:
   ```bash
   cd dcs2
   cmake -S . -B </path/to/build> -D CMAKE_INSTALL_PREFIX=<path/to/install>
   ```
