#!/bin/bash

echo "🚀 Iniciando Backend Simple - Cuaderno Feria Cueros"

# Configurar variables básicas
export FLASK_HOST=0.0.0.0
export FLASK_PORT=5000
export PDF_OUTPUT_DIR=/shared/pdf-output

# Crear directorios necesarios
mkdir -p "$PDF_OUTPUT_DIR"
mkdir -p /app/fotos
mkdir -p /app/uploads

echo "📡 Iniciando servidor Flask en $FLASK_HOST:$FLASK_PORT"
echo "📂 Directorio PDF: $PDF_OUTPUT_DIR"
echo "📸 Directorio Fotos: /app/fotos"

# Iniciar aplicación Flask directamente
cd /app && exec python main.py
