// Definición de la interfaz del contrato
// Esta interfaz declara todas las funciones públicas que el contrato implementará
#[starknet::interface]
pub trait IIdentidadDescentralizada<TContractState> {
    // Registra un nuevo usuario en el sistema con una reputación inicial
    fn registrar_usuarios(ref self: TContractState, direccion: felt252, reputacion_inicial: u64);
    
    // Actualiza el perfil de un usuario existente con nuevo nombre y biografía
    fn actualizar_perfil(ref self: TContractState, direccion: felt252, nuevo_nombre: felt252, nueva_bio: felt252);
    
    // Consulta la información de un usuario por su dirección
    // Retorna una tupla con (nombre, biografía, reputación, nivel)
    fn consultar_usuarios(self: @TContractState, direccion: felt252) -> (felt252, felt252, u64, u8);
    
    // Crea un nuevo reto en el sistema con sus detalles
    fn crear_retos(ref self: TContractState, id_reto: u64, titulo: felt252, descripcion: felt252, recompensa: u64);
    
    // Registra a un usuario como participante en un reto específico
    fn unirse_a_retos(ref self: TContractState, id_reto: u64, direccion: felt252);
    
    // Consulta la información de un reto por su ID
    // Retorna una tupla con (título, descripción, recompensa, estado de completado)
    fn consultar_retos(self: @TContractState, id_reto: u64) -> (felt252, felt252, u64, bool);
    
    // Permite a un usuario subir evidencia de haber completado un reto
    fn subir_evidencia(ref self: TContractState, id_reto: u64, direccion: felt252, evidencia: felt252);
    
    // Permite al administrador verificar si un reto ha sido completado correctamente
    fn verificar_reto(ref self: TContractState, id_reto: u64, verificado: bool);
}

// Implementación del contrato
// Aquí se define toda la lógica y el almacenamiento del contrato
#[starknet::contract]
pub mod IdentidadDescentralizada {
    // Importaciones necesarias para el funcionamiento del contrato
    use openzeppelin_access::ownable::OwnableComponent;  // Componente para gestión de propiedad
    use starknet::storage::{
        Map, StorageMapReadAccess, StorageMapWriteAccess, StoragePointerReadAccess,
        StoragePointerWriteAccess,
    };  // Utilidades para manejar el almacenamiento
    use starknet::{ContractAddress,};  // Funciones de utilidad de Starknet
    use super::IIdentidadDescentralizada;  // Importa la interfaz definida arriba

    // Declaración del componente Ownable para gestionar la propiedad del contrato
    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    // Implementación del componente Ownable
    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    // Constantes del contrato
    // Define roles y otros valores constantes
    const ADMIN_ROLE: felt252 = 'ADMIN_ROLE';

