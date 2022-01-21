# create step by step

```bash
# create the project
cargo new my-contract

# build the wasm folder
# build nested project and rename to wasm
cd my-contract
cargo new my-contract
mv my-contract/ wasm/

# add the meta crate
cargo new meta
```

## random nonce note
```
Martin Wagner | CIO | Knights of Cathena, [20.01.22 21:53]
[In reply to Bogdan Oloeriu]
it's the nonce of the nft you just created :) It will start at 1 and increase for every created nft :)
```

## random notes
testnet-bogdan: `erd1mhhnd3ux2duwc9824dhelherdj3gvzn04erdw29l8cyr5z8fpa7quda68z`
erdpy --verbose wallet derive testnet-bogdan.pem --mnemonic

[token name restrictions](https://docs.elrond.com/developers/esdt-tokens/#parameters-format)