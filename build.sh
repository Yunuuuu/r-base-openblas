#!/bin/sh
# Script to build R-base with rtools40
set -e
set -x

# build the complete installer, comment next line if you want a quick build
export build_installer=1

# What version to build from; default is r-devel
version=${version:-"4.2.1"}
case $version in
  devel)
    rsource_url="https://cran.r-project.org/src/base-prerelease/R-devel.tar.gz" ;;
  patched)
    rsource_url="https://cran.r-project.org/src/base-prerelease/R-latest.tar.gz" ;;
  *)
    rsource_url="https://cran.r-project.org/src/base/R-4/R-${version}.tar.gz" ;;
esac

# Put pdflatex on the path (needed only for CMD check)
export PATH="$HOME/scoop/apps/miktex/current/texmfs/install/miktex/bin/x64:$PATH"
export PATH="/ucrt64/bin:/x86_64-w64-mingw32.static.posix/bin:$PATH"
pdflatex --version || true
texindex --version
make --version

# get absolute paths
srcdir=$(dirname $(realpath $0))

# Install system libs
pacman -Syu --noconfirm
pacman -S --needed --noconfirm mingw-w64-ucrt-x86_64-{gcc,gcc-fortran,icu,libtiff,libjpeg,libpng,pcre2,xz,bzip2,zlib,cairo,tk,curl,libwebp}
pacman -S --needed --noconfirm mingw-w64-ucrt-x86_64-openblas

# Download sources and extract (note tarball contains symlinks)
rm -rf ${srcdir}/R-source
mkdir -p ${srcdir}/R-source
curl -OL $rsource_url
tarball=$(basename ${rsource_url})
MSYS="winsymlinks:lnk" tar -xf "${tarball}" -C ${srcdir}/R-source --strip-components=1
cd "${srcdir}/R-source"

# Download a certificate bunle
curl https://curl.se/ca/cacert.pem > etc/curl-ca-bundle.crt

# Create the TCL bundle required by tcltk package
mkdir -p Tcl/{bin,lib}
${srcdir}/create-tcltk-bundle-ucrt.sh

# Add custom patches here:
# patch -Np1 -i "${srcdir}/myfix.patch" 
patch -Np1 -i "${srcdir}/blas.diff"
patch -Np1 -i "${srcdir}/ISDIR.diff"

# Build just the core pieces (no manuals or installer)
cd "src/gnuwin32"
sed -e "s|@texindex@|$(cygpath -m $(which texindex))|" "${srcdir}/MkRules.local.in" > MkRules.local

# quick build only
if [ -z "$build_installer" ]; then
make all cairodevices recommended
../../bin/x64/Rgui.exe &
exit 0
fi

# full build
set -o pipefail
make distribution 2>&1 | tee ${srcdir}/build.log
#make check-all 2>&1 | tee ${srcdir}/check.log

# Copy to home dir
cd $srcdir
cp -v R-source/src/gnuwin32/installer/*.exe .
# You should comment next line if you don't want to use scoop to manage program
cp R-$version-win.exe $HOME/scoop/local_pkgs/R-$version-openblas.exe
installer=$(ls *.exe)
echo "::set-output name=installer::$installer"
echo "Done: $installer"
