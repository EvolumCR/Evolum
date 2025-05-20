// UserRegistry.cairo - Sistema de registro y gestión de usuarios
// Implementa la funcionalidad descrita en PRD 3.1.1

use starknet::ContractAddress;
use starknet::get_caller_address;
use starknet::get_block_timestamp;
use starknet::storage::{StorageMapReadAccess, StorageMapWriteAccess, StoragePointerReadAccess, StoragePointerWriteAccess, Map};
use core::num::traits::Zero;
use core::traits::TryInto;
use core::integer::Uint256;

#[starknet::contract]
mod UserRegistry {
    use super::{ContractAddress, get_caller_address, get_block_timestamp, StorageMapReadAccess, StorageMapWriteAccess, StoragePointerReadAccess, StoragePointerWriteAccess, Map, Zero, TryInto, Uint256};
    use starknet::ContractState;

    const MAX_BADGES: usize = 10;

    // Estructura para el perfil de usuario
    #[derive(Drop, starknet::Store, starknet::Serde)]
    pub struct UserProfile {
        wallet_address: ContractAddress,
        user_id: u64,
        username_ipfs_cid: Uint256,
        xp: Uint256,
        level: u8,
        reputation: i64,
        created_at: u64,
        last_active: u64
    }

    // Estructura para el registro de actividad
    #[derive(Drop, Copy, starknet::Store, starknet::Serde)]
    pub struct ActivityLog {
        activity_type: felt252,
        related_challenge_id: u128,
        timestamp: u64
    }

