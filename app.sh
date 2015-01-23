### UNRAR ###
_build_unrar() {
local VERSION="5.1.7-fs"
local FOLDER="unrar"
local FILE="unrar.tgz"
local URL="https://github.com/droboports/unrar/releases/download/v${VERSION}/${FILE}"

_download_app "${FILE}" "${URL}" "${FOLDER}"
mkdir -p "${DEST}/libexec"
cp -v "target/${FOLDER}/bin"/* "${DEST}/libexec/"
}

### P7ZIP ###
_build_p7zip() {
local VERSION="9.20.1-fs"
local FOLDER="p7zip"
local FILE="p7zip.tgz"
local URL="https://github.com/droboports/p7zip/releases/download/v${VERSION}/${FILE}"

_download_app "${FILE}" "${URL}" "${FOLDER}"
mkdir -p "${DEST}/libexec"
cp -v "target/${FOLDER}/bin"/* "${DEST}/libexec/"
}

### ZLIB ###
_build_zlib() {
local VERSION="1.2.8"
local FOLDER="zlib-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="http://zlib.net/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --prefix="${DEPS}" --libdir="${DEST}/lib"
make
make install
rm -v "${DEST}/lib/libz.a"
popd
}

### OPENSSL ###
_build_openssl() {
local OPENSSL_VERSION="1.0.1l"
local OPENSSL_FOLDER="openssl-${OPENSSL_VERSION}"
local OPENSSL_FILE="${OPENSSL_FOLDER}.tar.gz"
local OPENSSL_URL="http://www.openssl.org/source/${OPENSSL_FILE}"

_download_tgz "${OPENSSL_FILE}" "${OPENSSL_URL}" "${OPENSSL_FOLDER}"
pushd "target/${OPENSSL_FOLDER}"
./Configure --prefix="${DEPS}" \
  --openssldir="${DEST}/etc/ssl" \
  --with-zlib-include="${DEPS}/include" \
  --with-zlib-lib="${DEST}/lib" \
  shared zlib-dynamic threads linux-armv4 -DL_ENDIAN ${CFLAGS} ${LDFLAGS}
sed -i -e "s/-O3//g" Makefile
make -j1
make install_sw
cp -avR "${DEPS}/lib"/* "${DEST}/lib/"
rm -vfr "${DEPS}/lib"
rm -vf "${DEST}/lib/libcrypto.a" "${DEST}/lib/libssl.a"
sed -i -e "s|^exec_prefix=.*|exec_prefix=${DEST}|g" "${DEST}/lib/pkgconfig/openssl.pc"
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
local VERSION="14.1"
local FOLDER="nzbget-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="http://sourceforge.net/projects/nzbget/files/${FILE}"

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

_build() {
  _build_unrar
  _build_p7zip
  _build_zlib
  _build_openssl
  _build_ncurses
  _build_libxml2
  _build_nzbget
  _package
}
