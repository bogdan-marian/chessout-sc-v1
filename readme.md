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
[convert hex to decimal](https://stackoverflow.com/questions/13280131/hexadecimal-to-decimal-in-shell-script/13280173#13280173)

```bash
echo $((16#0f))
```

[dev net explorer](https://devnet-explorer.elrond.com/)
[esdt transfer with method invocation](https://docs.elrond.com/developers/esdt-tokens/#transfers-to-a-smart-contract)
[gasScheduleV5.toml](https://github.com/ElrondNetwork/elrond-go/blob/master/cmd/node/config/gasSchedules/gasScheduleV5.toml)

owner: `erd1qyu5wthldzr8wx5c9ucg8kjagg0jfs53s8nr3zpz3hypefsdd8ssycr6th`
contract: `erd1qqqqqqqqqqqqqpgqy5u6zj9ac0ar4e2ed2vtvltahtpnxy85d8ss528g22`
token: `TEST001-75f6bd`
current problem: `too much gas provided: gas needed = 3124104, gas remained = 543283186`

## create struct ouside storage mapper

```rust
self .price_tag(token.nonce).set(PriceTag{
price: token.price,
nonce: token.nonce,
etc....
});
```

## burn nft the fast way

If you only want to decrease the circulating supply, you can simply send your ESDT to the burn address:
`erd1deaddeaddeaddeaddeaddeaddeaddeaddeaddeaddeaddeaddeaqtv0gag`

btw, I don't know how the total supply of an ESDT is calculated on Elrond (Total minted = total supply?, if so, burning
locally doesn't decrease the total ESDT minted so doesn't decrease the total supply)

## how to encode some parameters

```rust
//Martin Wagner | CIO | Knights of Cathena, [18.12.21 15:31]
//And here some code :)

const payload = TransactionPayload.contractCall()
    .setFunction(new ContractFunction("ESDTNFTTransfer"))
    .setArgs([
                 BytesValue.fromUTF8(this.config.nftToken),
                 new U64Value(nonce),
             new BigUIntValue(new BigNumber(1)),
             new AddressValue(this.smartContract.getAddress()),
             BytesValue.fromUTF8("myFunction"),
             new BigUIntValue(myFunctionArg),
             ])
    .build();
return new Transaction({
receiver: sender,
gasLimit: new GasLimit(5000000),
data: payload,
});
```

## get tokenId explained

## hex conversions

```bash

# assign text value
TOURNAMENT_ID="tournament-02"

# convert to hex
echo -n ${TOURNAMENT_ID} | xxd -p

# revers from hex to asci
xxd -r -p <<<746f75726e616d656e742d3032

```