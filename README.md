# 🎯 Sistema de Tarjetas Personales - La Pampa Cueros

> Sistema completo para generar tarjetas de contacto personalizadas con envío automático por email para la Feria de Cueros Shanghai 2025.

## 🚀 Inicio Rápido

```bash
# 1. Clonar el repositorio
git clone https://github.com/ClaudioVilas/Tarjetas-personales.git
cd Tarjetas-personales

# 2. Dar permisos de ejecución
chmod +x start_local.sh

# 3. Iniciar el sistema completo
./start_local.sh
```

## 🌐 Acceso al Sistema

Una vez iniciado, el sistema estará disponible en:

- **🎨 Frontend Principal**: http://localhost
- **🎨 Frontend Alternativo**: http://localhost:5173  
- **⚙️ Backend API**: http://localhost:5000
- **📧 Email Service**: http://localhost:5001

### Health Checks
- Backend: http://localhost:5000/health
- Email: http://localhost:5001/health

## 🏗️ Arquitectura del Sistema

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │───▶│    Backend      │───▶│  Email Service  │
│  (React/Vite)   │    │   (Flask/PDF)   │    │  (Flask/SMTP)   │
│   Port 80/5173  │    │    Port 5000    │    │    Port 5001    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
        │                       │                       │
        │                       ▼                       ▼
        │              📄 Genera PDFs         📧 Envía emails con
        │              personalizados            adjuntos automáticos
        │                       │                       │
        └─────────────────────────────────────────────────┘
                    Flujo completo integrado
```

## ✨ Características Principales

### 📋 Generación de PDFs
- Tarjetas personalizadas con datos de contacto
- Soporte para hasta 2 fotos adicionales
- Información de empresa, contacto, posición y descripción
- Generación automática de nombres de archivo

### 📧 Sistema de Email
- Envío automático por SMTP seguro (STARTTLS)
- Adjuntos automáticos de PDFs La Pampa Cueros:
  - Claudio Vilas.pdf
  - Daniel Andrada.pdf  
  - Brochure_La_Pampa_page-op.pdf
- Configuración profesional con info@lapampacueros.com

### 🎨 Interfaz Web
- Formulario intuitivo para captura de datos
- Previsualización en tiempo real
- Diseño responsivo
- Integración completa con backend

## 🛠️ APIs Disponibles

### Backend (Puerto 5000)
```bash
# Generar PDF
POST /generate_pdf
Content-Type: application/x-www-form-urlencoded

# Parámetros: empresa, nombreContacto, posicion, mail, descripcion
```

### Email Service (Puerto 5001)
```bash
# Enviar email con PDF
POST /send_pdf_email
Content-Type: application/json

{
  "recipient_email": "destinatario@email.com",
  "recipient_name": "Nombre Destinatario", 
  "pdf_filename": "archivo.pdf",
  "empresa": "Nombre Empresa"
}
```

## 🗂️ Estructura del Proyecto

```
Tarjetas-personales/
├── 📁 docker-build/              # Configuración Docker principal
│   ├── 📁 backend/               # Servicio generación PDFs
│   ├── 📁 email/                 # Servicio envío emails
│   ├── 📁 frontend/              # Interfaz web React
│   ├── 📁 shared/pdf-output/     # PDFs generados (compartido)
│   └── 📄 docker-compose.yml     # Orquestación servicios
├── 📁 Mail/                      # Servicio email independiente
├── 📁 cuaderno-feria-cueros/     # Backend legacy
├── 📄 start_local.sh             # 🚀 Script inicio principal
├── 📄 README_FUNCIONAMIENTO.md   # Documentación técnica
└── 📄 README.md                  # Este archivo
```

## 📖 Documentación Adicional

- **[📋 Funcionamiento Detallado](README_FUNCIONAMIENTO.md)** - Guía técnica completa
- **[🏗️ Despliegue Docker](DOCKER_DEPLOYMENT.md)** - Configuración contenedores
- **[📸 Sistema de Fotos](IMPLEMENTACION_DOS_FOTOS.md)** - Manejo de imágenes
- **[📊 Resumen Proyecto](PROYECTO_RESUMEN.md)** - Overview técnico
- **[✅ Solución Implementada](SOLUCION_IMPLEMENTADA.md)** - Detalles técnicos

## 🔧 Comandos de Gestión

```bash
# Ver estado de servicios
docker compose ps

# Ver logs en tiempo real
docker compose logs -f

# Ver logs específicos
docker compose logs backend
docker compose logs email-service
docker compose logs frontend

# Reiniciar servicios
docker compose restart

# Detener sistema
docker compose down

# Reconstruir y reiniciar
docker compose up -d --build
```

## 🎯 Casos de Uso

### 1. Uso Típico (Interfaz Web)
1. Abrir http://localhost
2. Completar formulario con datos de contacto
3. Subir fotos (opcional)
4. Generar PDF automáticamente
5. Enviar por email con adjuntos La Pampa Cueros

### 2. Uso API (Integración)
```bash
# Generar PDF
curl -X POST "http://localhost:5000/generate_pdf" \
  -d "empresa=Mi Empresa&nombreContacto=Juan Pérez&mail=juan@empresa.com"

# Enviar email  
curl -X POST "http://localhost:5001/send_pdf_email" \
  -H "Content-Type: application/json" \
  -d '{"recipient_email":"juan@empresa.com","pdf_filename":"Mi-Empresa.pdf"}'
```

## 🛡️ Configuración de Seguridad

- **SMTP Seguro**: STARTTLS habilitado
- **Validación de archivos**: Solo PDFs permitidos
- **Paths seguros**: Validación de rutas de archivos
- **Contenedores aislados**: Cada servicio en su contenedor

## ⚙️ Requisitos del Sistema

- **Docker Desktop** instalado y ejecutándose
- **Puertos disponibles**: 80, 5000, 5001, 5173
- **Espacio en disco**: ~500MB para imágenes Docker
- **Memoria RAM**: ~1GB recomendado

## 🐛 Troubleshooting

### Problema: Puerto en uso
```bash
# Verificar puertos ocupados
lsof -i :5000
lsof -i :5001

# Cambiar puertos en docker-compose.yml si necesario
```

### Problema: Docker no responde
```bash
# Reiniciar Docker Desktop
# Verificar: docker info
```

### Problema: Emails no se envían
```bash
# Verificar logs del servicio email
docker compose logs email-service

# Test de conectividad SMTP
curl http://localhost:5001/test_email_connection
```

## 🚀 Estado del Proyecto

**✅ TOTALMENTE FUNCIONAL**

- ✅ Generación automática de PDFs
- ✅ Envío de emails con SMTP seguro  
- ✅ Adjuntos automáticos La Pampa Cueros
- ✅ Interfaz web responsiva
- ✅ Sistema Docker completo
- ✅ APIs REST documentadas
- ✅ Logs y monitoreo
- ✅ Documentación completa

---

## 📞 Información de Contacto

**Proyecto**: Sistema Tarjetas Feria Cueros Shanghai 2025  
**Empresa**: La Pampa Cueros  
**Email**: info@lapampacueros.com  
**Repositorio**: https://github.com/ClaudioVilas/Tarjetas-personales

---

### 🏆 Listo para Producción

Este sistema está completamente funcional y listo para ser usado en la Feria de Cueros Shanghai 2025. Solo ejecuta `./start_local.sh` y comienza a generar tarjetas personalizadas.

**¡Éxito en la feria! 🎯🚀**
