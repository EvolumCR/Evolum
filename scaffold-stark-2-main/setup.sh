#!/bin/bash
set -e # Salir inmediatamente si un comando termina con un estado diferente de cero.

# --- Funciones Auxiliares ---
print_info() {
    echo -e "\033[34mINFO:\033[0m $1"
}

print_success() {
    echo -e "\033[32mSUCCESS:\033[0m $1"
}

print_warning() {
    echo -e "\033[33mWARNING:\033[0m $1"
}

command_exists() {
    command -v "$1" &> /dev/null
}

# --- Configuración basada en el README ---
NODE_MIN_MAJOR=18
NODE_MIN_MINOR=17
SCARB_VERSION_REQUIRED="2.11.4"
SNFORGE_VERSION_REQUIRED="0.41.0" # Starknet Foundry
DEVNET_VERSION_REQUIRED="0.4.0"

# --- Funciones de Instalación ---

install_nvm_and_node() {
    print_info "--- Verificando/Instalando Node.js (>=v${NODE_MIN_MAJOR}.${NODE_MIN_MINOR}) vía nvm ---"

    if ! command_exists nvm && [ ! -s "$HOME/.nvm/nvm.sh" ]; then
        print_info "nvm no encontrado, instalando nvm..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        
        export NVM_DIR="$HOME/.nvm"
        if [ -s "$NVM_DIR/nvm.sh" ]; then
            # shellcheck source=/dev/null
            . "$NVM_DIR/nvm.sh"
            print_info "Intentando cargar nvm.sh para la sesión actual del script."
        else
            print_warning "nvm.sh no encontrado después de la instalación. Esto es inesperado."
        fi

        if ! command_exists nvm; then
            print_warning "nvm ha sido instalado, pero el comando 'nvm' aún no está disponible en la sesión actual del script."
            print_warning "Por favor, CIERRA Y REABRE TU TERMINAL, luego vuelve a ejecutar este script para continuar con la instalación de Node.js y otras herramientas."
            exit 0 # Salida exitosa parcial, acción del usuario requerida
        else
            print_success "nvm instalado y cargado en la sesión actual del script."
        fi
    else
        export NVM_DIR="$HOME/.nvm" # Asegurarse de que NVM_DIR esté seteado
        # shellcheck source=/dev/null
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # Asegurarse de que nvm esté cargado
        if ! command_exists nvm; then
             print_warning "nvm.sh existe pero el comando nvm no está disponible. Revisa tu configuración de nvm."
             # No salimos aquí, dejamos que el script intente continuar o falle más adelante si nvm es crucial.
        else
            print_info "nvm está disponible."
        fi
    fi
    
    if ! command_exists nvm; then # Doble chequeo antes de usar nvm
        print_warning "El comando nvm no está disponible. Omitiendo la instalación de Node.js vía nvm."
        return 1 # Indica un problema para que el script principal pueda decidir
    fi

    # Verificar la versión de Node.js o instalar si falta
    INSTALL_NODE=false
    if command_exists node; then
        CURRENT_NODE_VERSION=$(node -v)
        CURRENT_MAJOR=$(echo "$CURRENT_NODE_VERSION" | sed 's/v//' | cut -d. -f1)
        CURRENT_MINOR=$(echo "$CURRENT_NODE_VERSION" | sed 's/v//' | cut -d. -f2)
        if [ "$CURRENT_MAJOR" -lt "$NODE_MIN_MAJOR" ] || ([ "$CURRENT_MAJOR" -eq "$NODE_MIN_MAJOR" ] && [ "$CURRENT_MINOR" -lt "$NODE_MIN_MINOR" ]); then
            print_info "La versión instalada de Node.js ($CURRENT_NODE_VERSION) es menor que la requerida (v${NODE_MIN_MAJOR}.${NODE_MIN_MINOR})."
            INSTALL_NODE=true
        else
            print_success "Node.js $CURRENT_NODE_VERSION está instalado y cumple los requisitos."
        fi
    else
        print_info "Node.js no está instalado."
        INSTALL_NODE=true
    fi

    if [ "$INSTALL_NODE" = true ]; then
        print_info "Instalando Node.js v18 (última revisión) usando nvm..."
        nvm install 18
        nvm use 18 # Usar en la sesión actual
        nvm alias default 18 # Establecer como predeterminado para nuevas shells
        print_success "Node.js $(node -v) instalado vía nvm."
    fi
    return 0
}