    // Eventos
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        UserRegistered: UserRegistered,
        UserUpdated: UserUpdated,
        ActivityLogged: ActivityLogged,
        BadgeAdded: BadgeAdded,
        BadgeRemoved: BadgeRemoved
    }

    #[derive(Drop, starknet::Event)]
    struct UserRegistered {
        #[key]
        user_id: u128,
        #[key]
        wallet_address: ContractAddress,
        username_low: u128,
        username_high: u128
    }

    #[derive(Drop, starknet::Event)]
    struct UserUpdated {
        #[key]
        user_id: u128,
        field: felt252,
        old_value: felt252,
        new_value: felt252
    }

    #[derive(Drop, starknet::Event)]
    struct ActivityLogged {
        #[key]
        user_id: u128,
        activity_type: felt252,
        related_challenge_id: u128,
        timestamp: u64
    }

    #[derive(Drop, starknet::Event)]
    struct BadgeAdded {
        #[key]
        user_id: u128,
        badge_id: u128
    }

    #[derive(Drop, starknet::Event)]
    struct BadgeRemoved {
        #[key]
        user_id: u128,
        badge_id: u128
    }

    // Almacenamiento
    #[storage]
    struct Storage {
        admin_address: ContractAddress,
        next_user_id: u128,
        users: Map<ContractAddress, UserProfile>,
        wallet_to_user_id: Map<ContractAddress, u128>,
        user_activity_count: Map<ContractAddress, u128>,
        user_activities: Map<(ContractAddress, u128), ActivityLog>,
        user_badges: Map<(ContractAddress, u128), bool>  // Mapa de (user_id, badge_id) -> bool
    }

    // Constructor
    #[constructor]
    fn constructor(ref self: ContractState, initial_admin_address: ContractAddress) {
        self.admin_address.write(initial_admin_address);
        self.next_user_id.write(1);
    }

    // Errores personalizados como constantes
    const ERROR_NOT_ADMIN: felt252 = 'Not admin';
    const ERROR_USER_NOT_FOUND: felt252 = 'User not found';
    const ERROR_WALLET_ALREADY_REGISTERED: felt252 = 'USER_ALREADY_REGISTERED';
    const ERROR_INDEX_OUT_OF_BOUNDS: felt252 = 'Index out of bounds';
    const ERROR_ZERO_ADDRESS: felt252 = 'Zero address not allowed';
    const ERROR_BADGE_ALREADY_EXISTS: felt252 = 'Badge already exists';
    const ERROR_BADGE_NOT_FOUND: felt252 = 'Badge not found';
    const ERROR_MAX_BADGES_REACHED: felt252 = 'Maximum badges reached';

    // Modificador para funciones que solo el admin puede llamar
    fn assert_only_admin(self: @ContractState) {
        let caller = get_caller_address();
        assert(caller == self.admin_address.read(), ERROR_NOT_ADMIN);
    }

    #[abi(embed_v0)]
    impl UserRegistryImpl of super::IUserRegistry<ContractState> {
        // Registrar un nuevo usuario
        fn register_user(ref self: ContractState, username_low: u128, username_high: u128) -> u128 {
            let caller_address = get_caller_address();
            
            // Verificar que la wallet no esté registrada
            assert(self.wallet_to_user_id.read(caller_address) == 0, ERROR_WALLET_ALREADY_REGISTERED);
            
            // Generar nuevo ID de usuario
            let user_id = self.next_user_id.read();
            self.next_user_id.write(user_id + 1);
            
            // Crear perfil de usuario
            let user_profile = UserProfile {
                wallet_address: caller_address,
                user_id: user_id.try_into().unwrap(),
                username_ipfs_cid: Uint256 { low: username_low, high: username_high },
                xp: Uint256 { low: 0, high: 0 },
                level: 1,
                reputation: 0,
                created_at: get_block_timestamp(),
                last_active: get_block_timestamp()
            };
            
            // Guardar datos
            self.users.write(caller_address, user_profile);
            self.wallet_to_user_id.write(caller_address, user_id);
            
            // Emitir evento
            self.emit(Event::UserRegistered(UserRegistered {
                user_id,
                wallet_address: caller_address,
                username_low,
                username_high
            }));
            
            user_id
        }

        // Actualizar XP y nivel de usuario
        fn update_user_xp_and_level(ref self: ContractState, user_address: ContractAddress, xp_amount: u128) {
            assert_only_admin(@self);
            
            let mut user = self.users.read(user_address);
            assert(user.user_id != 0, ERROR_USER_NOT_FOUND);
            
            let old_xp = user.xp.low;
            user.xp.low += xp_amount;
            
            // Actualizar nivel basado en XP
            let new_level = if user.xp.low >= 550 {
                3
            } else if user.xp.low >= 150 {
                2
            } else {
                1
            };
            
            user.level = new_level.try_into().unwrap();
            self.users.write(user_address, user);
            
            // Emitir evento
            self.emit(Event::UserUpdated(UserUpdated {
                user_id: user.user_id.into(),
                field: 'xp',
                old_value: old_xp.into(),
                new_value: user.xp.low.into()
            }));
        }

        // Actualizar reputación de usuario
        fn update_user_reputation(ref self: ContractState, user_address: ContractAddress, reputation_change: i64) {
            assert_only_admin(@self);
            
            let mut user = self.users.read(user_address);
            assert(user.user_id != 0, ERROR_USER_NOT_FOUND);
            
            let old_reputation = user.reputation;
            user.reputation += reputation_change;
            self.users.write(user_address, user);
            
            // Emitir evento
            self.emit(Event::UserUpdated(UserUpdated {
                user_id: user.user_id.into(),
                field: 'reputation',
                old_value: old_reputation.into(),
                new_value: user.reputation.into()
            }));
        }

        // Registrar actividad de usuario
        fn log_user_activity(
            ref self: ContractState,
            user_address: ContractAddress,
            activity_type: felt252,
            related_challenge_id: u128
        ) {
            assert_only_admin(@self);
            
            let user = self.users.read(user_address);
            assert(user.user_id != 0, ERROR_USER_NOT_FOUND);
            
            let activity = ActivityLog {
                activity_type,
                related_challenge_id,
                timestamp: get_block_timestamp()
            };
            
            let activity_count = self.user_activity_count.read(user_address);
            self.user_activities.write((user_address, activity_count), activity);
            self.user_activity_count.write(user_address, activity_count + 1);
            
            // Actualizar última actividad
            let mut user = self.users.read(user_address);
            user.last_active = get_block_timestamp();
            self.users.write(user_address, user);
            
            // Emitir evento
            self.emit(Event::ActivityLogged(ActivityLogged {
                user_id: user.user_id.into(),
                activity_type,
                related_challenge_id,
                timestamp: get_block_timestamp()
            }));
        }

        // Obtener perfil de usuario
        fn get_user_profile(self: @ContractState, user_address: ContractAddress) -> UserProfile {
            self.users.read(user_address)
        }

        // Obtener ID de usuario por wallet
        fn get_user_id_by_wallet(self: @ContractState, wallet_address: ContractAddress) -> u128 {
            self.wallet_to_user_id.read(wallet_address)
        }

        // Obtener número de actividades de un usuario
        fn get_user_activity_count(self: @ContractState, user_address: ContractAddress) -> u128 {
            self.user_activity_count.read(user_address)
        }

        // Obtener una entrada específica del registro de actividades
        fn get_user_activity_log_entry(
            self: @ContractState,
            user_address: ContractAddress,
            index: u128
        ) -> ActivityLog {
            let count = self.user_activity_count.read(user_address);
            assert(index < count, ERROR_INDEX_OUT_OF_BOUNDS);
            self.user_activities.read((user_address, index))
        }

        // Cambiar el admin
        fn set_admin(ref self: ContractState, new_admin: ContractAddress) {
            assert_only_admin(@self);
            assert(!new_admin.is_zero(), ERROR_ZERO_ADDRESS);
            self.admin_address.write(new_admin);
        }

        // Añadir un badge a un usuario
        fn add_badge(ref self: ContractState, user_address: ContractAddress, badge_id: u128) {
            assert_only_admin(@self);
            
            // Verificar que el usuario existe
            let mut user = self.users.read(user_address);
            assert(user.user_id != 0, ERROR_USER_NOT_FOUND);
            
            // Verificar que el badge no existe
            assert(!self.user_badges.read((user_address, badge_id)), ERROR_BADGE_ALREADY_EXISTS);
            
            // Añadir badge
            self.user_badges.write((user_address, badge_id), true);
            
            // Emitir evento
            self.emit(Event::BadgeAdded(BadgeAdded {
                user_id: user.user_id.into(),
                badge_id
            }));
        }

        // Remover un badge de un usuario
        fn remove_badge(ref self: ContractState, user_address: ContractAddress, badge_id: u128) {
            assert_only_admin(@self);
            
            // Verificar que el usuario existe
            let mut user = self.users.read(user_address);
            assert(user.user_id != 0, ERROR_USER_NOT_FOUND);
            
            // Verificar que el badge existe
            assert(self.user_badges.read((user_address, badge_id)), ERROR_BADGE_NOT_FOUND);
            
            // Remover badge
            self.user_badges.write((user_address, badge_id), false);
            
            // Emitir evento
            self.emit(Event::BadgeRemoved(BadgeRemoved {
                user_id: user.user_id.into(),
                badge_id
            }));
        }

        // Verificar si un usuario tiene un badge
        fn has_badge(self: @ContractState, user_address: ContractAddress, badge_id: u128) -> bool {
            let user = self.users.read(user_address);
            assert(user.user_id != 0, ERROR_USER_NOT_FOUND);
            self.user_badges.read((user_address, badge_id))
        }
    }
}

