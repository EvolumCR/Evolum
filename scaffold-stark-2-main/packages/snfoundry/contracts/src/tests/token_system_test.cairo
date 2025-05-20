#[cfg(test)]
mod token_system_tests {
    use starknet::ContractAddress;
    use snforge_std::{
        declare, deploy, start_prank, stop_prank, CheatTarget, spy_events, EventFetcher, selector,
        assert_eq
    };

    // Importar el contrato TokenSystem
    use contracts::TokenSystem::{
        ITokenSystemDispatcher, ITokenSystemDispatcherTrait,
        XpMinted, BadgeMinted // Eventos
    };
    use core::traits::{TryInto, Into};
    use core::array::ArrayTrait;
    use core::option::OptionTrait;

    // Constantes para direcciones de prueba
    fn admin_address() -> ContractAddress {
        1_felt252.try_into().expect("Admin address invalid")
    }

    fn user1_address() -> ContractAddress {
        2_felt252.try_into().expect("User1 address invalid")
    }

    fn user2_address() -> ContractAddress {
        3_felt252.try_into().expect("User2 address invalid")
    }
    
    fn validator1_address() -> ContractAddress {
        4_felt252.try_into().expect("Validator1 address invalid")
    }
    
    fn validator2_address() -> ContractAddress {
        5_felt252.try_into().expect("Validator2 address invalid")
    }

    // Función auxiliar para desplegar el contrato TokenSystem
    fn deploy_token_system(initial_admin_address: ContractAddress) -> ITokenSystemDispatcher {
        let contract_class = declare("TokenSystem");
        let constructor_args = array![initial_admin_address.into()];
        let contract_address = deploy(contract_class, constructor_args).unwrap();
        ITokenSystemDispatcher { contract_address }
    }

    #[test]
    fn test_mint_xp() {
        // Desplegar contrato
        let token_system = deploy_token_system(admin_address());
        
        // Acuñar XP como admin
        start_prank(CheatTarget::One(token_system.contract_address), admin_address());
        token_system.mint_xp(user1_address(), 100);
        stop_prank(CheatTarget::One(token_system.contract_address));
        
        // Verificar balance
        let balance = token_system.get_xp_balance(user1_address());
        assert_eq(balance, 100, "Balance de XP debe ser 100");
    }
    
    #[test]
    fn test_transfer_xp() {
        // Desplegar contrato
        let token_system = deploy_token_system(admin_address());
        
        // Acuñar XP para user1
        start_prank(CheatTarget::One(token_system.contract_address), admin_address());
        token_system.mint_xp(user1_address(), 100);
        
        // Transferir XP de user1 a user2
        token_system.transfer_xp(user1_address(), user2_address(), 30);
        stop_prank(CheatTarget::One(token_system.contract_address));
        
        // Verificar balances
        let balance1 = token_system.get_xp_balance(user1_address());
        let balance2 = token_system.get_xp_balance(user2_address());
        assert_eq(balance1, 70, "Balance de user1 debe ser 70");
        assert_eq(balance2, 30, "Balance de user2 debe ser 30");
    }
    
    #[test]
    fn test_mint_badge() {
        // Desplegar contrato
        let token_system = deploy_token_system(admin_address());
        
        // Acuñar badge como admin
        start_prank(CheatTarget::One(token_system.contract_address), admin_address());
        let badge_id = token_system.mint_badge(user1_address(), 'ipfs://badge_metadata');
        stop_prank(CheatTarget::One(token_system.contract_address));
        
        // Verificar propiedad del badge
        let has_badge = token_system.has_badge(user1_address(), badge_id);
        assert(has_badge, "El usuario debe tener el badge");
        
        // Verificar contador de badges
        let badge_count = token_system.get_user_badge_count(user1_address());
        assert_eq(badge_count, 1, "El usuario debe tener 1 badge");
    }
    
    #[test]
    fn test_distribute_rewards() {
        // Desplegar contrato
        let token_system = deploy_token_system(admin_address());
        
        // Crear array de validadores
        let mut validators = ArrayTrait::new();
        validators.append(validator1_address());
        validators.append(validator2_address());
        
        // Distribuir recompensas como admin
        start_prank(CheatTarget::One(token_system.contract_address), admin_address());
        token_system.distribute_rewards(user1_address(), validators, 100);
        stop_prank(CheatTarget::One(token_system.contract_address));
        
        // Verificar balances
        // Participante: 70%
        let participant_balance = token_system.get_xp_balance(user1_address());
        assert_eq(participant_balance, 70, "El participante debe recibir 70% (70 XP)");
        
        // Validadores: 20% dividido entre 2
        let validator1_balance = token_system.get_xp_balance(validator1_address());
        let validator2_balance = token_system.get_xp_balance(validator2_address());
        assert_eq(validator1_balance, 10, "Validator1 debe recibir 10 XP");
        assert_eq(validator2_balance, 10, "Validator2 debe recibir 10 XP");
    }
    
    #[test]
    fn test_authorize_contract() {
        // Desplegar contrato
        let token_system = deploy_token_system(admin_address());
        
        // Autorizar un contrato (simulado por user2_address)
        start_prank(CheatTarget::One(token_system.contract_address), admin_address());
        token_system.authorize_contract(user2_address());
        stop_prank(CheatTarget::One(token_system.contract_address));
        
        // Ahora user2 debería poder acuñar XP
        start_prank(CheatTarget::One(token_system.contract_address), user2_address());
        token_system.mint_xp(user1_address(), 50);
        stop_prank(CheatTarget::One(token_system.contract_address));
        
        // Verificar que se acuñó XP
        let balance = token_system.get_xp_balance(user1_address());
        assert_eq(balance, 50, "El balance debe ser 50 XP");
    }
}