install_yarn() {
    print_info "--- Verificando/Instalando Yarn ---"
    if ! command_exists yarn; then
        print_info "Yarn no encontrado."
        if command_exists corepack; then
            print_info "Habilitando Yarn vía Corepack..."
            corepack enable
            # Puede que necesites ejecutar `yarn set version stable` o similar después,
            # pero `corepack enable` hace que `yarn` esté disponible.
            print_success "Yarn habilitado vía Corepack. Versión: $(yarn --version 2>/dev/null || echo 'ejecuta yarn --version para ver')"
        elif command_exists npm; then
            print_info "Corepack no encontrado. Instalando Yarn globalmente vía npm (clásico)..."
            sudo npm install --global yarn
            print_success "Yarn $(yarn --version) instalado globalmente vía npm."
        else
            print_warning "npm no está disponible. No se puede instalar Yarn automáticamente."
            return 1
        fi
    else
        print_success "Yarn ya está instalado: $(yarn --version)"
    fi
    return 0
}

install_git() {
    print_info "--- Verificando/Instalando Git ---"
    if ! command_exists git; then
        print_info "Git no encontrado. Instalando Git..."
        sudo apt update && sudo apt install -y git
        print_success "Git $(git --version) instalado."
    else
        print_success "Git ya está instalado: $(git --version)"
    fi
    return 0
}

install_starkup() {
    print_info "--- Verificando/Instalando Starkup ---"
    # STARKUP_EXEC="$HOME/.starknet/bin/starkup" # El script sh.starkup.sh (v0.2.6) no instala este binario si asdf ya está presente.

    if ! command_exists asdf; then
        print_info "Comando 'asdf' no encontrado. Ejecutando el script de instalación/configuración de Starkup (sh.starkup.sh)..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.starkup.sh | sh
        print_success "Script de instalación de Starkup ejecutado."
        
        # Intentar cargar asdf para la sesión actual del script
        if [ -s "$HOME/.asdf/asdf.sh" ]; then
            # shellcheck source=/dev/null
            . "$HOME/.asdf/asdf.sh"
            print_info "Intentando cargar asdf.sh para la sesión actual del script."
        fi

        if ! command_exists asdf; then
            print_warning "El comando 'asdf' aún no está disponible después de la instalación y el intento de carga."
            print_warning "Esto puede suceder si el script de Starkup necesita una nueva sesión de shell para que los cambios en PATH surtan efecto."
            print_warning "Por favor, CIERRA Y REABRE TU TERMINAL o ejecuta 'source ~/.bashrc' (o el archivo de configuración de tu shell)."
            print_warning "Luego, VUELVE A EJECUTAR este script (setup.sh) para continuar."
            exit 0 # Salida, acción del usuario requerida
        else
            print_success "Comando 'asdf' ahora disponible en la sesión actual del script."
        fi
    else
        print_success "Comando 'asdf' encontrado en el PATH."
        print_info "Asegurando que la configuración de ASDF para Starknet esté actualizada ejecutando sh.starkup.sh de nuevo..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.starkup.sh | sh
        print_success "Script de Starkup (sh.starkup.sh) re-ejecutado para asegurar configuración."
    fi

    # Asegurar que asdf.sh esté cargado antes de que setup_asdf_tools lo use.
    if [ -s "$HOME/.asdf/asdf.sh" ]; then
        # shellcheck source=/dev/null
        . "$HOME/.asdf/asdf.sh"
    fi
    return 0
}

