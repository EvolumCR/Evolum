#[starknet::interface]
pub trait IValidationSystem<TContractState> {
    // Asignar evidencia a validadores
    fn assign_validators(ref self: TContractState, challenge_id: u64, user_address: felt252, validator_count: u8);
    
    // Agregar un validador a una asignación existente
    fn add_validator(ref self: TContractState, challenge_id: u64, user_address: felt252, validator_address: felt252);
    
    // Validar evidencia (para validadores)
    fn validate_evidence(ref self: TContractState, challenge_id: u64, user_address: felt252, is_valid: bool, comments: felt252);
    
    // Calcular consenso y finalizar validación
    fn finalize_validation(ref self: TContractState, challenge_id: u64, user_address: felt252) -> bool;
    
    // Actualizar reputación de validadores
    fn update_validator_reputation(ref self: TContractState, validator_address: felt252, reputation_change: i64);
    
    // Consultar reputación de validador
    fn get_validator_reputation(self: @TContractState, validator_address: felt252) -> u64;
    
    // Registrar validador
    fn register_validator(ref self: TContractState, validator_address: felt252);
    
    // Funciones administrativas
    fn set_consensus_threshold(ref self: TContractState, new_threshold: u8);
    fn set_validator_manager(ref self: TContractState, manager: felt252, authorized: bool);
}

