#!/usr/bin/env bash
VERSION=$(printenv FABRIC_VERSION)
npm i grpc@1.10.1 fabric-ca-client@${VERSION} fabric-client@${VERSION}
npm i
npm rebuild
node benchmark/test/main
cp $(ls | grep report) ./reports