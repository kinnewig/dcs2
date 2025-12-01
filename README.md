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

## One-Step Automated Install
Those who want to get started quickly and conveniently may use dcs2 via the following command:
```bash
mkdir -p /tmp/dcs2 && wget -O /tmp/dcs2/dcs2.sh https://raw.githubusercontent.com/kinnewig/dcs2/refs/heads/main/scripts/dcs2-one-line-install.sh && bash /tmp/dcs2/dcs2.sh
```

## Alternative Install Methods
Directly downloading and running code from the internet comes with some danger, as it prevents you from checking what's going on. Here is a good read on that topic [piping to bash](https://pi-hole.net/blog/2016/07/25/curling-and-piping-to-bash/#page-content).
Therefore, here are some alternative installation methods which allow code review before installation:

### Method 1: Manually download the installer and run
Instead of doing it all in one step, download the script first, check what it is doing, and then run it.
```bash
wget -O dcs2.sh https://raw.githubusercontent.com/kinnewig/dcs2/refs/heads/main/scripts/dcs2-one-line-install.sh 
# Check what dcs2.sh is doing.
bash dcs2.sh
```

### Method 2: Clone the repository (recommended)
To use DCS2, follow these steps:
1. Install the Requirements (see next section).

2. Clone this repository:
   ```bash
   git clone https://github.com/kinnewig/dcs2.git
   cd dcs2
   ```

3. (Optional) Select the deal.II Version
   ```bash
   python3 scripts/select_version.py
   ```

4. (Optional) Package selection
   ```bash
   python3 scripts/select_packages.py
   ```

5. Start the install script
   ```bash
   ./dcs2 -p <path/to/install> -j <Number of threads> 
   ```
or if you want to install for exampe your own fork of deal.II
   ```bash
   cd dcs2
   ./dcs2 -p <path/to/install> -j <Number of threads> --cmake-flags "DEALII_CUSTOM_URL=https://github.com/<username>/dealii.git -D DEALII_CUSTOM_TAG=<Your Branch Name>" 
   ```

