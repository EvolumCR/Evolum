#[starknet::interface]
pub trait ITokenSystem<TContractState> {
    // Funciones para el token XP (ERC20)
    fn get_xp_balance(self: @TContractState, address: starknet::ContractAddress) -> u256;
    fn transfer_xp(ref self: TContractState, to: starknet::ContractAddress, amount: u256) -> bool;
    fn award_xp(ref self: TContractState, to: starknet::ContractAddress, amount: u256) -> bool;
    
    // Funciones para badges (ERC721)
    fn get_badge_count(self: @TContractState, address: starknet::ContractAddress) -> u256;
    fn get_badge_owner(self: @TContractState, badge_id: u256) -> starknet::ContractAddress;
    fn award_badge(ref self: TContractState, to: starknet::ContractAddress, badge_type: felt252) -> u256;
    
    // Funciones para distribución de recompensas
    fn distribute_challenge_rewards(
        ref self: TContractState, 
        user: starknet::ContractAddress, 
        challenge_id: u64, 
        xp_amount: u256, 
        badge_type: Option<felt252>
    ) -> bool;
    
    // Funciones administrativas
    fn set_reward_distributor(ref self: TContractState, distributor: starknet::ContractAddress, authorized: bool);
}

#[starknet::contract]
pub mod TokenSystem {
    use openzeppelin_access::ownable::OwnableComponent;
    use openzeppelin_token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};
    use openzeppelin_token::erc721::interface::{IERC721Dispatcher, IERC721DispatcherTrait};
    use starknet::storage::{Map, StorageMapReadAccess, StorageMapWriteAccess, StoragePointerReadAccess, StoragePointerWriteAccess};
    use starknet::{ContractAddress, get_caller_address, get_contract_address};
    use super::ITokenSystem;

    // Componente Ownable para gestión de permisos
    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    // Eventos del contrato
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        XPAwarded: XPAwarded,
        BadgeAwarded: BadgeAwarded,
        RewardsDistributed: RewardsDistributed,
        RewardDistributorSet: RewardDistributorSet,
    }

    // Evento emitido cuando se otorgan tokens XP
    #[derive(Drop, starknet::Event)]
    struct XPAwarded {
        #[key]
        user: ContractAddress,
        amount: u256,
    }

    // Evento emitido cuando se otorga un badge
    #[derive(Drop, starknet::Event)]
    struct BadgeAwarded {
        #[key]
        user: ContractAddress,
        #[key]
        badge_id: u256,
        badge_type: felt252,
    }

    // Evento emitido cuando se distribuyen recompensas
    #[derive(Drop, starknet::Event)]
    struct RewardsDistributed {
        #[key]
        user: ContractAddress,
        #[key]
        challenge_id: u64,
        xp_amount: u256,
        badge_awarded: bool,
    }

    // Evento emitido cuando se configura un distribuidor de recompensas
    #[derive(Drop, starknet::Event)]
    struct RewardDistributorSet {
        #[key]
        distributor: ContractAddress,
        authorized: bool,
    }

    // Estructura para almacenamiento del contrato
    #[storage]
    struct Storage {
        // Almacenamiento para tokens XP (ERC20 simplificado)
        xp_balances: Map<ContractAddress, u256>,
        xp_total_supply: u256,
        
        // Almacenamiento para badges (ERC721 simplificado)
        badge_owners: Map<u256, ContractAddress>,
        badge_types: Map<u256, felt252>,
        user_badge_count: Map<ContractAddress, u256>,
        next_badge_id: u256,
        
        // Distribuidores de recompensas autorizados
        reward_distributors: Map<ContractAddress, bool>,
        
        // Registro de recompensas por reto
        challenge_rewards: Map<(ContractAddress, u64), bool>,
        
        // Substorage para el componente Ownable
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
    }

    // Constructor del contrato
    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        // Inicializar el componente Ownable
        self.ownable.initializer(owner);
        
        // Inicializar el contador de badges
        self.next_badge_id.write(1);
        
        // Autorizar al propietario como distribuidor de recompensas
        self.reward_distributors.write(owner, true);
    }

    // Implementación de la interfaz ITokenSystem
    #[abi(embed_v0)]
    impl TokenSystemImpl of ITokenSystem<ContractState> {
        // Obtener el balance de XP de una dirección
        fn get_xp_balance(self: @ContractState, address: ContractAddress) -> u256 {
            self.xp_balances.read(address)
        }
        
        // Transferir tokens XP a otra dirección
        fn transfer_xp(ref self: ContractState, to: ContractAddress, amount: u256) -> bool {
            let caller = get_caller_address();
            let caller_balance = self.xp_balances.read(caller);
            
            // Verificar que el remitente tenga suficientes tokens
            assert(caller_balance >= amount, 'Saldo XP insuficiente');
            
            // Actualizar balances
            self.xp_balances.write(caller, caller_balance - amount);
            self.xp_balances.write(to, self.xp_balances.read(to) + amount);
            
            true
        }
        
        // Otorgar tokens XP a una dirección (solo administradores)
        fn award_xp(ref self: ContractState, to: ContractAddress, amount: u256) -> bool {
            // Verificar que el llamante sea un distribuidor autorizado
            let caller = get_caller_address();
            assert(self.reward_distributors.read(caller), 'No autorizado');
            
            // Actualizar balance del receptor
            let current_balance = self.xp_balances.read(to);
            self.xp_balances.write(to, current_balance + amount);
            
            // Actualizar suministro total
            let current_supply = self.xp_total_supply.read();
            self.xp_total_supply.write(current_supply + amount);
            
            // Emitir evento
            self.emit(XPAwarded { user: to, amount });
            
            true
        }
        
        // Obtener la cantidad de badges que posee una dirección
        fn get_badge_count(self: @ContractState, address: ContractAddress) -> u256 {
            self.user_badge_count.read(address)
        }
        
        // Obtener el propietario de un badge específico
        fn get_badge_owner(self: @ContractState, badge_id: u256) -> ContractAddress {
            self.badge_owners.read(badge_id)
        }
        
        // Otorgar un nuevo badge a una dirección
        fn award_badge(ref self: ContractState, to: ContractAddress, badge_type: felt252) -> u256 {
            // Verificar que el llamante sea un distribuidor autorizado
            let caller = get_caller_address();
            assert(self.reward_distributors.read(caller), 'No autorizado');
            
            // Obtener el próximo ID de badge
            let badge_id = self.next_badge_id.read();
            
            // Asignar el badge al usuario
            self.badge_owners.write(badge_id, to);
            self.badge_types.write(badge_id, badge_type);
            
            // Incrementar el contador de badges del usuario
            let user_badges = self.user_badge_count.read(to);
            self.user_badge_count.write(to, user_badges + 1);
            
            // Incrementar el contador global de badges
            self.next_badge_id.write(badge_id + 1);
            
            // Emitir evento
            self.emit(BadgeAwarded { user: to, badge_id, badge_type });
            
            badge_id
        }
        
        // Distribuir recompensas por completar un reto
        fn distribute_challenge_rewards(
            ref self: ContractState, 
            user: ContractAddress, 
            challenge_id: u64, 
            xp_amount: u256, 
            badge_type: Option<felt252>
        ) -> bool {
            // Verificar que el llamante sea un distribuidor autorizado
            let caller = get_caller_address();
            assert(self.reward_distributors.read(caller), 'No autorizado');
            
            // Verificar que el usuario no haya recibido ya recompensas por este reto
            let already_rewarded = self.challenge_rewards.read((user, challenge_id));
            assert(!already_rewarded, 'Recompensa ya otorgada');
            
            // Otorgar tokens XP
            let current_balance = self.xp_balances.read(user);
            self.xp_balances.write(user, current_balance + xp_amount);
            
            // Actualizar suministro total de XP
            let current_supply = self.xp_total_supply.read();
            self.xp_total_supply.write(current_supply + xp_amount);
            
            // Variable para rastrear si se otorgó un badge
            let mut badge_awarded = false;
            
            // Otorgar badge si se especificó
            match badge_type {
                Option::Some(badge_type) => {
                    // Obtener el próximo ID de badge
                    let badge_id = self.next_badge_id.read();
                    
                    // Asignar el badge al usuario
                    self.badge_owners.write(badge_id, user);
                    self.badge_types.write(badge_id, badge_type);
                    
                    // Incrementar el contador de badges del usuario
                    let user_badges = self.user_badge_count.read(user);
                    self.user_badge_count.write(user, user_badges + 1);
                    
                    // Incrementar el contador global de badges
                    self.next_badge_id.write(badge_id + 1);
                    
                    // Emitir evento de badge otorgado
                    self.emit(BadgeAwarded { user, badge_id, badge_type });
                    
                    badge_awarded = true;
                },
                Option::None => {},
            }
            
            // Marcar el reto como recompensado para este usuario
            self.challenge_rewards.write((user, challenge_id), true);
            
            // Emitir evento de recompensas distribuidas
            self.emit(RewardsDistributed { user, challenge_id, xp_amount, badge_awarded });
            
            true
        }
        
        // Configurar un distribuidor de recompensas
        fn set_reward_distributor(ref self: ContractState, distributor: ContractAddress, authorized: bool) {
            // Solo el propietario puede configurar distribuidores
            self.ownable.assert_only_owner();
            
            // Actualizar estado del distribuidor
            self.reward_distributors.write(distributor, authorized);
            
            // Emitir evento
            self.emit(RewardDistributorSet { distributor, authorized });
        }
    }
}