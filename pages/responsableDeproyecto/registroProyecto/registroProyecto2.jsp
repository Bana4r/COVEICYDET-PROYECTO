<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
    </style>
</head>
<body class="min-h-screen flex flex-col">
    <%@ include file="../header.jsp" %>
    <%@ include file="Navegador.jsp" %>
    
    <!-- Contenido principal -->
    <main class="flex-grow py-8">
        <div class="container mx-auto px-4">
            <div class="form-container bg-white rounded-xl overflow-hidden border border-slate-200">
                <!-- Encabezado del formulario -->
                <div class="bg-[#B28854] p-6">
                    <h1 class="text-2xl font-bold text-white flex items-center">
                        <i class="fas fa-file-contract mr-3"></i>Justificación y objetivos 2/10
                    </h1>
                    <p class="text-white/90 mt-2 flex items-center">
                        <i class="fas fa-info-circle mr-2"></i>Complete cada sección (todos los campos son obligatorios)
                    </p>
                </div>

                <!-- Formulario -->
                <form id="formPagina2" class="p-8 space-y-8">

                    <!-- Grupo 1: Descripción General -->
                    <section class="space-y-6">
                        <h4 class="text-sm font-semibold uppercase tracking-wide text-slate-500 flex items-center">
                            <i class="fas fa-file-alt mr-2 text-[#7A1737]"></i>Descripción General
                        </h4>

                        <div class="textarea-container">
                            <label for="resumen-ejecutivo" class="block text-sm font-medium text-gray-700 mb-2 flex items-center">
                                <i class="fas fa-align-left text-[#7A1737] mr-2"></i>Resumen Ejecutivo <span class="text-red-600 ml-1">*</span>
                                <i class="fas fa-info-circle text-gray-400 ml-2" title="Máximo 500 palabras"></i>
                            </label>
                            <textarea id="resumen-ejecutivo" name="resumen-ejecutivo" rows="5" required
                                placeholder="Describa brevemente el proyecto, alcance, impacto y resultados esperados (máximo 500 palabras)."
                                class="floating-input"></textarea>
                            <div id="contadorResumen" class="word-counter">0/500 palabras</div>
                        </div>

                        <div class="textarea-container">
                            <label for="antecedentes" class="block text-sm font-medium text-gray-700 mb-2 flex items-center">
                                <i class="fas fa-history text-[#7A1737] mr-2"></i>Antecedentes <span class="text-red-600 ml-1">*</span>
                                <i class="fas fa-info-circle text-gray-400 ml-2" title="Máximo 2000 palabras"></i>
                            </label>
                            <textarea id="antecedentes" name="antecedentes" rows="5" required
                                placeholder="Contexto previo, estudios, situación actual (máximo 2000 palabras)."
                                class="floating-input"></textarea>
                            <div id="contadorAntecedentes" class="word-counter">0/2000 palabras</div>
                        </div>

                        <div class="textarea-container">
                            <label for="pertinencia" class="block text-sm font-medium text-gray-700 mb-2 flex items-center">
                                <i class="fas fa-balance-scale text-[#7A1737] mr-2"></i>Pertinencia <span class="text-red-600 ml-1">*</span>
                                <i class="fas fa-info-circle text-gray-400 ml-2" title="Máximo 2000 palabras"></i>
                            </label>
                            <textarea id="pertinencia" name="pertinencia" rows="4" required
                                placeholder="Justifique la relevancia y necesidad del proyecto (máximo 2000 palabras)."
                                class="floating-input"></textarea>
                            <div id="contadorPertinencia" class="word-counter">0/2000 palabras</div>
                        </div>
                    </section>

                    <!-- Grupo 2: Fundamentación -->
                    <section class="space-y-6">
                        <h4 class="text-sm font-semibold uppercase tracking-wide text-slate-500 flex items-center">
                            <i class="fas fa-chart-line mr-2 text-[#7A1737]"></i>Fundamentación
                        </h4>

                        <div class="textarea-container">
                            <label for="preguntas-investigacion" class="block text-sm font-medium text-gray-700 mb-2 flex items-center">
                                <i class="fas fa-question-circle text-[#7A1737] mr-2"></i>Preguntas de Investigación <span class="text-red-600 ml-1">*</span>
                                <i class="fas fa-info-circle text-gray-400 ml-2" title="Máximo 500 palabras"></i>
                            </label>
                            <textarea id="preguntas-investigacion" name="preguntas-investigacion" rows="4" required
                                placeholder="Enumere preguntas clave (una por línea)."
                                class="floating-input"></textarea>
                            <div id="contadorPreguntasInvestigacion" class="word-counter">0/500 palabras</div>
                        </div>

                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div class="textarea-container">
                                <label for="objetivo-general" class="block text-sm font-medium text-gray-700 mb-2 flex items-center">
                                    <i class="fas fa-bullseye text-[#7A1737] mr-2"></i>Objetivo General <span class="text-red-600 ml-1">*</span>
                                    <i class="fas fa-info-circle text-gray-400 ml-2" title="Máximo 150 palabras"></i>
                                </label>
                                <textarea id="objetivo-general" name="objetivo-general" rows="4" required
                                    class="floating-input"></textarea>
                                <div id="contadorObjetivoGeneral" class="word-counter">0/150 palabras</div>
                            </div>
                            <div class="textarea-container">
                                <label for="objetivos-especificos" class="block text-sm font-medium text-gray-700 mb-2 flex items-center">
                                    <i class="fas fa-list-ol text-[#7A1737] mr-2"></i>Objetivos Específicos <span class="text-red-600 ml-1">*</span>
                                    <i class="fas fa-info-circle text-gray-400 ml-2" title="Máximo 300 palabras"></i>
                                </label>
                                <textarea id="objetivos-especificos" name="objetivos-especificos" rows="4" required
                                    class="floating-input"></textarea>
                                <div id="contadorObjetivosEspecificos" class="word-counter">0/300 palabras</div>
                            </div>
                        </div>
                    </section>

                    <!-- Navegación -->
                    <div class="flex flex-col-reverse gap-4 pt-8 border-t border-gray-200 sm:flex-row sm:justify-end">
                        <button type="button" onclick="guardarBorrador('formPagina2', 'pagina2', this)"
                                class="bg-gray-500 hover:bg-gray-600 text-white font-medium py-2 px-6 rounded-lg transition duration-200 flex items-center justify-center">
                            <i class="fas fa-save mr-2"></i>Guardar borrador
                        </button>
                        <div class="flex gap-4">
                            <button type="button"
                                    class="bg-gray-600 hover:bg-gray-700 text-white font-medium py-2 px-6 rounded-lg transition duration-200 flex items-center justify-center"
                                    onclick="location.href='/proyectos/pages/responsableDeproyecto/registroProyecto/registroProyecto.jsp'">
                                <i class="fas fa-arrow-left mr-2"></i>Anterior
                            </button>
                            <button type="button"
                                    class="bg-[#7A1737] hover:bg-[#5c0f2a] text-white font-medium py-2 px-6 rounded-lg transition duration-200 flex items-center justify-center"
                                    id="btnSiguiente">
                                Siguiente <i class="fas fa-arrow-right ml-2"></i>
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </main>
    <%@ include file="/footer.jsp" %>
    
    <script>
        // Función para contar palabras
        function contarPalabras(texto) {
            texto = texto.trim();
            if (texto === '') return 0;
            return texto.split(/\s+/).length;
        }

        // Configurar contador para un textarea
        function configurarContador(textareaId, contadorId, maxPalabras) {
            const textarea = document.getElementById(textareaId);
            const contador = document.getElementById(contadorId);
            
            if (!textarea || !contador) return;
            
            function actualizar() {
                const numPalabras = contarPalabras(textarea.value);
                contador.textContent = numPalabras + '/' + maxPalabras + ' palabras';
                
                // Cambiar colores
                if (numPalabras > maxPalabras) {
                    contador.className = 'word-counter warning';
                } else if (numPalabras === maxPalabras) {
                    contador.className = 'word-counter success';
                } else {
                    contador.className = 'word-counter';
                }
            }
            
            // Controlar el límite de palabras
            function controlarLimite(e) {
                const numPalabras = contarPalabras(textarea.value);
                
                if (numPalabras >= maxPalabras) {
                    // Permitir teclas de navegación y borrado
                    const teclasPermitidas = ['Backspace', 'Delete', 'ArrowLeft', 'ArrowRight', 'ArrowUp', 'ArrowDown', 'Home', 'End', 'Tab'];
                    
                    if (teclasPermitidas.includes(e.key) || e.ctrlKey || e.metaKey) {
                        return; // Permitir estas teclas
                    }
                    
                    // Si se intenta agregar más texto (espacio o letra)
                    if (e.key === ' ' || e.key.length === 1) {
                        e.preventDefault();
                        
                        // Mostrar mensaje temporal
                        contador.textContent = '⚠️ Límite alcanzado: ' + maxPalabras + ' palabras';
                        setTimeout(() => actualizar(), 2000);
                    }
                }
            }
            
            // Validar al pegar texto
            function controlarPegado(e) {
                e.preventDefault();
                const textoPegado = (e.clipboardData || window.clipboardData).getData('text');
                const textoActual = textarea.value;
                const inicio = textarea.selectionStart;
                const fin = textarea.selectionEnd;
                
                // Insertar el texto pegado
                const nuevoTexto = textoActual.substring(0, inicio) + textoPegado + textoActual.substring(fin);
                const palabrasNuevas = contarPalabras(nuevoTexto);
                
                if (palabrasNuevas <= maxPalabras) {
                    textarea.value = nuevoTexto;
                    textarea.setSelectionRange(inicio + textoPegado.length, inicio + textoPegado.length);
                } else {
                    // Calcular cuántas palabras se pueden agregar
                    const palabrasActuales = contarPalabras(textoActual);
                    const palabrasDisponibles = maxPalabras - palabrasActuales;
                    
                    if (palabrasDisponibles > 0) {
                        const palabrasPegadas = textoPegado.trim().split(/\s+/);
                        const palabrasPermitidas = palabrasPegadas.slice(0, palabrasDisponibles).join(' ');
                        
                        const nuevoTextoLimitado = textoActual.substring(0, inicio) + palabrasPermitidas + textoActual.substring(fin);
                        textarea.value = nuevoTextoLimitado;
                        textarea.setSelectionRange(inicio + palabrasPermitidas.length, inicio + palabrasPermitidas.length);
                    }
                    
                    contador.textContent = '⚠️ Límite alcanzado: ' + maxPalabras + ' palabras';
                    setTimeout(() => actualizar(), 2000);
                }
                
                actualizar();
            }
            
            // Escuchar cambios
            textarea.addEventListener('input', actualizar);
            textarea.addEventListener('keydown', controlarLimite);
            textarea.addEventListener('paste', controlarPegado);
            
            // Actualizar inicialmente
            actualizar();
        }

        // Función para guardar datos del formulario en localStorage con estructura adecuada para BD
        function guardarBorrador(formId, pageKey, targetBtn) {
            const form = document.getElementById(formId);
            
            // Estructura JSON adecuada para la base de datos (usando 'proyecto' como página 1)
            const jsonData = {
                proyecto: {
                    resumen_ejecutivo: form.querySelector('[name="resumen-ejecutivo"]')?.value || '',
                    antecedentes: form.querySelector('[name="antecedentes"]')?.value || '',
                    pertinencia: form.querySelector('[name="pertinencia"]')?.value || '',
                    preguntas_investigacion: form.querySelector('[name="preguntas-investigacion"]')?.value || '',
                    objetivos_general: form.querySelector('[name="objetivo-general"]')?.value || '',
                    objetivos_especificos: form.querySelector('[name="objetivos-especificos"]')?.value || ''
                }
            };
            
            localStorage.setItem('proyecto_borrador_' + pageKey, JSON.stringify(jsonData));
            // mostrar mensaje posicionado sobre el botón si se pasó targetBtn
            mostrarMensaje('Borrador guardado exitosamente', 'success', targetBtn);
        }

        function cargarBorrador(formId, pageKey) {
            const savedData = localStorage.getItem('proyecto_borrador_' + pageKey);
            
            if (savedData) {
                try {
                    const data = JSON.parse(savedData);
                    const form = document.getElementById(formId);
                    
                    // Cargar datos desde proyecto (compatible con formato antiguo pagina2)
                    const proyectoData = data.proyecto || data.pagina2 || data;
                    
                    if (proyectoData.resumen_ejecutivo) 
                        form.querySelector('[name="resumen-ejecutivo"]').value = proyectoData.resumen_ejecutivo;
                    if (proyectoData.antecedentes) 
                        form.querySelector('[name="antecedentes"]').value = proyectoData.antecedentes;
                    if (proyectoData.pertinencia) 
                        form.querySelector('[name="pertinencia"]').value = proyectoData.pertinencia;
                    if (proyectoData.preguntas_investigacion) 
                        form.querySelector('[name="preguntas-investigacion"]').value = proyectoData.preguntas_investigacion;
                    if (proyectoData.objetivos_general) 
                        form.querySelector('[name="objetivo-general"]').value = proyectoData.objetivos_general;
                    if (proyectoData.objetivos_especificos) 
                        form.querySelector('[name="objetivos-especificos"]').value = proyectoData.objetivos_especificos;
                } catch (error) {
                    console.error('Error al cargar borrador:', error);
                }
            }
        }

        function mostrarMensaje(mensaje, tipo = 'info', targetEl = null) {
            const messageDiv = document.createElement('div');
            let baseClasses = 'p-4 rounded-md shadow-lg z-50 border ';

            if (tipo === 'success') {
                baseClasses += 'bg-green-100 text-green-800 border-green-200';
            } else if (tipo === 'error') {
                baseClasses += 'bg-red-100 text-red-800 border-red-200';
            } else {
                baseClasses += 'bg-blue-100 text-blue-800 border-blue-200';
            }

            messageDiv.className = baseClasses;
            messageDiv.textContent = mensaje;

            if (targetEl && targetEl.getBoundingClientRect) {
                messageDiv.style.position = 'absolute';
                messageDiv.style.visibility = 'hidden';
                document.body.appendChild(messageDiv);

                const rect = targetEl.getBoundingClientRect();
                const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
                const scrollLeft = window.pageXOffset || document.documentElement.scrollLeft;

                const mw = messageDiv.offsetWidth;
                const mh = messageDiv.offsetHeight;

                let left = rect.left + scrollLeft + (rect.width - mw) / 2;
                let top = rect.top + scrollTop - mh - 8;
                if (top < (window.pageYOffset || document.documentElement.scrollTop)) {
                    top = rect.top + scrollTop + rect.height + 8;
                }

                const maxLeft = (window.pageXOffset || document.documentElement.scrollLeft) + document.documentElement.clientWidth - mw - 8;
                if (left < 8) left = 8;
                if (left > maxLeft) left = maxLeft;

                messageDiv.style.left = left + 'px';
                messageDiv.style.top = top + 'px';
                messageDiv.style.visibility = 'visible';
            } else {
                messageDiv.style.position = 'fixed';
                messageDiv.style.top = '1rem';
                messageDiv.style.right = '1rem';
                document.body.appendChild(messageDiv);
            }

            setTimeout(() => {
                if (messageDiv && messageDiv.parentNode) messageDiv.parentNode.removeChild(messageDiv);
            }, 3000);
        }

        // Cargar borrador y añadir control de navegación y protección contra abandono
        window.addEventListener('load', function() {
            // Configurar contadores de palabras
            configurarContador('resumen-ejecutivo', 'contadorResumen', 500);
            configurarContador('antecedentes', 'contadorAntecedentes', 2000);
            configurarContador('pertinencia', 'contadorPertinencia', 2000);
            configurarContador('preguntas-investigacion', 'contadorPreguntasInvestigacion', 500);
            configurarContador('objetivo-general', 'contadorObjetivoGeneral', 150);
            configurarContador('objetivos-especificos', 'contadorObjetivosEspecificos', 300);
            
            cargarBorrador('formPagina2', 'pagina2');

            const KEY = 'proyecto_borrador_pagina2_saved';
            const form = document.getElementById('formPagina2');
            const buttons = Array.from(document.querySelectorAll('button'));
            const guardarBtn = buttons.find(b => (b.getAttribute('onclick')||'').includes('guardarBorrador') || /guardar borrador/i.test(b.textContent));
            const siguienteBtn = document.getElementById('btnSiguiente') || buttons.find(b => /siguiente/i.test(b.textContent));

            function setDisabled(btn, disabled){
                if(!btn) return;
                // No usar disabled real para que los eventos sigan funcionando
                btn.setAttribute('aria-disabled', disabled ? 'true' : 'false');
                btn.setAttribute('data-disabled', disabled ? 'true' : 'false');
                if(disabled) {
                    btn.classList.add('opacity-60', 'cursor-not-allowed');
                    btn.classList.remove('hover:bg-[#5c0f2a]');
                } else {
                    btn.classList.remove('opacity-60', 'cursor-not-allowed');
                    btn.classList.add('hover:bg-[#5c0f2a]');
                }
            }

            if(!guardarBtn || !siguienteBtn){
                console.warn('No se encontraron botones Guardar/Siguiente en página2');
            }

            let saved = localStorage.getItem(KEY) === '1';
            setDisabled(siguienteBtn, !saved);

            if(guardarBtn){
                guardarBtn.addEventListener('click', function(){
                    localStorage.setItem(KEY,'1');
                    saved = true;
                    setDisabled(siguienteBtn, false);
                    console.log('Borrador pagina2 guardado -> Siguiente habilitado');
                });
            }

            // Agregar evento al botón siguiente para manejar navegación y advertencias
            if(siguienteBtn){
                siguienteBtn.addEventListener('click', function(e){
                    e.preventDefault();
                    e.stopPropagation();
                    
                    // Verificar si está "deshabilitado" (visualmente)
                    if(siguienteBtn.getAttribute('data-disabled') === 'true'){
                        mostrarMensaje('Debe guardar el borrador antes de continuar', 'error', siguienteBtn);
                        return false;
                    }
                    
                    // Si está habilitado, navegar a la siguiente página
                    window.location.href = '/proyectos/pages/responsableDeproyecto/registroProyecto/registroProyecto3.jsp';
                });
            }

            if(form){
                const inputs = Array.from(form.querySelectorAll('input, textarea, select'));
                const onChange = function(){
                    if(saved){
                        saved = false;
                        localStorage.setItem(KEY,'0');
                        setDisabled(siguienteBtn, true);
                        console.log('Formulario pagina2 modificado despues de guardar: Siguiente bloqueado');
                    }
                };
                inputs.forEach(el => el.addEventListener('input', onChange));
                inputs.forEach(el => el.addEventListener('change', onChange));

                // beforeunload
                window.addEventListener('beforeunload', function(e){
                    try{
                        if(!saved){
                            var msg = 'Tiene cambios sin guardar. ¿Desea salir sin guardar?';
                            e.preventDefault(); e.returnValue = msg; return msg;
                        }
                    }catch(err){ return undefined; }
                });
            }
        });
    </script>
</body>
</html>
