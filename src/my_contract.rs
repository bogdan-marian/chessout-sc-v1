#![no_std]

elrond_wasm::imports!();
elrond_wasm::derive_imports!();

mod nft_module;

#[derive(TypeAbi, TopEncode, TopDecode)]
pub struct ExampleAttributes {
    pub creation_timestamp: u64,
}

#[elrond_wasm::derive::contract]
pub trait MyContract :nft_module::NftModule{

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

    #[allow(clippy::too_many_arguments)]
    #[only_owner]
    #[endpoint(createNft)]
    fn create_nft(
        &self,
        name: ManagedBuffer,
        royalties: BigUint,
        uri: ManagedBuffer,
        selling_price: BigUint,
        #[var_args] opt_token_used_as_payment: OptionalArg<TokenIdentifier>,
        #[var_args] opt_token_used_as_payment_nonce: OptionalArg<u64>,
    ) -> SCResult<u64> {
        let token_used_as_payment = opt_token_used_as_payment
            .into_option()
            .unwrap_or_else(|| TokenIdentifier::egld());

        let token_used_as_payment_nonce = if token_used_as_payment.is_egld() {
            0
        } else {
            opt_token_used_as_payment_nonce
                .into_option()
                .unwrap_or_default()
        };

        let attributes = ExampleAttributes {
            creation_timestamp: self.blockchain().get_block_timestamp(),
        };

        self.create_nft_with_attributes(
            name,
            royalties,
            attributes,
            uri,
            selling_price,
            token_used_as_payment,
            token_used_as_payment_nonce,
        )
    }

    // <storage section>
    
    #[storage_set("owner")]
    fn set_owner(&self, address: &ManagedAddress);

    #[view(getCounter)]
    #[storage_mapper("counter")]
    fn counter(&self) -> SingleValueMapper<u16>;
}