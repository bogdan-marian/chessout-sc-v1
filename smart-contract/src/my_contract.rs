#![no_std]

extern crate alloc;
elrond_wasm::imports!();
elrond_wasm::derive_imports!();

mod nft_module;
mod chessout_module;


#[elrond_wasm::derive::contract]
pub trait MyContract: nft_module::NftModule + chessout_module::ChessoutModule {
    #[init]
    fn init(&self) {}
}