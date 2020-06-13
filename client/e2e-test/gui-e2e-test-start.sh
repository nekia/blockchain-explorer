#!/bin/bash

#
#    SPDX-License-Identifier: Apache-2.0
#

TIMEOUT=600
DELAY=10

ROOTDIR="$(cd "$(dirname "$0")"/../.. && pwd)"
FABRIC_V1_VERSION=1.4.6
FABRIC_V2_VERSION=2.1.1

echo "#### Downloaded fabric-test repo"

if [ $# -eq 0 ]; then
  echo "$0 [-1 | -2]"
  exit 1;
fi

while getopts "12" opt; do
  case "$opt" in
  1)
    SDKVER=1.4.8
    export FABRIC_VERSION=1
    export RELEASE_VERSION=1.4-stable
    CHECKOUT_HASH=45799a2ee4eefa49ae705cc57ed415270c35d60a
    # export FABRIC_CFG_PATH=$GOPATH/src/github.com/hyperledger/fabric-test/scripts/config
    export PATH=$GOPATH/src/github.com/hyperledger/fabric-test/scripts/bin:$PATH
    PULL_PEER_IMAGE_VERSION=${FABRIC_V1_VERSION}
    PULL_CA_IMAGE_VERSION=${FABRIC_V1_VERSION}
    ;;
  2)
    SDKVER=2.0.0-beta.2
    export FABRIC_VERSION=2
    CHECKOUT_HASH=09680bea5aa0ec464982f7979fd99a777e8c1fed
    export FABRIC_CFG_PATH=$GOPATH/src/github.com/hyperledger/fabric-test/config
    export PATH=$GOPATH/src/github.com/hyperledger/fabric-test/bin:$PATH
    PULL_PEER_IMAGE_VERSION=${FABRIC_V2_VERSION}
    PULL_CA_IMAGE_VERSION=${FABRIC_V1_VERSION}
    ;;
  *)
    echo "$0 [-1 | -2]"
    exit 1;
    ;;
  esac
done

echo "HASH: ${CHECKOUT_HASH}"
echo "SDK : ${SDKVER}"
echo "ROOT: ${ROOTDIR}"

go get -d github.com/hyperledger/fabric-test 

echo "#### Downloaded fabric-test repo"

pushd $GOPATH/src/github.com/hyperledger
sudo rm -rf fabric-test
if [ ! -d fabric-test ]; then
  git clone https://github.com/hyperledger/fabric-test.git
fi
cd fabric-test
# git checkout 45799a2ee4eefa49ae705cc57ed415270c35d60a
git checkout ${CHECKOUT_HASH}
make pull-binaries-fabric
echo "#### Updated each sub-module under fabric-test repo"
popd

pushd $GOPATH/src/github.com/hyperledger/fabric-test/tools/PTE
npm install fabric-client@${SDKVER}
npm install fabric-ca-client@${SDKVER}
echo "#### Installed required node packages"
popd

pushd ${ROOTDIR}
./build_docker_image.sh -d
popd

pushd ${ROOTDIR}
rm -rf wallet logs
popd

curl -sSL https://raw.githubusercontent.com/hyperledger/fabric/master/scripts/bootstrap.sh | bash -s -- ${PULL_PEER_IMAGE_VERSION} ${PULL_CA_IMAGE_VERSION} 0.4.18 -s -b
docker pull hyperledger/fabric-ca:${FABRIC_V1_VERSION}
docker tag hyperledger/fabric-ca:${FABRIC_V1_VERSION} hyperledger/fabric-ca:${FABRIC_V2_VERSION}

#
# Start selenium standalone server
#
pushd $ROOTDIR/client/e2e-test
export NETWORK_ID=configfiles_default
network_check=$(docker network ls --filter name=${NETWORK_ID} -q | wc -l)
if [ $network_check -eq 0 ]; then
  docker network create configfiles_default
fi
echo "#### Created network : ${NETWORK_ID}"

docker-compose down -v
docker-compose -f docker-compose-explorer.yaml down -v
docker-compose up -d
echo "#### Starting selenium containers ..."

rc=1
starttime=$(date +%s)
while
  [[ "$(($(date +%s) - starttime))" -lt "$TIMEOUT" ]] && [[ $rc -ne 0 ]];
do
  sleep $DELAY
  set -x
  docker logs selenium-chrome | grep -q "The node is registered to the hub and ready to use"
  rc=$?
  set +x
done
echo "#### Started selenium containers"
popd

pushd $ROOTDIR/client
echo "#### Starting WebDriverI/O based test suite"
npx wdio ./e2e-test/wdio.conf.js
popd