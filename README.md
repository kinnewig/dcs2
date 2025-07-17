# DCS2 - Deal.II CMake Superbuild 2
```bash
===================================================
                     _  __ ____ 
                    | \/  (_  _)
                    |_/\____)/__

===================================================
        deal.II CMake Superbuild Script 2
```


DCS2 simplifies the process of building and installing the **deal.II** library along with various third-party dependencies.

![Fedora 42](https://github.com/kinnewig/dcs2/actions/workflows/fedora-42.yml/badge.svg)

![Rocky 10](https://github.com/kinnewig/dcs2/actions/workflows/rocky-10.yml/badge.svg)

![Ubuntu 25.04](https://github.com/kinnewig/dcs2/actions/workflows/ubuntu-25.04.yml/badge.svg)

## Quick start

To use DCS2, follow these steps:
1. Install the Requirements (see next section).

2. Clone this repository:
   ```bash
   git clone https://github.com/kinnewig/dcs2.git
   ```

3. Start the install script
   ```bash
   cd dcs2
   ./dcs2 -p <path/to/install> -j <Number of threads>
   ```
or if you want to install for exampe your own fork of deal.II
   ```bash
   cd dcs2
   ./dcs2 -p <path/to/install> -j <Number of threads> --cmake-flags "DEALII_CUSTOM_URL=https://github.com/<username>/dealii.git -D DEALII_CUSTOM_TAG=<Your Branch Name>" 
   ```

## Requirements
DCS2 requires a modern MPI compiler, and a few additional programs that are not build by DCS2 itself.

### Fedora/Rocky/Redhat
Install the dependencies
```bash
 sudo dnf install @development-tools openmpi-devel boost-devel gcc-c++ git 
```
To enable openmpi by default add the following lines to the ~/.bashrc
```bash
source /etc/profile.d/modules.sh
module load mpi/openmpi-x86_64
```

### Ubuntu/Debian
Install the dependencies
```bash
sudo apt install build-essential libopenmpi-dev libboost-all-dev gfortran  git texinfo libssl-dev 
```

## DCS2 Options

Usage: 
```bash
./dcs2.sh [options] [--blas-stack=<blas option>] [--cmake-flags="<CMake Options>"]
```

| Short Option     | Long Option                     | Description                                                  |
|------------------|---------------------------------|---------------------------------------------------------------
| `-h`             | `--help`                        | Print the help message                                       |
| `-p <path>`      | `--prefix=<path>`               | Set a different prefix path                                  |
| `-b <path>`      | `--build=<path>`                | Set a different build path                                   |
| `-d <path>`      | `--bin-dir=<path>`              | Set a different binary path                                  |
| `-l <path>`      | `--lib-dir=<path>`              | Set a different library path                                 |
| `-j <threads>`   | `--parallel=<threads>`          | Set number of threads to use                                 |
| `-A <ON\|OFF>`   | `--add_to_path=<ON\|OFF>`       | Enable or disable adding deal.II permanently to the path     |
| `-N <ON\|OFF>`   | `--ninja=<ON\|OFF>`             | Enable or disable the use of Ninja                           |
| `-M <ON\|OFF>`   | `--mold=<ON\|OFF>`              | Enable or disable the use of mold                            |
| `-U`             |                                 | Do not interrupt                                             |
| `-v`             | `--version`                     | Print the version number                                     |
|                  | `--blas-stack=<blas option>`    | Select which BLAS to use (default|AMD)                       |
|                  | `--cmake-flags=<CMake Options>` | Specify additional CMake Options, see below                  |


### Blas Options
One specilty of DCS2 is, that it can build deal.II and the TPL packages with different Blas backends.

#### System
If you want to install DEALII using the system-provided BLAS stack, please use the following flag
```bash
--blas-stack=system
```

The most straightforward method for installing DEALII is to rely on the BLAS, LAPACK, and ScaLAPACK libraries, which are typically provided by the system repositories. 

You need to install the developer packages of the following packages `openblas` `lapack` `scalapack`.
In the case of Fedora/Rocky/Redhat this boils down to `sudo dnf install openblas-devel lapack-devel scalapack-openmpi-devel`


#### AMD AOCL 
AMD AOCL provides hardware acceleration for AMD Zen CPUs, to select this Blas stack use
```bash
--blas-stack=AMD
```

To use the AOCL stack the AOCC compilier is required. Due to licensing, the AOCC compiler cannot be downloaded automatically.
Download [aocc-compiler-5.0.0.tar](https://www.amd.com/de/developer/aocc/eula/aocc-5-0-eula.html?filename=aocc-compiler-5.0.0.tar) and place it in the DCS2 root directory. DCS2 will attempt to install it automatically from there.

Alternatively, visit: https://www.amd.com/de/developer/aocc.html download the latest version, and install it manually.

### Installation Tools 
DCS2 provides a list of installation tools.

#### CMake 
- CMake is a hard dependency for DCS2; therefore, if no CMake version is detected, CMake is automatically downloaded and installed.

#### Linker: Mold 
- `-M|--mold` with the options `ON|OFF|DOWNLOAD`

#### Ninja
- `-N|--ninja` with the options `ON|OFF`


## CMake Options

### deal.II Itself
- `DEALII_VERSION`: Specify the deal.II version (default: "master")
- `DEALII_CUSTOM_URL`: If defined, this variable allows you to specify a custom Git URL for deal.II. You can use this to point to a different repository or a specific fork.
- `DEALII_CUSTOM_TAG`: If defined, this variable sets a custom Git tag (commit hash, branch, or release) for deal.II. Use this to select a specific version or snapshot.
- `DEALII_CUSTOM_NAME`: If defined, this variable sets a custom for the deal.II install folder (by default the version is used as name for the folder).
- `DEALII_WITH_64BIT`: Build deal.II with 64bit indice support (default: OFF)
- `DEALII_WITH_COMPLEX`: Build deal.II with complex number support (default: OFF)

#### Developing
For deal.II and any TPL a custom path can be provided via `-D <PACKAGE>_SOURCE_DIR`. The custom path can either be a local folder containing the package, an archive or an URL.
This feature is meant for development (e.g. you can provide your local deal.II folder, which is handy if you are working on deal.II itself), or it can be used to install deal.II and it dependecies on computers/servers without direct internet access.

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

#### Grid generation
- `GMSH` (default version: "4.12.2", default "OFF")
#### Dependencies:
   Only testes on Fedora 40/41/42 and Rocky 9, requires the following dependencies `dnf install fltk fltk-devel mesa-libGLU-devel mesa-libGL-devel`.

- `OCCT` OpenCascade (default version: "7.8.1", default "OFF")
#### Dependencies:
- `TCL` (default version: "8.6.15", default "OFF")
- `TK` (default version: "8.6.15", default "OFF")

#### Algebra Packages
- `PETSC` (default version: "3.23.3")

- `TRILINOS` (default version: "16.1.0")

#### Miscellaneous
- `TBB` Intel One Thread Building Blocks (default version: "2021.13.0")
- `VTK` (default version: "9.3.1", default "OFF")


## Troubleshooting
### The build of deal.II fails
deal.II requires 8GB of RAM per thread during the build process. If your build fails lower the number of threads to use (e.g. -j 2 when your system has 16GB of RAM).

## Acknowledgements 

DCS2 is originally based on [dealii-cmake-superbuild](https://github.com/jpthiele/dealii-cmake-superbuild) and [candi](https://github.com/dealii/candi).
