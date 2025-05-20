use starknet::ContractAddress;

#[starknet::contract]
mod ChallengeSystem {
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use starknet::get_block_timestamp;
    use starknet::storage::{StorageMapReadAccess, StorageMapWriteAccess, StoragePointerReadAccess, StoragePointerWriteAccess, Map};
    use core::array::ArrayTrait;
    use core::num::traits::Zero;

    // Enumeración para el estado del reto
    #[derive(Drop, Copy, starknet::Store, PartialEq, Serde)]
    #[derive(Default)]
    enum ChallengeState {
        #[default]
        Created,
        Active,
        PendingValidation,
        Completed,
        Expired
    }

    // Estructura para almacenar información del reto
    #[derive(Drop, starknet::Store, Serde)]
    pub struct Challenge {
        id: u128,
        creator: ContractAddress,
        description: felt252,
        criteria: felt252,
        state: ChallengeState,
        deadline_submission: u64,
        deadline_validation: u64,
        rewards_xp: u128,
        reward_badge_id: u128,
        participant_count: u128,
    }

    // Estructura para almacenar la participación en un reto
    #[derive(Drop, starknet::Store, Serde)]
    pub struct Participation {
        challenge_id: u128,
        participant: ContractAddress,
        evidence_ipfs_hash: felt252,
        submission_timestamp: u64,
        is_validated: bool,
    }

