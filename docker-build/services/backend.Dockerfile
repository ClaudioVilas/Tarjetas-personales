# Dockerfile para Backend (Cuaderno Feria Cueros)
FROM python:3.11-slim

WORKDIR /app

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copiar requirements
COPY requirements.txt .

# Instalar dependencias de Python
RUN pip install --no-cache-dir -r requirements.txt

# Copiar código del backend
COPY backend/ ./

# Crear directorios necesarios
RUN mkdir -p /app/fotos /app/uploads /shared/pdf-output

# Exponer puerto
EXPOSE 5000

# Variables de entorno por defecto
ENV FLASK_APP=main.py
ENV PYTHONPATH=/app
ENV PDF_OUTPUT_DIR=/shared/pdf-output
ENV PHOTOS_DIR=/app/fotos

# Script de inicio simple
COPY start-backend-simple.sh /start-backend-simple.sh
RUN chmod +x /start-backend-simple.sh

CMD ["/start-backend-simple.sh"]
