# Dockerfile para Frontend (Front Cuaderno Feria) - Enfoque estático
FROM nginx:alpine

# Copiar archivos estáticos del frontend directamente
COPY frontend/ /usr/share/nginx/html/

# Copiar configuración de nginx personalizada
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Script para configuración dinámica de IP
COPY configure-frontend.sh /configure-frontend.sh
RUN chmod +x /configure-frontend.sh

EXPOSE 80

# Iniciar nginx con configuración dinámica
CMD ["/configure-frontend.sh"]
