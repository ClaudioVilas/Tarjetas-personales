# Dockerfile para Servicio de Email (Mail)
FROM python:3.11-slim

WORKDIR /app

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Copiar requirements
COPY requirements.txt .

# Instalar dependencias de Python
RUN pip install --no-cache-dir -r requirements.txt

# Copiar código del servicio de email
COPY email/ ./

# Crear directorio para PDFs compartidos
RUN mkdir -p /shared/pdf-output /app/attachments

# Exponer puerto
EXPOSE 5001

# Variables de entorno
ENV PYTHONPATH=/app
ENV PDF_INPUT_DIR=/shared/pdf-output
ENV ATTACHMENTS_DIR=/app/attachments

# Script de inicio
COPY start-email.sh /start-email.sh
RUN chmod +x /start-email.sh

CMD ["/start-email.sh"]
