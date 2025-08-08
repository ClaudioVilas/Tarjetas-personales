#!/bin/bash

# Script de inicio para Servicio de Email con configuración dinámica
CONFIG_DIR=${CONFIG_DIR:-/shared/config}
MAX_WAIT=60
WAIT_COUNT=0

echo "📧 Iniciando Servicio de Email"
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
    EMAIL_URL=$(jq -r '.services.email.url' "$CONFIG_DIR/network-config.json")
else
    # Fallback sin jq
    LOCAL_IP=$(grep -o '"local_ip": "[^"]*"' "$CONFIG_DIR/network-config.json" | cut -d'"' -f4)
fi

echo "🌐 IP Local detectada: $LOCAL_IP"
echo "📧 Email Service URL: $EMAIL_URL"

# Cargar variables de entorno si existe
if [ -f "$CONFIG_DIR/.env" ]; then
    source "$CONFIG_DIR/.env"
    echo "✅ Variables de entorno cargadas desde .env"
fi

# Configurar rutas dinámicamente
export EMAIL_HOST=${LOCAL_IP:-0.0.0.0}
export PDF_INPUT_DIR=${PDF_INPUT_DIR:-/shared/pdf-output}

# Crear directorios necesarios
mkdir -p "$PDF_INPUT_DIR"
mkdir -p /app/attachments

# Mensaje de inicio
echo "📡 Iniciando servidor de Email en $EMAIL_HOST:5001"
echo "📂 Directorio PDF: $PDF_INPUT_DIR"
echo "📎 Directorio Attachments: /app/attachments"

# Iniciar servicio de email
exec python email_server.py
