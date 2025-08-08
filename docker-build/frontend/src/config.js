// Configuración dinámica del frontend
export const getConfig = () => {
  // Intentar cargar configuración desde el archivo generado dinámicamente
  if (window.APP_CONFIG) {
    return {
      BACKEND_URL: window.APP_CONFIG.BACKEND_URL,
      EMAIL_SERVICE_URL: window.APP_CONFIG.EMAIL_SERVICE_URL,
      LOCAL_IP: window.APP_CONFIG.LOCAL_IP
    };
  }
  
  // Fallback a variables de entorno o valores por defecto
  return {
    BACKEND_URL: import.meta.env.VITE_BACKEND_URL || 'http://localhost:5000',
    EMAIL_SERVICE_URL: import.meta.env.VITE_EMAIL_SERVICE_URL || 'http://localhost:5001',
    LOCAL_IP: 'localhost'
  };
};

// Función para actualizar la configuración dinámicamente
export const updateConfig = () => {
  return new Promise((resolve, reject) => {
    const script = document.createElement('script');
    script.src = '/config.js?t=' + Date.now();
    script.onload = () => {
      resolve(getConfig());
    };
    script.onerror = reject;
    document.head.appendChild(script);
  });
};
