#!/bin/bash
# Script para automatizar la IP local en backend y frontend y arrancar ambos servicios

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

# Arrancar backend en segundo plano
pkill -f cuaderno-feria-cueros/main.py 2>/dev/null
nohup python3 cuaderno-feria-cueros/main.py > backend.log 2>&1 &
echo "Backend iniciado en $device_ip:5000"

# Arrancar frontend (Vite) en segundo plano
yarn --cwd front-cuaderno-feria install || npm --prefix front-cuaderno-feria install
nohup npm --prefix front-cuaderno-feria run dev > frontend.log 2>&1 &
echo "Frontend iniciado en http://$device_ip:5173"
