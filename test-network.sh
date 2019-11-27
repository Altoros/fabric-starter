#!/usr/bin/env bash

composeTemplatesFolder="docker-compose-templates"
artifactsTemplatesFolder="artifact-templates"
: ${FABRIC_STARTER_HOME:=$PWD}
: ${TEMPLATES_ARTIFACTS_FOLDER:=$FABRIC_STARTER_HOME/$artifactsTemplatesFolder}
: ${TEMPLATES_DOCKER_COMPOSE_FOLDER:=$FABRIC_STARTER_HOME/$composeTemplatesFolder}
: ${GENERATED_ARTIFACTS_FOLDER:=./artifacts}
: ${GENERATED_DOCKER_COMPOSE_FOLDER:=./dockercompose}
: ${DOMAIN:="example.com"}
: ${ORG1:="a"}
: ${ORG2:="b"}
: ${ORG3:="c"}
CHAINCODE_COMMON_NAME=reference
CHAINCODE_BILATERAL_NAME=relationship
CHAINCODE_COMMON_INIT='{"Args":["init","a","100","b","100"]}'
CHAINCODE_BILATERAL_INIT='{"Args":["init","a","100","b","100"]}'
COLLECTION_CONFIG='$GOPATH/src/reference/collections_config.json'

COMMON_POLICY="AND('a.member','b.member','c.member')"
CH_AB_POLICY=""
CH_AC_POLICY=""

chaincode_version="$(od -vAn -N4 -tu4 < /dev/urandom)" # Randomise version to not enter it manually.


function installChaincode() {
    org=$1
    n=$2
    v=$3
    f="$GENERATED_DOCKER_COMPOSE_FOLDER/docker-compose-${org}.yaml"
    # chaincode path is the same as chaincode name by convention: code of chaincode instruction lives in ./chaincode/go/instruction mapped to docker path /opt/gopath/src/instruction
    p=${n}
    #p=/opt/chaincode/node
    l=golang
    #l=node

    info "installing chaincode $n to peers of $org from ./chaincode/go/$p $v using $f"

    echo "docker-compose --file ${f} run --rm \"cli.$org.$DOMAIN\" bash -c \"CORE_PEER_ADDRESS=peer0.$org.$DOMAIN:7051 peer chaincode install -n $n -v $v -p $p -l $l "
    echo " && CORE_PEER_ADDRESS=peer1.$org.$DOMAIN:7051 peer chaincode install -n $n -v $v -p $p -l $l\""

    docker-compose --file ${f} run --rm "cli.$org.$DOMAIN" bash -c "CORE_PEER_ADDRESS=peer0.$org.$DOMAIN:7051 peer chaincode install -n $n -v $v -p $p -l $l \
    && CORE_PEER_ADDRESS=peer1.$org.$DOMAIN:7051 peer chaincode install -n $n -v $v -p $p -l $l"
}

function upgradeChaincode() {
    org=$1
    channel_name=$2
    v=$3
    n=$4
    i=$5
    policy=$6
    if [ -n "$policy" ]; then policy="-P \"$policy\""; else policy=""; fi

    cc=$7
    if [ -z "$cc" ]; then
    cc=""
    else
    cc="--collections-config $cc"
    fi

    f="$GENERATED_DOCKER_COMPOSE_FOLDER/docker-compose-${org}.yaml"

    for peer in "peer0"; do
      #  for channel_name in ${channel_names[@]}; do
            info "Upgrading chaincode $n on $channel_name by $org using $f with policy $policy and $i"

            c="CORE_PEER_ADDRESS=$peer.$org.$DOMAIN:7051 peer chaincode upgrade -n $n -v ${v} -c '$i' -o orderer.$DOMAIN:7050 -C $channel_name $cc $policy --tls --cafile /etc/hyperledger/crypto/orderer/tls/ca.crt"
            d="cli.$org.$DOMAIN"

            echo "Upgrading with $d by $c"
            docker-compose --file ${f} run --rm ${d} bash -c "${c}"
    #    done
    done
}


echo "=== Upgrading all chaincodes with $chaincode_version"

for org in ${ORG1} ${ORG2} ${ORG3}
do
    for chaincode_name in ${CHAINCODE_COMMON_NAME} ${CHAINCODE_BILATERAL_NAME}
    do
      installChaincode "${org}" "${chaincode_name}" $chaincode_version
    done
done

# Upgrade chaincodes

upgradeChaincode "${ORG1}" "common" "$chaincode_version" "${CHAINCODE_COMMON_NAME}" "${CHAINCODE_COMMON_INIT}" "$COMMON_POLICY" "${COLLECTION_CONFIG}"
upgradeChaincode "${ORG1}" "common" "$chaincode_version" "${CHAINCODE_BILATERAL_NAME}" "${CHAINCODE_BILATERAL_INIT}" "$COMMON_POLICY" "${COLLECTION_CONFIG}"
upgradeChaincode "${ORG1}" "${ORG1}-${ORG2}" "$chaincode_version" "${CHAINCODE_BILATERAL_NAME}" "${CHAINCODE_BILATERAL_INIT}" "$CH_AB_POLICY" "${COLLECTION_CONFIG}"
upgradeChaincode "${ORG1}" "${ORG1}-${ORG3}" "$chaincode_version" "${CHAINCODE_BILATERAL_NAME}" "${CHAINCODE_BILATERAL_INIT}" "$CH_AC_POLICY" "${COLLECTION_CONFIG}"

echo "=== Testing chaincodes"

#docker exec cli.${ORG1}.${DOMAIN} bash -c "export CORE_PEER_ADDRESS=peer0.a.example.com:7051 && peer chaincode invoke -n reference -c '{\"Args\":[\"invokeChaincode\",\"common\",\"relationship\",\"move\",\"a\",\"b\",\"15\"]}' -o orderer.example.com:7050 -C common --tls --cafile /etc/hyperledger/crypto/orderer/tls/ca.crt"
docker exec cli.${ORG1}.${DOMAIN} bash -c "export CORE_PEER_ADDRESS=peer0.a.example.com:7051 && peer chaincode invoke -n reference -c '{\"Args\":[\"move\",\"a\",\"b\",\"23\"]}' -o orderer.example.com:7050 -C common --tls --cafile /etc/hyperledger/crypto/orderer/tls/ca.crt"
#docker exec cli.${ORG1}.${DOMAIN} bash -c "export CORE_PEER_ADDRESS=peer0.a.example.com:7051 && peer chaincode invoke -n reference -c '{\"Args\":[\"invokeChaincode\",\"common\",\"relationship\",\"query\",\"a\"]}' -o orderer.example.com:7050 -C common --tls --cafile /etc/hyperledger/crypto/orderer/tls/ca.crt"
#docker exec cli.${ORG1}.${DOMAIN} bash -c "export CORE_PEER_ADDRESS=peer0.a.example.com:7051 && peer chaincode query -n reference -c '{\"Args\":[\"getResponse\"]}' -o orderer.example.com:7050 -C common --tls --cafile /etc/hyperledger/crypto/orderer/tls/ca.crt"
