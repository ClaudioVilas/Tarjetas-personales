import React, { useState, useEffect } from 'react';
import './App.css';

// Estilo global para centrar el div principal
const style = document.createElement('style');
style.innerHTML = `#root > div { min-height: 100vh; display: flex; align-items: center; justify-content: center; }`;
document.head.appendChild(style);


function App() {
  const [empresa, setEmpresa] = useState('');
  const [mail, setMail] = useState('');
  const [descripcion, setDescripcion] = useState('');
  // Ya no se usa 'text', se envían los campos por separado
  const [pdfUrl, setPdfUrl] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [latestPhoto, setLatestPhoto] = useState(null);
  const [latestPhotoFilename, setLatestPhotoFilename] = useState(null);
  
  // Estados para las nuevas fotos
  const [photo1, setPhoto1] = useState(null);
  // const [photo2, setPhoto2] = useState(null);
  const [photo1Filename, setPhoto1Filename] = useState(null);
  // const [photo2Filename, setPhoto2Filename] = useState(null);

  // Cambia esta URL si tu backend está en otra IP/puerto
  const BACKEND_URL = 'http://172.22.8.13:5000'; // Cambia si tu backend está en otra IP
  
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

  // Restaurar la descarga automática del PDF generado
  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    try {
      if (!latestPhotoFilename) throw new Error('No hay foto disponible');
      
      // Debug: verificar qué valores se están enviando
      console.log('[DEBUG FRONTEND] Valores a enviar:');
      console.log('- filename:', latestPhotoFilename);
      console.log('- empresa:', empresa);
      console.log('- mail:', mail);
      console.log('- descripcion:', descripcion);
      console.log('- photo1:', photo1 ? 'Sí' : 'No');
      // console.log('- photo2:', photo2 ? 'Sí' : 'No');
      console.log('- photo1Filename:', photo1Filename);
      // console.log('- photo2Filename:', photo2Filename);
      
      // Generar el PDF usando los campos individuales
      const pdfForm = new FormData();
      pdfForm.append('filename', latestPhotoFilename);
      pdfForm.append('empresa', empresa);
      pdfForm.append('mail', mail);
      pdfForm.append('descripcion', descripcion);
      
      // Enviar información sobre las fotos adicionales
      pdfForm.append('hasPhoto1', photo1 ? 'true' : 'false');
      pdfForm.append('hasPhoto2', 'false'); // photo2 ? 'true' : 'false');
      pdfForm.append('photo1_filename', photo1Filename || '');
      pdfForm.append('photo2_filename', ''); // photo2Filename || '');
      
      const pdfRes = await fetch(`${BACKEND_URL}/generate_pdf`, {
        method: 'POST',
        body: pdfForm,
      });
      if (!pdfRes.ok) throw new Error('Error generando el PDF');
      const blob = await pdfRes.blob();
      // Descargar el PDF directamente
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = 'resultado.pdf';
      document.body.appendChild(a);
      a.click();
      setTimeout(() => {
        window.URL.revokeObjectURL(url);
        document.body.removeChild(a);
      }, 100);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
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
          <button type="submit" disabled={loading || !latestPhotoFilename}>
            {loading ? 'Generando PDF...' : 'Generar PDF'}
          </button>
        </div>
      </form>
      {error && <div className="error">{error}</div>}
    </div>
  );
}

export default App;
