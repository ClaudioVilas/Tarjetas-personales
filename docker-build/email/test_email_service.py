#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Test básico para el servicio de email
"""

import sys
import os

# Agregar el directorio actual al path para importar email_service
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from email_service import EmailService

def test_smtp_connection():
    """Prueba la conexión SMTP"""
    print("🔧 Probando conexión SMTP...")
    
    email_service = EmailService()
    result = email_service.test_connection()
    
    if result['success']:
        print("✅ Conexión SMTP exitosa!")
        print(f"   Servidor: {email_service.smtp_server}:{email_service.smtp_port}")
        print(f"   Email: {email_service.sender_email}")
        return True
    else:
        print("❌ Error en conexión SMTP:")
        print(f"   {result['message']}")
        return False

def main():
    print("📧 Test del Servicio de Email")
    print("=" * 40)
    
    # Test de conexión SMTP
    connection_ok = test_smtp_connection()
    
    if not connection_ok:
        print("\n❌ Tests fallidos. Verificar configuración SMTP.")
        return False
    
    print("\n✅ Todos los tests pasaron!")
    print("\n🚀 El servicio de email está listo para usar.")
    print("   Para iniciar el servidor: python email_server.py")
    
    return True

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