### Method 3: Container (Docker/Podman)
If you want to use dcs2 on a non-supported OS, e.g., Windows, you can use the [dcs2-container](https://github.com/kinnewig/dcs2-container).
For more information, see the documentation of the dcs2-container.

## Requirements
DCS2 requires a modern MPI compiler, and a few additional programs that are not build by DCS2 itself.

Note the packages: `boost-devel`, `cmake`, `ninja-build` and `mold` are recommended but not strictly required, as DCS2 can install these packages, if they are not present.

### Fedora (>=41)
Install the dependencies
```bash
sudo dnf install @c-development @development-tools openmpi-devel gcc-c++ gcc-gfortran git texinfo boost-devel cmake ninja-build mold
```
To enable openmpi by default add the following lines to the ~/.bashrc
```bash
source /etc/profile.d/modules.sh
module load mpi/openmpi-x86_64
```

### Rocky / Redhat Linux
In Redhat Linux 10/Rocky 10 some dependencies where moved into EPEL.
So first activate EPEL:
```bash
dnf install epel-release
dnf config-manager --set-enabled crb
dnf update
```

Install the dependencies
```bash
sudo dnf groupinstall "Development Tools"
sudo dnf install openmpi-devel gcc-c++ git texinfo boost-devel cmake ninja-build mold

```
To enable openmpi by default add the following lines to the ~/.bashrc
```bash
source /etc/profile.d/modules.sh
module load mpi/openmpi-x86_64
```


### Ubuntu/Debian
Install the dependencies
```bash
sudo apt install build-essential libopenmpi-dev gfortran git texinfo libssl-dev python-is-python3 pkg-config libboost-all-dev cmake ninja-build mold 
```

## DCS2 Options

Usage: 
```bash
./dcs2.sh [options] [--blas-stack=<blas option>] [--cmake-flags="<CMake Options>"]
```

| Short Option             | Long Option                     | Description                                                  |
|--------------------------|---------------------------------|---------------------------------------------------------------
| `-h`                     | `--help`                        | Print the help message                                       |
| `-p <path>`              | `--prefix <path>`               | Set a different prefix path                                  |
| `-b <path>`              | `--build <path>`                | Set a different build path                                   |
| `-d <path>`              | `--bin-dir <path>`              | Set a different binary path                                  |
| `-l <path>`              | `--lib-dir <path>`              | Set a different library path                                 |
| `-j <threads>`           | `--parallel <threads>`          | Set number of threads to use                                 |
| `-A <ON\|OFF>`           | `--add_to_path <ON\|OFF>`       | Enable or disable adding deal.II permanently to the path     |
| `-N <DOWNLOAD\|ON\|OFF>` | `--ninja <DOWNLOAD\|ON\|OFF>`   | Enable or disable the use of Ninja                           |
| `-M <DOWNLOAD\|ON\|OFF>` | `--mold <DOWNLOAD\|ON\|OFF>`    | Enable or disable the use of mold                            |
| `-O <ON\|OFF>`           | `--optimization-flags <ON\|OFF>`| Enable or disable the use of optimization flags              |
| `-U`                     |                                 | Do not interrupt                                             |
| `-v`                     | `--version`                     | Print the version number                                     |
|                          | `--blas-stack=<blas option>`    | Select which BLAS to use (FLAME|SYSTEM|AMD|MKL)              |
|                          | `--cmake-flags=<CMake Options>` | Specify additional CMake Options, see below                  |


### Blas Options
One specialty of DCS2 is its ability to build deal.II and the TPL packages with different BLAS backends.
You can select the backend using the flag `--blas-stack=<backend>`. 
The following options are available:
- `AMD` AMD AOCL, optimized BLAS routines for AMD CPUs.
- `FLAME` Builds BLIS and FLAME. This is the default option.
- `MKL` Intel OneMKL, optimized BLAS routines for Intel CPUs.
- `SYSTEM` Uses BLAS, LAPACK, and ScaLAPACK provided by the system's package manager.


#### AMD AOCL 
AMD AOCL provides hardware acceleration for AMD Zen CPUs. To select this BLAS stack, use:
```bash
--blas-stack=AMD
```

The AOCL stack requires the AOCC compiler. Due to licensing restrictions, AOCC cannot be downloaded automatically.
Download [aocc-compiler-5.0.0.tar](https://www.amd.com/de/developer/aocc/eula/aocc-5-0-eula.html?filename=aocc-compiler-5.0.0.tar) and place it in the DCS2 root directory. DCS2 will attempt to install it automatically from there.

Alternatively, visit: https://www.amd.com/de/developer/aocc.html download the latest version, and install it manually.


#### FLAME
Builds BLIS and FLAME. This option offers a good balance between ease of use and performance, and is the recommended default.
```bash
--blas-stack=FLAME
```

#### Intel MKL
Intel OneMKL provides optimized BLAS, LAPACK, and ScaLAPACK routines for Intel architectures. To select this BLAS stack, use:
```bash
--blas-stack=MKL
```
This requires the Intel oneAPI Base Toolkit to be installed before running DCS2. For installation instructions, please refer to the official documentation of the [Intel oneAPI Base Tookit](https://www.intel.com/content/www/us/en/developer/tools/oneapi/base-toolkit-download.html).


#### System
If you want to install DEALII using the system-provided BLAS stack, please use the following flag
```bash
--blas-stack=SYSTEM
```

The most straightforward method for installing DEALII is to rely on the BLAS, LAPACK, and ScaLAPACK libraries, which are typically provided by the system repositories. 

You need to install the developer packages of the following packages `openblas` `lapack` `scalapack`.

In the case of Fedora/Rocky/Redhat this boils down to `sudo dnf install openblas-devel lapack-devel scalapack-openmpi-devel`

In the case of Ubuntu/Debian `sudo apt install libopenblas-dev liblapack-dev libscalapack-openmpi-dev`


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

#### BOOST
- `BOOST_DIR`: If Boost is installed on a custom path, the path has to be provided, otherwise deal.II will not find BOOST.

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

#### BLAS/LAPACK Packages
- `FLAME`: i.e.: `BLIS` (default version: "0.9.0") and `LIBFLAME` (default version: "5.2.0")
- `ScaLAPACK` (default version: "2.2.1")

#### Data Formats
- `HDF5`  (Hierarchical Data Format version 5) is an open-source file format and data model designed to store and organize large, complex, heterogeneous data in a flexible and efficient way. (default "ON")
- `NetCDF` (The Unidata network Common Data Form) is a set of software libraries and machine-independent data formats designed to store, access, and share array-oriented scientific data in a self-describing and portable way. (default "OFF")
#### Direct Solver
- `MUMPS` (default version: "5.6.2")
- `SUITESPARSE` (default version: "5.6.2")
- `SUPERLU_DIST` (default: "ON")
- `SUNDIALS` a SUite of Nonlinear and DIfferential/ALgebraic equation Solvers (default "OFF"). 

#### Graph partitioning
- `P4EST` (default version: "2.8.5")
- `METIS` and `ParMETIS` Graph partitioner (default "ON")
- `T8CODE` Tree-based adaptive mesh refinement with arbitrary element shapes (default "OFF")

#### Grid generation
- `ASSIMP` is a portable Open Source library to import various well-known 3D model formats in a uniform manner (default "OFF")

- `GMSH` (default version: "4.12.2", default "OFF")

  Extra dependencie for OCCT: `FLTK` 

   Extra dependencies of GMSH for Fedora / Rocky 9 `sudo dnf install fltk-devel mesa-libGLU-devel mesa-libGL-devel`.

   Extra dependencies of GMSH for Ubuntu / Debian `sudo apt install libfltk1.3-dev libglu1-mesa-dev libgl1-mesa-dev`.

- `OCCT` OpenCascade (default version: "7.8.1", default "OFF")

  Extra dependencie for OCCT: `TCL` 

  Extra dependencie for OCCT: `TK` 

#### Algebra Packages
- `GINKGO` (default "OFF")

- `PETSC` (default version: "3.23.3")

- `TRILINOS` (default version: "16.1.0")

#### Automatic Differentiation
- `ADOL-C` (default "OFF")
- `SymEngine` is a fast symbolic manipulation library, written in C++. (default "OFF")

#### Tools
- `NUMDIFF` is a little program that can be used to compare putatively similar files line by line and field by field, ignoring small numeric differences or/and different numeric formats. Used in the ctests of deal.II (default "ON")
- `zlib-ng` zlib replacement with optimizations for "next generation" systems (default "ON"). 

#### Miscellaneous
- `ArborX` Performance-portable geometric search library (default "OFF")
- `ARPACK`  is an open-source library designed to provide performance portable algorithms for geometric search, similarly to nanoflann and Boost Geometry. (default "OFF")
- `boost` (default "OFF")
- `CGAL` (The Computational Geometry Algorithms Library)  is a C++ library that aims to provide easy access to efficient and reliable algorithms in computational geometry. (default "OFF")
- `GMP` (default version: "6.2.1")
- `GSL` GNU Scientific Library (default "OFF")
- `HYPRE` HYPRE is a library of high performance preconditioners and solvers featuring multigrid methods for the solution of large, sparse linear systems of equations on massively parallel computers (default "ON", as dependency of PETSC)
- `MPFR` (default version: "4.2.1")
- `MUPARSER` is a fast math parser library for C/C++ with (optional) OpenMP support.  (default "OFF")
- `TBB` Intel One Thread Building Blocks (default version: "2021.13.0")
- `VTK` (default version: "9.3.1", default "OFF")


## Troubleshooting
### The build of deal.II fails
deal.II requires 8GB of RAM per thread during the build process. If your build fails lower the number of threads to use (e.g. -j 2 when your system has 16GB of RAM).

## Acknowledgements 

DCS2 is originally based on [dealii-cmake-superbuild](https://github.com/jpthiele/dealii-cmake-superbuild) and [candi](https://github.com/dealii/candi).
