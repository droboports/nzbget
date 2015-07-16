### UNRAR ###
_build_unrar() {
local VERSION="5.2.7"
local FOLDER="unrar"
local FILE="unrarsrc-${VERSION}.tar.gz"
local URL="http://www.rarlab.com/rar/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd target/"${FOLDER}"
mv makefile Makefile
make CXX="${CXX}" CXXFLAGS="${CFLAGS} -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE" STRIP="${STRIP}" LDFLAGS="${LDFLAGS} -pthread"
make install DESTDIR="${DEST}"
mkdir -p "${DEST}/libexec"
mv "${DEST}/bin/unrar" "${DEST}/libexec/"
popd
}

### P7ZIP ###
_build_p7zip() {
local VERSION="9.38.1"
local FOLDER="p7zip_${VERSION}"
local FILE="${FOLDER}_src_all.tar.bz2"
local URL="http://sourceforge.net/projects/p7zip/files/p7zip/${VERSION}/${FILE}"

_download_bz2 "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
cp makefile.linux_cross_arm makefile.linux
make all3 CC="${CC} \$(ALLFLAGS)" CXX="${CXX} \$(ALLFLAGS)" OPTFLAGS="${CFLAGS}"
make install DEST_HOME="${DEPS}" DEST_BIN="${DEST}/libexec" DEST_SHARE="${DEST}/lib/p7zip"
popd
}

### ZLIB ###
_build_zlib() {
local VERSION="1.2.8"
local FOLDER="zlib-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="http://zlib.net/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --prefix="${DEPS}" --libdir="${DEST}/lib" --shared
make
make install
rm -v "${DEST}/lib/libz.a"
popd
}

### OPENSSL ###
_build_openssl() {
local VERSION="1.0.2d"
local FOLDER="openssl-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="http://www.openssl.org/source/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
cp -vf "src/${FOLDER}-parallel-build.patch" "target/${FOLDER}/"
pushd "target/${FOLDER}"
patch -p1 -i "${FOLDER}-parallel-build.patch"
./Configure --prefix="${DEPS}" --openssldir="${DEST}/etc/ssl" \
  zlib-dynamic --with-zlib-include="${DEPS}/include" --with-zlib-lib="${DEPS}/lib" \
  shared threads linux-armv4 -DL_ENDIAN ${CFLAGS} ${LDFLAGS} -Wa,--noexecstack -Wl,-z,noexecstack
sed -i -e "s/-O3//g" Makefile
make
make install_sw
cp -vfaR "${DEPS}/lib"/* "${DEST}/lib/"
rm -vfr "${DEPS}/lib"
rm -vf "${DEST}/lib/libcrypto.a" "${DEST}/lib/libssl.a"
sed -i -e "s|^exec_prefix=.*|exec_prefix=${DEST}|g" "${DEST}/lib/pkgconfig/openssl.pc"
popd
}

### WGET ###
_build_wget() {
local VERSION="1.16.3"
local FOLDER="wget-${VERSION}"
local FILE="${FOLDER}.tar.xz"
local URL="http://ftp.gnu.org/gnu/wget/${FILE}"

_download_xz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
PKG_CONFIG_PATH="${DEST}/lib/pkgconfig" ./configure --host="${HOST}" --prefix="${DEPS}" --sysconfdir="${DEST}/etc" --bindir="${DEST}/libexec"  --with-ssl=openssl --with-openssl=yes --with-libssl-prefix="${DEST}" --disable-pcre
make
make install
echo "ca_certificate = ${DEST}/etc/ssl/certs/ca-certificates.crt" >> "${DEST}/etc/wgetrc"
mv -f "${DEST}/etc/wgetrc" "${DEST}/etc/wgetrc.default"
popd
}

### NCURSES ###
_build_ncurses() {
local VERSION="5.9"
local FOLDER="ncurses-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="http://ftp.gnu.org/gnu/ncurses/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd target/"${FOLDER}"
./configure --host="${HOST}" --prefix="${DEPS}" --libdir="${DEST}/lib" --datadir="${DEST}/share" --with-shared --enable-rpath --with-termlib=tinfo
make
make install
rm -v "${DEST}/lib"/*.a
popd
}

### LIBXML2 ###
_build_libxml2() {
local VERSION="2.9.2"
local FOLDER="libxml2-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="ftp://xmlsoft.org/libxml2/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
PKG_CONFIG_LIBDIR="${DEST}/lib/pkgconfig" ./configure --host="${HOST}" --prefix="${DEPS}" --libdir="${DEST}/lib" --without-python --disable-static LIBS="-lz"
make
make install
popd
}

### NZBGET ###
_build_nzbget() {
local VERSION="15.0"
local FOLDER="nzbget-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="http://sourceforge.net/projects/nzbget/files/nzbget-stable/${VERSION}/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --host="${HOST}" --prefix="${DEST}" --with-zlib-includes="${DEPS}/include" --with-zlib-libraries="${DEST}/lib" --with-tlslib=OpenSSL --with-openssl-includes="${DEPS}/include" --with-openssl-libraries="${DEST}/lib" --with-libcurses-includes="${DEPS}/include" --with-libcurses-libraries="${DEST}/lib" --with-libxml2-includes="${DEPS}/include/libxml2" --with-libxml2-libraries="${DEST}/lib"
make
make install
mv -v "${DEST}/share/nzbget/webui" "${DEST}/www"
mv -v "${DEST}/share/nzbget/nzbget.conf" "${DEST}/etc/nzbget.conf.default"
sed -e "s|^MainDir=.*|MainDir=/mnt/DroboFS/Shares/Public/Downloads|g" \
    -e "s|^DestDir=.*|DestDir=\${MainDir}/complete|g" \
    -e "s|^InterDir=.*|InterDir=\${MainDir}/incomplete|g" \
    -e "s|^NzbDir=.*|NzbDir=\${MainDir}/watch|g" \
    -e "s|^LockFile=.*|LockFile=/tmp/DroboApps/nzbget/pid.txt|g" \
    -e "s|^LogFile=.*|LogFile=/tmp/DroboApps/nzbget/log.txt|g" \
    -e "s|^ConfigTemplate=.*|ConfigTemplate=/mnt/DroboFS/Shares/DroboApps/nzbget/etc/nzbget.conf.default|g" \
    -e "s|^WebDir=.*|WebDir=/mnt/DroboFS/Shares/DroboApps/nzbget/www|g" \
    -e "s|^UMask=.*|UMask=0002|g" \
    -e "s|^UnrarCmd=.*|UnrarCmd=/mnt/DroboFS/Shares/DroboApps/nzbget/libexec/unrar|g" \
    -e "s|^SevenZipCmd=.*|SevenZipCmd=/mnt/DroboFS/Shares/DroboApps/nzbget/libexec/7z|g" \
    -i "${DEST}/etc/nzbget.conf.default"
popd
}

### CERTIFICATES ###
_build_certificates() {
# update CA certificates on a Debian/Ubuntu machine:
#sudo update-ca-certificates
cp -vf /etc/ssl/certs/ca-certificates.crt "${DEST}/etc/ssl/certs/"
#wget -O "${DEST}/etc/ssl/certs/ca-certificates.crt" "http://curl.haxx.se/ca/cacert.pem"
}

_build() {
  _build_unrar
  _build_p7zip
  _build_zlib
  _build_openssl
  _build_ncurses
  _build_libxml2
  _build_nzbget
  _build_wget
  _build_certificates
  _package
}
