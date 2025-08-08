#!/bin/bash

# Script de inicio para Backend con configuración dinámica
CONFIG_DIR=${CONFIG_DIR:-/shared/config}
MAX_WAIT=60
WAIT_COUNT=0

echo "🚀 Iniciando Backend - Cuaderno Feria Cueros"
echo "📁 Esperando configuración de IP en: $CONFIG_DIR"

# Esperar por la configuración de IP
while [ ! -f "$CONFIG_DIR/network-config.json" ] && [ $WAIT_COUNT -lt $MAX_WAIT ]; do
    echo "⏳ Esperando configuración de red... ($WAIT_COUNT/$MAX_WAIT)"
    sleep 1
    WAIT_COUNT=$((WAIT_COUNT + 1))
done

if [ ! -f "$CONFIG_DIR/network-config.json" ]; then
    echo "❌ Error: No se pudo obtener configuración de red"
    exit 1
fi

# Leer configuración
if command -v jq >/dev/null 2>&1; then
    LOCAL_IP=$(jq -r '.local_ip' "$CONFIG_DIR/network-config.json")
    BACKEND_URL=$(jq -r '.services.backend.url' "$CONFIG_DIR/network-config.json")
else
    # Fallback sin jq
    LOCAL_IP=$(grep -o '"local_ip": "[^"]*"' "$CONFIG_DIR/network-config.json" | cut -d'"' -f4)
fi

echo "🌐 IP Local detectada: $LOCAL_IP"
echo "🔧 Backend URL: $BACKEND_URL"

# Cargar variables de entorno si existe
if [ -f "$CONFIG_DIR/.env" ]; then
    source "$CONFIG_DIR/.env"
    echo "✅ Variables de entorno cargadas desde .env"
fi

# Configurar rutas dinámicamente  
export FLASK_HOST=0.0.0.0  # Flask debe escuchar en todas las interfaces
export PDF_OUTPUT_DIR=${PDF_OUTPUT_DIR:-/shared/pdf-output}
export LOCAL_IP=${LOCAL_IP}

# Crear directorios necesarios
mkdir -p "$PDF_OUTPUT_DIR"
mkdir -p /app/fotos
mkdir -p /app/uploads

# Mensaje de inicio
echo "📡 Iniciando servidor Flask en $FLASK_HOST:5000"
echo "📂 Directorio PDF: $PDF_OUTPUT_DIR"
echo "📸 Directorio Fotos: /app/fotos"

# Iniciar aplicación Flask
exec python main.py