// Interfaz del contrato UserRegistry
#[starknet::interface]
trait IUserRegistry<TContractState> {
    fn register_user(ref self: TContractState, username_low: u128, username_high: u128) -> u128;
    
    fn update_user_xp_and_level(ref self: TContractState, user_address: ContractAddress, xp_amount: u128);
    
    fn update_user_reputation(ref self: TContractState, user_address: ContractAddress, reputation_change: i64);
    
    fn log_user_activity(
        ref self: TContractState,
        user_address: ContractAddress,
        activity_type: felt252,
        related_challenge_id: u128
    );
    
    fn get_user_profile(self: @TContractState, user_address: ContractAddress) -> UserRegistry::UserProfile;
    
    fn get_user_id_by_wallet(self: @TContractState, wallet_address: ContractAddress) -> u128;
    
    fn get_user_activity_count(self: @TContractState, user_address: ContractAddress) -> u128;
    
    fn get_user_activity_log_entry(
        self: @TContractState,
        user_address: ContractAddress,
        index: u128
    ) -> UserRegistry::ActivityLog;
    
    fn set_admin(ref self: TContractState, new_admin: ContractAddress);

    fn add_badge(ref self: TContractState, user_address: ContractAddress, badge_id: u128);
    
    fn remove_badge(ref self: TContractState, user_address: ContractAddress, badge_id: u128);
    
    fn has_badge(self: @TContractState, user_address: ContractAddress, badge_id: u128) -> bool;
}