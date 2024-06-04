#!/bin/bash

# Maintainer information
echo "Maintainer: sid@tamu.edu"

# Variables
GIT_REPO=https://github.com/rdkit/rdkit.git
GIT_BRANCH=master
GIT_TAG=
POSTGRES_VERSION=16
JAVA_VERSION=17

# Update package list and install dependencies
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
  build-essential \
  python3-dev \
  python3-numpy \
  python3-pip \
  cmake \
  catch2 \
  sqlite3 \
  libsqlite3-dev \
  libboost-all-dev \
  zlib1g-dev \
  swig \
  libeigen3-dev \
  git \
  wget \
  openjdk-${JAVA_VERSION}-jdk \
  zip \
  unzip \
  libfreetype6-dev \
  postgresql \
  postgresql-contrib \
  postgresql-plpython3 \
  libpq-dev

# Clone the RDKit repository
if [ -n "$GIT_TAG" ]; then 
  echo "Checking out tag $GIT_TAG from repo $GIT_REPO branch $GIT_BRANCH"
else 
  echo "Checking out repo $GIT_REPO branch $GIT_BRANCH"
fi

git clone -b $GIT_BRANCH --single-branch $GIT_REPO

if [ -n "$GIT_TAG" ]; then 
  cd rdkit && git fetch --tags && git checkout $GIT_TAG
else
  cd rdkit
fi

# Environment variables
export RDBASE=$(pwd)
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$RDBASE/lib:$RDBASE/Code/JavaWrappers/gmwrapper:/usr/lib/x86_64-linux-gnu:/usr/lib/aarch64-linux-gnu/
export PYTHONPATH=$PYTHONPATH:$RDBASE

# Set up Java environment
sudo ln -s $(ls -d /usr/lib/jvm/java-$JAVA_VERSION-openjdk-*) /usr/lib/jvm/java-$JAVA_VERSION-openjdk
export JAVA_HOME=/usr/lib/jvm/java-$JAVA_VERSION-openjdk
export CLASSPATH=$RDBASE/Code/JavaWrappers/gmwrapper/org.RDKit.jar

# Create build directory and change to it
mkdir -p $RDBASE/build
cd $RDBASE/build

# Run cmake with specified options
cmake -Wno-dev \
  -DPYTHON_EXECUTABLE=/usr/bin/python3 \
  -DRDK_INSTALL_INTREE=OFF \
  -DRDK_BUILD_INCHI_SUPPORT=ON \
  -DRDK_BUILD_AVALON_SUPPORT=ON \
  -DRDK_BUILD_PYTHON_WRAPPERS=ON \
  -DRDK_BUILD_SWIG_WRAPPERS=ON \
  -DRDK_BUILD_PGSQL=ON \
  -DPostgreSQL_ROOT=/usr/lib/postgresql/$POSTGRES_VERSION \
  -DPostgreSQL_TYPE_INCLUDE_DIR=/usr/include/postgresql/$POSTGRES_VERSION/server \
  -DCMAKE_INSTALL_PREFIX=/usr \
  -DCPACK_PACKAGE_RELOCATABLE=OFF \
  ..

# Build and install RDKit
nproc=$(getconf _NPROCESSORS_ONLN)
make -j $(( nproc > 2 ? nproc - 2 : 1 ))
sudo make install

# Install PostgreSQL RDKit extension
sudo sh $RDBASE/Code/PgSQL/rdkit/pgsql_install.sh

# Package the build (optional)
cpack -G DEB

# Create a tarball of the Java documentation (optional)
cd $RDBASE/Code/JavaWrappers/gmwrapper && tar cvfz javadoc.tgz doc

# Return to the RDKit base directory
cd $RDBASE

echo "RDKit installation and setup completed successfully."

# Additional steps to setup PostgreSQL and enable RDKit
sudo -u postgres psql -c "CREATE EXTENSION rdkit;"
echo "RDKit extension enabled in PostgreSQL."
