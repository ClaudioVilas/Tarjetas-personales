# 📧 Servicio de Envío de Emails

Servicio para enviar PDFs generados por email desde el sistema de tarjetas personales de la Feria Cueros Shanghai 2025.

## 🚀 Configuración y Uso

### Instalación de dependencias
```bash
cd Mail
pip install -r requirements.txt
```

### Iniciar el servidor
```bash
python email_server.py
```

El servicio estará disponible en: `http://localhost:5001`

## 📡 API Endpoints

### POST /send_pdf_email
Envía un PDF por email a un destinatario específico.

**Request Body (JSON):**
```json
{
  "recipient_email": "cliente@ejemplo.com",
  "recipient_name": "Nombre Cliente",
  "pdf_filename": "Tarjeta_Empresa_ABC.pdf",
  "empresa": "Empresa ABC"
}
```

**Response:**
```json
{
  "success": true,
  "message": "PDF enviado correctamente a cliente@ejemplo.com",
  "timestamp": "2025-07-25T18:30:00"
}
```

### GET /test_email_connection
Prueba la conexión SMTP.

**Response:**
```json
{
  "success": true,
  "message": "Conexión SMTP exitosa"
}
```

### GET /health
Estado del servicio.

**Response:**
```json
{
  "service": "Email Service",
  "status": "running",
  "version": "1.0.0"
}
```

## ⚙️ Configuración SMTP

El servicio está configurado para usar:
- **Servidor SMTP:** p3plzcpnl509160.prod.phx3.secureserver.net
- **Puerto:** 465 (SSL/TLS)
- **Email:** info@lapampacueros.com
- **Autenticación:** Requerida

## 📝 Logs

Los logs se guardan en:
- `email_service.log` - Logs del servicio de email
- `email_server.log` - Logs del servidor Flask

## 🔧 Integración con Frontend

Desde el frontend (React), hacer llamada POST:

```javascript
const sendEmail = async (emailData) => {
  try {
    const response = await fetch('http://localhost:5001/send_pdf_email', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(emailData)
    });
    
    const result = await response.json();
    return result;
  } catch (error) {
    console.error('Error enviando email:', error);
    return { success: false, message: error.message };
  }
};
```

## 🛡️ Seguridad

- Credenciales SMTP incluidas en código (desarrollo)
- Para producción, usar variables de entorno
- Validación de datos de entrada
- Logs detallados para auditoría
