#!/bin/bash
# Script para automatizar la IP local en backend, frontend y servicio de email

# Obtener la IP local de la interfaz en0
device_ip=$(ipconfig getifaddr en0)
if [ -z "$device_ip" ]; then
  echo "No se pudo obtener la IP de en0. Abortando."
  exit 1
fi

echo "Usando IP: $device_ip"

# Cambiar IP en backend (main.py)
sed -i '' "s/app.run(host='[0-9.]*', port=5000)/app.run(host='$device_ip', port=5000)/" cuaderno-feria-cueros/main.py

# Cambiar IP en frontend (App.jsx)
sed -i '' "s|const BACKEND_URL = 'http://[0-9.]*:5000'|const BACKEND_URL = 'http://$device_ip:5000'|" front-cuaderno-feria/src/App.jsx

# Instalar dependencias del servicio de email
echo "Instalando dependencias del servicio de email..."
pip3 install -r Mail/requirements.txt

# Arrancar backend en segundo plano
pkill -f cuaderno-feria-cueros/main.py 2>/dev/null
nohup python3 cuaderno-feria-cueros/main.py > backend.log 2>&1 &
echo "✅ Backend iniciado en $device_ip:5000"

# Arrancar servicio de email en segundo plano
pkill -f Mail/email_server.py 2>/dev/null
nohup python3 Mail/email_server.py > Mail/email_server.log 2>&1 &
echo "✅ Servicio de email iniciado en localhost:5001"

# Arrancar frontend (Vite) en segundo plano
yarn --cwd front-cuaderno-feria install || npm --prefix front-cuaderno-feria install
nohup npm --prefix front-cuaderno-feria run dev > frontend.log 2>&1 &
echo "✅ Frontend iniciado en http://$device_ip:5173"

echo ""
echo "🚀 Todos los servicios iniciados:"
echo "   📱 Frontend: http://$device_ip:5173"
echo "   🔧 Backend: http://$device_ip:5000"
echo "   📧 Email Service: http://localhost:5001"
echo ""
echo "📋 Para verificar logs:"
echo "   tail -f backend.log"
echo "   tail -f frontend.log"
echo "   tail -f Mail/email_server.log"
