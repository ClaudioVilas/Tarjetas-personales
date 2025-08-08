# Dockerfile para Servicio de Configuración de IP
FROM alpine:latest

# Instalar herramientas necesarias
RUN apk add --no-cache curl jq iproute2 bash

WORKDIR /app

# Script principal de configuración
COPY ip-config-service.sh /app/ip-config-service.sh
RUN chmod +x /app/ip-config-service.sh

# Crear directorio de configuración compartida
RUN mkdir -p /shared/config

# Variables de entorno
ENV CONFIG_DIR=/shared/config
ENV UPDATE_INTERVAL=30

CMD ["/app/ip-config-service.sh"]
