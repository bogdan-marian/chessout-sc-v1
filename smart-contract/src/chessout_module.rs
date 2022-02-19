use elrond_wasm::elrond_codec::TopEncode;

elrond_wasm::imports!();
elrond_wasm::derive_imports!();

#[derive(TypeAbi, TopEncode, TopDecode, ManagedVecItem, NestedEncode, NestedDecode)]
pub struct TournamentInfo<M: ManagedTypeApi> {
    pub tournament_id: BoxedBytes,
    pub token_identifier: TokenIdentifier<M>,
    pub sing_in_price: BigUint<M>,
    pub manager: ManagedAddress<M>,
    pub funds: BigUint<M>,
    pub participants: ManagedVec<M, ManagedAddress<M>>,
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
        let _participants: ManagedVec<ManagedAddress> = ManagedVec::new();

        let info = TournamentInfo {
            tournament_id: (_tournament_id),
            token_identifier: (_token_identifier),
            sing_in_price: (_sing_in_price),
            manager: (_manager),
            funds: (_funds),
            participants: (_participants),
        };
        self.tournament_info(&info.tournament_id).set(&info);

        Ok(())
    }

    #[view(getTournamentInfoList)]
    fn get_tournament_info_list(&self, idList: ManagedVarArgs<BoxedBytes>)
                                -> ManagedVec<TournamentInfo<Self::Api>> {
        let mut v: ManagedVec<TournamentInfo<Self::Api>> = ManagedVec::new();
        for vi in idList {
            let info = self.tournament_info(&vi);
            v.push(info.get());
        }
        return v;
    }

    // storage

    #[view(getTournamentInfo)]
    #[storage_mapper("tournamentInfo")]
    fn tournament_info(&self, tournament_id: &BoxedBytes) -> SingleValueMapper<TournamentInfo<Self::Api>>;
}