#[starknet::contract]
pub mod ValidationSystem {
    use openzeppelin_access::ownable::OwnableComponent;
    use starknet::storage::{Map, StorageMapReadAccess, StorageMapWriteAccess, StoragePointerReadAccess, StoragePointerWriteAccess};
    use starknet::{ContractAddress, get_caller_address};
    use super::IValidationSystem;

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
        ValidatorAssigned: ValidatorAssigned,
        EvidenceValidated: EvidenceValidated,
        ValidationFinalized: ValidationFinalized,
        ValidatorReputationUpdated: ValidatorReputationUpdated,
        ValidatorRegistered: ValidatorRegistered,
        ConsensusThresholdUpdated: ConsensusThresholdUpdated,
        ValidatorManagerSet: ValidatorManagerSet,
    }

    // Definición de los eventos
    // Evento emitido cuando se asigna un validador a una evidencia
    #[derive(Drop, starknet::Event)]
    struct ValidatorAssigned {
        #[key]
        challenge_id: u64,
        #[key]
        user_address: felt252,
        #[key]
        validator_address: felt252,
    }

    // Evento emitido cuando un validador valida una evidencia
    #[derive(Drop, starknet::Event)]
    struct EvidenceValidated {
        #[key]
        challenge_id: u64,
        #[key]
        user_address: felt252,
        #[key]
        validator_address: felt252,
        is_valid: bool,
        comments: felt252,
    }

    // Evento emitido cuando se finaliza una validación
    #[derive(Drop, starknet::Event)]
    struct ValidationFinalized {
        #[key]
        challenge_id: u64,
        #[key]
        user_address: felt252,
        result: bool,
        positive_votes: u8,
        negative_votes: u8,
        total_validators: u8,
    }

    // Evento emitido cuando se actualiza la reputación de un validador
    #[derive(Drop, starknet::Event)]
    struct ValidatorReputationUpdated {
        #[key]
        validator_address: felt252,
        reputation_change: i64,
        new_reputation: u64,
    }

    // Evento emitido cuando se registra un nuevo validador
    #[derive(Drop, starknet::Event)]
    struct ValidatorRegistered {
        #[key]
        validator_address: felt252,
    }

    // Evento emitido cuando se actualiza el umbral de consenso
    #[derive(Drop, starknet::Event)]
    struct ConsensusThresholdUpdated {
        old_threshold: u8,
        new_threshold: u8,
    }

    // Evento emitido cuando se configura un gestor de validadores
    #[derive(Drop, starknet::Event)]
    struct ValidatorManagerSet {
        #[key]
        manager: felt252,
        authorized: bool,
    }
    
    // Estructura que representa una validación
    #[derive(Drop, Copy, Serde, starknet::Store)]
    struct Validation {
        is_valid: bool,
        comments: felt252,
        timestamp: u64,
    }

    // Estructura para almacenamiento del contrato
    #[storage]
    struct Storage {
        // Mapeo de validadores asignados a cada par (reto, usuario)
        assigned_validators_count: Map<(u64, felt252), u32>,
        assigned_validator_at_index: Map<(u64, felt252, u32), felt252>,
        
        // Mapeo de validaciones realizadas por cada validador para cada par (reto, usuario)
        validations: Map<(u64, felt252, felt252), Validation>,
        
        // Mapeo de resultados finales de validación para cada par (reto, usuario)
        validation_results: Map<(u64, felt252), bool>,
        
        // Mapeo de estado de finalización de validación para cada par (reto, usuario)
        validation_finalized: Map<(u64, felt252), bool>,
        
        // Reputación de cada validador
        validator_reputation: Map<felt252, u64>,
        
        // Registro de validadores
        is_validator: Map<felt252, bool>,
        
        // Umbral de consenso (porcentaje necesario para aprobar, de 0 a 100)
        consensus_threshold: u8,
        
        // Gestores de validadores autorizados
        validator_managers: Map<felt252, bool>,
        
        // Substorage para el componente Ownable
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
    }
    
    // Funciones auxiliares internas
    #[generate_trait]
    impl InternalFunctions of InternalFunctionsTrait {
        // Función auxiliar para verificar si un usuario es un gestor de validadores
        fn is_validator_manager(self: @ContractState, address: felt252) -> bool {
            self.validator_managers.read(address)
        }
        
        // Función auxiliar para verificar si una validación está finalizada
        fn is_validation_finalized(self: @ContractState, challenge_id: u64, user_address: felt252) -> bool {
            self.validation_finalized.read((challenge_id, user_address))
        }
        
        // Función auxiliar para calcular consenso
        fn calculate_consensus(self: @ContractState, challenge_id: u64, user_address: felt252) -> (bool, u8, u8, u8) {
            // Obtener número de validadores asignados
            let validators_len = self.assigned_validators_count.read((challenge_id, user_address));
            
            let mut positive_votes: u8 = 0;
            let mut negative_votes: u8 = 0;
            
            // Contar votos
            let mut i: u32 = 0;
            
            loop {
                if i >= validators_len {
                    break;
                }
                
                let validator = self.assigned_validator_at_index.read((challenge_id, user_address, i));
                let validation = self.validations.read((challenge_id, user_address, validator));
                
                if validation.timestamp != 0 { // Si hay una validación
                    if validation.is_valid {
                        positive_votes += 1;
                    } else {
                        negative_votes += 1;
                    }
                }
                
                i += 1;
            };
            
            let total_validators = positive_votes + negative_votes;
            
            // Calcular porcentaje de votos positivos
            let positive_percentage = if total_validators > 0 {
                (positive_votes * 100) / total_validators
            } else {
                0
            };
            
            // Determinar resultado basado en umbral
            let threshold = self.consensus_threshold.read();
            let result = positive_percentage >= threshold;
            
            (result, positive_votes, negative_votes, total_validators)
        }
    }

    // Constructor del contrato
    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        // Inicializar el componente Ownable
        self.ownable.initializer(owner);
        
        // Establecer umbral de consenso predeterminado (70%)
        self.consensus_threshold.write(70);
        
        // Autorizar al propietario como gestor de validadores
        self.validator_managers.write(owner.into(), true);
    }

    // Implementación de la interfaz IValidationSystem
    #[abi(embed_v0)]
    impl ValidationSystemImpl of IValidationSystem<ContractState> {
        // Asignar validadores a una evidencia
        fn assign_validators(ref self: ContractState, challenge_id: u64, user_address: felt252, validator_count: u8) {
            // Verificar que el llamante sea un gestor de validadores autorizado
            let caller = get_caller_address();
            assert(InternalFunctions::is_validator_manager(@self, caller.into()), 'No autorizado');
            
            // Verificar que la validación no haya sido finalizada
            assert(!InternalFunctions::is_validation_finalized(@self, challenge_id, user_address), 'Validacion ya finalizada');
            
            // Inicializar el contador de validadores a 0
            self.assigned_validators_count.write((challenge_id, user_address), 0);
            
            // Nota: En una implementación real, aquí se agregarían los validadores
            // Por ahora, los validadores se agregarán mediante llamadas a add_validator
        }
        
        // Agregar un validador a una asignación existente
        fn add_validator(ref self: ContractState, challenge_id: u64, user_address: felt252, validator_address: felt252) {
            // Verificar que el llamante sea un gestor de validadores autorizado
            let caller = get_caller_address();
            assert(InternalFunctions::is_validator_manager(@self, caller.into()), 'No autorizado');
            
            // Verificar que la validación no haya sido finalizada
            assert(!InternalFunctions::is_validation_finalized(@self, challenge_id, user_address), 'Validacion ya finalizada');
            
            // Verificar que la dirección proporcionada sea un validador registrado
            assert(self.is_validator.read(validator_address), 'No es validador');
            
            // Obtener el contador actual de validadores
            let current_count = self.assigned_validators_count.read((challenge_id, user_address));
            
            // Agregar el nuevo validador
            self.assigned_validator_at_index.write((challenge_id, user_address, current_count), validator_address);
            
            // Incrementar el contador
            self.assigned_validators_count.write((challenge_id, user_address), current_count + 1);
            
            // Emitir evento
            self.emit(ValidatorAssigned {
                challenge_id,
                user_address,
                validator_address,
            });
        }
        
        // Validar evidencia (para validadores)
        fn validate_evidence(ref self: ContractState, challenge_id: u64, user_address: felt252, is_valid: bool, comments: felt252) {
            // Obtener la dirección del validador (llamante)
            let validator_address = get_caller_address();
            
            // Verificar que el llamante sea un validador registrado
            assert(self.is_validator.read(validator_address.into()), 'Its not a validator');
            
            // Verificar que la validación no haya sido finalizada
            assert(!self.validation_finalized.read((challenge_id, user_address)), 'Validation already finalized');
            
            // Registrar la validación
            let validation = Validation {
                is_valid,
                comments,
                timestamp: starknet::get_block_timestamp(),
            };
            
            self.validations.write((challenge_id, user_address, validator_address.into()), validation);
            
            // Emitir evento
            self.emit(EvidenceValidated {
                challenge_id,
                user_address,
                validator_address: validator_address.into(),
                is_valid,
                comments,
            });
        }
        
        // Calcular consenso y finalizar validación
        fn finalize_validation(ref self: ContractState, challenge_id: u64, user_address: felt252) -> bool {
            // Verificar que el llamante sea un gestor de validadores autorizado
            let caller = get_caller_address();
            assert(InternalFunctions::is_validator_manager(@self, caller.into()), 'No autorizado');
            
            // Verificar que la validación no haya sido finalizada
            assert(!InternalFunctions::is_validation_finalized(@self, challenge_id, user_address), 'Validacion ya finalizada');
            
            // Calcular consenso usando la función auxiliar
            let (result, positive_votes, negative_votes, total_validators) = 
                InternalFunctions::calculate_consensus(@self, challenge_id, user_address);
            
            // Registrar resultado
            self.validation_results.write((challenge_id, user_address), result);
            self.validation_finalized.write((challenge_id, user_address), true);
            
            // Emitir evento
            self.emit(ValidationFinalized {
                challenge_id,
                user_address,
                result,
                positive_votes,
                negative_votes,
                total_validators,
            });
            
            result
        }
        
        // Actualizar reputación de validadores
        fn update_validator_reputation(ref self: ContractState, validator_address: felt252, reputation_change: i64) {
            // Verificar que el llamante sea un gestor de validadores autorizado
            let caller = get_caller_address();
            assert(InternalFunctions::is_validator_manager(@self, caller.into()), 'No autorizado');
            
            // Obtener reputación actual
            let current_reputation = self.validator_reputation.read(validator_address);
            
            // Calcular nueva reputación (evitando underflow)
            let new_reputation = if reputation_change < 0 {
                let negative_change = -reputation_change;
                let abs_change: u64 = negative_change.try_into().unwrap();
                if current_reputation > abs_change {
                    current_reputation - abs_change
                } else {
                    0
                }
            } else {
                let positive_change: u64 = reputation_change.try_into().unwrap();
                current_reputation + positive_change
            };
            
            // Actualizar reputación
            self.validator_reputation.write(validator_address, new_reputation);
            
            // Emitir evento
            self.emit(ValidatorReputationUpdated {
                validator_address,
                reputation_change,
                new_reputation,
            });
        }
        
        // Consultar reputación de validador
        fn get_validator_reputation(self: @ContractState, validator_address: felt252) -> u64 {
            self.validator_reputation.read(validator_address)
        }
        
        // Registrar validador
        fn register_validator(ref self: ContractState, validator_address: felt252) {
            // Verificar que el llamante sea un gestor de validadores autorizado
            let caller = get_caller_address();
            assert(InternalFunctions::is_validator_manager(@self, caller.into()), 'No autorizado');
            
            // Registrar validador
            self.is_validator.write(validator_address, true);
            
            // Inicializar reputación
            self.validator_reputation.write(validator_address, 100); // Reputación inicial
            
            // Emitir evento
            self.emit(ValidatorRegistered { validator_address });
        }
        
        // Funciones administrativas
        fn set_consensus_threshold(ref self: ContractState, new_threshold: u8) {
            // Solo el propietario puede cambiar el umbral
            self.ownable.assert_only_owner();
            
            // Verificar que el umbral esté en el rango válido (0-100)
            assert(new_threshold <= 100, 'Umbral fuera de rango');
            
            // Guardar umbral anterior
            let old_threshold = self.consensus_threshold.read();
            
            // Actualizar umbral
            self.consensus_threshold.write(new_threshold);
            
            // Emitir evento
            self.emit(ConsensusThresholdUpdated { old_threshold, new_threshold });
        }
        
        fn set_validator_manager(ref self: ContractState, manager: felt252, authorized: bool) {
            // Solo el propietario puede configurar gestores
            self.ownable.assert_only_owner();
            
            // Actualizar estado del gestor
            self.validator_managers.write(manager, authorized);
            
            // Emitir evento
            self.emit(ValidatorManagerSet { manager, authorized });
        }
    }
}