elrond_wasm::imports!();
elrond_wasm::derive_imports!();

use alloc::string::String;
use elrond_wasm::elrond_codec::TopEncode;

#[derive(TypeAbi, TopEncode, TopDecode)]
pub struct TournamentInfo<M: ManagedTypeApi> {
    pub token: TokenIdentifier<M>,
    pub manager: ManagedAddress<M>,
    pub funds: BigUint<M>,
    pub sing_in_price: BigUint<M>,
    pub tournament_id: String,
    pub participants: VecMapper<M, ManagedAddress<M>>,
}


#[elrond_wasm::module]
pub trait ChessoutModule {}