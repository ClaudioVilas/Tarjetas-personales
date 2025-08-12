#!/bin/bash

# Script mejorado para gestión completa de Docker
# Incluye detección de IP, construcción optimizada y monitoreo

set -e

echo "🐳 === GESTOR DOCKER TARJETAS PERSONALES ==="
echo "📅 $(date)"
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funciones de utilidad
print_step() {
    echo -e "${BLUE}🔄 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Función para detectar IP actual
detect_ip() {
    print_step "Detectando IP actual del sistema..."
    
    local detected_ip=""
    
    # Método 1: WiFi (en0) - macOS
    if command -v ifconfig >/dev/null 2>&1; then
        detected_ip=$(ifconfig en0 2>/dev/null | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | head -1)
        if [ -n "$detected_ip" ]; then
            print_success "IP detectada en WiFi (en0): $detected_ip"
            echo "$detected_ip"
            return
        fi
        
        # Método 2: Ethernet (en1)
        detected_ip=$(ifconfig en1 2>/dev/null | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | head -1)
        if [ -n "$detected_ip" ]; then
            print_success "IP detectada en Ethernet (en1): $detected_ip"
            echo "$detected_ip"
            return
        fi
        
        # Método 3: Cualquier interfaz activa
        detected_ip=$(ifconfig 2>/dev/null | grep 'inet ' | grep -v '127.0.0.1' | grep -v '169.254' | awk '{print $2}' | head -1)
        if [ -n "$detected_ip" ]; then
            print_success "IP detectada en interfaz activa: $detected_ip"
            echo "$detected_ip"
            return
        fi
    fi
    
    print_warning "No se pudo detectar IP automáticamente"
    echo "192.168.1.100" # IP por defecto
}

# Función para actualizar IP en docker-compose.yml
update_ip_in_compose() {
    local new_ip=$1
    print_step "Actualizando IP en docker-compose.yml..."
    
    if command -v sed >/dev/null 2>&1; then
        # Backup del archivo original
        cp docker-compose.yml docker-compose.yml.backup.$(date +%Y%m%d_%H%M%S)
        
        # Actualizar la IP
        sed -i '' "s/EXTERNAL_IP=.*/EXTERNAL_IP=$new_ip/" docker-compose.yml
        print_success "IP actualizada a: $new_ip"
    else
        print_error "sed no disponible"
        return 1
    fi
}

# Función para verificar y crear directorios
setup_directories() {
    print_step "Verificando y creando directorios necesarios..."
    
    local dirs=(
        "volumes/shared-config"
        "volumes/shared-pdf"
        "data/backend/fotos"
        "data/backend/uploads"
        "data/email/attachments"
    )
    
    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            print_success "Directorio creado: $dir"
        fi
    done
}

# Función para limpiar sistema Docker
cleanup_docker() {
    print_step "Limpiando sistema Docker anterior..."
    
    # Detener servicios actuales
    docker-compose down -v --remove-orphans 2>/dev/null || true
    
    # Limpiar imágenes del proyecto
    docker images --format "table {{.Repository}}:{{.Tag}}" | grep "docker-build" | xargs -r docker rmi -f 2>/dev/null || true
    
    # Limpiar caché de build
    docker builder prune -f >/dev/null 2>&1 || true
    
    print_success "Limpieza completada"
}

# Función para construir servicios
build_services() {
    print_step "Construyendo servicios Docker..."
    
    # Habilitar BuildKit para builds más rápidos
    export DOCKER_BUILDKIT=1
    export COMPOSE_DOCKER_CLI_BUILD=1
    
    # Construir servicios en paralelo cuando sea posible
    docker-compose build --parallel --no-cache
    
    print_success "Servicios construidos exitosamente"
}

# Función para iniciar servicios
start_services() {
    print_step "Iniciando servicios Docker..."
    
    # Iniciar servicios
    docker-compose up -d
    
    print_success "Servicios iniciados"
}

# Función para verificar salud de servicios
check_health() {
    print_step "Verificando salud de los servicios..."
    
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        attempt=$((attempt + 1))
        
        # Verificar estado de contenedores
        local healthy_count=$(docker-compose ps --services --filter "status=running" | wc -l | tr -d ' ')
        local total_services=4
        
        if [ "$healthy_count" -eq "$total_services" ]; then
            print_success "Todos los servicios están funcionando correctamente"
            return 0
        fi
        
        print_warning "Esperando que los servicios se inicien... (${attempt}/${max_attempts})"
        sleep 5
    done
    
    print_error "Algunos servicios no se iniciaron correctamente"
    docker-compose ps
    return 1
}

# Función para mostrar información de conexión
show_connection_info() {
    local current_ip=$1
    
    echo ""
    echo "🎉 === SERVICIOS LISTOS ==="
    echo ""
    print_success "URLs de acceso:"
    echo "  📱 Frontend:      http://$current_ip"
    echo "  🔧 Backend:       http://$current_ip:5000"
    echo "  📧 Email Service: http://$current_ip:5001"
    echo ""
    print_success "Comandos útiles:"
    echo "  docker-compose logs -f               # Ver logs en tiempo real"
    echo "  docker-compose ps                    # Estado de servicios"
    echo "  docker-compose restart <servicio>   # Reiniciar servicio específico"
    echo "  docker-compose down                  # Detener todos los servicios"
    echo "  ./docker-manager.sh status           # Ver estado detallado"
    echo ""
}

# Función para mostrar estado de servicios
show_status() {
    echo "📊 === ESTADO DE SERVICIOS ==="
    docker-compose ps
    echo ""
    echo "🌐 === REDES ==="
    docker network ls | grep tarjetas
    echo ""
    echo "💾 === VOLÚMENES ==="
    docker volume ls | grep tarjetas
    echo ""
    echo "🔧 === SALUD DE SERVICIOS ==="
    docker-compose exec ip-config test -f /shared/config/network-config.json && echo "✅ IP Config: OK" || echo "❌ IP Config: FAIL"
    curl -s http://localhost:5000/health >/dev/null && echo "✅ Backend: OK" || echo "❌ Backend: FAIL"
    curl -s http://localhost:5001/health >/dev/null && echo "✅ Email Service: OK" || echo "❌ Email Service: FAIL"
    curl -s http://localhost:80 >/dev/null && echo "✅ Frontend: OK" || echo "❌ Frontend: FAIL"
}

# Función principal
main() {
    case "${1:-start}" in
        "start")
            # Detectar IP automáticamente o usar manual
            local current_ip
            if [ -n "$MANUAL_IP" ]; then
                current_ip="$MANUAL_IP"
                print_success "Usando IP manual: $current_ip"
            else
                current_ip=$(detect_ip)
            fi
            
            # Ejecutar pasos de configuración
            setup_directories
            update_ip_in_compose "$current_ip"
            cleanup_docker
            build_services
            start_services
            
            # Verificar y mostrar información
            if check_health; then
                show_connection_info "$current_ip"
            else
                print_error "Error en el inicio de servicios"
                exit 1
            fi
            ;;
            
        "stop")
            print_step "Deteniendo servicios..."
            docker-compose down
            print_success "Servicios detenidos"
            ;;
            
        "restart")
            print_step "Reiniciando servicios..."
            $0 stop
            sleep 2
            $0 start
            ;;
            
        "clean")
            print_step "Limpieza completa del sistema..."
            cleanup_docker
            docker system prune -a --volumes -f
            print_success "Limpieza completa finalizada"
            ;;
            
        "status")
            show_status
            ;;
            
        "logs")
            docker-compose logs -f "${2:-}"
            ;;
            
        "help"|"--help"|"-h")
            echo "🐳 Gestor Docker - Tarjetas Personales"
            echo ""
            echo "Uso: $0 [comando] [opciones]"
            echo ""
            echo "Comandos:"
            echo "  start     - Iniciar todos los servicios (por defecto)"
            echo "  stop      - Detener todos los servicios"
            echo "  restart   - Reiniciar todos los servicios"
            echo "  clean     - Limpieza completa del sistema Docker"
            echo "  status    - Mostrar estado de servicios"
            echo "  logs      - Ver logs (logs <servicio> para servicio específico)"
            echo "  help      - Mostrar esta ayuda"
            echo ""
            echo "Variables de entorno:"
            echo "  MANUAL_IP=192.168.1.100  - Forzar IP específica"
            echo ""
            echo "Ejemplos:"
            echo "  $0                        - Iniciar con IP automática"
            echo "  MANUAL_IP=10.0.0.50 $0   - Iniciar con IP manual"
            echo "  $0 logs email-service     - Ver logs del servicio de email"
            echo ""
            ;;
            
        *)
            print_error "Comando desconocido: $1"
            echo "Usa '$0 help' para ver comandos disponibles"
            exit 1
            ;;
    esac
}

# Verificar que estamos en el directorio correcto
if [ ! -f "docker-compose.yml" ]; then
    print_error "docker-compose.yml no encontrado"
    print_warning "Ejecuta este script desde el directorio docker-build"
    exit 1
fi

# Ejecutar función principal
main "$@"