setup_asdf_tools() {
    print_info "--- Configurando herramientas de Starknet vía asdf ---"
    if ! command_exists asdf; then
        print_warning "Comando asdf no encontrado. Esto podría ser porque Starkup no está instalado o '$HOME/.starknet/env' no está cargado en tu sesión actual."
        print_warning "Por favor, asegúrate de que Starkup esté instalado y ejecuta 'source \"\$HOME/.starknet/env\"' o abre una nueva terminal, luego vuelve a ejecutar esta parte del script o sigue el README."
        return 1
    fi

    # Scarb
    print_info "Verificando/Configurando Scarb v${SCARB_VERSION_REQUIRED}..."
    CURRENT_SCARB_GLOBAL=$(asdf global scarb 2>/dev/null | awk '{print $2}' || echo "none")
    if [ "$CURRENT_SCARB_GLOBAL" != "$SCARB_VERSION_REQUIRED" ]; then
        asdf plugin-add scarb https://github.com/software-mansion/asdf-scarb.git || print_info "Plugin asdf de Scarb ya añadido o falló al añadir."
        asdf install scarb "$SCARB_VERSION_REQUIRED"
        asdf global scarb "$SCARB_VERSION_REQUIRED"
        print_success "Scarb configurado a v${SCARB_VERSION_REQUIRED} globalmente vía asdf."
    else
        print_success "Scarb v${SCARB_VERSION_REQUIRED} ya está configurado globalmente vía asdf."
    fi

    # Starknet Foundry (snforge)
    print_info "Verificando/Configurando Starknet Foundry (snforge) v${SNFORGE_VERSION_REQUIRED}..."
    CURRENT_SNFORGE_GLOBAL=$(asdf global starknet-foundry 2>/dev/null | awk '{print $2}' || echo "none")
    if [ "$CURRENT_SNFORGE_GLOBAL" != "$SNFORGE_VERSION_REQUIRED" ]; then
        asdf plugin-add starknet-foundry https://github.com/foundry-rs/asdf-starknet-foundry.git || print_info "Plugin asdf de Starknet Foundry ya añadido o falló al añadir."
        asdf install starknet-foundry "$SNFORGE_VERSION_REQUIRED"
        asdf global starknet-foundry "$SNFORGE_VERSION_REQUIRED"
        print_success "Starknet Foundry configurado a v${SNFORGE_VERSION_REQUIRED} globalmente vía asdf."
    else
        print_success "Starknet Foundry v${SNFORGE_VERSION_REQUIRED} ya está configurado globalmente vía asdf."
    fi
    
    # Starknet Devnet
    print_info "Verificando/Configurando Starknet Devnet v${DEVNET_VERSION_REQUIRED}..."
    CURRENT_DEVNET_GLOBAL=$(asdf global starknet-devnet 2>/dev/null | awk '{print $2}' || echo "none")
    if [ "$CURRENT_DEVNET_GLOBAL" != "$DEVNET_VERSION_REQUIRED" ]; then
        asdf plugin-add starknet-devnet https://github.com/gianalarcon/asdf-starknet-devnet.git || print_info "Plugin asdf de Starknet Devnet ya añadido o falló al añadir."
        asdf install starknet-devnet "$DEVNET_VERSION_REQUIRED"
        asdf global starknet-devnet "$DEVNET_VERSION_REQUIRED"
        print_success "Starknet Devnet configurado a v${DEVNET_VERSION_REQUIRED} globalmente vía asdf."
    else
        print_success "Starknet Devnet v${DEVNET_VERSION_REQUIRED} ya está configurado globalmente vía asdf."
    fi
    return 0
}

# --- Ejecución Principal ---
main() {
    print_info "Iniciando la configuración del entorno de desarrollo de Starknet para WSL..."

    install_git || print_warning "Problema al instalar Git."
    install_nvm_and_node # No saldrá si nvm se carga correctamente
    install_yarn || print_warning "Problema al instalar Yarn."
    install_starkup # No saldrá si asdf se carga correctamente
    
    # Solo intentar configurar asdf si los pasos anteriores no indicaron salir.
    setup_asdf_tools || print_warning "Problema al configurar herramientas con asdf."

    print_success "Script de configuración completado."
    print_warning "Si alguna instalación de herramientas (especialmente nvm o starkup) se realizó por primera vez y el script NO se detuvo, es posible que aún necesites abrir una nueva ventana de terminal o recargar tu perfil de shell (ej., 'source ~/.bashrc' o 'source ~/.zshrc') para que todos los cambios surtan efecto completamente en futuras sesiones interactivas."
}

# Ejecutar la función principal
main