    // Definición de eventos que el contrato puede emitir
    // Los eventos permiten notificar a aplicaciones externas sobre cambios en el contrato
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        OwnableEvent: OwnableComponent::Event,  // Eventos del componente Ownable
        UsuarioRegistrado: UsuarioRegistrado,   // Evento cuando se registra un usuario
        PerfilActualizado: PerfilActualizado,   // Evento cuando se actualiza un perfil
        RetoCreado: RetoCreado,                 // Evento cuando se crea un reto
        UsuarioUnidoAReto: UsuarioUnidoAReto,   // Evento cuando un usuario se une a un reto
        EvidenciaSubida: EvidenciaSubida,       // Evento cuando se sube evidencia
        RetoVerificado: RetoVerificado,         // Evento cuando se verifica un reto
    }
    
    // Estructura del evento UsuarioRegistrado
    #[derive(Drop, starknet::Event)]
    struct UsuarioRegistrado {
        #[key]  // Campo indexado para búsquedas eficientes
        direccion: felt252,        // Dirección del usuario registrado
        reputacion_inicial: u64,   // Reputación inicial asignada
    }
    
    // Estructura del evento PerfilActualizado
    #[derive(Drop, starknet::Event)]
    struct PerfilActualizado {
        #[key]  // Campo indexado para búsquedas eficientes
        direccion: felt252,      // Dirección del usuario que actualizó su perfil
        nuevo_nombre: felt252,   // Nuevo nombre del usuario
        nueva_bio: felt252,      // Nueva biografía del usuario
    }
    
    // Estructura del evento RetoCreado
    #[derive(Drop, starknet::Event)]
    struct RetoCreado {
        #[key]  // Campo indexado para búsquedas eficientes
        id_reto: u64,          // ID único del reto creado
        titulo: felt252,       // Título del reto
        descripcion: felt252,  // Descripción del reto
        recompensa: u64,       // Recompensa ofrecida por completar el reto
    }
    
    // Estructura del evento UsuarioUnidoAReto
    #[derive(Drop, starknet::Event)]
    struct UsuarioUnidoAReto {
        #[key]  // Campo indexado para búsquedas eficientes
        id_reto: u64,     // ID del reto al que se unió el usuario
        #[key]  // Campo indexado para búsquedas eficientes
        direccion: felt252,  // Dirección del usuario que se unió al reto
    }
    
    // Estructura del evento EvidenciaSubida
    #[derive(Drop, starknet::Event)]
    struct EvidenciaSubida {
        #[key]  // Campo indexado para búsquedas eficientes
        id_reto: u64,       // ID del reto para el que se subió evidencia
        #[key]  // Campo indexado para búsquedas eficientes
        direccion: felt252,   // Dirección del usuario que subió la evidencia
        evidencia: felt252,   // Datos de la evidencia subida
    }
    
    // Estructura del evento RetoVerificado
    #[derive(Drop, starknet::Event)]
    struct RetoVerificado {
        #[key]  // Campo indexado para búsquedas eficientes
        id_reto: u64,      // ID del reto verificado
        verificado: bool,   // Estado de verificación (true = completado correctamente)
    }

    // Estructuras para almacenamiento de datos
    // Define los tipos de datos complejos que se almacenarán en el contrato
    
    // Estructura que representa a un usuario en el sistema
    #[derive(Drop, Copy, Serde, starknet::Store)]
    struct Usuario {
        nombre: felt252,    // Nombre del usuario
        bio: felt252,       // Biografía o descripción del usuario
        reputacion: u64,    // Puntuación de reputación del usuario
        nivel: u8,          // Nivel del usuario basado en su reputación
    }

    // Estructura que representa un reto en el sistema
    #[derive(Drop, Copy, Serde, starknet::Store)]
    struct Reto {
        titulo: felt252,       // Título del reto
        descripcion: felt252,  // Descripción detallada del reto
        recompensa: u64,       // Recompensa por completar el reto
        completado: bool,      // Estado de completado del reto
    }

    // Definición del almacenamiento del contrato
    // Aquí se declaran todas las variables de estado que persistirán en la blockchain
    #[storage]
    struct Storage {
        usuarios: Map<felt252, Usuario>,  // Mapa de usuarios por dirección
        retos: Map<u64, Reto>,            // Mapa de retos por ID
        participantes_reto: Map<(u64, felt252), bool>,  // Registro de participantes en retos
        evidencias: Map<(u64, felt252), felt252>,       // Evidencias subidas por usuarios
        contador_retos: u64,              // Contador para asignar IDs únicos a los retos
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,  // Almacenamiento del componente Ownable
    }

    // Constructor del contrato
    // Se ejecuta una sola vez cuando el contrato se despliega
    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        self.contador_retos.write(0);           // Inicializa el contador de retos a 0
        self.ownable.initializer(owner);        // Establece el propietario inicial del contrato
    }

    // Implementación de la interfaz IIdentidadDescentralizada
    #[abi(embed_v0)]
    impl IdentidadDescentralizadaImpl of IIdentidadDescentralizada<ContractState> {
        // Registra un nuevo usuario en el sistema con una reputación inicial
        fn registrar_usuarios(ref self: ContractState, direccion: felt252, reputacion_inicial: u64) {
            // Calcula el nivel inicial basado en la reputación
            let nivel_inicial = calcular_nivel(reputacion_inicial);
            
            // Crea un nuevo usuario con valores predeterminados
            let nuevo_usuario = Usuario {
                nombre: 'Usuario Nuevo',  // Nombre predeterminado
                bio: 'Sin biografia',     // Biografia predeterminada
                reputacion: reputacion_inicial,  // Reputación inicial proporcionada
                nivel: nivel_inicial,     // Nivel inicial calculado
            };
            
            // Almacena el usuario en el mapa de usuarios
            self.usuarios.write(direccion, nuevo_usuario);
            
            // Emite un evento para notificar que se ha registrado un usuario
            self.emit(UsuarioRegistrado { direccion, reputacion_inicial });
        }
        
        // Actualiza el perfil de un usuario existente con nuevo nombre y biografía
        fn actualizar_perfil(ref self: ContractState, direccion: felt252, nuevo_nombre: felt252, nueva_bio: felt252) {
            // Obtiene el usuario actual
            let usuario_actual = self.usuarios.read(direccion);
            
            // Crea un usuario actualizado manteniendo la reputación y nivel
            let usuario_actualizado = Usuario {
                nombre: nuevo_nombre,
                bio: nueva_bio,
                reputacion: usuario_actual.reputacion,
                nivel: usuario_actual.nivel,
            };
            
            // Actualiza el usuario en el almacenamiento
            self.usuarios.write(direccion, usuario_actualizado);
            
            // Emite un evento para notificar la actualización del perfil
            self.emit(PerfilActualizado { direccion, nuevo_nombre, nueva_bio });
        }
        
        // Consulta la información de un usuario por su dirección
        // Retorna una tupla con (nombre, biografía, reputación, nivel)
        fn consultar_usuarios(self: @ContractState, direccion: felt252) -> (felt252, felt252, u64, u8) {
            // Lee el usuario del almacenamiento
            let usuario = self.usuarios.read(direccion);
            
            // Retorna una tupla con los datos del usuario
            (usuario.nombre, usuario.bio, usuario.reputacion, usuario.nivel)
        }
        
        // Crea un nuevo reto en el sistema con sus detalles
        fn crear_retos(ref self: ContractState, id_reto: u64, titulo: felt252, descripcion: felt252, recompensa: u64) {
            // Crea un nuevo reto con los detalles proporcionados
            let nuevo_reto = Reto {
                titulo,
                descripcion,
                recompensa,
                completado: false,  // Inicialmente el reto no está completado
            };
            
            // Almacena el reto en el mapa de retos
            self.retos.write(id_reto, nuevo_reto);
            
            // Incrementa el contador de retos para el próximo ID
            self.contador_retos.write(self.contador_retos.read() + 1);
            
            // Emite un evento para notificar la creación del reto
            self.emit(RetoCreado { id_reto, titulo, descripcion, recompensa });
        }
        
        // Registra a un usuario como participante en un reto específico
        fn unirse_a_retos(ref self: ContractState, id_reto: u64, direccion: felt252) {
            // Registra al usuario como participante en el reto
            self.participantes_reto.write((id_reto, direccion), true);
            
            // Emite un evento para notificar que un usuario se ha unido al reto
            self.emit(UsuarioUnidoAReto { id_reto, direccion });
        }
        
        // Consulta la información de un reto por su ID
        fn consultar_retos(self: @ContractState, id_reto: u64) -> (felt252, felt252, u64, bool) {
            // Lee el reto del almacenamiento
            let reto = self.retos.read(id_reto);
            
            // Retorna una tupla con los datos del reto
            (reto.titulo, reto.descripcion, reto.recompensa, reto.completado)
        }
        
        // Permite a un usuario subir evidencia de haber completado un reto
        fn subir_evidencia(ref self: ContractState, id_reto: u64, direccion: felt252, evidencia: felt252) {
            // Verifica que el usuario esté participando en el reto
            assert(self.participantes_reto.read((id_reto, direccion)), 'Usuario no participa en reto');
            
            // Almacena la evidencia proporcionada
            self.evidencias.write((id_reto, direccion), evidencia);
            
            // Emite un evento para notificar que se ha subido evidencia
            self.emit(EvidenciaSubida { id_reto, direccion, evidencia });
        }
        
        // Permite al administrador verificar si un reto ha sido completado correctamente
        fn verificar_reto(ref self: ContractState, id_reto: u64, verificado: bool) {
            // Asegura que solo el propietario pueda verificar retos
            self.ownable.assert_only_owner();
            
            // Obtiene el reto actual
            let reto_actual = self.retos.read(id_reto);
            
            // Actualiza el estado de completado del reto
            let reto_actualizado = Reto {
                titulo: reto_actual.titulo,
                descripcion: reto_actual.descripcion,
                recompensa: reto_actual.recompensa,
                completado: verificado,  // Actualiza el estado de completado
            };
            
            // Guarda el reto actualizado
            self.retos.write(id_reto, reto_actualizado);
            
            // Emite un evento para notificar la verificación del reto
            self.emit(RetoVerificado { id_reto, verificado });
        }
    }

    // Función interna para calcular el nivel basado en la reputación
    fn calcular_nivel(reputacion: u64) -> u8 {
        // Implementación básica de cálculo de nivel basado en reputación
        // Puedes ajustar estos umbrales según tus necesidades
        if reputacion < 100 {
            1 // Nivel 1 para reputación menor a 100
        } else if reputacion < 500 {
            2 // Nivel 2 para reputación entre 100 y 499
        } else if reputacion < 1000 {
            3 // Nivel 3 para reputación entre 500 y 999
        } else if reputacion < 5000 {
            4 // Nivel 4 para reputación entre 1000 y 4999
        } else {
            5 // Nivel 5 para reputación de 5000 o más
        }
    }
}
