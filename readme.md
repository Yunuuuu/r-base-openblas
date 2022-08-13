# Base R Installer with openblas ![GHA Build Status](https://github.com/r-windows/r-base/actions/workflows/full-build.yml/badge.svg)

> Scripts to build R for Windows (ucrt64) using [Rtools40](https://github.com/r-windows/rtools-installer) toolchains.

This repository was used to build dailies and official releases for R 4.0.0 - 4.1.3. Sadly as of R 4.2.0, R-core has decided to go back to building the releases privately by an R-core member. Yet the current scripts and CI still work, and can be used for testing and understanding the build process.

## Warning 
Don't rely on the release file of current branch, since I build R installers for each machine I used. If you want to build R 4.2 for Windows with OpenBLAS and specific machine architectures, you need to be careful. To use the same installer on different computers Avraham Adler recommend `-mtune=generic -pipe`.

To use this repository, you should firstly clone it or download it as zip file and then adjust some file path. Since I used `scoop` to manage may software, the path I set is based on the software downloaded from `scoop`. You should ajdust these to yours, including `miktex` file path in `build.sh` (`export PATH` in 21 line, strangely, by setting this I cannot make my `miktex` work so I choose to set environment variable in `msys2` manually) file and `Inno Setup` file path in `MkRules.local.in` (`ISDIR` in the 35 line) file

This branch was based on the two detailed posts of Avraham Adler
 - https://www.avrahamadler.com/2020/05/12/building-r-4-for-windows-with-openblas/
 - https://www.avrahamadler.com/2022/01/17/building-r-42-with-openblas-windows/

Great thanks to Duncan Murdoch and Jeroen Ooms for their great efforts in Windows R builds system, and to Avraham Adler for the detailed tutorial of openblas support in R.

## Downloads

Signed builds can be found under [releases](https://github.com/r-windows/r-base/releases). These installers are signed with a certified developer certificate, trusted by all Windows systems.

For the very latest svn builds, or testing patches, also checkout the r-contributor [svn-dashboard](https://contributor.r-project.org/svn-dashboard/)!

## Build requirements

To build R for Windows, you need:

 - [rtools40](https://cran.r-project.org/bin/windows/Rtools/)
 - [InnoSetup 6](https://www.jrsoftware.org/isdl.php) (only required for installer)
 - [MikTex](https://miktex.org/download) (only required for installer)

Rtools40 provides perl and all required system libraries.

## How to build yourself

Clone or [download](https://github.com/r-windows/r-base/archive/master.zip) this repository. Optionally edit [`MkRules.local.in`](MkRules.local.in) to adjust compiler flags. Now open any rtools msys2 shell from the Windows start menu.

![win10](https://user-images.githubusercontent.com/216319/73364595-1fe28080-42ab-11ea-9858-ac8c660757d6.png)

To build the latest R-devel from source, run the [`./build.sh`](build.sh) script inside the rtools40 bash shell. This will download and build a complete ucrt64 version of R-devel, but no manuals or the installer.

This is useful if you want to test a patch for base R. You can adjust the [`./build.sh`](build.sh) script to add patches.

### Building the full installer

Alternatively to build the complete installer as it would appear on CRAN, set an environment variable `build_installer` when running the build script:

```sh
# Run in rtools40 shell
export build_installer=1
./build.sh
```

This requires you have innosetup and latex installed on your machine (in addition to rtools40). The process involves building R as well as pdf manuals and finally the installer program.
