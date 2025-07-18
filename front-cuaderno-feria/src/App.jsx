import React, { useState, useEffect } from 'react';

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

  // Cambia esta URL si tu backend está en otra IP/puerto
  const BACKEND_URL = 'http://localhost:5000'; // Cambia si tu backend está en otra IP
  // Polling para obtener la última foto cada 2 segundos
  useEffect(() => {
    const interval = setInterval(async () => {
      try {
        const res = await fetch(`${BACKEND_URL}/ultima_foto`);
        const data = await res.json();
        if (data.filename) {
          setLatestPhoto(`${BACKEND_URL}/fotos/${data.filename}`);
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

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    try {
      if (!latestPhotoFilename) throw new Error('No hay foto disponible');
      // Generar el PDF usando los campos individuales
      const pdfForm = new FormData();
      pdfForm.append('filename', latestPhotoFilename);
      pdfForm.append('empresa', empresa);
      pdfForm.append('mail', mail);
      pdfForm.append('descripcion', descripcion);
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
    <div className="container" style={{
      minHeight: '100vh',
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      background: '#f7f7f7'
    }}>
      <h1 style={{ fontSize: '1.6em', textAlign: 'center', marginBottom: 24 }}>
        Datos de Contactos Feria Cueros Shanghai 2025
      </h1>
      <form onSubmit={handleSubmit} className="pdf-form" style={{
        marginBottom: 24,
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        width: '100%',
        maxWidth: 400,
        background: '#fff',
        padding: 24,
        borderRadius: 12,
        boxShadow: '0 2px 16px #0001'
      }}>
        <label style={{display: 'block', marginBottom: 12}}>
          <span style={{fontWeight: 'bold'}}>Nombre de la empresa:</span><br />
          <input type="text" value={empresa} onChange={handleEmpresaChange} style={{width: '100%', padding: 8, marginTop: 4}} />
        </label>
        {latestPhoto && (
          <div className="latest-photo" style={{marginBottom: 16}}>
            <img src={latestPhoto} alt="Última foto" style={{maxWidth: '300px', marginBottom: 8, transform: 'rotate(-90deg)'}} />
          </div>
        )}
        <label style={{display: 'block', marginBottom: 12}}>
          <span style={{fontWeight: 'bold'}}>Mail:</span><br />
          <input type="email" value={mail} onChange={handleMailChange} style={{width: '100%', padding: 8, marginTop: 4}} />
        </label>
        <label style={{display: 'block', marginBottom: 12}}>
          <span style={{fontWeight: 'bold'}}>Descripcion:</span><br />
          <textarea value={descripcion} onChange={handleDescripcionChange} rows={3} style={{width: '100%', padding: 8, marginTop: 4}} />
        </label>
        <button type="submit" disabled={loading || !latestPhotoFilename}>
          {loading ? 'Generando PDF...' : 'Generar PDF'}
        </button>
      </form>
      {error && <div className="error">{error}</div>}


      {/* El PDF se descarga automáticamente al generarse, sin previsualización */}

      {/* Eliminada la visualización y descarga del PDF generado debajo de la pantalla principal */}
    </div>
  );
}

export default App;
