#!/usr/bin/env bash
echo "Clone hyperledger/caliper..."
git clone https://github.com/hyperledger/caliper.git
echo "Copy ./docker/. to ./caliper"
cp -ra ./docker/. ./caliper
echo "Copy ./ext/custom-query/. to ./caliper/."
cp -ra ./ext/custom-query/. ./caliper/.

# copy into benchmark
# network-config.json -> fabric.json
# copy into network/fabric/<folder> from ./artifacts/channel & /crypto-config
echo "Copy ../artifacts/channel to ./network/fabric/test/channel"
cp -ra ../artifacts/channel ./network/fabric/test/channel
echo "Copy ../artifacts/crypto-config to ./network/fabric/test/crypto-config"
cp -ra ../artifacts/crypto-config ./network/fabric/test/crypto-config
# copy chaincode into src/contract/fabric/<folder> from ./chaincode
echo "Copy ../chaincode to ./src/contract/fabric/test"
cp -ra ../chaincode ./src/contract/fabric/test
