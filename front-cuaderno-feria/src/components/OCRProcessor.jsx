import React, { useState } from 'react';
import { createWorker } from 'tesseract.js';
import './OCRProcessor.css';

const OCRProcessor = ({ 
  imageUrl, 
  onDataExtracted, 
  onError, 
  isProcessing, 
  setIsProcessing 
}) => {
  const [extractedText, setExtractedText] = useState('');
  const [showPreview, setShowPreview] = useState(false);
  const [progress, setProgress] = useState(0);
  const [extractedData, setExtractedData] = useState({});

  // Función para procesar la imagen con OCR
  const processImage = async () => {
    if (!imageUrl) {
      onError('No hay imagen disponible para procesar');
      return;
    }

    setIsProcessing(true);
    setProgress(0);
    setExtractedText('');
    setExtractedData({});

    try {
      console.log('[OCR] Iniciando procesamiento de imagen...');
      
      // Crear worker de Tesseract
      const worker = await createWorker('spa+eng', 1, {
        logger: m => {
          console.log('[OCR Progress]', m);
          if (m.status === 'recognizing text') {
            setProgress(Math.round(m.progress * 100));
          }
        }
      });

      // Configurar opciones para mejorar precisión
      await worker.setParameters({
        tessedit_char_whitelist: 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@.-_+() ',
        tessedit_pageseg_mode: '6', // Uniform block of text
      });

      console.log('[OCR] Procesando imagen...');
      const { data: { text } } = await worker.recognize(imageUrl);
      
      console.log('[OCR] Texto extraído:', text);
      setExtractedText(text);
      
      // Extraer datos estructurados del texto
      const extractedInfo = extractBusinessCardData(text);
      setExtractedData(extractedInfo);
      
      console.log('[OCR] Datos extraídos:', extractedInfo);
      setShowPreview(true);

      await worker.terminate();
      
    } catch (error) {
      console.error('[OCR] Error:', error);
      onError(`Error en OCR: ${error.message}`);
    } finally {
      setIsProcessing(false);
      setProgress(0);
    }
  };

  // Función para extraer datos específicos del texto usando RegEx
  const extractBusinessCardData = (text) => {
    const data = {
      empresa: '',
      nombreContacto: '',
      posicion: '',
      mail: '',
      telefono: '',
      descripcion: ''
    };

    if (!text) return data;

    // Limpiar texto
    const cleanText = text.replace(/\n+/g, '\n').trim();
    const lines = cleanText.split('\n').filter(line => line.trim().length > 0);

    console.log('[OCR] Líneas procesadas:', lines);

    // Extraer email (prioridad alta)
    const emailRegex = /([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})/gi;
    const emailMatch = text.match(emailRegex);
    if (emailMatch && emailMatch[0]) {
      data.mail = emailMatch[0].toLowerCase();
    }

    // Extraer teléfono (múltiples patrones)
    const phonePatterns = [
      /(\+?\d{1,3}[-.\s]?)?\(?(\d{1,4})\)?[-.\s]?(\d{1,4})[-.\s]?(\d{1,4})[-.\s]?(\d{1,4})/g,
      /(\+54\s?9?\s?\d{2,4}[-.\s]?\d{3,4}[-.\s]?\d{3,4})/gi,
      /(011[-.\s]?\d{4}[-.\s]?\d{4})/gi
    ];

    for (let pattern of phonePatterns) {
      const phoneMatch = text.match(pattern);
      if (phoneMatch && phoneMatch[0]) {
        data.telefono = phoneMatch[0].replace(/\s+/g, ' ').trim();
        break;
      }
    }

    // Heurística para nombre y empresa basada en posición y formato
    const processedLines = lines.map(line => line.trim()).filter(line => 
      line.length > 0 && 
      !emailRegex.test(line) && 
      !phonePatterns.some(pattern => pattern.test(line))
    );

    if (processedLines.length > 0) {
      // Primer línea no-email/teléfono suele ser nombre o empresa
      const firstLine = processedLines[0];
      
      // Si tiene mayúsculas dominantes, probablemente es empresa
      const upperCaseRatio = (firstLine.match(/[A-Z]/g) || []).length / firstLine.length;
      
      if (upperCaseRatio > 0.5 || firstLine.length > 25) {
        data.empresa = firstLine;
        // Segunda línea podría ser nombre
        if (processedLines[1] && processedLines[1].length < 25) {
          data.nombreContacto = processedLines[1];
        }
      } else {
        data.nombreContacto = firstLine;
        // Segunda línea podría ser empresa
        if (processedLines[1]) {
          data.empresa = processedLines[1];
        }
      }
    }

    // Buscar cargos/posiciones comunes
    const positionKeywords = [
      'gerente', 'manager', 'director', 'presidente', 'ceo', 'cto', 'cfo',
      'coordinador', 'supervisor', 'jefe', 'responsable', 'encargado',
      'representante', 'vendedor', 'comercial', 'ejecutivo', 'analista'
    ];

    for (let line of processedLines) {
      const lowerLine = line.toLowerCase();
      if (positionKeywords.some(keyword => lowerLine.includes(keyword))) {
        data.posicion = line;
        break;
      }
    }

    // Si no encontramos posición, usar una línea que no sea nombre/empresa
    if (!data.posicion && processedLines.length > 2) {
      for (let i = 2; i < processedLines.length; i++) {
        const line = processedLines[i];
        if (line !== data.empresa && line !== data.nombreContacto && line.length < 50) {
          data.posicion = line;
          break;
        }
      }
    }

    // Descripción: combinar líneas restantes
    const remainingLines = processedLines.filter(line => 
      line !== data.empresa && 
      line !== data.nombreContacto && 
      line !== data.posicion
    );
    
    if (remainingLines.length > 0) {
      data.descripcion = remainingLines.join('. ').substring(0, 200);
    }

    return data;
  };

  // Función para aplicar los datos extraídos al formulario
  const applyExtractedData = () => {
    onDataExtracted(extractedData);
    setShowPreview(false);
    setExtractedText('');
    setExtractedData({});
  };

  // Función para descartar los datos extraídos
  const discardExtractedData = () => {
    setShowPreview(false);
    setExtractedText('');
    setExtractedData({});
  };

  return (
    <div className="ocr-processor">
      <div className="ocr-controls">
        <button 
          onClick={processImage}
          disabled={isProcessing || !imageUrl}
          className="btn-ocr"
        >
          {isProcessing ? `Procesando... ${progress}%` : '🔍 Extraer Datos de Tarjeta'}
        </button>
        
        {isProcessing && (
          <div className="progress-bar">
            <div 
              className="progress-fill" 
              style={{ width: `${progress}%` }}
            ></div>
          </div>
        )}
      </div>

      {showPreview && (
        <div className="ocr-preview">
          <h3>📋 Datos Extraídos</h3>
          
          <div className="extracted-data-preview">
            <div className="data-field">
              <strong>Empresa:</strong> 
              <span className={extractedData.empresa ? 'has-data' : 'no-data'}>
                {extractedData.empresa || 'No detectado'}
              </span>
            </div>
            
            <div className="data-field">
              <strong>Nombre:</strong> 
              <span className={extractedData.nombreContacto ? 'has-data' : 'no-data'}>
                {extractedData.nombreContacto || 'No detectado'}
              </span>
            </div>
            
            <div className="data-field">
              <strong>Cargo:</strong> 
              <span className={extractedData.posicion ? 'has-data' : 'no-data'}>
                {extractedData.posicion || 'No detectado'}
              </span>
            </div>
            
            <div className="data-field">
              <strong>Email:</strong> 
              <span className={extractedData.mail ? 'has-data' : 'no-data'}>
                {extractedData.mail || 'No detectado'}
              </span>
            </div>
            
            <div className="data-field">
              <strong>Teléfono:</strong> 
              <span className={extractedData.telefono ? 'has-data' : 'no-data'}>
                {extractedData.telefono || 'No detectado'}
              </span>
            </div>

            {extractedData.descripcion && (
              <div className="data-field">
                <strong>Descripción:</strong> 
                <span className="has-data">{extractedData.descripcion}</span>
              </div>
            )}
          </div>

          <details className="raw-text-details">
            <summary>📄 Ver texto completo extraído</summary>
            <pre className="raw-text">{extractedText}</pre>
          </details>

          <div className="preview-actions">
            <button 
              onClick={applyExtractedData}
              className="btn-apply"
            >
              ✅ Aplicar al Formulario
            </button>
            <button 
              onClick={discardExtractedData}
              className="btn-discard"
            >
              ❌ Descartar
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

export default OCRProcessor;
