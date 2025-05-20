#[cfg(test)]
mod user_registry_tests {
    use starknet::ContractAddress;
    use snforge_std::{
        declare, deploy, start_prank, stop_prank, CheatTarget, spy_events, EventFetcher, selector,
        assert_eq
    };

    use contracts::UserRegistry::{
        IUserRegistryDispatcher, IUserRegistryDispatcherTrait, UserProfile,
        UserRegistered, ActivityLog
    };
    use core::traits::{TryInto, Into};
    use core::array::ArrayTrait;
    use core::option::OptionTrait;
    use core::num::traits::Zero;

    // Test addresses
    fn admin_address() -> ContractAddress {
        1_felt252.try_into().unwrap()
    }

    fn user1_address() -> ContractAddress {
        2_felt252.try_into().unwrap()
    }

    fn user2_address() -> ContractAddress {
        3_felt252.try_into().unwrap()
    }
    
    fn zero_address() -> ContractAddress {
        0_felt252.try_into().unwrap()
    }

    // Helper function to deploy UserRegistry contract
    fn deploy_user_registry(initial_admin_address: ContractAddress) -> IUserRegistryDispatcher {
        let contract_class = declare("UserRegistry");
        let constructor_calldata = array![initial_admin_address.into()];
        let contract_address = deploy(contract_class.class_hash, constructor_calldata)
            .expect("Deploy failed");
        IUserRegistryDispatcher { contract_address }
    }

    #[test]
    fn test_constructor_deploys_successfully() {
        let admin_addr = admin_address();
        let dispatcher = deploy_user_registry(admin_addr);
        assert(!dispatcher.contract_address.is_zero(), 'Contract address is zero');
    }

    #[test]
    fn test_register_user_success_and_event() {
        let dispatcher = deploy_user_registry(admin_address());
        let mut events_spy = spy_events(CheatTarget::One(dispatcher.contract_address));
        
        // Registrar usuario
        let user_id = dispatcher.register_user(12345, 67890);
        
        // Verificar evento
        let mut emitted_events = events_spy.fetch_events();
        let user_registered_event = ArrayTrait::pop_front(ref emitted_events).unwrap();
        
        // Verificar perfil
        let profile = dispatcher.get_user_profile(user1_address());
        assert(profile.user_id == user_id.try_into().unwrap(), 'User ID mismatch');
        assert(profile.username_ipfs_cid.low == 12345, 'Username low mismatch');
        assert(profile.username_ipfs_cid.high == 67890, 'Username high mismatch');
        assert(profile.level == 1, 'Initial level should be 1');
        assert(profile.xp.low == 0, 'Initial XP should be 0');
        assert(profile.reputation == 0, 'Initial reputation should be 0');
    }

    #[test]
    #[should_panic(expected: ('USER_ALREADY_REGISTERED',))]
    fn test_register_user_fails_if_already_registered() {
        let dispatcher = deploy_user_registry(admin_address());
        
        // Registrar usuario por primera vez
        dispatcher.register_user(12345, 67890);
        
        // Intentar registrar el mismo usuario de nuevo
        dispatcher.register_user(12345, 67890);
    }

    #[test]
    fn test_get_user_profile_for_unregistered_user_returns_defaults() {
        let dispatcher = deploy_user_registry(admin_address());
        let profile = dispatcher.get_user_profile(user1_address());
        assert(profile.user_id == 0, 'User ID should be 0 for unregistered user');
    }

    #[test]
    fn test_update_user_xp_and_level() {
        let dispatcher = deploy_user_registry(admin_address());
        
        // Registrar usuario
        let user_id = dispatcher.register_user(12345, 67890);
        
        // Actualizar XP y nivel
        dispatcher.update_user_xp_and_level(user1_address(), 100);
        
        // Verificar cambios
        let profile = dispatcher.get_user_profile(user1_address());
        assert(profile.xp.low == 100, 'XP should be updated');
        assert(profile.level == 1, 'Level should still be 1');
        
        // Actualizar a nivel 2
        dispatcher.update_user_xp_and_level(user1_address(), 50);
        let profile = dispatcher.get_user_profile(user1_address());
        assert(profile.xp.low == 150, 'XP should be 150');
        assert(profile.level == 2, 'Level should be 2');
        
        // Actualizar a nivel 3
        dispatcher.update_user_xp_and_level(user1_address(), 400);
        let profile = dispatcher.get_user_profile(user1_address());
        assert(profile.xp.low == 550, 'XP should be 550');
        assert(profile.level == 3, 'Level should be 3');
    }
    
