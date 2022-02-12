elrond_wasm::imports!();
elrond_wasm::derive_imports!();

use elrond_wasm::elrond_codec::TopEncode;

#[derive(TypeAbi, TopEncode, TopDecode)]
pub struct TournamentInfo<M: ManagedTypeApi> {
    pub tournament_id: BoxedBytes,
    pub token_identifier: TokenIdentifier<M>,
    pub sing_in_price: BigUint<M>,
    pub manager: ManagedAddress<M>,
    pub timestamp: u64,
    pub funds: BigUint<M>,
    pub participants: Vec<ManagedAddress<M>>,
}


#[elrond_wasm::module]
pub trait ChessoutModule {
    #[endpoint(createTournament)]
    fn create_tournament(
        &self,
        _tournament_id: BoxedBytes,
        _token_identifier: TokenIdentifier,
        _sing_in_price: BigUint,
    ) -> SCResult<()> {
        require!(!_tournament_id.is_empty(), "Tournament id missing");
        let _timestamp = self.blockchain().get_block_timestamp();
        let _manager: ManagedAddress = self.blockchain().get_caller();
        let _funds: BigUint = BigUint::zero();
        let _participants: Vec<ManagedAddress> = Vec::new();

        let info = TournamentInfo {
            tournament_id: (_tournament_id),
            token_identifier: (_token_identifier),
            sing_in_price: (_sing_in_price),
            manager: (_manager),
            timestamp: (_timestamp),
            funds: (_funds),
            participants: (_participants),
        };
        self.tournament_info(&info.tournament_id).set(&info);

        Ok(())
    }


    // storage

    #[view(getTournamentInfo)]
    #[storage_mapper("tournamentInfo")]
    fn tournament_info(&self, tournament_id: &BoxedBytes) -> SingleValueMapper<TournamentInfo<Self::Api>>;
}