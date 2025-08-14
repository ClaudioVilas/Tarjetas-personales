
from flask import Flask, request, send_from_directory, jsonify
from flask_cors import CORS
from datetime import datetime
import os
from fpdf import FPDF
from PIL import Image
import tempfile

app = Flask(__name__)
CORS(app)

PDF_FOLDER = '/Users/claudiovilas/Downloads/Copia de Proyecto Tarjetas Feria 2/Pdf Feria'
FOTOS_FOLDER = '/Users/claudiovilas/Downloads/Copia de Proyecto Tarjetas Feria 2/cuaderno-feria-cueros/fotos'

# Asegurar que las carpetas existan
os.makedirs(PDF_FOLDER, exist_ok=True)
os.makedirs(FOTOS_FOLDER, exist_ok=True)

def compress_image(image_path, quality=70):
    """
    Comprime una imagen al 70% de calidad y devuelve la ruta del archivo temporal comprimido
    """
    try:
        # Usar PIL/Pillow si está disponible, sino devolver la imagen original
        from PIL import Image
        
        # Abrir la imagen
        img = Image.open(image_path)
        
        # Convertir a RGB si es necesario (para JPEG)
        if img.mode != 'RGB':
            img = img.convert('RGB')
        
        # Crear archivo temporal para la imagen comprimida
        temp_file = tempfile.NamedTemporaryFile(delete=False, suffix='.jpg')
        temp_path = temp_file.name
        temp_file.close()
        
        # Guardar con compresión
        img.save(temp_path, 'JPEG', quality=quality, optimize=True)
        
        print(f"[DEBUG] Imagen comprimida: {image_path} -> {temp_path} (calidad {quality}%)")
        return temp_path
        
    except ImportError:
        print("[WARNING] PIL/Pillow no disponible, usando imagen original sin compresión")
        return image_path
    except Exception as e:
        print(f"[ERROR] Error comprimiendo imagen: {e}")
        return image_path

