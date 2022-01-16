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