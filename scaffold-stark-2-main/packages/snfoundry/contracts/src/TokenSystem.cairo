// TokenSystem.cairo - Sistema de tokens y recompensas
// Implementa la funcionalidad descrita en PRD 3.1.3

use starknet::ContractAddress;

#[starknet::contract]
mod TokenSystem {
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use starknet::storage::{StorageMapReadAccess, StorageMapWriteAccess, StoragePointerReadAccess, StoragePointerWriteAccess};

    const ERROR_NOT_ADMIN: felt252 = 'Not admin';
    const ERROR_NOT_AUTHORIZED: felt252 = 'Not authorized';

    // Eventos
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        XpMinted: XpMinted,
        XpTransferred: XpTransferred,
        BadgeMinted: BadgeMinted,
    }

    #[derive(Drop, starknet::Event)]
    struct XpMinted {
        recipient: ContractAddress,
        amount: u128,
    }

    #[derive(Drop, starknet::Event)]
    struct XpTransferred {
        sender: ContractAddress,
        recipient: ContractAddress,
        amount: u128,
    }

    #[derive(Drop, starknet::Event)]
    struct BadgeMinted {
        recipient: ContractAddress,
        badge_id: u128,
        metadata_uri: felt252,
    }

    // Almacenamiento
    #[storage]
    struct Storage {
        admin_address: ContractAddress,
        authorized_contracts: starknet::storage::Map<ContractAddress, bool>,
        xp_balances: starknet::storage::Map<ContractAddress, u128>,
        badge_owners: starknet::storage::Map<u128, ContractAddress>,
        user_badges: starknet::storage::Map<(ContractAddress, u128), bool>,
        user_badge_count: starknet::storage::Map<ContractAddress, u128>,
        next_badge_id: u128,
        community_fund: u128,
    }

    // Constructor
    #[constructor]
    fn constructor(ref self: ContractState, initial_admin_address: ContractAddress) {
        self.admin_address.write(initial_admin_address);
        self.next_badge_id.write(1);
    }

    // Modificador para funciones que solo el admin puede llamar
    fn assert_only_admin(self: @ContractState) {
        let caller = get_caller_address();
        assert(caller == self.admin_address.read(), ERROR_NOT_ADMIN);
    }

    // Modificador para funciones que solo contratos autorizados pueden llamar
    fn only_authorized(self: @ContractState) {
        let _caller = get_caller_address();
        assert(self.authorized_contracts.read(_caller), ERROR_NOT_AUTHORIZED);
    }

    #[abi(embed_v0)]
    impl TokenSystemImpl of super::ITokenSystem<ContractState> {
        fn mint_xp(ref self: ContractState, recipient: ContractAddress, amount: u128) {
            only_authorized(@self);
            
            let _current_balance = self.xp_balances.read(recipient);
            self.xp_balances.write(recipient, _current_balance + amount);
            
            self.emit(XpMinted { recipient, amount });
        }

        fn transfer_xp(
            ref self: ContractState, 
            sender: ContractAddress, 
            recipient: ContractAddress, 
            amount: u128
        ) {
            only_authorized(@self);
            
            let sender_balance = self.xp_balances.read(sender);
            assert(sender_balance >= amount, 'TokenSystem: insufficient XP');
            
            self.xp_balances.write(sender, sender_balance - amount);
            let _recipient_balance = self.xp_balances.read(recipient);
            self.xp_balances.write(recipient, _recipient_balance + amount);
        }

        fn get_xp_balance(self: @ContractState, user_address: ContractAddress) -> u128 {
            self.xp_balances.read(user_address)
        }

        fn mint_badge(ref self: ContractState, recipient: ContractAddress, metadata_uri: felt252) -> u128 {
            only_authorized(@self);
            
            let badge_id = self.next_badge_id.read();
            self.next_badge_id.write(badge_id + 1);
            
            self.badge_owners.write(badge_id, recipient);
            
            let _user_badge_count = self.user_badge_count.read(recipient);
            self.user_badges.write((recipient, _user_badge_count), true);
            self.user_badge_count.write(recipient, _user_badge_count + 1);
            
            self.emit(Event::BadgeMinted(BadgeMinted { recipient, badge_id, metadata_uri }));
            
            badge_id
        }

        fn has_badge(self: @ContractState, user_address: ContractAddress, badge_id: u128) -> bool {
            self.badge_owners.read(badge_id) == user_address
        }

        fn get_user_badge_count(self: @ContractState, user_address: ContractAddress) -> u128 {
            self.user_badge_count.read(user_address)
        }

        fn authorize_contract(ref self: ContractState, contract_address: ContractAddress) {
            assert_only_admin(@self);
            self.authorized_contracts.write(contract_address, true);
        }

        fn revoke_contract_authorization(ref self: ContractState, contract_address: ContractAddress) {
            assert_only_admin(@self);
            self.authorized_contracts.write(contract_address, false);
        }

        fn distribute_rewards(
            ref self: ContractState, 
            participant: ContractAddress, 
            validators: Array<ContractAddress>, 
            xp_reward: u128
        ) {
            only_authorized(@self);
            
            let participant_reward = (xp_reward * 70) / 100;
            let validators_reward = (xp_reward * 20) / 100;
            let mut community_reward = xp_reward - participant_reward - validators_reward;
            
            let _current_participant_balance = self.xp_balances.read(participant);
            self.xp_balances.write(participant, _current_participant_balance + participant_reward);
            
            let mut validators_span = validators.span();
            let validator_count = validators_span.len();
            
            if validator_count > 0 {
                let _reward_per_validator = validators_reward / validator_count.into();
                
                loop {
                    match validators_span.pop_front() {
                        Option::Some(_validator) => {
                            let _current_validator_balance = self.xp_balances.read(*_validator);
                            self.xp_balances.write(*_validator, _current_validator_balance + _reward_per_validator);
                        },
                        Option::None => { break; }
                    };
                };
            } else {
                community_reward += validators_reward;
            }
            
            let _current_community_fund = self.community_fund.read();
            self.community_fund.write(_current_community_fund + community_reward);
        }

        fn set_admin(ref self: ContractState, new_admin: ContractAddress) {
            assert_only_admin(@self);
            self.admin_address.write(new_admin);
        }
    }
}

// Interfaz externa del contrato
#[starknet::interface]
trait ITokenSystem<TContractState> {
    fn mint_xp(ref self: TContractState, recipient: ContractAddress, amount: u128);
    fn transfer_xp(ref self: TContractState, sender: ContractAddress, recipient: ContractAddress, amount: u128);
    fn get_xp_balance(self: @TContractState, user_address: ContractAddress) -> u128;
    fn mint_badge(ref self: TContractState, recipient: ContractAddress, metadata_uri: felt252) -> u128;
    fn has_badge(self: @TContractState, user_address: ContractAddress, badge_id: u128) -> bool;
    fn get_user_badge_count(self: @TContractState, user_address: ContractAddress) -> u128;
    fn authorize_contract(ref self: TContractState, contract_address: ContractAddress);
    fn revoke_contract_authorization(ref self: TContractState, contract_address: ContractAddress);
    fn distribute_rewards(ref self: TContractState, participant: ContractAddress, validators: Array<ContractAddress>, xp_reward: u128);
    fn set_admin(ref self: TContractState, new_admin: ContractAddress);
}