# � Sistema de Tarjetas Personales - La Pampa Cueros

> Sistema completo para generar tarjetas de contacto personalizadas con envío automático por email para la Feria de Cueros Shanghai 2025.

## � Inicio Rápido

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

### � Interfaz Web
- Formulario intuitivo para captura de datos
- Previsualización en tiempo real
- Diseño responsivo
- Integración completa con backend

### Frontend (React + Vite)
- **Ubicación:** `docker-build/frontend/`
- **Framework:** React 18 + Vite
- **Funcionalidades:**
  - Formulario de datos de contacto (empresa, mail, descripción)
  - Gestión de Foto 1 con preview
  - Polling automático de última foto disponible
  - Generación y descarga automática de PDF

### Backend (Flask + Python)
- **Ubicación:** `cuaderno-feria-cueros/`
- **Framework:** Flask + CORS
- **Funcionalidades:**
  - Generación de PDF con FPDF
  - Gestión de archivos de fotos
  - API REST para frontend
  - Naming automático de archivos

### Servicio de Email (Flask + SMTP)
- **Ubicación:** `Mail/`
- **Framework:** Flask + SMTP
- **Funcionalidades:**
  - Envío automático de PDFs por email
  - Configuración SMTP segura (SSL/TLS)
  - Templates HTML personalizados
  - Logs detallados de envíos

## 🚀 Instalación y Uso

### Prerrequisitos
- Node.js 18+
- Python 3.8+
- pip

### Configuración Frontend
```bash
cd front-cuaderno-feria
npm install
npm run dev
```

### Configuración Backend
```bash
cd cuaderno-feria-cueros
pip install flask flask-cors fpdf2
python main.py
```

### Configuración Servicio Email
```bash
cd Mail
pip install -r requirements.txt
python email_server.py
```

### Inicio Automático (Recomendado)
```bash
# Inicia todos los servicios automáticamente
chmod +x start_local.sh
./start_local.sh
```

## 📱 Funcionalidades Implementadas

### ✅ Completadas
- [x] **Formulario de datos:** Empresa, email, descripción
- [x] **Gestión de Foto 1:** Upload, preview, eliminación
- [x] **Generación de PDF:** Con datos + Foto 1
- [x] **Polling automático:** Detección de nuevas fotos
- [x] **Responsive design:** Adaptable a móviles
- [x] **Naming inteligente:** PDFs nombrados por empresa
- [x] **Alineación izquierda:** Todos los elementos del PDF
- [x] **Envío automático por email:** PDFs enviados al email ingresado
- [x] **Templates HTML:** Emails personalizados con branding

### ❌ Funcionalidad Comentada (Por Requerimientos)
- [x] **Foto 2:** Completamente deshabilitada
- [x] **Foto principal:** No incluida en PDF final

## 📄 Estructura del PDF Generado
1. **Título:** "Datos de Contactos Feria Cueros Shanghai 2025"
2. **Empresa:** Nombre ingresado
3. **Mail:** Email de contacto
4. **Descripción:** Descripción del negocio
5. **Foto 1:** Imagen seleccionada (16:9, 160x90px)

## 🔧 API Endpoints

### Backend (Puerto 5000)
- `GET /ultima_foto` - Obtiene la última foto disponible
- `POST /upload` - Sube nueva foto
- `POST /generate_pdf` - Genera PDF con datos
- `GET /fotos/<filename>` - Sirve archivos de foto

### Servicio Email (Puerto 5001)
- `POST /send_pdf_email` - Envía PDF por email
- `GET /test_email_connection` - Prueba conexión SMTP
- `GET /health` - Estado del servicio

## 📁 Estructura del Proyecto
```
Copia de Proyecto Tarjetas Feria 2/
├── front-cuaderno-feria/          # Frontend React
│   ├── src/
│   │   ├── App.jsx               # Componente principal
│   │   ├── App.css               # Estilos
│   │   └── main.jsx              # Entry point
│   └── package.json
├── cuaderno-feria-cueros/        # Backend Flask
│   ├── main.py                   # Servidor principal
│   ├── fotos/                    # Almacén de imágenes
│   └── backend.log               # Logs del servidor
├── Mail/                         # Servicio de email
│   ├── email_service.py          # Lógica de envío SMTP
│   ├── email_server.py           # API REST para emails
│   ├── requirements.txt          # Dependencias Python
│   └── README.md                 # Documentación del servicio
├── Pdf Feria/                    # PDFs generados
├── SOLUCION_IMPLEMENTADA.md      # Documentación técnica
└── README.md                     # Este archivo
```

## 🧪 Tests Incluidos
- `test_solo_hasta_foto1.pdf` - PDF con Foto 1
- `test_sin_foto1.pdf` - PDF solo con texto
- `test_margen_izquierdo.pdf` - Verificación de alineación

## 🔮 Roadmap Futuro
- [ ] Autenticación de usuarios
- [ ] Dashboard de gestión
- [ ] Múltiples templates de email
- [ ] Integración con más proveedores SMTP

## 💻 Tecnologías Utilizadas
- **Frontend:** React, Vite, CSS3
- **Backend:** Python, Flask, FPDF
- **Email Service:** Python, Flask, SMTP, HTML Templates
- **Storage:** Sistema de archivos local
- **Tools:** Git, VS Code

## 📞 Contacto
Sistema desarrollado para La Pampa Cueros
- Email: info@lapampacueros.com