    #[test]
    fn test_update_user_reputation() {
        let dispatcher = deploy_user_registry(admin_address());
        
        // Registrar usuario
        let user_id = dispatcher.register_user(12345, 67890);
        
        // Actualizar reputación
        dispatcher.update_user_reputation(user1_address(), 10);
        
        // Verificar cambios
        let profile = dispatcher.get_user_profile(user1_address());
        assert(profile.reputation == 10, 'Reputation should be updated');
        
        // Actualizar reputación negativa
        dispatcher.update_user_reputation(user1_address(), -5);
        let profile = dispatcher.get_user_profile(user1_address());
        assert(profile.reputation == 5, 'Reputation should be 5');
    }
    
    #[test]
    fn test_log_user_activity() {
        let dispatcher = deploy_user_registry(admin_address());
        
        // Registrar usuario
        let user_id = dispatcher.register_user(12345, 67890);
        
        // Registrar actividad
        dispatcher.log_user_activity(user1_address(), 'challenge_completed', 1);
        
        // Verificar contador de actividades
        let activity_count = dispatcher.get_user_activity_count(user1_address());
        assert(activity_count == 1, 'Activity count should be 1');
        
        // Verificar actividad
        let activity = dispatcher.get_user_activity_log_entry(user1_address(), 0);
        assert(activity.activity_type == 'challenge_completed', 'Activity type mismatch');
        assert(activity.related_challenge_id == 1, 'Challenge ID mismatch');
    }
    
    #[test]
    fn test_get_user_id_by_wallet() {
        let user_registry = deploy_user_registry(admin_address());
        
        // Verify unregistered wallet returns 0
        let non_registered_id = user_registry.get_user_id_by_wallet(user1_address());
        assert_eq(non_registered_id, 0, 'ID for unregistered wallet should be 0');
        
        // Register a user
        start_prank(CheatTarget::One(user_registry.contract_address), user1_address());
        let user_id = user_registry.register_user(12345, 67890);
        stop_prank(CheatTarget::One(user_registry.contract_address));
        
        // Verify returns correct ID
        let registered_id = user_registry.get_user_id_by_wallet(user1_address());
        assert_eq(registered_id, user_id, 'ID for registered wallet should match');
    }

    #[test]
    fn test_badge_management() {
        let dispatcher = deploy_user_registry(admin_address());
        
        // Registrar usuario
        let user_id = dispatcher.register_user(12345, 67890);
        
        // Añadir badge
        dispatcher.add_badge(user1_address(), 1);
        
        // Verificar badge
        let has_badge = dispatcher.has_badge(user1_address(), 1);
        assert(has_badge, 'User should have badge 1');
        
        // Remover badge
        dispatcher.remove_badge(user1_address(), 1);
        
        // Verificar badge removido
        let has_badge = dispatcher.has_badge(user1_address(), 1);
        assert(!has_badge, 'User should not have badge 1');
    }

    #[test]
    #[should_panic(expected: ('Not admin',))]
    fn test_non_admin_cannot_add_badge() {
        let dispatcher = deploy_user_registry(admin_address());
        
        // Registrar usuario
        let user_id = dispatcher.register_user(12345, 67890);
        
        // Intentar añadir badge como no-admin
        start_prank(CheatTarget::One(user1_address()));
        dispatcher.add_badge(user1_address(), 1);
        stop_prank(CheatTarget::One(user1_address()));
    }

    #[test]
    fn test_set_admin() {
        let dispatcher = deploy_user_registry(admin_address());
        
        // Cambiar admin
        dispatcher.set_admin(user1_address());
        
        // Verificar que el nuevo admin puede realizar acciones de admin
        start_prank(CheatTarget::One(user1_address()));
        dispatcher.add_badge(user2_address(), 1);
        stop_prank(CheatTarget::One(user1_address()));
    }

    #[test]
    #[should_panic(expected: ('Not admin',))]
    fn test_non_admin_cannot_set_admin() {
        let dispatcher = deploy_user_registry(admin_address());
        
        // Intentar cambiar admin como no-admin
        start_prank(CheatTarget::One(user1_address()));
        dispatcher.set_admin(user2_address());
        stop_prank(CheatTarget::One(user1_address()));
    }

    #[test]
    #[should_panic(expected: ('Zero address not allowed',))]
    fn test_cannot_set_zero_address_as_admin() {
        let dispatcher = deploy_user_registry(admin_address());
        dispatcher.set_admin(zero_address());
    }
}