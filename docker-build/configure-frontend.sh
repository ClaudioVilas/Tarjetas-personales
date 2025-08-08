#!/bin/sh

# Script de configuración para Frontend con IP dinámica
CONFIG_DIR=${CONFIG_DIR:-/shared/config}
NGINX_HTML="/usr/share/nginx/html"
MAX_WAIT=60
WAIT_COUNT=0

echo "🌐 Configurando Frontend con IP dinámica"
echo "📁 Esperando configuración de IP en: $CONFIG_DIR"

# Esperar por la configuración de IP
while [ ! -f "$CONFIG_DIR/network-config.json" ] && [ $WAIT_COUNT -lt $MAX_WAIT ]; do
    echo "⏳ Esperando configuración de red... ($WAIT_COUNT/$MAX_WAIT)"
    sleep 1
    WAIT_COUNT=$((WAIT_COUNT + 1))
done

if [ ! -f "$CONFIG_DIR/network-config.json" ]; then
    echo "❌ Error: No se pudo obtener configuración de red, usando localhost"
    LOCAL_IP="localhost"
else
    # Leer IP desde configuración (sin jq para simplicidad en Alpine)
    LOCAL_IP=$(grep -o '"local_ip": "[^"]*"' "$CONFIG_DIR/network-config.json" | cut -d'"' -f4)
fi

echo "🌐 IP Local detectada: $LOCAL_IP"

# Asegurar que el directorio dist existe
mkdir -p "$NGINX_HTML/dist"

# Determinar URLs basándose en el contexto de ejecución
# Si el frontend está expuesto en puerto 5173 (desarrollo), usar localhost
# Si está en puerto 80 (producción), usar IP interna
if [ "$FRONTEND_PORT" = "5173" ] || [ -n "$DEV_MODE" ]; then
    BACKEND_URL="http://localhost:5000"
    EMAIL_SERVICE_URL="http://localhost:5001"
    FRONTEND_URL="http://localhost:5173"
    echo "🔧 Modo desarrollo: usando localhost"
else
    BACKEND_URL="http://$LOCAL_IP:5000"
    EMAIL_SERVICE_URL="http://$LOCAL_IP:5001"
    FRONTEND_URL="http://$LOCAL_IP:80"
    echo "🔧 Modo producción: usando IP interna"
fi

# Crear archivo de configuración para el frontend en el directorio dist
cat > "$NGINX_HTML/dist/config.js" << EOF
// Configuración dinámica generada automáticamente
window.APP_CONFIG = {
  LOCAL_IP: '$LOCAL_IP',
  BACKEND_URL: '$BACKEND_URL',
  EMAIL_SERVICE_URL: '$EMAIL_SERVICE_URL',
  FRONTEND_URL: '$FRONTEND_URL',
  TIMESTAMP: '$(date -Iseconds)'
};

console.log('🔧 Configuración cargada:', window.APP_CONFIG);
EOF

# También crear en la raíz para compatibilidad
cat > "$NGINX_HTML/config.js" << EOF
// Configuración dinámica generada automáticamente
window.APP_CONFIG = {
  LOCAL_IP: '$LOCAL_IP',
  BACKEND_URL: '$BACKEND_URL',
  EMAIL_SERVICE_URL: '$EMAIL_SERVICE_URL',
  FRONTEND_URL: '$FRONTEND_URL',
  TIMESTAMP: '$(date -Iseconds)'
};

console.log('🔧 Configuración cargada:', window.APP_CONFIG);
EOF

# Reemplazar placeholders en archivos HTML/JS si existen
if [ -d "$NGINX_HTML/assets" ]; then
    find "$NGINX_HTML/assets" -name "*.js" -type f -exec sed -i "s|DYNAMIC_BACKEND_URL|$BACKEND_URL|g" {} \;
    find "$NGINX_HTML/assets" -name "*.js" -type f -exec sed -i "s|DYNAMIC_EMAIL_URL|$EMAIL_SERVICE_URL|g" {} \;
fi

# Crear script de recarga de configuración
cat > "$NGINX_HTML/reload-config.js" << EOF
// Script para recargar configuración dinámicamente
function reloadConfig() {
    fetch('/config.js')
        .then(response => response.text())
        .then(script => {
            eval(script);
            console.log('🔄 Configuración recargada:', window.APP_CONFIG);
        })
        .catch(error => console.error('❌ Error cargando configuración:', error));
}

// Recargar cada 30 segundos
setInterval(reloadConfig, 30000);
EOF

echo "✅ Frontend configurado para IP: $LOCAL_IP"
echo "📡 Backend: $BACKEND_URL"
echo "📧 Email Service: $EMAIL_SERVICE_URL"
echo "🌐 Frontend: $FRONTEND_URL"

# Iniciar nginx
exec nginx -g "daemon off;"
