#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

ARCH=$(dpkg --print-architecture)
echo "-----------> ARCH" $ARCH
MARCH=$(uname -s|tr '[:upper:]' '[:lower:]')
echo "-----------> MARCH" $MARCH
MVN_METADATA=$(echo "https://nexus.hyperledger.org/content/repositories/releases/org/hyperledger/fabric/hyperledger-fabric-stable/maven-metadata.xml")
curl -L "$MVN_METADATA" > maven-metadata.xml
RELEASE_TAG=$(cat maven-metadata.xml | grep release)
COMMIT=$(echo $RELEASE_TAG | awk -F - '{ print $4 }' | cut -d "<" -f1)
VERSION=1.2.0
echo "-----------> BASE_VERSION = $VERSION"

# TODO
# if [ $TRAVIS = true ]; then
FABRIC_SAMPLES_ABSOLUTE_DIR=$TRAVIS_BUILD_DIR
# else
# FABRIC_SAMPLES_ABSOLUTE_DIR=$BASE_FOLDER/fabric-samples

# XXX
# TODO Parametrize so that it is "CI universal".
#cd $BASE_FOLDER/fabric-samples || exit
cd $FABRIC_SAMPLES_ABSOLUTE_DIR || exit
# XXX

curl https://nexus.hyperledger.org/content/repositories/releases/org/hyperledger/fabric/hyperledger-fabric-stable/$MARCH-$ARCH.$VERSION-stable-$COMMIT/hyperledger-fabric-stable-$MARCH-$ARCH.$VERSION-stable-$COMMIT.tar.gz | tar xz

cd first-network || exit

# XXX
#export PATH=gopath/src/github.com/hyperledger/fabric-samples/bin:$PATH
export PATH=$TRAVIS_BUILD_DIR/bin:$PATH
# XXX

err_Check() {
if [ $1 != 0 ]; then
    echo "Error: -----------> $2 test case failed"
    exit 1
fi
}

 echo "############## BYFN,EYFN DEFAULT CHANNEL TEST ###################"
 echo "#################################################################"
 echo y | ./byfn.sh -m down
 echo y | ./byfn.sh -m up -t 60
 err_Check $? default-channel
 echo y | ./eyfn.sh -m up -t 60
 err_Check $? default-channel
 echo y | ./eyfn.sh -m down
 echo

 echo "############### BYFN,EYFN CUSTOM CHANNEL WITH COUCHDB TEST ##############"
 echo "#########################################################################"
 echo y | ./byfn.sh -m up -c custom-channel-couchdb -s couchdb -t 60
 err_Check $? custom-channel-couch couchdb
 echo y | ./eyfn.sh -m up -c custom-channel-couchdb -s couchdb -t 60
 err_Check $? custom-channel-couch
 echo y | ./eyfn.sh -m down
 echo

 echo "############### BYFN,EYFN WITH NODE Chaincode. TEST ################"
 echo "####################################################################"
 echo y | ./byfn.sh -m up -l node -t 60
 err_Check $? default-channel-node
 echo y | ./eyfn.sh -m up -l node -t 60
 err_Check $? default-channel-node
 echo y | ./eyfn.sh -m down

 echo "############### FABRIC-CA SAMPLES TEST ########################"
 echo "###############################################################"
# XXX
# TODO Parametrize so that it is "CI universal".
#cd $WORKSPACE/gopath/src/github.com/hyperledger/fabric-samples/fabric-ca
cd  $FABRIC_SAMPLES_ABSOLUTE_DIR/fabric-ca
# XXX
 ./start.sh
 err_Check $? fabric-ca
 ./stop.sh
