# Sistema OCR para Extracción Automática de Datos de Tarjetas Personales

## Descripción General

Este sistema implementa reconocimiento óptico de caracteres (OCR) usando `tesseract.js` para extraer automáticamente datos de tarjetas personales y completar formularios de contacto.

## Funcionalidades Principales

### 🔍 **Extracción Automática de Datos**
- **Nombre de la persona**: Detecta nombres personales
- **Empresa/Compañía**: Identifica nombres de empresas 
- **Cargo/Posición**: Reconoce títulos y cargos profesionales
- **Email**: Extrae direcciones de correo electrónico
- **Teléfono**: Identifica números telefónicos (formatos argentinos e internacionales)
- **Descripción**: Captura información adicional relevante

### 📱 **Flujo de Trabajo**

1. **Captura de Imagen**: El sistema detecta automáticamente cuando hay una nueva foto disponible
2. **Activación OCR**: El usuario presiona "🔍 Extraer Datos de Tarjeta" 
3. **Procesamiento**: Tesseract.js procesa la imagen con indicador de progreso
4. **Extracción Inteligente**: Algoritmos especializados identifican cada campo usando:
   - Expresiones regulares para emails y teléfonos
   - Heurísticas para nombres y empresas
   - Palabras clave para cargos profesionales
5. **Vista Previa**: Muestra todos los datos extraídos antes de aplicar
6. **Aplicación**: El usuario confirma y los datos se cargan automáticamente en el formulario

## Componentes Técnicos

### `OCRProcessor.jsx`
Componente principal que maneja todo el proceso OCR:

```jsx
<OCRProcessor
  imageUrl={latestPhoto}
  onDataExtracted={handleOCRDataExtracted}
  onError={handleOCRError}
  isProcessing={isOCRProcessing}
  setIsProcessing={setIsOCRProcessing}
/>
```

**Props:**
- `imageUrl`: URL de la imagen a procesar
- `onDataExtracted`: Callback con datos extraídos
- `onError`: Callback para manejo de errores
- `isProcessing`: Estado del procesamiento
- `setIsProcessing`: Función para actualizar estado

### Algoritmos de Extracción

#### **Detección de Email**
```javascript
const emailRegex = /([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})/gi;
```

#### **Detección de Teléfono**
Múltiples patrones para formatos argentinos e internacionales:
```javascript
const phonePatterns = [
  /(\+?\d{1,3}[-.\s]?)?\(?(\d{1,4})\)?[-.\s]?(\d{1,4})[-.\s]?(\d{1,4})[-.\s]?(\d{1,4})/g,
  /(\+54\s?9?\s?\d{2,4}[-.\s]?\d{3,4}[-.\s]?\d{3,4})/gi,
  /(011[-.\s]?\d{4}[-.\s]?\d{4})/gi
];
```

#### **Heurística para Nombres y Empresas**
- **Empresas**: Líneas con alta proporción de mayúsculas o longitud > 25 caracteres
- **Nombres**: Líneas cortas con formato de nombres personales
- **Cargos**: Búsqueda por palabras clave profesionales

### Configuración de Tesseract

```javascript
const worker = await createWorker('spa+eng', 1, {
  logger: m => {
    if (m.status === 'recognizing text') {
      setProgress(Math.round(m.progress * 100));
    }
  }
});

await worker.setParameters({
  tessedit_char_whitelist: 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@.-_+() ',
  tessedit_pageseg_mode: '6', // Uniform block of text
});
```

## Mejores Prácticas para Precisión del OCR

### 📷 **Calidad de Imagen**
- **Resolución**: Mínimo 300 DPI para texto pequeño
- **Iluminación**: Luz uniforme, evitar sombras y reflejos
- **Enfoque**: Imagen nítida sin desenfoques
- **Contraste**: Alto contraste entre texto y fondo

### 🎯 **Posicionamiento**
- **Orientación**: Tarjeta completamente horizontal
- **Encuadre**: Incluir toda la tarjeta sin cortes
- **Distancia**: Suficientemente cerca para leer el texto claramente
- **Estabilidad**: Evitar movimiento durante la captura

### 🔤 **Optimizaciones de Texto**
- **Idiomas**: Configurado para español e inglés (`spa+eng`)
- **Caracteres**: Lista blanca de caracteres válidos para tarjetas
- **Modo de segmentación**: Optimizado para bloques uniformes de texto

## Instalación y Dependencias

```bash
npm install tesseract.js
```

### Archivos del Sistema OCR
```
src/
├── components/
│   ├── OCRProcessor.jsx      # Componente principal OCR
│   └── OCRProcessor.css      # Estilos del componente
├── App.jsx                   # Integración en aplicación principal
└── App.css                   # Estilos adicionales
```

## Manejo de Errores

### **Errores Comunes y Soluciones**

1. **"No hay imagen disponible"**
   - Verificar que `imageUrl` esté definida
   - Confirmar que la imagen sea accesible

2. **"Error en OCR: NetworkError"**
   - Verificar conectividad a internet (Tesseract descarga modelos)
   - Revisar configuración de CORS si es necesario

3. **"Texto no reconocido correctamente"**
   - Mejorar calidad de imagen
   - Verificar orientación de la tarjeta
   - Limpiar lente de cámara

## Configuración de Desarrollo

### **Variables de Entorno**
```javascript
const BACKEND_URL = 'http://172.40.210.24:5000';
```

### **Integración con Backend**
El sistema se integra con el polling existente de fotos:
```javascript
useEffect(() => {
  const interval = setInterval(async () => {
    try {
      const res = await fetch(`${BACKEND_URL}/ultima_foto`);
      const data = await res.json();
      if (data.filename) {
        const photoUrl = `${BACKEND_URL}/fotos/${data.filename}?t=${Date.now()}`;
        setLatestPhoto(photoUrl);
        setLatestPhotoFilename(data.filename);
      }
    } catch (e) {
      // Handle error
    }
  }, 2000);
  return () => clearInterval(interval);
}, [BACKEND_URL]);
```

## Rendimiento y Optimización

### **Tiempos de Procesamiento**
- **Pequeñas (< 1MB)**: 3-8 segundos
- **Medianas (1-3MB)**: 8-15 segundos
- **Grandes (> 3MB)**: 15-30 segundos

### **Optimizaciones Implementadas**
- **Caché de Worker**: Reutilización cuando es posible
- **Lista blanca de caracteres**: Reduce tiempo de procesamiento
- **Progreso en tiempo real**: Feedback visual para el usuario
- **Limpieza de memoria**: Terminación correcta del worker

## Casos de Uso

### **Tipos de Tarjetas Compatibles**
- ✅ Tarjetas comerciales estándar
- ✅ Tarjetas con logos y colores
- ✅ Texto en español e inglés
- ✅ Múltiples formatos de teléfono
- ⚠️ Tarjetas con fondos muy decorativos (menor precisión)
- ⚠️ Texto muy pequeño o fuentes ornamentales

### **Validaciones Implementadas**
- **Email**: Formato válido antes de aplicar
- **Teléfono**: Limpieza de espacios y caracteres
- **Texto**: Eliminación de espacios extra
- **Longitud**: Límites razonables por campo

Este sistema proporciona una experiencia fluida para digitalizar tarjetas personales con alta precisión y manejo robusto de errores.