    // Eventos
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        ChallengeCreated: ChallengeCreated,
        ChallengeJoined: ChallengeJoined,
        EvidenceSubmitted: EvidenceSubmitted,
        ChallengeValidated: ChallengeValidated,
        ChallengeStateChanged: ChallengeStateChanged
    }

    #[derive(Drop, starknet::Event)]
    struct ChallengeCreated {
        #[key]
        challenge_id: u128,
        creator: ContractAddress,
        description: felt252,
        deadline_submission: u64,
    }

    #[derive(Drop, starknet::Event)]
    struct ChallengeJoined {
        #[key]
        challenge_id: u128,
        #[key]
        participant: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct EvidenceSubmitted {
        #[key]
        challenge_id: u128,
        #[key]
        participant: ContractAddress,
        evidence_ipfs_hash: felt252,
    }

    #[derive(Drop, starknet::Event)]
    struct ChallengeValidated {
        #[key]
        challenge_id: u128,
        #[key]
        participant: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct ChallengeStateChanged {
        #[key]
        challenge_id: u128,
        old_state: ChallengeState,
        new_state: ChallengeState,
    }

    // Almacenamiento
    #[storage]
    struct Storage {
        admin_address: ContractAddress,
        next_challenge_id: u128,
        challenges: Map<u128, Challenge>,
        participations: Map<(u128, ContractAddress), Participation>,
        user_participation_count: Map<ContractAddress, u128>,
        user_participations: Map<(ContractAddress, u128), u128>,
        validation_contract: ContractAddress,
        token_system_contract: ContractAddress,
        user_registry_contract: ContractAddress
    }

    // Constructor
    #[constructor]
    fn constructor(ref self: ContractState, initial_admin_address: ContractAddress) {
        self.admin_address.write(initial_admin_address);
        self.next_challenge_id.write(1);
    }

    // Errores personalizados como constantes
    const ERROR_NOT_ADMIN: felt252 = 'Not admin';
    const ERROR_NOT_VALIDATION: felt252 = 'Not validator';
    const ERROR_CHALLENGE_NOT_FOUND: felt252 = 'Challenge not found';
    const ERROR_CHALLENGE_NOT_ACTIVE: felt252 = 'Challenge not active';
    const ERROR_DEADLINE_PASSED: felt252 = 'Deadline passed';
    const ERROR_ALREADY_JOINED: felt252 = 'Already joined';
    const ERROR_NOT_JOINED: felt252 = 'Not joined';
    const ERROR_EVIDENCE_ALREADY_SUBMITTED: felt252 = 'Evidence already submitted';
    const ERROR_PARTICIPANT_NOT_FOUND: felt252 = 'Participant not found';
    const ERROR_NO_EVIDENCE: felt252 = 'No evidence submitted';
    const ERROR_ZERO_ADDRESS: felt252 = 'Zero address not allowed';
    const ERROR_INDEX_OUT_OF_BOUNDS: felt252 = 'Index out of bounds';
    
    // Modificador para funciones que solo el admin puede llamar
    fn assert_only_admin(self: @ContractState) {
        let caller = get_caller_address();
        assert(caller == self.admin_address.read(), ERROR_NOT_ADMIN);
    }

    // Modificador para funciones que solo el contrato de validación puede llamar
    fn assert_only_validation_contract(self: @ContractState) {
        let caller = get_caller_address();
        assert(
            caller == self.validation_contract.read(), 
            ERROR_NOT_VALIDATION
        );
    }

    #[abi(embed_v0)]
    impl ChallengeSystemImpl of super::IChallengeSystem<ContractState> {
        // Crea un nuevo reto
        fn create_challenge(
            ref self: ContractState, 
            description: felt252, 
            criteria: felt252,
            deadline_submission: u64,
            deadline_validation: u64,
            rewards_xp: u128,
            reward_badge_id: u128
        ) -> u128 {
            let caller = get_caller_address();
            let current_time = get_block_timestamp();
            
            // Validaciones básicas
            assert(deadline_submission > current_time, ERROR_DEADLINE_PASSED);
            assert(deadline_validation > deadline_submission, ERROR_DEADLINE_PASSED);
            
            let challenge_id = self.next_challenge_id.read();
            self.next_challenge_id.write(challenge_id + 1);
            
            let challenge = Challenge {
                id: challenge_id,
                creator: caller,
                description,
                criteria,
                state: ChallengeState::Active,
                deadline_submission,
                deadline_validation,
                rewards_xp,
                reward_badge_id,
                participant_count: 0,
            };
            
            self.challenges.write(challenge_id, challenge);
            
            self.emit(Event::ChallengeCreated(ChallengeCreated { 
                challenge_id, 
                creator: caller, 
                description, 
                deadline_submission 
            }));
            
            challenge_id
        }

        // Un usuario se une a un reto
        fn join_challenge(ref self: ContractState, challenge_id: u128) {
            let caller = get_caller_address();
            let challenge = self.challenges.read(challenge_id);
            
            // Validaciones
            assert(challenge.id == challenge_id, ERROR_CHALLENGE_NOT_FOUND);
            assert(challenge.state == ChallengeState::Active, ERROR_CHALLENGE_NOT_ACTIVE);
            assert(
                get_block_timestamp() < challenge.deadline_submission, 
                ERROR_DEADLINE_PASSED
            );
            
            // Verificar que el usuario no se haya unido ya
            let existing_participation = self.participations.read((challenge_id, caller));
            assert(existing_participation.participant.is_zero(), ERROR_ALREADY_JOINED);
            
            // Crear participación
            let participation = Participation {
                challenge_id,
                participant: caller,
                evidence_ipfs_hash: 0, // Sin evidencia aún
                submission_timestamp: 0, // Se actualizará cuando se envíe evidencia
                is_validated: false,
            };
            
            // Actualizar contador de participantes del reto
            let mut challenge_updated = challenge;
            challenge_updated.participant_count += 1;
            self.challenges.write(challenge_id, challenge_updated);
            
            // Guardar participación
            self.participations.write((challenge_id, caller), participation);
            
            // Actualizar contador de participaciones del usuario
            let user_count = self.user_participation_count.read(caller);
            self.user_participation_count.write(caller, user_count + 1);
            self.user_participations.write((caller, user_count), challenge_id);
            
            // Emitir evento
            self.emit(Event::ChallengeJoined(ChallengeJoined { 
                challenge_id, 
                participant: caller 
            }));
        }

        // Enviar evidencia para un reto
        fn submit_evidence(
            ref self: ContractState, 
            challenge_id: u128, 
            evidence_ipfs_hash: felt252
        ) {
            let caller = get_caller_address();
            let challenge = self.challenges.read(challenge_id);
            let current_time = get_block_timestamp();
            
            // Validaciones
            assert(challenge.id == challenge_id, ERROR_CHALLENGE_NOT_FOUND);
            assert(challenge.state == ChallengeState::Active, ERROR_CHALLENGE_NOT_ACTIVE);
            assert(
                current_time < challenge.deadline_submission, 
                ERROR_DEADLINE_PASSED
            );
            
            // Verificar que el usuario se haya unido al reto
            let mut participation = self.participations.read((challenge_id, caller));
            assert(!participation.participant.is_zero(), ERROR_NOT_JOINED);
            assert(participation.evidence_ipfs_hash == 0, ERROR_EVIDENCE_ALREADY_SUBMITTED);
            
            // Actualizar participación con la evidencia
            participation.evidence_ipfs_hash = evidence_ipfs_hash;
            participation.submission_timestamp = current_time;
            self.participations.write((challenge_id, caller), participation);
            
            // Emitir evento
            self.emit(Event::EvidenceSubmitted(EvidenceSubmitted { 
                challenge_id, 
                participant: caller, 
                evidence_ipfs_hash 
            }));
            
            // Verificar si es necesario cambiar el estado del reto
            // Si todos los participantes han enviado evidencia o ha pasado el plazo
            if current_time >= challenge.deadline_submission {
                let old_state = challenge.state;
                let mut challenge_updated = challenge;
                challenge_updated.state = ChallengeState::PendingValidation;
                self.challenges.write(challenge_id, challenge_updated);
                
                self.emit(Event::ChallengeStateChanged(ChallengeStateChanged {
                    challenge_id,
                    old_state,
                    new_state: ChallengeState::PendingValidation 
                }));
            }
        }
        
        // Validar la evidencia de un participante
        fn validate_evidence(
            ref self: ContractState, 
            challenge_id: u128, 
            participant: ContractAddress, 
            is_valid: bool
        ) {
            // Solo el contrato de validación puede llamar a esta función
            assert_only_validation_contract(@self);
            
            let challenge = self.challenges.read(challenge_id);
            assert(challenge.id == challenge_id, ERROR_CHALLENGE_NOT_FOUND);
            assert(
                challenge.state == ChallengeState::PendingValidation,
                ERROR_NO_EVIDENCE
            );
            
            // Actualizar la participación
            let mut participation = self.participations.read((challenge_id, participant));
            assert(!participation.participant.is_zero(), ERROR_PARTICIPANT_NOT_FOUND);
            assert(participation.evidence_ipfs_hash != 0, ERROR_NO_EVIDENCE);
            
            participation.is_validated = is_valid;
            self.participations.write((challenge_id, participant), participation);
            
            // Emitir evento
            self.emit(Event::ChallengeValidated(ChallengeValidated { 
                challenge_id, 
                participant 
            }));
        }
        
        // Finalizar un reto (cambiar a estado Completed o Expired)
        fn finalize_challenge(ref self: ContractState, challenge_id: u128) {
            // Solo el admin puede finalizar un reto manualmente
            assert_only_admin(@self);
            
            let challenge = self.challenges.read(challenge_id);
            assert(challenge.id == challenge_id, ERROR_CHALLENGE_NOT_FOUND);
            
            let current_time = get_block_timestamp();
            let old_state = challenge.state;
            let mut new_state = old_state;
            
            // Determinar el nuevo estado basado en el tiempo
            if current_time > challenge.deadline_validation {
                if old_state == ChallengeState::PendingValidation {
                    new_state = ChallengeState::Completed;
                } else if old_state == ChallengeState::Active {
                    new_state = ChallengeState::Expired;
                }
            }
            
            // Solo actualizar si hay cambio de estado
            if new_state != old_state {
                let mut challenge_updated = challenge;
                challenge_updated.state = new_state;
                self.challenges.write(challenge_id, challenge_updated);
                
                self.emit(Event::ChallengeStateChanged(ChallengeStateChanged {
                    challenge_id,
                    old_state,
                    new_state 
                }));
            }
        }
        
        // Configurar la dirección del contrato de validación
        fn set_validation_contract(ref self: ContractState, contract_address: ContractAddress) {
            assert_only_admin(@self);
            assert(!contract_address.is_zero(), ERROR_ZERO_ADDRESS);
            self.validation_contract.write(contract_address);
        }
        
        // Configurar la dirección del contrato de tokens
        fn set_token_system_contract(ref self: ContractState, contract_address: ContractAddress) {
            assert_only_admin(@self);
            assert(!contract_address.is_zero(), ERROR_ZERO_ADDRESS);
            self.token_system_contract.write(contract_address);
        }
        
        // Configurar la dirección del contrato de registro de usuarios
        fn set_user_registry_contract(ref self: ContractState, contract_address: ContractAddress) {
            assert_only_admin(@self);
            assert(!contract_address.is_zero(), ERROR_ZERO_ADDRESS);
            self.user_registry_contract.write(contract_address);
        }
        
        // Obtener información de un reto
        fn get_challenge(self: @ContractState, challenge_id: u128) -> Challenge {
            self.challenges.read(challenge_id)
        }
        
        // Obtener información de una participación
        fn get_participation(
            self: @ContractState,
            challenge_id: u128,
            participant: ContractAddress
        ) -> Participation {
            self.participations.read((challenge_id, participant))
        }
        
        // Obtener el número de retos en los que ha participado un usuario
        fn get_user_participation_count(self: @ContractState, user: ContractAddress) -> u128 {
            self.user_participation_count.read(user)
        }
        
        // Obtener el ID de un reto en el que ha participado un usuario por índice
        fn get_user_participation_by_index(
            self: @ContractState,
            user: ContractAddress,
            index: u128
        ) -> u128 {
            assert(index < self.user_participation_count.read(user), ERROR_INDEX_OUT_OF_BOUNDS);
            self.user_participations.read((user, index))
        }
    }
}

// Interfaz del contrato ChallengeSystem
#[starknet::interface]
trait IChallengeSystem<TContractState> {
    fn create_challenge(
        ref self: TContractState,
        description: felt252,
        criteria: felt252,
        deadline_submission: u64,
        deadline_validation: u64,
        rewards_xp: u128,
        reward_badge_id: u128
    ) -> u128;
    
    fn join_challenge(ref self: TContractState, challenge_id: u128);
    
    fn submit_evidence(
        ref self: TContractState,
        challenge_id: u128,
        evidence_ipfs_hash: felt252
    );
    
    fn validate_evidence(
        ref self: TContractState,
        challenge_id: u128,
        participant: ContractAddress,
        is_valid: bool
    );
    
    fn finalize_challenge(ref self: TContractState, challenge_id: u128);
    
    fn set_validation_contract(ref self: TContractState, contract_address: ContractAddress);
    
    fn set_token_system_contract(ref self: TContractState, contract_address: ContractAddress);
    
    fn set_user_registry_contract(ref self: TContractState, contract_address: ContractAddress);
    
    fn get_challenge(self: @TContractState, challenge_id: u128) -> ChallengeSystem::Challenge;
    
    fn get_participation(
        self: @TContractState,
        challenge_id: u128,
        participant: ContractAddress
    ) -> ChallengeSystem::Participation;
    
    fn get_user_participation_count(self: @TContractState, user: ContractAddress) -> u128;
    
    fn get_user_participation_by_index(
        self: @TContractState,
        user: ContractAddress,
        index: u128
    ) -> u128;
}