# Endpoint para generar PDF
@app.route('/generate_pdf', methods=['POST'])
def generate_pdf():
    try:
        # Debug: imprimir lo que recibe el backend
        print(f"[DEBUG] request.form: {dict(request.form)}")
        print(f"[DEBUG] request.files: {dict(request.files)}")
        
        filename = request.form.get('filename', '').strip()
        empresa = request.form.get('empresa', '').strip()
        nombreContacto = request.form.get('nombreContacto', '').strip()
        posicion = request.form.get('posicion', '').strip()
        mail = request.form.get('mail', '').strip()
        descripcion = request.form.get('descripcion', '').strip()
        hasPhoto1 = request.form.get('hasPhoto1', 'false') == 'true'
        hasPhoto2 = request.form.get('hasPhoto2', 'false') == 'true'
        photo1_filename = request.form.get('photo1_filename', '').strip()
        photo2_filename = request.form.get('photo2_filename', '').strip()
        
        print(f"[DEBUG] filename: '{filename}'")
        print(f"[DEBUG] empresa: '{empresa}'")
        print(f"[DEBUG] nombreContacto: '{nombreContacto}'")
        print(f"[DEBUG] posicion: '{posicion}'")
        print(f"[DEBUG] mail: '{mail}'")
        print(f"[DEBUG] descripcion: '{descripcion}'")
        print(f"[DEBUG] hasPhoto1: {hasPhoto1}")
        print(f"[DEBUG] hasPhoto2: {hasPhoto2}")
        print(f"[DEBUG] photo1_filename: '{photo1_filename}'")
        print(f"[DEBUG] photo2_filename: '{photo2_filename}'")
        
        # Ya no requerimos filename obligatorio
        # if not filename:
        #     return 'Faltan datos', 400
        # Normalizar nombre de empresa para usar como nombre de archivo
        import re
        if empresa:
            # Reemplazar espacios por guion medio y otros caracteres no válidos por guion bajo
            empresa_filename = empresa.replace(' ', '-')
            empresa_filename = re.sub(r'[^a-zA-Z0-9\-]', '_', empresa_filename)
        else:
            # Buscar un nombre disponible sin sobrescribir
            base = 'sin_nombre'
            i = 1
            empresa_filename = base
            while os.path.exists(os.path.join(PDF_FOLDER, f"{empresa_filename}.pdf")):
                empresa_filename = f"{base}_{i}"
                i += 1
        
        # Solo verificar la imagen si se proporciona filename
        if filename:
            image_path = os.path.join(FOTOS_FOLDER, filename)
            if not os.path.exists(image_path):
                print(f"[WARNING] Imagen no encontrada: {image_path}, continuando sin imagen principal")
        else:
            print("[INFO] No se proporcionó filename, generando PDF sin imagen principal")
        pdf = FPDF()
        pdf.add_page()
        # Título
        pdf.set_font('Arial', 'B', 16)
        pdf.cell(0, 15, 'Datos de Contactos Feria Cueros Shanghai 2025', ln=1, align='L')
        pdf.ln(5)
        
        # Empresa
        pdf.set_font('Arial', 'B', 12)
        pdf.cell(0, 10, f'Nombre de la empresa:', ln=1, align='L')
        pdf.set_font('Arial', '', 12)
        pdf.cell(0, 8, empresa or 'No especificado', ln=1, align='L')
        pdf.ln(5)
        
        # Nombre de contacto
        pdf.set_font('Arial', 'B', 12)
        pdf.cell(0, 10, 'Nombre de contacto:', ln=1, align='L')
        pdf.set_font('Arial', '', 12)
        pdf.cell(0, 8, nombreContacto or 'No especificado', ln=1, align='L')
        pdf.ln(5)
        
        # Posición
        pdf.set_font('Arial', 'B', 12)
        pdf.cell(0, 10, 'Posición:', ln=1, align='L')
        pdf.set_font('Arial', '', 12)
        pdf.cell(0, 8, posicion or 'No especificado', ln=1, align='L')
        pdf.ln(5)
        
        # Mail
        pdf.set_font('Arial', 'B', 12)
        pdf.cell(0, 10, 'Mail:', ln=1)
        pdf.set_font('Arial', '', 12)
        pdf.cell(0, 8, mail or 'No especificado', ln=1)
        pdf.ln(5)
        
        # Descripcion
        pdf.set_font('Arial', 'B', 12)
        pdf.cell(0, 10, 'Descripcion:', ln=1)
        pdf.set_font('Arial', '', 12)
        pdf.multi_cell(0, 8, descripcion or 'No especificado')
        pdf.ln(5)
        
        # Fotos adicionales (Solo Foto 1)
        if hasPhoto1 and photo1_filename:
            pdf.set_font('Arial', 'B', 12)
            pdf.cell(0, 8, 'Foto 1', ln=1, align='L')
            try:
                pdf.ln(5)
                photo1_path = os.path.join(FOTOS_FOLDER, photo1_filename)
                if os.path.exists(photo1_path):
                    # Comprimir imagen al 70% de calidad
                    compressed_photo1_path = compress_image(photo1_path, quality=70)
                    
                    # Foto 1 en aspecto 16:9, doble de tamaño, alineada a la izquierda
                    pdf.image(compressed_photo1_path, x=pdf.get_x(), y=pdf.get_y(), w=160, h=90)
                    pdf.ln(95)
                    
                    # Limpiar archivo temporal si se creó uno
                    if compressed_photo1_path != photo1_path:
                        try:
                            os.unlink(compressed_photo1_path)
                        except:
                            pass
                else:
                    print(f"[!] Foto 1 no encontrada: {photo1_path}")
                    pdf.ln(100)
            except Exception as e:
                print(f"[!] Error insertando Foto 1: {e}")
                pdf.ln(100)
        
        # Foto 2 adicional
        if hasPhoto2 and photo2_filename:
            pdf.set_font('Arial', 'B', 12)
            pdf.cell(0, 8, 'Foto 2', ln=1, align='L')
            try:
                pdf.ln(5)
                photo2_path = os.path.join(FOTOS_FOLDER, photo2_filename)
                if os.path.exists(photo2_path):
                    # Comprimir imagen al 70% de calidad
                    compressed_photo2_path = compress_image(photo2_path, quality=70)
                    
                    # Foto 2 en aspecto 16:9, doble de tamaño, alineada a la izquierda
                    pdf.image(compressed_photo2_path, x=pdf.get_x(), y=pdf.get_y(), w=160, h=90)
                    pdf.ln(95)
                    
                    # Limpiar archivo temporal si se creó uno
                    if compressed_photo2_path != photo2_path:
                        try:
                            os.unlink(compressed_photo2_path)
                        except:
                            pass
                else:
                    print(f"[!] Foto 2 no encontrada: {photo2_path}")
                    pdf.ln(100)
            except Exception as e:
                print(f"[!] Error insertando Foto 2: {e}")
                pdf.ln(100)
        
        # COMENTADO: No incluir foto principal en el PDF
        # try:
        #     pdf.ln(5)
        #     pdf.image(image_path, x=pdf.get_x(), y=pdf.get_y(), w=100)
        #     pdf.ln(80)
        # except Exception as e:
        #     print(f"[!] Error insertando imagen principal: {e}")
        #     pdf.ln(85)
        
        # Guardar PDF
        pdf_filename = f"{empresa_filename}.pdf"
        pdf_path = os.path.join(PDF_FOLDER, pdf_filename)
        # Validar que el PDF se guarde solo dentro de la carpeta Pdf Feria
        pdf_path_abs = os.path.abspath(pdf_path)
        pdf_folder_abs = os.path.abspath(PDF_FOLDER)
        downloads_abs = os.path.expanduser('~/Downloads')
        print(f"[DEBUG] pdf_path_abs: {pdf_path_abs}")
        print(f"[DEBUG] pdf_folder_abs: {pdf_folder_abs}")
        print(f"[DEBUG] downloads_abs: {downloads_abs}")
        # No permitir guardar fuera de Pdf Feria
        # Solo falla si NO está dentro de Pdf Feria
        if not pdf_path_abs.startswith(pdf_folder_abs):
            print(f"[ERROR] Validación de ruta fallida: pdf_path_abs={pdf_path_abs}, pdf_folder_abs={pdf_folder_abs}")
            return 'No se permite guardar el PDF fuera de la carpeta Pdf Feria', 500
        pdf.output(pdf_path_abs)
        print(f"[✔] PDF generado: {pdf_path_abs}")
        return send_from_directory(PDF_FOLDER, pdf_filename, as_attachment=True)
    except Exception as e:
        import traceback
        print(f"[!] Error inesperado en generate_pdf: {e}")
        traceback.print_exc()
        return f'Error interno: {e}', 500

