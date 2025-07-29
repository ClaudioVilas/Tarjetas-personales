import React, { useState, useEffect } from 'react';
import './App.css';

// Estilo global para centrar el div principal
const style = document.createElement('style');
style.innerHTML = `#root > div { min-height: 100vh; display: flex; align-items: center; justify-content: center; }`;
document.head.appendChild(style);


function App() {
  const [empresa, setEmpresa] = useState('');
  const [nombreContacto, setNombreContacto] = useState('');
  const [posicion, setPosicion] = useState('');
  const [mail, setMail] = useState('');
  const [descripcion, setDescripcion] = useState('');
  // Ya no se usa 'text', se envían los campos por separado
  const [pdfUrl, setPdfUrl] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [latestPhoto, setLatestPhoto] = useState(null);
  const [latestPhotoFilename, setLatestPhotoFilename] = useState(null);
  
  // Estados para envío de email
  const [emailSending, setEmailSending] = useState(false);
  const [emailSuccess, setEmailSuccess] = useState('');
  const [lastGeneratedPdfName, setLastGeneratedPdfName] = useState('');
  
  // Estados para las nuevas fotos
  const [photo1, setPhoto1] = useState(null);
  // const [photo2, setPhoto2] = useState(null);
  const [photo1Filename, setPhoto1Filename] = useState(null);
  // const [photo2Filename, setPhoto2Filename] = useState(null);

  // Cambia esta URL si tu backend está en otra IP/puerto
  const BACKEND_URL = 'http://192.168.0.197:5000'; // Cambia si tu backend está en otra IP
  const EMAIL_SERVICE_URL = 'http://localhost:5001'; // Servicio de email
  
  // Polling para obtener la última foto cada 2 segundos
  useEffect(() => {
    const interval = setInterval(async () => {
      try {
        const res = await fetch(`${BACKEND_URL}/ultima_foto`);
        const data = await res.json();
        if (data.filename) {
          // Cache busting: agregar timestamp para forzar recarga si la foto cambia
          const photoUrl = `${BACKEND_URL}/fotos/${data.filename}?t=${Date.now()}`;
          setLatestPhoto(photoUrl);
          setLatestPhotoFilename(data.filename);
        } else {
          setLatestPhoto(null);
          setLatestPhotoFilename(null);
        }
      } catch (e) {
        setLatestPhoto(null);
        setLatestPhotoFilename(null);
      }
    }, 2000);
    return () => clearInterval(interval);
  }, [BACKEND_URL]);






  const handleEmpresaChange = (e) => {
    setEmpresa(e.target.value);
    setPdfUrl(null);
    setError('');
  };
  const handleNombreContactoChange = (e) => {
    setNombreContacto(e.target.value);
    setPdfUrl(null);
    setError('');
  };
  const handlePosicionChange = (e) => {
    setPosicion(e.target.value);
    setPdfUrl(null);
    setError('');
  };
  const handleMailChange = (e) => {
    setMail(e.target.value);
    setPdfUrl(null);
    setError('');
  };
  const handleDescripcionChange = (e) => {
    setDescripcion(e.target.value);
    setPdfUrl(null);
    setError('');
  };

  // Funciones para manejar los botones de fotos
  const handleBoton1Click = async () => {
    try {
      if (!latestPhotoFilename) {
        setError('No hay foto disponible para enviar');
        return;
      }
      // Enviar la foto actual al primer componente
      const photoUrl = `${BACKEND_URL}/fotos/${latestPhotoFilename}?t=${Date.now()}`;
      setPhoto1(photoUrl);
      setPhoto1Filename(latestPhotoFilename);
      setError('');
    } catch (err) {
      setError('Error al cargar foto 1');
    }
  };

  // const handleBoton2Click = async () => {
  //   try {
  //     if (!latestPhotoFilename) {
  //       setError('No hay foto disponible para enviar');
  //       return;
  //     }
  //     // Enviar la foto actual al segundo componente
  //     const photoUrl = `${BACKEND_URL}/fotos/${latestPhotoFilename}?t=${Date.now()}`;
  //     setPhoto2(photoUrl);
  //     setPhoto2Filename(latestPhotoFilename);
  //     setError('');
  //   } catch (err) {
  //     setError('Error al cargar foto 2');
  //   }
  // };
  
  // Funciones para borrar fotos
  const handleBorrarFoto1 = () => {
    setPhoto1(null);
    setPhoto1Filename(null);
    setError('');
  };

  // const handleBorrarFoto2 = () => {
  //   setPhoto2(null);
  //   setPhoto2Filename(null);
  //   setError('');
  // };

  // Función para enviar email con PDF
  const sendEmailWithPdf = async (pdfFilename) => {
    if (!mail || !mail.trim()) {
      console.log('[DEBUG EMAIL] No hay email proporcionado, saltando envío de correo');
      return false;
    }

    try {
      console.log('[DEBUG EMAIL] Iniciando envío de email...');
      setEmailSending(true);
      setEmailSuccess('');
      setError(''); // Limpiar errores previos
      
      const emailData = {
        recipient_email: mail,
        recipient_name: empresa || '',
        pdf_filename: pdfFilename,
        empresa: empresa || 'Feria Shanghai 2025',
        nombreContacto: nombreContacto || '',
        posicion: posicion || '',
        mail: mail || '',
        descripcion: descripcion || ''
      };

      console.log('[DEBUG EMAIL] Enviando datos:', emailData);    

      const response = await fetch(`${EMAIL_SERVICE_URL}/send_pdf_email`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(emailData)
      });
console.log('[DEBUG EMAIL] Respuesta del servidor:', response);
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }

      const result = await response.json();
      console.log('[DEBUG EMAIL] Respuesta del servidor:', result);
      
      if (result.success) {
        setEmailSuccess(`✅ PDF enviado correctamente a ${mail}`);
        return true;
      } else {
        setError(`❌ Error enviando email: ${result.message || 'Error desconocido'}`);
        return false;
      }
    } catch (err) {
      console.error('[DEBUG EMAIL] Error:', err);
      setError(`❌ Error de conexión con servicio de email: ${err.message}`);
      return false;
    } finally {
      console.log('[DEBUG EMAIL] Finalizando envío de email...');
      setEmailSending(false);
    }
  };

  // Restaurar la descarga automática del PDF generado
  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    setEmailSuccess('');
    setEmailSending(false); // Asegurar que inicie en false
    
    try {
      // Debug: verificar qué valores se están enviando
      console.log('[DEBUG FRONTEND] Valores a enviar:');
      console.log('- filename:', latestPhotoFilename);
      console.log('- empresa:', empresa);
      console.log('- nombreContacto:', nombreContacto);
      console.log('- posicion:', posicion);
      console.log('- mail:', mail);
      console.log('- descripcion:', descripcion);
      console.log('- photo1:', photo1 ? 'Sí' : 'No');
      console.log('- photo1Filename:', photo1Filename);
      
      // Generar el PDF usando los campos individuales
      const pdfForm = new FormData();
      pdfForm.append('filename', latestPhotoFilename || ''); // Permitir filename vacío
      pdfForm.append('empresa', empresa || '');
      pdfForm.append('nombreContacto', nombreContacto || '');
      pdfForm.append('posicion', posicion || '');
      pdfForm.append('mail', mail || '');
      pdfForm.append('descripcion', descripcion || '');
      
      // Enviar información sobre las fotos adicionales
      pdfForm.append('hasPhoto1', photo1 ? 'true' : 'false');
      pdfForm.append('hasPhoto2', 'false');
      pdfForm.append('photo1_filename', photo1Filename || '');
      pdfForm.append('photo2_filename', '');
      
      console.log('[DEBUG] Generando PDF...');
      const pdfRes = await fetch(`${BACKEND_URL}/generate_pdf`, {
        method: 'POST',
        body: pdfForm,
      });
      
      if (!pdfRes.ok) throw new Error(`Error generando el PDF: ${pdfRes.status} ${pdfRes.statusText}`);
      
      // Obtener el nombre del archivo del header de respuesta
      const contentDisposition = pdfRes.headers.get('Content-Disposition');
      let pdfFilename = 'resultado.pdf';
      
      if (contentDisposition) {
        const match = contentDisposition.match(/filename="([^"]+)"/);
        if (match) {
          pdfFilename = match[1];
        }
      } else if (empresa) {
        // Generar nombre basado en empresa (igual que backend: espacios -> guion, otros caracteres no válidos -> guion bajo)
        let empresaFilename = empresa.replace(/ /g, '-');
        empresaFilename = empresaFilename.replace(/[^a-zA-Z0-9\-]/g, '_');
        pdfFilename = `${empresaFilename}.pdf`;
      }
      
      setLastGeneratedPdfName(pdfFilename);
      
      // Descargar el PDF directamente (reactivado por requerimiento)
      const blob = await pdfRes.blob();
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = pdfFilename;
      document.body.appendChild(a);
      a.click();
      setTimeout(() => {
        window.URL.revokeObjectURL(url);
        document.body.removeChild(a);
      }, 100);
      
      console.log('[DEBUG] PDF generado exitosamente, verificando si enviar por email...');
      
      // Enviar por email solo si se proporcionó un email válido
      if (mail && mail.trim()) {
        console.log('[DEBUG EMAIL] Enviando por email a:', mail);
        const emailResult = await sendEmailWithPdf(pdfFilename);
        console.log('[DEBUG EMAIL] Resultado del envío:', emailResult);
      } else {
        console.log('[DEBUG EMAIL] No se envía email: no hay dirección válida');
      }
      
    } catch (err) {
      console.error('[ERROR]', err);
      setError(err.message);
      setEmailSending(false); // Asegurar que se resetee en caso de error
    } finally {
      setLoading(false);
      console.log('[DEBUG] Proceso completado, reseteando estados...');
    }
  };



  return (
    <div className="container">
      <h1>
        Datos de Contactos Feria Cueros Shanghai 2025
      </h1>
      <form onSubmit={handleSubmit} className="pdf-form">
        <div className="form-fields">
          <label>
            <span>Nombre de la empresa:</span>
            <input type="text" value={empresa} onChange={handleEmpresaChange} />
          </label>
          <label>
            <span>Nombre de contacto:</span>
            <input type="text" value={nombreContacto} onChange={handleNombreContactoChange} />
          </label>
          <label>
            <span>Posición:</span>
            <input type="text" value={posicion} onChange={handlePosicionChange} />
          </label>
          <label>
            <span>Mail:</span>
            <input type="email" value={mail} onChange={handleMailChange} />
          </label>
          <label>
            <span>Descripcion:</span>
            <textarea value={descripcion} onChange={handleDescripcionChange} rows={3} />
          </label>
        </div>
        
        {/* Nuevos componentes para fotos adicionales */}
        <div className="additional-photos">
          {/* Foto 1 */}
          <div className="photo-container">
            <h3>Foto 1</h3>
            <div className="photo-display">
              {photo1 ? (
                <img src={photo1} alt="Foto 1" className="photo-img" />
              ) : (
                <span className="photo-placeholder">Sin foto (horizontal/vertical)</span>
              )}
            </div>
            <div className="photo-btns">
              <button 
                type="button" 
                onClick={handleBoton1Click}
                disabled={!latestPhotoFilename}
                className="btn-primary"
              >
                Agregar Foto 1
              </button>
              {photo1 && (
                <button 
                  type="button" 
                  onClick={handleBorrarFoto1}
                  className="btn-delete"
                >
                  Borrar Foto 1
                </button>
              )}
            </div>
          </div>
          
          {/* Foto 2 */}
          {/* <div className="photo-container">
            <h3>Foto 2</h3>
            <div className="photo-display">
              {photo2 ? (
                <img src={photo2} alt="Foto 2" className="photo-img" />
              ) : (
                <span className="photo-placeholder">Sin foto (horizontal/vertical)</span>
              )}
            </div>
            <div className="photo-btns">
              <button 
                type="button" 
                onClick={handleBoton2Click}
                disabled={!latestPhotoFilename}
                className="btn-primary"
              >
                Agregar Foto 2
              </button>
              {photo2 && (
                <button 
                  type="button" 
                  onClick={handleBorrarFoto2}
                  className="btn-delete"
                >
                  Borrar Foto 2
                </button>
              )}
            </div>
          </div> */}
        </div>

        {latestPhoto && (
          <div className="image-section">
            <div className="latest-photo">
              <img src={latestPhoto} alt="Última foto" className="latest-photo-img" />
            </div>
          </div>
        )}
        <div className="button-section">
          <button type="submit" disabled={loading || emailSending}>
            {loading ? 'Generando PDF...' : emailSending ? 'Enviando por email...' : 'Generar PDF'}
          </button>
          {/* Mensaje eliminado, no mostrar información extra */}
        </div>
      </form>
      
      {emailSuccess && <div className="success">{emailSuccess}</div>}
      {error && <div className="error">{error}</div>}
    </div>
  );
}

export default App;
