#!/usr/bin/env bash
# shameless ripoff of https://git.archlinux.org/svntogit/packages.git/tree/trunk/PKGBUILD?h=packages/boost

set -e -u -x

export _stagedir="./stagedir"
export JOBS="$(sed -e 's/.*\(-j *[0-9]\+\).*/\1/' <<< ${MAKEFLAGS:-"-j $(nproc)"})"

./bootstrap.sh --with-toolset=gcc --with-icu --with-python=/usr/bin/python2

install -v -Dm755 tools/build/src/engine/*/b2 "${_stagedir}"/bin/b2

# Support for OpenMPI
echo "using mpi ;" >> project-config.jam

# boostbook is needed by quickbook
install -dm755 "${_stagedir}"/share/boostbook
cp -a tools/boostbook/{xsl,dtd} "${_stagedir}"/share/boostbook/

"${_stagedir}"/bin/b2 \
  variant=release \
  debug-symbols=off \
  threading=multi \
  runtime-link=shared \
  link=shared,static \
  toolset=gcc \
  python=2.7 \
  cflags="-fPIC -O2" \
  cxxflags="-std=c++14 -fPIC -O2" \
  linkflags="${LDFLAGS}" \
  --layout=system \
  ${JOBS} \
  \
  --prefix="${_stagedir}" \
  install

# because b2 in boost 1.62.0 doesn't seem to respect python parameter, we
# need another run for liboost_python3.so
sed -e '/using python/ s@;@: /usr/include/python${PYTHON_VERSION/3*/${PYTHON_VERSION}m} ;@' \
  -i bootstrap.sh

./bootstrap.sh --with-toolset=gcc --with-icu --with-python=/usr/bin/python3 \
  --with-libraries=python

"${_stagedir}"/bin/b2 clean
"${_stagedir}"/bin/b2 \
  variant=release \
  debug-symbols=off \
  threading=multi \
  runtime-link=shared \
  link=shared,static \
  toolset=gcc \
  python=3.5 \
  cflags="-fPIC -O2" \
  cxxflags="-std=c++14 -fPIC -O2" \
  linkflags="${LDFLAGS}" \
  --layout=system \
  ${JOBS} \
  \
  --prefix="${_stagedir}/python3" \
  --with-python \
  install

cp -a "${_stagedir}"/{bin,include,share} /app
cp -a "${_stagedir}"/lib/*.a /app/lib
install -Dm644 LICENSE_1_0.txt /app/share/licenses/boost/LICENSE_1_0.txt
install -Dm644 "${_stagedir}"/python3/lib/libboost_*.a /app/lib/

install -dm755 /app
cp -a "${_stagedir}"/lib /app
cp -a "${_stagedir}"/python3/lib/libboost_* /app/lib
