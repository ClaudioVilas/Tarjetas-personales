#!/bin/bash

# Script para iniciar el proyecto completo localmente usando Docker
# Autor: Sistema de Tarjetas Personales - La Pampa Cueros
# Fecha: 22 de agosto de 2025

set -e  # Salir si algún comando falla

echo "🚀 Iniciando proyecto Tarjetas Personales - La Pampa Cueros"
echo "=================================================="

# Cambiar al directorio docker-build
cd "$(dirname "$0")/docker-build"

echo "📁 Directorio actual: $(pwd)"

# Verificar que docker-compose.yml existe
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: docker-compose.yml no encontrado"
    exit 1
fi

echo "🔍 Verificando estado de Docker..."
if ! docker info >/dev/null 2>&1; then
    echo "❌ Error: Docker no está ejecutándose. Por favor, inicia Docker Desktop."
    exit 1
fi

echo "✅ Docker está funcionando"

echo "🛠️  Construyendo e iniciando servicios..."
echo "   - IP Config Service"
echo "   - Backend (Generación de PDFs)"
echo "   - Email Service" 
echo "   - Frontend (Interfaz web)"

# Construir e iniciar todos los servicios
docker compose up -d --build

echo ""
echo "⏳ Esperando que los servicios estén listos..."
sleep 10

# Verificar estado de los servicios
echo "📊 Estado de los servicios:"
docker compose ps

echo ""
echo "🌐 URLs disponibles:"
echo "   📱 Frontend:     http://localhost"
echo "   📱 Frontend:     http://localhost:5173 (alternativo)"
echo "   🔧 Backend:      http://localhost:5000"
echo "   📧 Email:        http://localhost:5001"
echo ""
echo "🎯 Health checks:"
echo "   Backend:  http://localhost:5000/health"
echo "   Email:    http://localhost:5001/health"
echo ""
echo "✅ Proyecto iniciado correctamente!"
echo "   Para detener: docker compose down"
echo "   Para ver logs: docker compose logs -f"
echo "=================================================="
