#![no_std]

elrond_wasm::imports!();
elrond_wasm::derive_imports!();

mod nft_module;


#[elrond_wasm::derive::contract]
pub trait MyContract {

    #[init]
    fn init(&self) {
        let _my_address: ManagedAddress = self.blockchain().get_caller();
        self.set_owner(&_my_address);
    }

    #[endpoint]
    fn increment(&self) -> SCResult<()> {
        self.counter().update(|counter| *counter += 1);
        let _initial_count = 0;
        self.counter().set(&_initial_count);
        Ok(())
    }

    // <storage section>
    
    #[storage_set("owner")]
    fn set_owner(&self, address: &ManagedAddress);

    #[view(getCounter)]
    #[storage_mapper("counter")]
    fn counter(&self) -> SingleValueMapper<u16>;
}