@app.route('/upload', methods=['POST'])
def upload_file():
    print(f"Headers: {dict(request.headers)}")
    print(f"Content-Type: {request.content_type}")
    print(f"request.data length: {len(request.data)}")
    print(f"request.files: {request.files}")
    print(f"request.form: {request.form}")

    empresa = request.form.get('empresa', '').strip()
    import re
    if empresa:
        empresa_filename = re.sub(r'[^a-zA-Z0-9_-]', '_', empresa)
    else:
        empresa_filename = 'sin_nombre'
    print(f"[DEBUG] empresa: '{empresa}' empresa_filename: '{empresa_filename}'")

    # Si viene como raw data (no multipart, como desde el atajo de iPhone)
    if request.data and empresa_filename:
        filename = f"{empresa_filename}.jpg"
        filepath = os.path.join(FOTOS_FOLDER, filename)
        print(f"[DEBUG] RAW filename: {filename} filepath: {filepath}")
        with open(filepath, 'wb') as f:
            f.write(request.data)
        print(f"[✔] Imagen guardada: {filepath}")
        return 'Imagen recibida correctamente', 200

    # Si viene como multipart (por si usas otro método en el futuro)
    if 'image' in request.files and empresa_filename:
        file = request.files['image']
        if file.filename == '':
            return 'Nombre de archivo vacío', 400
        filename = f"{empresa_filename}.jpg"
        filepath = os.path.join(FOTOS_FOLDER, filename)
        print(f"[DEBUG] MULTIPART filename: {filename} filepath: {filepath}")
        file.save(filepath)
        print(f"[✔] Imagen guardada: {filepath}")
        return 'Imagen recibida correctamente', 200

    return 'No se encontró imagen en la solicitud o falta el nombre de empresa', 400

@app.route('/ultima_foto', methods=['GET'])
def ultima_foto():
    try:
        print(f"[DEBUG] Listando archivos en {FOTOS_FOLDER}")
        archivos = [f for f in os.listdir(FOTOS_FOLDER) if f.lower().endswith('.jpg')]
        print(f"[DEBUG] Archivos encontrados: {archivos}")
        if not archivos:
            print("[DEBUG] No hay archivos JPG en la carpeta de fotos")
            return jsonify({'filename': None}), 200
        # Ordenar por fecha de modificación (más reciente primero)
        archivos.sort(key=lambda f: os.path.getmtime(os.path.join(FOTOS_FOLDER, f)), reverse=True)
        print(f"[DEBUG] Archivo más reciente: {archivos[0]}")
        return jsonify({'filename': archivos[0]}), 200
    except Exception as e:
        print(f"[ERROR] en /ultima_foto: {e}")
        return jsonify({'error': str(e)}), 500

# Endpoint para crear copia única de una foto para posición específica
@app.route('/create_unique_photo', methods=['POST'])
def create_unique_photo():
    try:
        data = request.get_json()
        source_filename = data.get('source_filename')
        position = data.get('position')  # 'photo1' o 'photo2'
        
        if not source_filename or not position:
            return jsonify({'error': 'Faltan parámetros'}), 400
            
        source_path = os.path.join(FOTOS_FOLDER, source_filename)
        if not os.path.exists(source_path):
            return jsonify({'error': 'Archivo fuente no encontrado'}), 404
            
        # Generar nombre único basado en timestamp y posición
        import time
        timestamp = int(time.time() * 1000)  # milisegundos
        unique_filename = f"{position}_{timestamp}.jpg"
        unique_path = os.path.join(FOTOS_FOLDER, unique_filename)
        
        # Copiar archivo
        import shutil
        shutil.copy2(source_path, unique_path)
        
        print(f"[DEBUG] Copia única creada: {source_filename} -> {unique_filename}")
        return jsonify({'unique_filename': unique_filename}), 200
        
    except Exception as e:
        print(f"[ERROR] en /create_unique_photo: {e}")
        return jsonify({'error': str(e)}), 500

# Endpoint para servir fotos individuales
@app.route('/fotos/<filename>')
def serve_foto(filename):
    print(f"Intentando servir: '{filename}'")
    return send_from_directory(FOTOS_FOLDER, filename)

# Endpoint de health check para Docker
@app.route('/health')
def health_check():
    return jsonify({"status": "healthy", "timestamp": datetime.now().isoformat()})

if __name__ == '__main__':
    # Usar variables de entorno para host y puerto
    host = os.environ.get('FLASK_HOST', '0.0.0.0')
    port = int(os.environ.get('FLASK_PORT', 5000))
    app.run(host=host, port=port)
