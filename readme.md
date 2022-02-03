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

