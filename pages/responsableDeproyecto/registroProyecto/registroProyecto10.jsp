<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<% if (!"responsable".equals(String.valueOf(session.getAttribute("rol")))) { String n=request.getRequestURI()+(request.getQueryString()!=null?("?"+request.getQueryString()):""); response.sendRedirect(request.getContextPath()+"/pages/login/login.jsp?next="+java.net.URLEncoder.encode(n,"UTF-8")); return; } %>

<%!
    private static final String DB_URL = "jdbc:postgresql://localhost:5432/proyectos";
    private static final String DB_USER = "dbusr25";
    private static final String DB_PASSWORD = "mxToro24000Chocolate";

    private static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
    }
%>

<%
    //--- BLOQUEO DE SEGURIDAD ---//
    Integer idUsuarioSeguridad = (Integer) session.getAttribute("id_usuario");

    if (idUsuarioSeguridad != null) {
        boolean yaTieneProyecto = false;

        try (Connection conn = getConnection();
            PreparedStatement ps = conn.prepareStatement("SELECT 1 FROM proyecto_usuarios WHERE id_usuario = ? LIMIT 1")) {

                ps.setInt(1, idUsuarioSeguridad);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        yaTieneProyecto = true;
                    }
                }
                } catch (Exception e) {
                    e.printStackTrace();
                }
                if (yaTieneProyecto) {
                    response.sendRedirect(request.getContextPath() + "/pages/responsableDeproyecto/paginaPrincipal/index.jsp");
                    return;
                }
        }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <title>Justificación y objetivos - COVEICYDET</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');
        
        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
        }
        
        .form-container {
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
        }
        
        .floating-input {
            border: 1px solid #cbd5e0;
            border-radius: 0.5rem;
            padding: 0.75rem;
            width: 100%;
            transition: all 0.2s;
            resize: vertical;
        }
        
        .floating-input:focus {
            outline: none;
            border-color: #7A1737;
            box-shadow: 0 0 0 3px rgba(122, 23, 55, 0.2);
        }
        
        .word-counter {
            font-size: 0.875rem;
            margin-top: 0.5rem;
            text-align: right;
            padding: 0.25rem 0.5rem;
            background-color: #f8fafc;
            border-radius: 0.25rem;
            border: 1px solid #e2e8f0;
            font-weight: 500;
        }
        
        .word-counter.warning {
            color: #dc2626;
            background-color: #fef2f2;
            border-color: #fecaca;
        }
        
        .word-counter.success {
            color: #16a34a;
            background-color: #f0fdf4;
            border-color: #bbf7d0;
        }
        
        .textarea-container {
            margin-bottom: 1rem;
        }

        /* Nuevos estilos para la vista previa */
        .preview-container {
            display: none;
            margin-top: 1rem;
            border: 1px solid #e2e8f0;
            border-radius: 0.5rem;
            padding: 1rem;
            background: #f8fafc;
        }

        .preview-frame {
            width: 100%;
            height: 500px;
            border: 1px solid #cbd5e0;
            border-radius: 0.25rem;
        }

        .file-info {
            background: #f1f5f9;
            border-radius: 0.5rem;
            padding: 1rem;
            margin-bottom: 1rem;
            display: none;
        }
    </style>
</head>
<body class="min-h-screen flex flex-col">
    <%@ include file="../header.jsp" %>
    
    <!-- Contenido principal -->
    <%@ include file="Navegador.jsp" %>
