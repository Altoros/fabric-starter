# General
For network testing [Caliper](https://github.com/hyperledger/caliper) is used. 
Network should be configured and up.

## Init
To properly initialize the test, make sure that all files were generated (`network.sh -m generate`).

To setup the test please issue
```bash
$ ./init.sh
```

## Results
After test execution generated report can be found in `/reports` folder.

Next, please configure benchmark `benchmark/test` folder:
- `add.js` and `query.js` - please speficy your chaincode name and version, function name and input/query parameters
- `config.json` - [test configuration](https://github.com/hyperledger/caliper/blob/master/docs/Architecture.md#configuration-file)
- `fabric.json` - network configuration. All the parameters can be fetched from the `artifacts/network-config.json` file.

## Start
```bash
$ ./start.sh
```

## TODO
1. automate `fabric.json` configuration
2. automate network deployment (executing network.sh from the framework)

