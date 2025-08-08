# 🔧 Backend Compilado

Backend compilado con PyInstaller para ejecución standalone sin necesidad de tener Python instalado.

## 📦 Archivos Generados

- `backend_compiled` - Ejecutable standalone del backend (15.6 MB)
- `start_backend_compiled.sh` - Script para iniciar el backend compilado
- `BACKEND_COMPILED.md` - Esta documentación

## 🧹 Archivos de Compilación Limpiados

Los siguientes archivos temporales fueron eliminados para ahorrar espacio:
- ~~`cuaderno-feria-cueros/dist/`~~ - Carpeta de distribución (15 MB) 
- ~~`cuaderno-feria-cueros/build/`~~ - Archivos de construcción (23 MB)
- ~~`cuaderno-feria-cueros/backend.spec`~~ - Especificación de PyInstaller
- ~~`__pycache__/`~~ - Cachés de Python
- ~~`*.pyc`~~ - Archivos compilados de Python

**Espacio ahorrado**: ~38 MB

## 🚀 Uso del Backend Compilado

### Iniciar con Script:
```bash
./start_backend_compiled.sh
```

### Iniciar Directamente:
```bash
./backend_compiled
```

## 📡 Información del Servidor

- **URL**: http://172.40.210.24:5000
- **Endpoints**: Todos los endpoints del backend original
- **Funcionalidades**: 
  - ✅ Generación de PDF con compresión al 70%
  - ✅ Subida de imágenes
  - ✅ Gestión de fotos
  - ✅ API REST completa

## 🔧 Ventajas del Ejecutable Compilado

1. **Sin dependencias**: No necesita Python instalado
2. **Portable**: Un solo archivo ejecutable
3. **Rápido**: Tiempo de inicio optimizado
4. **Seguro**: Código compilado y protegido
5. **Fácil distribución**: Solo copiar el ejecutable

## 📋 Especificaciones Técnicas

- **Tamaño**: ~15.6 MB
- **Arquitectura**: arm64 (Apple Silicon)
- **SO Compatible**: macOS 11+
- **Librerías incluidas**: 
  - Flask + CORS
  - FPDF (generación PDF)
  - Pillow (compresión imágenes)
  - Todas las dependencias necesarias

## 🛠️ Recompilar (si necesario)

Para recompilar el backend:

```bash
cd cuaderno-feria-cueros
pip install pyinstaller
pyinstaller --onefile --name backend main.py
cp dist/backend ../backend_compiled

# Limpiar archivos temporales
rm -rf build dist backend.spec
```

## 📝 Notas

- El ejecutable mantiene todas las funcionalidades del backend original
- La compresión de imágenes al 70% está incluida
- Las rutas de archivos están configuradas para el entorno de producción
- El servidor se inicia automáticamente en la IP configurada
