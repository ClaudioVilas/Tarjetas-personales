# 🐳 Docker Deployment - Tarjetas Feria

## 📦 ESTRUCTURA GENERADA

```
docker-build/
├── services/                    # Dockerfiles de cada servicio
│   ├── backend.Dockerfile       # Backend Flask + PDF
│   ├── frontend.Dockerfile      # Frontend React + Nginx  
│   ├── email.Dockerfile         # Servicio SMTP
│   └── ip-config.Dockerfile     # Detección IP dinámica
│
├── backend/                     # Código del backend
├── frontend/                    # Código del frontend  
├── email/                       # Código del servicio email
├── data/                        # Datos persistentes
│   ├── backend/fotos/           # Imágenes subidas
│   ├── backend/uploads/         # Archivos temporales
│   └── email/attachments/       # PDFs La Pampa Cueros
│
├── docker-compose.yml           # Orquestación principal
├── nginx.conf                   # Configuración Nginx
├── ip-config-service.sh         # Script detección IP
├── start-backend.sh             # Inicio backend
├── start-email.sh               # Inicio email service
├── configure-frontend.sh        # Configuración frontend
├── package.json                 # Metadata del proyecto
└── README.md                    # Documentación de uso
```

## 🔧 CONFIGURACIÓN DINÁMICA DE IP

### ✅ Problema Resuelto:
- **Antes**: IP hardcodeada en código fuente
- **Ahora**: Detección automática y configuración dinámica

### 🛠️ Cómo Funciona:

1. **Servicio `ip-config`** detecta la IP local cada 30s
2. Genera archivo `/shared/config/network-config.json`:
   ```json
   {
     "local_ip": "192.168.1.100",
     "backend_url": "http://192.168.1.100:5000",
     "email_service_url": "http://192.168.1.100:5001",
     "frontend_url": "http://192.168.1.100:80"
   }
   ```
3. Genera archivo `.env` con variables de entorno
4. Cada servicio lee esta configuración al iniciar
5. Frontend carga configuración vía JavaScript dinámico

## 🚀 INICIO DEL SISTEMA

```bash
# 1. Navegar al directorio de build
cd docker-build

# 2. Iniciar todos los servicios
docker-compose up -d

# 3. Verificar que todo esté funcionando
docker-compose ps
docker-compose logs -f
```

## 📡 URLS DE ACCESO (Dinámicas)

Una vez iniciado, el sistema estará disponible en:
- **Frontend**: http://[IP-DETECTADA]:80
- **Backend API**: http://[IP-DETECTADA]:5000
- **Email Service**: http://[IP-DETECTADA]:5001

La IP se detecta automáticamente según la red donde esté la máquina.

## 🔄 COMUNICACIÓN ENTRE SERVICIOS

### Red Docker Interna:
- `backend` ↔ `email-service` (puerto 5001)
- `frontend` → `backend` (puerto 5000)  
- `frontend` → `email-service` (puerto 5001)

### Volúmenes Compartidos:
- `shared-config`: Configuración de IP dinámica
- `shared-pdf`: PDFs generados por backend → email service
- `./data/*`: Datos persistentes del host

## 🛠️ VENTAJAS DE ESTA SOLUCIÓN

### ✅ **IP Dinámica**:
- Se adapta automáticamente a cualquier red
- No requiere reconfiguración manual
- Actualización en tiempo real

### ✅ **Containerizado**:
- Fácil despliegue en cualquier máquina con Docker
- Servicios aislados y escalables
- Gestión centralizada con docker-compose

### ✅ **Persistencia**:
- Datos conservados entre reinicios
- Volúmenes para fotos, PDFs y configuración
- Logs accesibles

### ✅ **Producción-Ready**:
- Nginx optimizado para frontend
- Restart automático de servicios
- Configuración de red robusta

## 🔧 COMANDOS DE GESTIÓN

```bash
# Ver logs en tiempo real
docker-compose logs -f

# Reiniciar un servicio específico  
docker-compose restart backend

# Parar todos los servicios
docker-compose down

# Parar y limpiar volúmenes
docker-compose down -v

# Reconstruir tras cambios de código
docker-compose build
docker-compose up -d

# Ver estado de servicios
docker-compose ps

# Acceder a shell de un contenedor
docker-compose exec backend bash
```

## 🎯 RESULTADO FINAL

✅ **Sistema completamente dockerizado**
✅ **IP dinámica funcionando automáticamente** 
✅ **Comunicación fluida entre servicios**
✅ **Build listo para producción**
✅ **Documentación completa incluida**

El proyecto ahora puede ejecutarse en **cualquier red** con un solo comando: `docker-compose up -d`
