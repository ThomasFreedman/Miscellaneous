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
   if [ ! $BRANCH ]; then
      time git clone $PROJECT #defaults to master
   else
      time git clone $PROJECT -b $BRANCH #switches to specified branch/tag
   fi
   # time git submodule update --init --recursive - This will fail unless inside the project folder. Already called below
   # these were added to build non-master branch code -- provided by abitmore
   # git fetch origin - redundant. You've just cloned the entire repo. Fetch is useful to update when cloned originally in the past
   # git checkout origin/release - redundant. You've already specified branch/tag in the -b argument
   # git submodule update --init --recursive This will fail unless inside the project folder. Already called below
   # git submodule sync --recursive This will fail unless inside the project folder. Already called below
   # git submodule update --init --recursive This will fail unless inside the project folder. Already called below
   # cmake Not needed here
   # exit  # Normally would not be here, and would finish below
fi
cd $SUB 
if [ $UPDATE -eq 1 ]; then
##################################################################################################
# Just get the latest or tagged / commit changes
##################################################################################################   
   echo "Updating source from git..."
   git fetch #fetches list of latest tags/branches
   time git checkout $TAG #checks out specified branch/tag
   time git pull #redundant here(fetch already does this job) but doesn't hurt
fi
##################################################################################################
# Build the GRAPHENE witness node and CLI wallet.                                        #
##################################################################################################

time git submodule update --init --recursive 
time git submodule sync --recursive 
time git submodule update --init --recursive #normally not needed but was necessary last time. doesnt hurt so leave it here
cmake -DCMAKE_BUILD_TYPE=$BUILD_TYPE .
time make

cp $BUILD_DIR/$SUB/programs/cli_wallet/cli_wallet $BIN/cli_wallet$DAT
cp $BUILD_DIR/$SUB/programs/witness_node/witness_node $BIN/witness_node$DAT
pushd $BIN
rm -rf witness_node cli_wallet
ln -s witness_node$DAT witness_node
ln -s cli_wallet$DAT cli_wallet
popd
