<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<% if (!"responsable".equals(String.valueOf(session.getAttribute("rol")))) { String n=request.getRequestURI()+(request.getQueryString()!=null?("?"+request.getQueryString()):""); response.sendRedirect(request.getContextPath()+"/pages/login/login.jsp?next="+java.net.URLEncoder.encode(n,"UTF-8")); return; } %>

<%@ include file="/WEB-INF/seguridadProyecto.jsp" %>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <title>Planeación y evaluación - COVEICYDET</title>
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
        
        .modal {
            transition: all 0.3s ease;
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
                        <i class="fas fa-calendar-alt mr-3"></i>Planeación y evaluación 3/10
                    </h1>
                    <p class="text-white/90 mt-2 flex items-center">
                        <i class="fas fa-info-circle mr-2"></i>Complete cada sección (todos los campos son necesarios)
                    </p>
                </div>

                <!-- Formulario -->
                <form id="formPagina3" class="p-8 space-y-8" action="#" method="post">

                    <!-- Factores de riesgo y mitigación -->
                    <div class="textarea-container">
                        <label for="factores-riesgo" class="block text-sm font-medium text-gray-700 mb-2 flex items-center">
                            <i class="fas fa-exclamation-triangle text-[#7A1737] mr-2"></i>Factores de Riesgo y Mitigación <span class="text-red-600 ml-1">*</span>
                            <i class="fas fa-info-circle text-gray-400 ml-2" title="Máximo 1000 palabras"></i>
                        </label>
                        <textarea id="factores-riesgo" name="factores-riesgo" rows="4" required
                                placeholder="Describa los factores de riesgo y mitigación para el proyecto."
                                class="floating-input"></textarea>
                        <div id="contadorFactoresRiesgo" class="word-counter">0/1000 palabras</div>
                    </div>

                    <!-- Referencias bibliográficas -->
                    <div class="textarea-container">
                        <label for="metodologia" class="block text-sm font-medium text-gray-700 mb-2 flex items-center">
                            <i class="fas fa-book text-[#7A1737] mr-2"></i>Metodologia (resumen) <span class="text-red-600 ml-1">*</span> <!-- checarlo para despues 05/11/2025 Describa brevemente la metodologia del proyecto-->
                            <i class="fas fa-info-circle text-gray-400 ml-2" title="Máximo 1500 palabras"></i>
                        </label>
                        <textarea id="metodologia" name="metodologia" rows="4" required
                                placeholder="Describa brevemente la metodologia del proyecto"
                                class="floating-input"></textarea>
                        <div id="contadorMetodologia" class="word-counter">0/1500 palabras</div>
                    </div>
                    
                    <!-- ya no se usa :,c
                    Vinculación institucional
                    <div class="textarea-container">
                        <label for="vinculacion-institucional" class="block text-sm font-medium text-gray-700 mb-2 flex items-center">
                            <i class="fas fa-handshake text-[#7A1737] mr-2"></i>Vinculación Institucional <span class="text-red-600 ml-1">*</span>
                            <i class="fas fa-info-circle text-gray-400 ml-2" title="Máximo 800 palabras"></i>
                        </label>
                        <textarea id="vinculacion-institucional" name="vinculacion-institucional" rows="4" required
                                placeholder="Escriba el nombre de la institución."
                                class="floating-input"></textarea>
                        <div id="contadorVinculacion" class="word-counter">0/800 palabras</div>
                    </div> -->

                    <!-- Resultados esperados -->
                    <div class="textarea-container">
                        <label for="resultados" class="block text-sm font-medium text-gray-700 mb-2 flex items-center">
                            <i class="fas fa-chart-line text-[#7A1737] mr-2"></i>Resultados Esperados <span class="text-red-600 ml-1">*</span>
                            <i class="fas fa-info-circle text-gray-400 ml-2" title="Máximo 1000 palabras"></i>
                        </label>
                        <textarea id="resultados" name="resultados" rows="4" required
                                placeholder="Describa los resultados esperados del proyecto."
                                class="floating-input"></textarea>
                        <div id="contadorResultados" class="word-counter">0/1000 palabras</div>
                    </div>

                    <!-- inicio de areas de impacto: social, ambiental, economico cientifico y tecnologico -->
                    <h4 class="text-sm font-semibold uppercase tracking-wide text-slate-500 flex items-center">
                            <i class="fas fa-chart-line mr-2 text-[#7A1737]"></i>Areas de impacto
                    </h4>

                    <!-- social -->
                    <div class="textarea-container">
                        <label for="areas-impacto" class="block text-sm font-medium text-gray-700 mb-2 flex items-center">
                            <i class="fas fa-bullseye text-[#7A1737] mr-2"></i>Social <span class="text-red-600 ml-1">*</span>
                            <i class="fas fa-info-circle text-gray-400 ml-2" title="Máximo 1000 palabras"></i>
                        </label>
                        <textarea id="areas-impacto" name="areas-impacto" rows="4" required
                                placeholder="Describa las áreas de impacto del proyecto."
                                class="floating-input"></textarea>
                        <div id="contadorAreasImpacto" class="word-counter">0/1000 palabras</div>
                    </div>

                    <!-- ambiental -->
                    <div class="textarea-container">
                        <label for="areas-impacto-ambiental" class="block text-sm font-medium text-gray-700 mb-2 flex items-center">
                            <i class="fas fa-leaf text-[#7A1737] mr-2"></i>Ambiental <span class="text-red-600 ml-1">*</span>
                            <i class="fas fa-info-circle text-gray-400 ml-2" title="Máximo 1000 palabras"></i>
                        </label>
                        <textarea id="areas-impacto-ambiental" name="areas-impacto-ambiental" rows="4" required
                                placeholder="Describa las áreas de impacto ambiental del proyecto."
                                class="floating-input"></textarea>
                        <div id="contadorAreasImpactoAmbiental" class="word-counter">0/1000 palabras</div>
                    </div>

                    <!-- economico cientifico -->
                    <div class="textarea-container">
                        <label for="areas-impacto-economico" class="block text-sm font-medium text-gray-700 mb-2 flex items-center">
                            <i class="fas fa-dollar-sign text-[#7A1737] mr-2"></i>Económico <span class="text-red-600 ml-1">*</span>
                            <i class="fas fa-info-circle text-gray-400 ml-2" title="Máximo 800 palabras"></i>
                        </label>
                        <textarea id="areas-impacto-economico" name="areas-impacto-economico" rows="4" required
                                placeholder="Describa las áreas de impacto económico del proyecto."
                                class="floating-input"></textarea>
                        <div id="contadorAreasImpactoEconomico" class="word-counter">0/800 palabras</div>
                    </div>

                    <!-- tecnologico -->
                    <div class="textarea-container">
                        <label for="areas-impacto-tecnologico" class="block text-sm font-medium text-gray-700 mb-2 flex items-center">
                            <i class="fas fa-microchip text-[#7A1737] mr-2"></i>Cientifico/Tecnológico <span class="text-red-600 ml-1">*</span>
                            <i class="fas fa-info-circle text-gray-400 ml-2" title="Máximo 1000 palabras"></i>
                        </label>
                        <textarea id="areas-impacto-tecnologico" name="areas-impacto-tecnologico" rows="4" required
                                placeholder="Describa las áreas de impacto tecnológico del proyecto."
                                class="floating-input"></textarea>
                        <div id="contadorAreasImpactoTecnologico" class="word-counter">0/1000 palabras</div>
                    </div>

                    <!-- Botones de acción -->
                    <div class="flex flex-col-reverse gap-4 pt-8 border-t border-gray-200 sm:flex-row sm:justify-end">
                        <button type="button" onclick="guardarBorrador('formPagina3', 'pagina3', this)"
                                class="bg-gray-500 hover:bg-gray-600 text-white font-medium py-2 px-6 rounded-lg transition duration-200 flex items-center justify-center">
                            <i class="fas fa-save mr-2"></i>Guardar Borrador
                        </button>
                        <div class="flex gap-4">
                            <button type="button"
                                    class="bg-gray-600 hover:bg-gray-700 text-white font-medium py-2 px-6 rounded-lg transition duration-200 flex items-center justify-center"
                                    onclick="location.href='/proyectos/pages/responsableDeproyecto/registroProyecto/registroProyecto2.jsp'">
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

        // Utilidades para normalizar valores que llegan como 'false'/false/null
        function isFalseyString(v) {
            return v === false || v === 'false' || v === 'null' || v === 'undefined' || v === 'NaN';
        }
        function safe(v) {
            return (v == null || isFalseyString(v)) ? '' : String(v);
        }

        // Funciones para guardar y cargar borradores con estructura adecuada para BD
        function guardarBorrador(formId, pageKey, targetBtn) {
            const form = document.getElementById(formId);
            
            // Estructura JSON adecuada para la base de datos
            const jsonData = {
                proyecto: {
                    factores_riesgo_mitigacion: form.querySelector('[name="factores-riesgo"]')?.value || '',
                    resumen_metodologia: form.querySelector('[name="metodologia"]')?.value || '',
                    resultados_esperados: form.querySelector('[name="resultados"]')?.value || '',
                    impacto_social: form.querySelector('[name="areas-impacto"]')?.value || '',
                    impacto_ambiental: form.querySelector('[name="areas-impacto-ambiental"]')?.value || '',
                    impacto_economico: form.querySelector('[name="areas-impacto-economico"]')?.value || '',
                    impacto_cientificoTecnologico: form.querySelector('[name="areas-impacto-tecnologico"]')?.value || ''
                }
            };
            
            localStorage.setItem('proyecto_borrador_' + pageKey, JSON.stringify(jsonData));
            mostrarMensaje('Borrador guardado exitosamente', 'success', targetBtn);
        }

        function cargarBorrador(formId, pageKey) {
            const savedData = localStorage.getItem('proyecto_borrador_' + pageKey);
            
            if (savedData) {
                try {
                    const data = JSON.parse(savedData);
                    const form = document.getElementById(formId);
                    
                    // Cargar datos de proyecto (página 3)
                    if (data.proyecto) {
                        if (data.proyecto.factores_riesgo_mitigacion) 
                            form.querySelector('[name="factores-riesgo"]').value = data.proyecto.factores_riesgo_mitigacion;
                        if (data.proyecto.resumen_metodologia) 
                            form.querySelector('[name="metodologia"]').value = data.proyecto.resumen_metodologia;
                        if (data.proyecto.resultados_esperados) 
                            form.querySelector('[name="resultados"]').value = data.proyecto.resultados_esperados;
                        if (data.proyecto.impacto_social) 
                            form.querySelector('[name="areas-impacto"]').value = data.proyecto.impacto_social;
                        if (data.proyecto.impacto_ambiental) 
                            form.querySelector('[name="areas-impacto-ambiental"]').value = data.proyecto.impacto_ambiental;
                        if (data.proyecto.impacto_economico) 
                            form.querySelector('[name="areas-impacto-economico"]').value = data.proyecto.impacto_economico;
                        if (data.proyecto.impacto_cientificoTecnologico) 
                            form.querySelector('[name="areas-impacto-tecnologico"]').value = data.proyecto.impacto_cientificoTecnologico;
                    }
                } catch (error) {
                    console.error('Error al cargar el borrador:', error);
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



        // Cargar borrador y añadir control beforeunload y bloqueo/Siguiente
        window.addEventListener('load', function() {
            // Configurar contadores de palabras
            configurarContador('factores-riesgo', 'contadorFactoresRiesgo', 1000);
            configurarContador('metodologia', 'contadorMetodologia', 1500);
            configurarContador('vinculacion-institucional', 'contadorVinculacion', 800);
            configurarContador('resultados', 'contadorResultados', 1000);
            configurarContador('areas-impacto', 'contadorAreasImpacto', 1000);
            configurarContador('areas-impacto-ambiental', 'contadorAreasImpactoAmbiental', 1000);
            configurarContador('areas-impacto-economico', 'contadorAreasImpactoEconomico', 1000);
            configurarContador('areas-impacto-tecnologico', 'contadorAreasImpactoTecnologico', 1000);
            
            cargarBorrador('formPagina3', 'pagina3');

            const KEY = 'proyecto_borrador_pagina3_saved';
            const form = document.getElementById('formPagina3');
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

            let saved = localStorage.getItem(KEY) === '1';
            setDisabled(siguienteBtn, !saved);

            if(guardarBtn){ 
                guardarBtn.addEventListener('click', function(){ 
                    localStorage.setItem(KEY,'1'); 
                    saved = true; 
                    setDisabled(siguienteBtn, false); 
                    console.log('Borrador pagina3 guardado -> Siguiente habilitado'); 
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
                    window.location.href = '/proyectos/pages/responsableDeproyecto/registroProyecto/registroProyecto4.jsp';
                });
            }

            if(form){
                const inputs = Array.from(form.querySelectorAll('input, textarea, select'));
                const onChange = function(){ if(saved){ saved = false; localStorage.setItem(KEY,'0'); setDisabled(siguienteBtn, true); console.log('Formulario pagina3 modificado despues de guardar: Siguiente bloqueado'); } };
                inputs.forEach(el => el.addEventListener('input', onChange));
                inputs.forEach(el => el.addEventListener('change', onChange));

                window.addEventListener('beforeunload', function(e){ try{ if(!saved){ var msg='Tiene cambios sin guardar. ¿Desea salir sin guardar?'; e.preventDefault(); e.returnValue = msg; return msg; } }catch(err){ return undefined; } });
            }
        });
    </script>

    <%@ include file="/footer.jsp" %>
</body>
</html>