<main class="flex-grow py-8">
        <div class="container mx-auto px-4">
            <div class="form-container bg-white rounded-xl overflow-hidden border border-slate-200">
                <!-- Encabezado del formulario -->
                <div class="bg-[#B28854] p-6">
                    <h1 class="text-2xl font-bold text-white flex items-center">
                        <i class="fas fa-file-contract mr-3"></i>Cargar archivo del documento extenso 10/10
                    </h1>
                    <p class="text-white/90 mt-2 flex items-center">
                        <i class="fas fa-info-circle mr-2"></i>Subir documento extenso formato PDF
                    </p>
                </div>
                <!-- Formulario -->
                <form id="formPagina10" class="p-8 space-y-8">

                    <!-- subir extenso en formato pdf-->
                    <div class="flex flex-col space-y-2">
                        <label for="documentoExtenso" class="text-sm font-medium text-gray-700 flex items-center">
                            <i class="fas fa-upload mr-2 text-[#7A1737]"></i>Subir documento extenso (formato PDF):
                            <span id="documentoExtenso_status" class="ml-2 text-sm font-normal"></span>
                        </label>

                        <input type="hidden" id="documentoExtenso_path" name="documentoExtenso_path">
                        
                        <input type="file" id="documentoExtenso" name="documentoExtenso" accept=".pdf"
                               class="border border-gray-300 rounded-lg p-2 focus:outline-none focus:ring-2 focus:ring-[#7A1737]">
                        <p class="text-sm text-gray-500">Por favor, suba el documento en formato PDF. Tamaño máximo: 10MB.</p>
                        
                        <!-- Información del archivo -->
                        <div id="fileInfo" class="file-info">
                            <div class="flex items-center justify-between">
                                <div class="flex items-center">
                                    <i class="fas fa-file-pdf text-red-500 mr-3 text-xl"></i>
                                    <div>
                                        <div id="fileName" class="font-medium text-gray-800"></div>
                                        <div id="fileSize" class="text-sm text-gray-600"></div>
                                    </div>
                                </div>
                                <button type="button" id="removeFile" class="text-red-500 hover:text-red-700">
                                    <i class="fas fa-times"></i>
                                </button>
                            </div>
                        </div>

                        <!-- boton para visualizar el archivo subido-->
                        <button type="button" id="visualizarDocumentoBtn"
                                class="bg-green-600 hover:bg-green-700 text-white font-medium py-2 px-4 rounded-lg transition duration-200 flex items-center justify-center w-max mt-2">
                            <i class="fas fa-eye mr-2"></i>Vista previa
                        </button>

                        <!-- Contenedor de vista previa -->
                        <div id="previewContainer" class="preview-container">
                            <div class="flex justify-between items-center mb-2">
                                <h3 class="font-medium text-gray-700">Vista previa del documento</h3>
                                <button type="button" id="closePreview" class="text-gray-500 hover:text-gray-700">
                                    <i class="fas fa-times"></i>
                                </button>
                            </div>
                            <iframe id="previewFrame" class="preview-frame" src="about:blank"></iframe>
                        </div>
                    </div>

                    <!-- Navegación -->
                    <div class="flex flex-col-reverse gap-4 pt-8 border-t border-gray-200 sm:flex-row sm:justify-end">
                        <button type="button" onclick="guardarBorrador('formPagina10', 'pagina10', this)"
                                class="bg-gray-500 hover:bg-gray-600 text-white font-medium py-2 px-6 rounded-lg transition duration-200 flex items-center justify-center">
                            <i class="fas fa-save mr-2"></i>Guardar Borrador
                        </button>
                        <div class="flex gap-4">
                            <button type="button"
                                    class="bg-gray-600 hover:bg-gray-700 text-white font-medium py-2 px-6 rounded-lg transition duration-200 flex items-center justify-center"
                                    onclick="location.href='/proyectos/pages/responsableDeproyecto/registroProyecto/registroProyecto9.jsp'">
                                <i class="fas fa-arrow-left mr-2"></i>Anterior
                            </button>
                            <button type="button" id="enviarProyectoBtn"
                                    class="bg-green-600 hover:bg-green-700 text-white font-medium py-2 px-6 rounded-lg transition duration-200 flex items-center justify-center">
                                <i class="fas fa-paper-plane mr-2"></i>Enviar Proyecto
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </main>
    <%@ include file="/footer.jsp" %>
    
    <script>
        // =========================================================================
        // 1. NUEVOS MÉTODOS DE GESTIÓN DE ARCHIVOS (Subida/Eliminado Automático)
        // =========================================================================
    
        async function handleFileUpload(fileInput, hiddenPathInput, statusElement) {
            const file = fileInput.files[0];
            const baseId = fileInput.id;
            
            if (!file) return;
    
            // Validaciones
            if (file.type !== 'application/pdf') {
                mostrarMensaje('Por favor, seleccione un archivo PDF', 'error', fileInput);
                fileInput.value = '';
                return;
            }
            if (file.size > 10 * 1024 * 1024) { // 10MB
                mostrarMensaje('El archivo excede el tamaño máximo de 10MB', 'error', fileInput);
                fileInput.value = '';
                return;
            }
    
            // Leer para enviar
            const reader = new FileReader();
            const fileReadPromise = new Promise((resolve, reject) => {
                reader.onload = () => resolve(reader.result);
                reader.onerror = (error) => reject(error);
            });
            reader.readAsDataURL(file);
    
            // Estado visual
            statusElement.textContent = 'Procesando...';
            statusElement.className = 'ml-2 text-sm text-blue-600';
            
            // Mostrar preview preliminar
            actualizarVistaArchivo(true, file.name, 'Cargando...');
    
            try {
                const base64String = await fileReadPromise;
                statusElement.textContent = 'Subiendo al servidor...';
    
                const bodyParams = new URLSearchParams();
                bodyParams.append('fileName', file.name);
                bodyParams.append('fileData', base64String);
    
                // Subir a upload.jsp
                const response = await fetch('/proyectos/pages/responsableDeproyecto/registroProyecto/upload.jsp', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: bodyParams
                });
    
                const result = await response.json();
    
                if (response.ok && result.success) {
                    // EXITO:
                    // 1. Guardamos la RUTA WEB que nos devolvió el servidor en el input oculto
                    hiddenPathInput.value = result.webUrl;
                    
                    // 2. Actualizamos la vista previa con datos reales
                    actualizarVistaArchivo(true, result.originalName, (file.size/1024/1024).toFixed(2)+' MB');
                    statusElement.textContent = 'Subida exitosa';
                    statusElement.className = 'ml-2 text-sm text-green-600';
    
                    // 3. AUTO-GUARDADO: Esto es clave.
                    // Guardamos inmediatamente en localStorage para que si recarga, el archivo siga ahí.
                    guardarBorrador('formPagina10', 'pagina10', null);
                    console.log('Documento extenso subido y guardado en borrador.');
    
                } else {
                    throw new Error(result.message || 'Error al subir.');
                }
            } catch (error) {
                console.error('Error:', error);
                statusElement.textContent = `Error: ${error.message}`;
                statusElement.className = 'ml-2 text-sm text-red-600';
                actualizarVistaArchivo(false); // Ocultar preview si falló
            }
        }
    
        async function handleFileDelete() {
            const hiddenPathInput = document.getElementById('documentoExtenso_path');
            const fileUrl = hiddenPathInput.value;
            const statusElement = document.getElementById('documentoExtenso_status');
    
            if (!fileUrl) return;
    
            if (!confirm('¿Eliminar documento extenso?')) return;
    
            try {
                const bodyParams = new URLSearchParams();
                bodyParams.append('fileUrl', fileUrl);
    
                const response = await fetch('/proyectos/pages/responsableDeproyecto/registroProyecto/deleteFile.jsp', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: bodyParams
                });
    
                const result = await response.json();
    
                if (response.ok && result.success) {
                    // Limpiar inputs
                    hiddenPathInput.value = '';
                    document.getElementById('documentoExtenso').value = '';
                    
                    // Limpiar UI
                    actualizarVistaArchivo(false);
                    if(statusElement) statusElement.textContent = '';
                    
                    // Ocultar iframe si estaba abierto
                    document.getElementById('previewContainer').style.display = 'none';
                    document.getElementById('previewFrame').src = 'about:blank';
    
                    // Actualizar borrador para que sepa que ya no hay archivo
                    guardarBorrador('formPagina10', 'pagina10', null);
                    mostrarMensaje('Archivo eliminado', 'success');
                }
            } catch (error) {
                console.error(error);
                mostrarMensaje('Error al eliminar', 'error');
            }
        }
    
        // Helper visual (sin lógica de negocio)
        function actualizarVistaArchivo(visible, nombre, tamano) {
            const fileInfo = document.getElementById('fileInfo');
            const visualizarBtn = document.getElementById('visualizarDocumentoBtn');
            
            if (visible) {
                fileInfo.style.display = 'block';
                document.getElementById('fileName').textContent = nombre;
                if(tamano) document.getElementById('fileSize').textContent = tamano;
                if(visualizarBtn) visualizarBtn.style.display = 'inline-flex';
            } else {
                fileInfo.style.display = 'none';
                document.getElementById('fileName').textContent = '';
                document.getElementById('fileSize').textContent = '';
                if(visualizarBtn) visualizarBtn.style.display = 'none';
            }
        }
    
        // =========================================================================
        // 2. GESTIÓN DE BORRADOR (Actualizado para guardar URL)
        // =========================================================================
    
        function guardarBorrador(formId, pageKey, targetBtn) {
            // Tomamos la URL del input oculto, NO el nombre del input file
            const path = document.getElementById('documentoExtenso_path').value;
            const nombreVisible = document.getElementById('fileName').textContent;
    
            const jsonData = {
                pagina10: {
                    // Guardamos la URL real para procesarProyecto
                    doc_extenso: path, 
                    // Guardamos el nombre visual para mostrarlo al usuario al cargar
                    doc_extenso_nombre_visual: nombreVisible 
                }
            };
    
            try {
                localStorage.setItem('proyecto_borrador_' + pageKey, JSON.stringify(jsonData));
                if(targetBtn) mostrarMensaje('Borrador guardado exitosamente', 'success', targetBtn);
            } catch(e) {
                console.error(e);
            }
        }
    
        function cargarBorrador(formId, pageKey) {
            const savedData = localStorage.getItem('proyecto_borrador_' + pageKey);
            if (savedData) {
                try {
                    const data = JSON.parse(savedData);
                    if (data.pagina10 && data.pagina10.doc_extenso) {
                        // Restaurar ruta en input oculto
                        document.getElementById('documentoExtenso_path').value = data.pagina10.doc_extenso;
                        
                        // Restaurar UI visual
                        const nombre = data.pagina10.doc_extenso_nombre_visual || 'Documento cargado';
                        actualizarVistaArchivo(true, nombre, '(Guardado)');
                    }
                } catch (e) { console.error(e); }
            }
        }
    
        // =========================================================================
        // 3. LOGICA DE CONSOLIDACIÓN Y ENVÍO (Manteniendo tu estructura)
        // =========================================================================
    
        function enviarProyectoCompleto() {
            try {
                const datosCompletos = {};
                
                // Recolectar las 10 páginas del LocalStorage
                for (let i = 1; i <= 10; i++) {
                    const key = 'proyecto_borrador_pagina' + i;
                    const savedData = localStorage.getItem(key);
                    
                    if (savedData) {
                        const parsed = JSON.parse(savedData);
                        datosCompletos['pagina' + i] = parsed['pagina' + i] || parsed;
                    } else {
                        datosCompletos['pagina' + i] = {};
                    }
                }
                
                // --- VALIDACIÓN FINAL ---
                // Verificamos el input oculto (la URL real), no el input file
                const urlDocumento = document.getElementById('documentoExtenso_path').value;
                
                if (!urlDocumento) {
                    mostrarMensaje('Falta subir el documento extenso en esta página.', 'error', document.getElementById('enviarProyectoBtn'));
                    return;
                }
    
                // Asegurarnos que la URL esté en el JSON final que se enviará
                if (!datosCompletos.pagina10) datosCompletos.pagina10 = {};
                
                // [IMPORTANTE] Esto es lo que lee procesarProyecto.jsp
                // Se asigna la URL del servidor (/uploads/...) al campo del JSON
                datosCompletos.pagina10.doc_extenso = urlDocumento;
    
                // También enviamos a pagina9 si tu procesarProyecto lo busca ahí (para seguridad)
                if (!datosCompletos.pagina9) datosCompletos.pagina9 = {};
                datosCompletos.pagina9.doc_extenso = urlDocumento;
    
                console.log('📦 Enviando proyecto consolidado:', datosCompletos);
    
                // Crear el formulario dinámico
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = '/proyectos/pages/responsableDeproyecto/registroProyecto/procesarProyecto.jsp';
    
                const input = document.createElement('input');
                input.type = 'hidden';
                input.name = 'datosProyecto';
                input.value = JSON.stringify(datosCompletos);
    
                form.appendChild(input);
                document.body.appendChild(form);
                
                mostrarMensaje('Enviando proyecto...', 'info');
                setTimeout(() => form.submit(), 1000);
    
            } catch (error) {
                console.error('Error al consolidar:', error);
                mostrarMensaje('Error al procesar el envío: ' + error.message, 'error');
            }
        }
    
        // =========================================================================
        // 4. INICIALIZACIÓN
        // =========================================================================
    
        function mostrarMensaje(mensaje, tipo = 'info', targetEl = null) {
            const messageDiv = document.createElement('div');
            let classes = 'p-4 rounded-md shadow-lg z-50 border fixed top-4 right-4 ';
            if (tipo === 'success') classes += 'bg-green-100 text-green-800 border-green-200';
            else if (tipo === 'error') classes += 'bg-red-100 text-red-800 border-red-200';
            else classes += 'bg-blue-100 text-blue-800 border-blue-200';
            
            messageDiv.className = classes;
            messageDiv.textContent = mensaje;
            document.body.appendChild(messageDiv);
            setTimeout(() => messageDiv.remove(), 3000);
        }
    
        window.addEventListener('load', function() {
            cargarBorrador('formPagina10', 'pagina10');
    
            const fileInput = document.getElementById('documentoExtenso');
            const hiddenInput = document.getElementById('documentoExtenso_path');
            const statusSpan = document.getElementById('documentoExtenso_status');
            const removeBtn = document.getElementById('removeFile');
            const visualizarBtn = document.getElementById('visualizarDocumentoBtn');
            const closePreview = document.getElementById('closePreview');
            const previewContainer = document.getElementById('previewContainer');
            const previewFrame = document.getElementById('previewFrame');
            const enviarBtn = document.getElementById('enviarProyectoBtn');
            const guardarBtn = document.querySelector('button[onclick*="guardarBorrador"]');
    
            // Listeners de Archivo
            fileInput.addEventListener('change', () => handleFileUpload(fileInput, hiddenInput, statusSpan));
            if(removeBtn) removeBtn.addEventListener('click', handleFileDelete);
    
            // Listener de Visualizar (Ahora usa la URL del input oculto)
            if(visualizarBtn) {
                visualizarBtn.addEventListener('click', function() {
                    const url = hiddenInput.value;
                    if (url) {
                        previewFrame.src = url;
                        previewContainer.style.display = 'block';
                        previewContainer.scrollIntoView({ behavior: 'smooth' });
                    } else {
                        mostrarMensaje('No hay documento cargado para visualizar', 'error', this);
                    }
                });
            }
    
            if(closePreview) {
                closePreview.addEventListener('click', () => {
                    previewContainer.style.display = 'none';
                    previewFrame.src = 'about:blank';
                });
            }
    
            // Lógica de bloqueo de botón (tu lógica original)
            const KEY_SAVED = 'proyecto_borrador_pagina10_saved';
            let saved = localStorage.getItem(KEY_SAVED) === '1';
            
            function updateEnviarBtn() {
                if(saved) {
                    enviarBtn.classList.remove('opacity-50', 'cursor-not-allowed');
                    enviarBtn.removeAttribute('disabled');
                } else {
                    enviarBtn.classList.add('opacity-50', 'cursor-not-allowed');
                    enviarBtn.setAttribute('disabled', 'true');
                }
            }
            if(enviarBtn) updateEnviarBtn();
    
            if(guardarBtn) {
                guardarBtn.addEventListener('click', () => {
                    localStorage.setItem(KEY_SAVED, '1');
                    saved = true;
                    if(enviarBtn) updateEnviarBtn();
                });
            }
    
            if(enviarBtn) {
                enviarBtn.addEventListener('click', (e) => {
                    e.preventDefault();
                    if(!saved) {
                        mostrarMensaje('Guarde el borrador antes de enviar.', 'error', enviarBtn);
                        return;
                    }
                    // Consolidar y enviar
                    enviarProyectoCompleto();
                });
            }
            
            // Detectar cambios no guardados
            // Se dispara solo cuando el usuario cambia el input (lo cual inicia la subida)
            // La subida luego marca como guardado automáticamente, así que es seguro.
            fileInput.addEventListener('input', () => {
                saved = false;
                localStorage.setItem(KEY_SAVED, '0');
                if(enviarBtn) updateEnviarBtn();
            });
        });

        
    </script>
</body>
</html>
