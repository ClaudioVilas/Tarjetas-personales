#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Servicio de envío de emails para el sistema de tarjetas personales
Envía PDFs generados por email usando configuración SMTP segura
"""

import smtplib
import os
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders
from email.utils import formataddr
import logging
from datetime import datetime

# Configuración del logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('email_service.log'),
        logging.StreamHandler()
    ]
)

class EmailService:
    def __init__(self):
        # Configuración SMTP basada en las imágenes proporcionadas
        self.smtp_server = "p3plzcpnl509160.prod.phx3.secureserver.net"
        self.smtp_port = 465  # SMTP SSL/TLS
        self.sender_email = "info@lapampacueros.com"
        self.sender_password = "Breakers2@21"
        self.sender_name = "La Pampa Cueros - Feria Shanghai 2025"
        
    def send_pdf_email(self, recipient_email, recipient_name="", pdf_path="", empresa=""):
        """
        Envía un email con el PDF adjunto
        
        Args:
            recipient_email (str): Email del destinatario
            recipient_name (str): Nombre del destinatario (opcional)
            pdf_path (str): Ruta al archivo PDF
            empresa (str): Nombre de la empresa para personalizar el mensaje
            
        Returns:
            dict: Resultado del envío con status y mensaje
        """
        try:
            # Verificar que el archivo PDF existe
            if not os.path.exists(pdf_path):
                raise FileNotFoundError(f"PDF no encontrado: {pdf_path}")
            
            # Crear mensaje
            msg = MIMEMultipart()
            msg['From'] = formataddr((self.sender_name, self.sender_email))
            msg['To'] = recipient_email
            msg['Subject'] = f"Tarjeta de Contacto - {empresa if empresa else 'Feria Cueros Shanghai 2025'}"
            
            # Cuerpo del email
            body = self._create_email_body(recipient_name, empresa)
            msg.attach(MIMEText(body, 'html', 'utf-8'))
            
            # Adjuntar PDF
            self._attach_pdf(msg, pdf_path, empresa)
            
            # Enviar email
            with smtplib.SMTP_SSL(self.smtp_server, self.smtp_port) as server:
                server.login(self.sender_email, self.sender_password)
                server.send_message(msg)
            
            logging.info(f"Email enviado exitosamente a {recipient_email}")
            return {
                "success": True,
                "message": f"PDF enviado correctamente a {recipient_email}",
                "timestamp": datetime.now().isoformat()
            }
            
        except FileNotFoundError as e:
            error_msg = f"Error: {str(e)}"
            logging.error(error_msg)
            return {"success": False, "message": error_msg}
            
        except smtplib.SMTPAuthenticationError:
            error_msg = "Error de autenticación SMTP. Verificar credenciales."
            logging.error(error_msg)
            return {"success": False, "message": error_msg}
            
        except smtplib.SMTPException as e:
            error_msg = f"Error SMTP: {str(e)}"
            logging.error(error_msg)
            return {"success": False, "message": error_msg}
            
        except Exception as e:
            error_msg = f"Error inesperado: {str(e)}"
            logging.error(error_msg)
            return {"success": False, "message": error_msg}
    
    def _create_email_body(self, recipient_name, empresa):
        """Crea el cuerpo HTML del email"""
        return f"""
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <style>
                body {{ font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; }}
                .container {{ max-width: 600px; margin: 0 auto; background-color: white; border-radius: 10px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }}
                .header {{ background: linear-gradient(135deg, #8B4513, #A0522D); color: white; padding: 30px; text-align: center; }}
                .content {{ padding: 30px; }}
                .footer {{ background-color: #f8f9fa; padding: 20px; text-align: center; color: #666; }}
                .highlight {{ color: #8B4513; font-weight: bold; }}
                .logo {{ font-size: 24px; font-weight: bold; margin-bottom: 10px; }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <div class="logo">🏷️ La Pampa Cueros</div>
                    <h2>Feria Cueros Shanghai 2025</h2>
                </div>
                <div class="content">
                    <h3>¡Hola{' ' + recipient_name if recipient_name else ''}!</h3>
                    <p>Te enviamos tu <span class="highlight">tarjeta de contacto personalizada</span> desde nuestra participación en la Feria Cueros Shanghai 2025.</p>
                    
                    {f'<p>Empresa: <span class="highlight">{empresa}</span></p>' if empresa else ''}
                    
                    <p>En el archivo adjunto encontrarás todos los datos de contacto que nos proporcionaste. Esta tarjeta te permitirá mantener nuestros datos siempre a mano.</p>
                    
                    <h4>📧 Información de contacto:</h4>
                    <ul>
                        <li><strong>Email:</strong> info@lapampacueros.com</li>
                        <li><strong>Empresa:</strong> La Pampa Cueros</li>
                        <li><strong>Evento:</strong> Feria Cueros Shanghai 2025</li>
                    </ul>
                    
                    <p>¡Gracias por tu interés en nuestros productos!</p>
                </div>
                <div class="footer">
                    <p><small>Este email fue enviado automáticamente desde nuestro sistema de tarjetas personales.</small></p>
                    <p><small>© 2025 La Pampa Cueros - Feria Cueros Shanghai</small></p>
                </div>
            </div>
        </body>
        </html>
        """
    
    def _attach_pdf(self, msg, pdf_path, empresa):
        """Adjunta el PDF al mensaje"""
        with open(pdf_path, "rb") as attachment:
            part = MIMEBase('application', 'octet-stream')
            part.set_payload(attachment.read())
        
        encoders.encode_base64(part)
        
        # Nombre del archivo adjunto
        filename = f"Tarjeta_Contacto_{empresa.replace(' ', '_') if empresa else 'Feria_Shanghai'}.pdf"
        part.add_header(
            'Content-Disposition',
            f'attachment; filename= {filename}'
        )
        
        msg.attach(part)
    
    def test_connection(self):
        """Prueba la conexión SMTP"""
        try:
            with smtplib.SMTP_SSL(self.smtp_server, self.smtp_port) as server:
                server.login(self.sender_email, self.sender_password)
            
            logging.info("Conexión SMTP exitosa")
            return {"success": True, "message": "Conexión SMTP exitosa"}
            
        except Exception as e:
            error_msg = f"Error de conexión SMTP: {str(e)}"
            logging.error(error_msg)
            return {"success": False, "message": error_msg}


def main():
    """Función principal para pruebas"""
    email_service = EmailService()
    
    # Probar conexión
    result = email_service.test_connection()
    print(f"Test de conexión: {result}")


if __name__ == "__main__":
    main()
