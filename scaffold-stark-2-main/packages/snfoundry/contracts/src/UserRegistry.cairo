// SPDX-License-Identifier: MIT
// UserRegistry.cairo - Actualizado a Cairo 1+ (Starknet v2.11.4)

#[starknet::contract]
mod UserRegistry {
    use starknet::ContractAddress;
    // use starknet::u256::U256; // Eliminado - Se intentará usar u256 directamente
    use starknet::storage::Map;
    // Traits necesarios para .read() y .write() en el almacenamiento
    use starknet::storage::{
        StoragePointerWriteAccess, StorageMapReadAccess, StorageMapWriteAccess,
        StoragePointerReadAccess
    };
    use starknet::get_caller_address; // Importación directa

    // Constantes (ejemplo, ajusta según necesidad)
    const LEVEL_2_XP_LOW: u128 = 100;
    // ... y así sucesivamente para otros niveles

    #[storage]
    struct Storage {
        user_profiles: Map<ContractAddress, UserProfile>,
        user_id_counter: u64,
        address_to_user_id: Map<ContractAddress, u64>,
        user_id_to_address: Map<u64, ContractAddress>,
        admin_address: ContractAddress,
    }

    #[derive(Drop, Serde, starknet::Store)]
    struct UserProfile {
        wallet_address: ContractAddress,
        user_id: u64,
        username_ipfs_cid: u256, // Cambiado a u256
        xp: u256,                // Cambiado a u256
        level: u8,
        reputation: i64,
    }

    #[derive(Drop, Serde, starknet::Store)]
    struct ActivityLog {
        timestamp: u64,
        activity_type: u8,
        related_id: u64,
        reputation_change: i64,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        UserRegistered: UserRegistered,
        UserProfileUpdated: UserProfileUpdated,
        UserXpUpdated: UserXpUpdated,
        UserLevelUp: UserLevelUp,
        UserReputationUpdated: UserReputationUpdated,
        ActivityLogged: ActivityLogged,
        AdminAddressChanged: AdminAddressChanged,
    }

    #[derive(Drop, starknet::Event)]
    struct UserRegistered {
        #[key]
        user_id: u64,
        wallet_address: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct UserProfileUpdated {
        #[key]
        user_id: u64,
        username_ipfs_cid: u256, // Cambiado a u256
    }

    #[derive(Drop, starknet::Event)]
    struct UserXpUpdated {
        #[key]
        user_id: u64,
        new_xp: u256,          // Cambiado a u256
        old_xp: u256,          // Cambiado a u256
    }

    #[derive(Drop, starknet::Event)]
    struct UserLevelUp {
        #[key]
        user_id: u64,
        new_level: u8,
        old_level: u8, // Ejemplo de campo
    }

    #[derive(Drop, starknet::Event)]
    struct UserReputationUpdated {
        #[key]
        user_id: u64,
        new_reputation: i64,
        old_reputation: i64, // Ejemplo de campo
    }

    #[derive(Drop, starknet::Event)]
    struct ActivityLogged {
        #[key]
        user_id: u64,
        activity_type: u8, // Ejemplo de campo
        timestamp: u64, // Ejemplo de campo
    }
    
    #[derive(Drop, starknet::Event)]
    struct AdminAddressChanged {
        #[key]
        new_admin_address: ContractAddress,
        old_admin_address: ContractAddress, // Ejemplo de campo
    }


    #[constructor]
    fn constructor(ref self: ContractState, initial_admin_address: ContractAddress) {
        self.admin_address.write(initial_admin_address);
        self.user_id_counter.write(1_u64);
    }

    #[external(v0)]
    fn register_user(ref self: ContractState, username_ipfs_cid_low: u128, username_ipfs_cid_high: u128) {
        let caller_address: ContractAddress = get_caller_address(); // Llamada directa
        
        let existing_user_id: u64 = self.address_to_user_id.read(caller_address);
        assert(existing_user_id == 0_u64, 'USER_ALREADY_REGISTERED');

        let new_user_id: u64 = self.user_id_counter.read();
        
        // Si u256 es el tipo correcto, la inicialización { low: ..., high: ... } debería seguir funcionando.
        let initial_username_cid = u256 { low: username_ipfs_cid_low, high: username_ipfs_cid_high };
        let initial_xp = u256 { low: 0, high: 0 };

        let new_profile = UserProfile {
            wallet_address: caller_address,
            user_id: new_user_id,
            username_ipfs_cid: initial_username_cid,
            xp: initial_xp,
            level: 1_u8,
            reputation: 0_i64,
        };

        self.user_profiles.write(caller_address, new_profile);
        self.address_to_user_id.write(caller_address, new_user_id);
        self.user_id_to_address.write(new_user_id, caller_address);
        self.user_id_counter.write(new_user_id + 1_u64);

        self.emit(UserRegistered { user_id: new_user_id, wallet_address: caller_address });
    }

    fn get_user_profile(self: @ContractState, user_address: ContractAddress) -> UserProfile {
        self.user_profiles.read(user_address)
    }
    
    // ... resto de las funciones y lógica del contrato actualizadas ...
}