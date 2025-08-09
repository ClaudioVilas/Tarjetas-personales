#!/bin/bash

# Script simple para detectar y configurar IP dinámica (compatible con BusyBox)

CONFIG_DIR=${CONFIG_DIR:-/shared/config}
UPDATE_INTERVAL=${UPDATE_INTERVAL:-30}

echo "🔍 Iniciando servicio de configuración de IP dinámica..."
echo "📁 Directorio de configuración: $CONFIG_DIR"
echo "⏱️  Intervalo de actualización: ${UPDATE_INTERVAL}s"
if [ -n "$EXTERNAL_IP" ]; then
    echo "🌍 IP externa configurada manualmente: $EXTERNAL_IP"
else
    echo "🔍 Detectando IP automáticamente desde el contenedor"
fi

# Función para detectar la IP local (simplificada para BusyBox)
detect_local_ip() {
    # Si hay una IP externa configurada manualmente, usarla
    if [ -n "$EXTERNAL_IP" ]; then
        echo "$EXTERNAL_IP"
        return
    fi
    
    # Método simple usando el gateway por defecto
    ip route show | grep default | head -1 | awk '{print $9}'
}

# Función para generar configuración JSON
generate_config() {
    local ip="$1"
    local timestamp=$(date +%Y-%m-%dT%H:%M:%S)
    
    cat > "$CONFIG_DIR/network-config.json" << EOF
{
  "local_ip": "$ip",
  "backend_url": "http://$ip:5000",
  "email_service_url": "http://$ip:5001", 
  "frontend_url": "http://$ip:80",
  "timestamp": "$timestamp",
  "services": {
    "backend": {
      "host": "$ip",
      "port": 5000,
      "url": "http://$ip:5000"
    },
    "email": {
      "host": "$ip",
      "port": 5001,
      "url": "http://$ip:5001"
    },
    "frontend": {
      "host": "$ip",
      "port": 80,
      "url": "http://$ip:80"
    }
  }
}
EOF
}

# Función para generar archivo .env
generate_env_file() {
    local ip="$1"
    
    cat > "$CONFIG_DIR/.env" << EOF
# Configuración dinámica de red - Generado automáticamente
LOCAL_IP=$ip
BACKEND_URL=http://$ip:5000
EMAIL_SERVICE_URL=http://$ip:5001
FRONTEND_URL=http://$ip:80

# URLs para React/Vite
VITE_BACKEND_URL=http://$ip:5000
VITE_EMAIL_SERVICE_URL=http://$ip:5001

# Configuración para Python/Flask
FLASK_HOST=$ip
BACKEND_HOST=$ip
EMAIL_HOST=$ip
EOF
}

# Crear directorio si no existe
mkdir -p "$CONFIG_DIR"

# Loop principal
current_ip=""
while true; do
    new_ip=$(detect_local_ip)
    
    # Si no se puede obtener IP usando el primer método, intentar con hostname
    if [ -z "$new_ip" ] || [ "$new_ip" = "" ]; then
        new_ip=$(hostname -i 2>/dev/null | awk '{print $1}')
    fi
    
    # Si aún no hay IP, usar una IP por defecto
    if [ -z "$new_ip" ] || [ "$new_ip" = "" ]; then
        new_ip="172.20.0.10"  # IP por defecto dentro de la red Docker
    fi
    
    if [ -n "$new_ip" ] && [ "$new_ip" != "$current_ip" ]; then
        echo "🔄 IP detectada: $new_ip (anterior: ${current_ip:-'none'})"
        
        # Generar configuraciones
        generate_config "$new_ip"
        generate_env_file "$new_ip" 
        
        # Crear archivo de estado
        echo "$new_ip" > "$CONFIG_DIR/current-ip.txt"
        date +%Y-%m-%dT%H:%M:%S > "$CONFIG_DIR/last-update.txt"
        
        current_ip="$new_ip"
        echo "✅ Configuración actualizada exitosamente"
    fi
    
    sleep "$UPDATE_INTERVAL"
done
