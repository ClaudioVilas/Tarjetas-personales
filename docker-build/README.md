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
