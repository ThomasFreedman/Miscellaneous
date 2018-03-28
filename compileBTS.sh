#!/bin/bash

#export PROJECT=https://github.com/bytemaster/bitshares-core.git
export PROJECT=https://github.com/bitshares/bitshares-core.git
export BUILD_DIR=/home/admin/.BitShares2_build
export BIN=/home/admin/bin
export SUB=bitshares-core
export BUILD_TYPE="Release"
#export BUILD_TYPE="Debug"
export UPDATE=0
export TAG=
export DAT=_staging

#read -p "Press [Enter] key to continue..."
cd $BUILD_DIR

if [ $UPDATE -eq 0 ]; then
##################################################################################################
# Clone the TESTNET project
##################################################################################################
   rm -rf * .*
   echo "Clone $PROJECT project..."
   time git clone $PROJECT
   time git submodule update --init --recursive
   # these were added to build non-master branch code -- provided by abitmore
   git fetch origin
   git checkout origin/release
   git submodule update --init --recursive
   git submodule sync --recursive
   git submodule update --init --recursive
   cmake
   exit  # Normally would not be here, and would finish below
else
##################################################################################################
# Just get the latest or tagged / commit changes
##################################################################################################
   echo "Updating source from git..."
   git fetch
   time git checkout $TAG
   time git pull origin $TAG
fi
##################################################################################################
# Build the GRAPHENE witness node and CLI wallet.                                        #
##################################################################################################
cd $SUB
time git submodule update --init --recursive
cmake -DCMAKE_BUILD_TYPE=$BUILD_TYPE .
time make

cp $BUILD_DIR/$SUB/programs/cli_wallet/cli_wallet $BIN/cli_wallet$DAT
cp $BUILD_DIR/$SUB/programs/witness_node/witness_node $BIN/witness_node$DAT
pushd $BIN
rm -rf witness_node cli_wallet
ln -s witness_node$DAT witness_node
ln -s cli_wallet$DAT cli_wallet
popd
