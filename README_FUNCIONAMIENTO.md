# Sistema de Tarjetas Personales - La Pampa Cueros
## ✅ SISTEMA TOTALMENTE FUNCIONAL

### 🚀 Inicio Rápido

```bash
# Clonar e iniciar proyecto completo
git clone https://github.com/ClaudioVilas/Tarjetas-personales.git
cd Tarjetas-personales
chmod +x start_local.sh
./start_local.sh
```

### 🌐 URLs Disponibles

- **Frontend**: http://localhost (principal) / http://localhost:5173 (alternativo)
- **Backend**: http://localhost:5000 (generación de PDFs)
- **Email Service**: http://localhost:5001 (envío de emails)

### 🔧 Health Checks

- Backend: http://localhost:5000/health
- Email: http://localhost:5001/health

### 📋 Flujo Completo Funcionando

1. **Generación de PDF**: 
   ```bash
   curl -X POST "http://localhost:5000/generate_pdf" \
     -H "Content-Type: application/x-www-form-urlencoded" \
     -d "empresa=Empresa&nombreContacto=Contacto&posicion=Posicion&mail=email@test.com&descripcion=Descripcion"
   ```

2. **Envío de Email**:
   ```bash
   curl -X POST "http://localhost:5001/send_pdf_email" \
     -H "Content-Type: application/json" \
     -d '{
       "recipient_email": "destinatario@email.com",
       "recipient_name": "Nombre Destinatario",
       "pdf_filename": "archivo.pdf",
       "empresa": "Nombre Empresa"
     }'
   ```

### 📧 Configuración de Email

- **Servidor SMTP**: mail.lapampacueros.com:587
- **Usuario**: info@lapampacueros.com
- **Seguridad**: STARTTLS habilitado
- **Adjuntos automáticos**: PDFs de La Pampa Cueros incluidos

### 🛠️ Arquitectura

```
Frontend (React/Vite) → Backend (Flask/PDF) → Email Service (Flask/SMTP)
     ↓                       ↓                        ↓
Port 80/5173           Port 5000              Port 5001
```

### 📁 Estructura de Archivos

- `/shared/pdf-output/`: PDFs generados compartidos entre servicios
- `/app/fotos/`: Directorio de fotos en contenedor backend
- Volume mounting configurado correctamente

### 🔄 Comandos de Gestión

```bash
# Iniciar proyecto
./start_local.sh

# Ver estado
docker compose ps

# Ver logs
docker compose logs -f

# Detener
docker compose down

# Reconstruir
docker compose up -d --build
```

### ✅ Problemas Resueltos

1. **Rutas hardcodeadas**: Corregidas para usar rutas de contenedor
2. **Montaje de volúmenes**: Configurado correctamente
3. **Conectividad SMTP**: Verificada y funcionando
4. **Adjuntos automáticos**: PDFs La Pampa Cueros incluidos
5. **Flujo completo**: Frontend → Backend → Email operativo

### 📊 Estado Actual: TOTALMENTE FUNCIONAL ✅

- ✅ Generación de PDFs
- ✅ Envío de emails
- ✅ Adjuntos automáticos
- ✅ Configuración SMTP
- ✅ Interfaz web
- ✅ Sistema Docker completo
