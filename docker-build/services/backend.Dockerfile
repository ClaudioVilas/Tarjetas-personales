# Dockerfile para Backend (Cuaderno Feria Cueros)
FROM python:3.11-slim

WORKDIR /app

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copiar requirements desde el contexto docker-build
COPY requirements.txt .

# Instalar dependencias de Python
RUN pip install --no-cache-dir -r requirements.txt

# Copiar archivo principal desde backend/
COPY backend/main.py .

# Crear directorios necesarios
RUN mkdir -p /app/fotos /app/uploads /shared/pdf-output

# Exponer puerto
EXPOSE 5000

# Variables de entorno por defecto
ENV FLASK_APP=main.py
ENV PYTHONPATH=/app
ENV PDF_OUTPUT_DIR=/shared/pdf-output
ENV PHOTOS_DIR=/app/fotos

# Crear script de inicio simple inline
RUN echo '#!/bin/bash\n\
echo "🚀 Iniciando Backend Simple - Cuaderno Feria Cueros"\n\
echo "📡 Iniciando servidor Flask en 0.0.0.0:5000"\n\
echo "📂 Directorio PDF: $PDF_OUTPUT_DIR"\n\
echo "📸 Directorio Fotos: $PHOTOS_DIR"\n\
cd /app\n\
exec python main.py' > /start-backend-simple.sh && chmod +x /start-backend-simple.sh

CMD ["/start-backend-simple.sh"]
