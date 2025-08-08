#!/bin/bash

# Script de build automático para el proyecto Tarjetas Feria
# Genera todo el entorno Dockerizado listo para despliegue

echo "🚀 Iniciando build del proyecto Tarjetas Feria..."

PROJECT_ROOT="$(pwd)"
BUILD_DIR="$PROJECT_ROOT/docker-build"
DATA_DIR="$BUILD_DIR/data"

# Crear directorios de datos
echo "📁 Creando estructura de directorios..."
mkdir -p "$DATA_DIR"/{backend/{fotos,uploads},email/attachments}

# ===============================
# PREPARAR BACKEND
# ===============================
echo "🔧 Preparando Backend..."

# Crear directorio backend en build
mkdir -p "$BUILD_DIR/backend"

# Copiar archivos del backend
cp -r cuaderno-feria-cueros/* "$BUILD_DIR/backend/"

# Crear requirements.txt para backend
cat > "$BUILD_DIR/requirements.txt" << EOF
Flask==2.3.3
flask-cors==4.0.0
Werkzeug==2.3.7
fpdf2==2.7.4
Pillow==10.0.0
python-dotenv==1.0.0
EOF

# ===============================
# PREPARAR FRONTEND
# ===============================
echo "🌐 Preparando Frontend..."

# Crear directorio frontend en build
mkdir -p "$BUILD_DIR/frontend"

# Copiar archivos del frontend
cp -r front-cuaderno-feria/* "$BUILD_DIR/frontend/"

# Modificar App.jsx para usar configuración dinámica
cat > "$BUILD_DIR/frontend/src/config.js" << 'EOF'
// Configuración dinámica del frontend
export const getConfig = () => {
  // Intentar cargar configuración desde el archivo generado dinámicamente
  if (window.APP_CONFIG) {
    return {
      BACKEND_URL: window.APP_CONFIG.BACKEND_URL,
      EMAIL_SERVICE_URL: window.APP_CONFIG.EMAIL_SERVICE_URL,
      LOCAL_IP: window.APP_CONFIG.LOCAL_IP
    };
  }
  
  // Fallback a variables de entorno o valores por defecto
  return {
    BACKEND_URL: import.meta.env.VITE_BACKEND_URL || 'http://localhost:5000',
    EMAIL_SERVICE_URL: import.meta.env.VITE_EMAIL_SERVICE_URL || 'http://localhost:5001',
    LOCAL_IP: 'localhost'
  };
};

// Función para actualizar la configuración dinámicamente
export const updateConfig = () => {
  return new Promise((resolve, reject) => {
    const script = document.createElement('script');
    script.src = '/config.js?t=' + Date.now();
    script.onload = () => {
      resolve(getConfig());
    };
    script.onerror = reject;
    document.head.appendChild(script);
  });
};
EOF

# ===============================
# PREPARAR SERVICIO DE EMAIL
# ===============================
echo "📧 Preparando Servicio de Email..."

# Crear directorio email en build
mkdir -p "$BUILD_DIR/email"

# Copiar archivos del servicio de email
cp -r Mail/* "$BUILD_DIR/email/"

# Copiar archivos PDF de La Pampa Cueros
cp -r "La Pampa Cueros"/* "$DATA_DIR/email/attachments/"

# ===============================
# GENERAR PACKAGE.JSON PARA EL BUILD
# ===============================
cat > "$BUILD_DIR/package.json" << 'EOF'
{
  "name": "tarjetas-feria-docker",
  "version": "1.0.0",
  "description": "Sistema de tarjetas personales Feria Cueros Shanghai 2025",
  "scripts": {
    "build": "echo 'Build completado'",
    "start": "docker-compose up -d",
    "stop": "docker-compose down",
    "restart": "docker-compose restart",
    "logs": "docker-compose logs -f",
    "clean": "docker-compose down -v && docker system prune -f"
  },
  "keywords": ["docker", "flask", "react", "pdf", "email"],
  "author": "Claudio Vilas",
  "license": "MIT"
}
EOF

# ===============================
# GENERAR README DE DESPLIEGUE
# ===============================
cat > "$BUILD_DIR/README.md" << 'EOF'
# 🎯 Tarjetas Feria - Entorno Docker

Sistema dockerizado para generación de tarjetas personales con configuración dinámica de IP.

## 🚀 Inicio Rápido

```bash
# Iniciar todos los servicios
docker-compose up -d

# Ver logs en tiempo real
docker-compose logs -f

# Detener servicios
docker-compose down
```

## 📡 URLs de Acceso

Los servicios se configuran automáticamente con la IP local detectada:

- **Frontend**: http://[IP-LOCAL]:80
- **Backend**: http://[IP-LOCAL]:5000  
- **Email Service**: http://[IP-LOCAL]:5001

## 🔧 Servicios Incluidos

### 1. **ip-config** 
- Detecta automáticamente la IP local
- Genera configuración dinámica en tiempo real
- Actualiza archivos `.env` y `config.json`

### 2. **backend**
- Generación de PDFs con compresión
- API REST para gestión de datos
- Almacenamiento compartido de archivos

### 3. **email-service**
- Envío de emails con adjuntos
- Integración con PDFs generados
- Configuración SMTP

### 4. **frontend**
- Interface React optimizada
- Configuración IP dinámica
- Nginx como servidor web

## 📁 Estructura de Datos

```
docker-build/
├── data/
│   ├── backend/
│   │   ├── fotos/          # Imágenes subidas
│   │   └── uploads/        # Archivos temporales
│   └── email/
│       └── attachments/    # PDFs de La Pampa Cueros
├── services/              # Dockerfiles
├── docker-compose.yml     # Configuración principal
└── README.md             # Esta documentación
```

## 🔄 Configuración Automática

El sistema detecta automáticamente:
- IP local de la red
- Configuración de servicios
- URLs de comunicación entre contenedores

No requiere configuración manual de IPs.

## 🛠️ Comandos Útiles

```bash
# Ver estado de servicios
docker-compose ps

# Reiniciar un servicio específico
docker-compose restart backend

# Ver logs de un servicio
docker-compose logs frontend

# Acceder a un contenedor
docker-compose exec backend bash

# Limpiar todo (incluye volúmenes)
docker-compose down -v
docker system prune -f
```

## 🔧 Desarrollo

Para modificar el código:

1. Editar archivos en `backend/`, `frontend/`, o `email/`
2. Reconstruir servicios: `docker-compose build`
3. Reiniciar: `docker-compose up -d`

## 📋 Requisitos

- Docker >= 20.10
- Docker Compose >= 2.0
- Puertos 80, 5000, 5001 disponibles
EOF

# ===============================
# PERMISOS Y FINALIZACIÓN
# ===============================
echo "🔒 Configurando permisos..."

# Dar permisos de ejecución a los scripts
chmod +x "$BUILD_DIR"/*.sh

# Crear archivo de versión
echo "$(date -Iseconds)" > "$BUILD_DIR/build-timestamp.txt"

echo ""
echo "✅ Build completado exitosamente!"
echo ""
echo "📁 Directorio de build: $BUILD_DIR"
echo "🚀 Para iniciar: cd docker-build && docker-compose up -d"
echo "📡 Frontend estará disponible en: http://[TU-IP-LOCAL]:80"
echo "🔧 Backend API en: http://[TU-IP-LOCAL]:5000"
echo "📧 Email Service en: http://[TU-IP-LOCAL]:5001"
echo ""
echo "🔍 La IP se detecta automáticamente al iniciar los contenedores"
