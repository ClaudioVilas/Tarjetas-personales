#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Servidor Flask para el servicio de envío de emails
API REST para enviar PDFs por email
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import logging
from email_service import EmailService

# Configurar logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('email_server.log'),
        logging.StreamHandler()
    ]
)

app = Flask(__name__)
CORS(app)

# Instancia del servicio de email
email_service = EmailService()

@app.route('/send_pdf_email', methods=['POST'])
def send_pdf_email():
    """
    Endpoint para enviar PDF por email
    
    Espera JSON con:
    - recipient_email: email del destinatario
    - recipient_name: nombre del destinatario (opcional)
    - pdf_filename: nombre del archivo PDF
    - empresa: nombre de la empresa
    """
    try:
        data = request.get_json()
        
        # Validar datos requeridos
        if not data:
            return jsonify({
                "success": False,
                "message": "No se recibieron datos JSON"
            }), 400
        
        recipient_email = data.get('recipient_email')
        if not recipient_email:
            return jsonify({
                "success": False,
                "message": "Email del destinatario es requerido"
            }), 400
        
        pdf_filename = data.get('pdf_filename')
        if not pdf_filename:
            return jsonify({
                "success": False,
                "message": "Nombre del archivo PDF es requerido"
            }), 400
        
        # Construir ruta completa al PDF
        pdf_path = os.path.join('..', 'Pdf Feria', pdf_filename)
        pdf_path = os.path.abspath(pdf_path)
        
        logging.info(f"Intentando enviar PDF: {pdf_path} a {recipient_email}")
        
        # Datos opcionales
        recipient_name = data.get('recipient_name', '')
        empresa = data.get('empresa', '')
        
        # Enviar email
        result = email_service.send_pdf_email(
            recipient_email=recipient_email,
            recipient_name=recipient_name,
            pdf_path=pdf_path,
            empresa=empresa
        )
        
        if result['success']:
            return jsonify(result), 200
        else:
            return jsonify(result), 500
            
    except Exception as e:
        error_msg = f"Error en el servidor: {str(e)}"
        logging.error(error_msg)
        return jsonify({
            "success": False,
            "message": error_msg
        }), 500

@app.route('/test_email_connection', methods=['GET'])
def test_email_connection():
    """Endpoint para probar la conexión SMTP"""
    try:
        result = email_service.test_connection()
        
        if result['success']:
            return jsonify(result), 200
        else:
            return jsonify(result), 500
            
    except Exception as e:
        error_msg = f"Error probando conexión: {str(e)}"
        logging.error(error_msg)
        return jsonify({
            "success": False,
            "message": error_msg
        }), 500

@app.route('/health', methods=['GET'])
def health():
    """Endpoint de salud del servicio"""
    return jsonify({
        "service": "Email Service",
        "status": "running",
        "version": "1.0.0"
    }), 200

@app.errorhandler(404)
def not_found(error):
    return jsonify({
        "success": False,
        "message": "Endpoint no encontrado"
    }), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({
        "success": False,
        "message": "Error interno del servidor"
    }), 500

if __name__ == '__main__':
    print("🚀 Iniciando servidor de email...")
    print("📧 Servicio disponible en http://localhost:5001")
    print("🔗 Endpoints disponibles:")
    print("   POST /send_pdf_email - Enviar PDF por email")
    print("   GET  /test_email_connection - Probar conexión SMTP")
    print("   GET  /health - Estado del servicio")
    
    app.run(debug=True, host='0.0.0.0', port=5001)
