#!/bin/bash

# Script para iniciar el backend compilado
# Compilado con PyInstaller para standalone execution

echo "🚀 Iniciando Backend Compilado..."
echo "📡 Servidor: http://172.40.210.24:5000"
echo "📝 Para detener presiona Ctrl+C"
echo ""

# Cambiar al directorio del script
cd "$(dirname "$0")"

# Ejecutar el backend compilado
./backend_compiled
