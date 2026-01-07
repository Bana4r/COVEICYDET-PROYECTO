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
        
        .semestre-section {
            transition: all 0.2s ease;
            border-radius: 0.5rem;
            overflow: visible;
        }
        
        .semestre-section:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
        }
        
        .input-focus:focus {
            border-color: #7A1737;
            box-shadow: 0 0 0 3px rgba(122, 23, 55, 0.1);
        }
        
        .semestre-header {
            background: linear-gradient(135deg, #7A1737, #9D5B64);
            color: white;
            border-radius: 0.5rem 0.5rem 0 0;
        }

        .semestre-visible {
            padding: 0.75rem 1rem;
            background: transparent;
            color: #1f2937;
        }

        .semestre-visible h3 {
            color: #111827;
            font-weight: 700;
            margin: 0;
            z-index: 60;
            position: relative;
        }

        .semestre-section { margin-top: 0.75rem; }

        .semestre-pill-visible {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            background: #fff;
            color: #7A1737;
            border-radius: 999px;
            padding: 0.25rem 0.6rem;
            font-weight: 700;
            box-shadow: 0 1px 3px rgba(0,0,0,0.06);
            margin-right: 0.5rem;
        }
        
        .badge-semestre {
            background-color: #B28854;
            color: white;
            border-radius: 1rem;
            padding: 0.25rem 0.75rem;
            font-size: 0.75rem;
            font-weight: 600;
            display: inline-block;
            min-width: 84px;
            text-align: center;
        }
        
        .table-actividades {
            width: 100%;
            border-collapse: collapse;
        }
        
        /* AJUSTES EN LAS COLUMNAS DE LA TABLA */
        .table-actividades th {
            background-color: #7A1737;
            color: white;
            padding: 0.75rem;
            text-align: left;
            font-weight: 600;
        }
        
        /* Columna de Nombre de Actividad más pequeña */
        .table-actividades th:nth-child(1) {
            width: 25%; /* Reducido de 6/12 (50%) a 25% */
        }
        
        /* Columna de Entregables más grande */
        .table-actividades th:nth-child(2) {
            width: 65%; /* Aumentado de 5/12 (41.6%) a 65% */
        }
        
        /* Columna de Acciones */
        .table-actividades th:nth-child(3) {
            width: 10%; /* Mantenido similar */
        }
        
        .table-actividades td {
            padding: 0.75rem;
            border-bottom: 1px solid #e5e7eb;
            vertical-align: top;
        }
        
        .table-actividades tr:hover {
            background-color: #f9fafb;
        }
        
        .btn-remove {
            background-color: #dc2626;
            color: white;
            transition: all 0.2s ease;
        }
        
        .btn-remove:hover {
            background-color: #b91c1c;
            transform: translateY(-1px);
        }
        
        /* ESTILOS MEJORADOS PARA ENTREGABLES - DESPLEGABLE */
        .entregables-container {
            position: relative;
            width: 100%;
        }
        
        .entregables-title {
            font-weight: 600;
            color: #7A1737;
            font-size: 0.9rem;
            margin-bottom: 0.5rem;
            display: flex;
            align-items: center;
            cursor: pointer;
            padding: 0.75rem;
            background-color: #f8fafc;
            border: 1px solid #e5e7eb;
            border-radius: 0.375rem;
            transition: all 0.2s ease;
        }
        
        .entregables-title:hover {
            background-color: #f1f5f9;
            border-color: #7A1737;
        }
        
        .entregables-title i {
            margin-right: 0.5rem;
            transition: transform 0.2s ease;
        }
        
        .entregables-title.expanded i {
            transform: rotate(90deg);
        }
        
        .entregables-dropdown {
            display: none; /* Oculto por defecto */
            position: relative;
            background: white;
            border: 1px solid #d1d5db;
            border-radius: 0.375rem;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
            z-index: 10;
            max-height: 300px;
            overflow-y: auto;
            padding: 1rem;
            margin-bottom: 0.5rem;
        }
        
        .entregables-dropdown.show {
            display: block; /* Mostrar cuando tenga la clase show */
        }
        
        .entregable-group {
            margin-bottom: 1rem;
        }
        
        .entregable-group-title {
            font-weight: 600;
            color: #7A1737;
            font-size: 0.85rem;
            padding: 0.5rem 0.25rem;
            margin-bottom: 0.5rem;
            border-bottom: 1px solid #e5e7eb;
            background-color: #f8fafc;
            border-radius: 0.25rem;
            cursor: default;
            pointer-events: none;
            user-select: none;
        }
        
        .entregable-item {
            display: flex;
            align-items: center;
            padding: 0.5rem;
            margin: 0.125rem 0;
            border-radius: 0.25rem;
            transition: background-color 0.2s;
            cursor: pointer;
        }
        
        .entregable-item:hover {
            background-color: #f3f4f6;
        }
        
        .entregable-checkbox {
            margin-right: 0.5rem;
            width: 16px;
            height: 16px;
            cursor: pointer;
        }
        
        .entregable-label {
            font-size: 0.85rem;
            color: #374151;
            cursor: pointer;
            flex: 1;
            line-height: 1.3;
        }
        
        /* CONTENEDOR PARA ETIQUETAS VISIBLES */
        .selected-tags-container {
            min-height: 60px;
            padding: 0.75rem;
            background-color: #f8fafc;
            border-radius: 0.375rem;
            border: 1px solid #e5e7eb;
            margin-top: 0.5rem;
        }
        
        .selected-tags {
            display: flex;
            flex-wrap: wrap;
            gap: 0.5rem;
        }
        
        .selected-tag {
            display: inline-flex;
            align-items: center;
            background: linear-gradient(135deg, #7A1737, #9D5B64);
            color: white;
            padding: 0.5rem 0.75rem;
            border-radius: 1rem;
            font-size: 0.8rem;
            font-weight: 500;
            gap: 0.25rem;
            max-width: 250px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        
        .remove-tag {
            margin-left: 0.25rem;
            cursor: pointer;
            width: 16px;
            height: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
            background-color: rgba(255, 255, 255, 0.3);
            transition: background-color 0.2s;
            font-size: 0.7rem;
        }

        .selected-tag .tag-text {
            display: inline-block;
            color: white;
            font-size: 0.8rem;
            line-height: 1;
            max-width: 200px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        
        .remove-tag:hover {
            background-color: rgba(255, 255, 255, 0.5);
        }
        
        .entregables-counter {
            font-size: 0.75rem;
            color: #6b7280;
            margin-top: 0.5rem;
            text-align: center;
            padding: 0.375rem;
            background-color: #f9fafb;
            border-radius: 0.25rem;
        }
        
        .entregables-counter.has-selection {
            color: #7A1737;
            font-weight: 500;
            background-color: #fef2f2;
        }
        
        .empty-selection {
            color: #9ca3af;
            font-style: italic;
            text-align: center;
            padding: 0.75rem;
            font-size: 0.85rem;
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

        /* Asegurar que el contenedor de entregables tenga suficiente espacio */
        .entregables-cell {
            min-width: 500px;
        }
        
        /* Input más pequeño para nombre de actividad */
        .actividad-nombre-input {
            width: 100%;
            padding: 0.5rem 0.75rem;
            border: 1px solid #d1d5db;
            border-radius: 0.375rem;
            font-size: 0.875rem;
            transition: all 0.2s;
        }
        
        .actividad-nombre-input:focus {
            outline: none;
            border-color: #7A1737;
            box-shadow: 0 0 0 2px rgba(122, 23, 55, 0.1);
        }

        /* Asegurar que los elementos del dropdown no propaguen eventos */
        .entregables-dropdown,
        .entregables-dropdown *,
        .entregables-title,
        .entregables-title *,
        .entregable-item,
        .entregable-item *,
        .selected-tags-container,
        .selected-tags-container * {
            pointer-events: auto;
        }

        /* Prevenir que los títulos de grupo sean clickeables */
        .entregable-group-title {
            pointer-events: none;
            user-select: none;
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
                        <i class="fas fa-calendar-alt mr-3"></i>Cronograma de Actividades 7/10
                    </h1>
                    <p class="text-white/90 mt-2 flex items-center">
                        <i class="fas fa-info-circle mr-2"></i>Complete cada sección (todos los campos son necesarios)
                    </p>
                </div>

                <!-- Formulario -->
                <form class="p-8 space-y-8" action="#" method="post">
                    <!-- Contenedor para las secciones de semestres -->
                    <div id="semestresContainer" class="space-y-6">
                        
                    <div class="semestre-section bg-white border border-gray-200 rounded-lg">
                        <div class="semestre-visible">
                            <h3 class="text-lg font-semibold">Semestre 1</h3>
                        </div>
                        <div class="semestre-header p-4 flex justify-between items-center">
                            <div></div>
                            <span class="badge-semestre" title="Semestre 1">Semestre 1</span>
                        </div>
                        <div class="p-6 space-y-6">
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div>
                                    <label for="descripcionSemestre1" class="block text-sm font-medium text-gray-700 mb-1">Descripción del Semestre 1:</label>
                                    <textarea id="descripcionSemestre1" name="descripcionSemestre1" rows="2" class="w-full px-3 py-2 border border-gray-300 rounded-md input-focus" placeholder="Descripción general del semestre..."></textarea>
                                </div>
                                <div>
                                    <label for="metaSemestre1" class="block text-sm font-medium text-gray-700 mb-1">Meta del Semestre 1:</label>
                                    <textarea id="metaSemestre1" name="metaSemestre1" rows="2" class="w-full px-3 py-2 border border-gray-300 rounded-md input-focus" placeholder="Describa las metas específicas a alcanzar..."></textarea>
                                </div>
                            </div>
                            <div class="border-t border-gray-200 pt-4">
                                <div class="flex justify-between items-center mb-4">
                                    <h4 class="text-lg font-semibold text-gray-800">Actividades del Semestre 1</h4>
                                    <button id="agregarActividadBtn1" type="button" class="agregar-actividad bg-[#7A1737] hover:bg-[#5A2329] text-white font-medium py-2 px-4 rounded-md transition duration-200 flex items-center" data-semestre="1">
                                        <i class="fas fa-plus mr-2"></i>Agregar Actividad
                                    </button>
                                </div>
                                <div class="overflow-x-auto">
                                    <table class="table-actividades">
                                        <thead>
                                            <tr>
                                                <th class="w-3/12">Actividad</th>
                                                <th class="w-8/12">Entregables</th>
                                                <th class="w-1/12">Acciones</th>
                                            </tr>
                                        </thead>
                                        <tbody id="actividadesTable1">
                                            <tr id="emptyRow1">
                                                <td colspan="3" class="text-center text-gray-500 py-4">
                                                    No hay actividades agregadas en Semestre 1. Haga clic en "Agregar Actividad" para comenzar.
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="semestre-section bg-white border border-gray-200 rounded-lg">
                        <div class="semestre-visible">
                            <h3 class="text-lg font-semibold">Semestre 2</h3>
                        </div>
                        <div class="semestre-header p-4 flex justify-between items-center">
                            <div></div>
                            <span class="badge-semestre" title="Semestre 2">Semestre 2</span>
                        </div>
                        <div class="p-6 space-y-6">
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div>
                                    <label for="descripcionSemestre2" class="block text-sm font-medium text-gray-700 mb-1">Descripción del Semestre 2:</label>
                                    <textarea id="descripcionSemestre2" name="descripcionSemestre2" rows="2" class="w-full px-3 py-2 border border-gray-300 rounded-md input-focus" placeholder="Descripción general del semestre..."></textarea>
                                </div>
                                <div>
                                    <label for="metaSemestre2" class="block text-sm font-medium text-gray-700 mb-1">Meta del Semestre 2:</label>
                                    <textarea id="metaSemestre2" name="metaSemestre2" rows="2" class="w-full px-3 py-2 border border-gray-300 rounded-md input-focus" placeholder="Describa las metas específicas a alcanzar..."></textarea>
                                </div>
                            </div>
                            <div class="border-t border-gray-200 pt-4">
                                <div class="flex justify-between items-center mb-4">
                                    <h4 class="text-lg font-semibold text-gray-800">Actividades del Semestre 2</h4>
                                    <button id="agregarActividadBtn2" type="button" class="agregar-actividad bg-[#7A1737] hover:bg-[#5A2329] text-white font-medium py-2 px-4 rounded-md transition duration-200 flex items-center" data-semestre="2">
                                        <i class="fas fa-plus mr-2"></i>Agregar Actividad
                                    </button>
                                </div>
                                <div class="overflow-x-auto">
                                    <table class="table-actividades">
                                        <thead>
                                            <tr>
                                                <th class="w-3/12">Actividad</th>
                                                <th class="w-8/12">Entregables</th>
                                                <th class="w-1/12">Acciones</th>
                                            </tr>
                                        </thead>
                                        <tbody id="actividadesTable2">
                                            <tr id="emptyRow2">
                                                <td colspan="3" class="text-center text-gray-500 py-4">
                                                    No hay actividades agregadas en Semestre 2. Haga clic en "Agregar Actividad" para comenzar.
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                    <!-- Navegación -->
                    <div class="flex flex-col-reverse gap-4 pt-8 border-t border-gray-200 sm:flex-row sm:justify-end">
                        <button type="button" onclick="guardarBorrador('formPagina2', 'pagina2', this)"
                                class="bg-gray-500 hover:bg-gray-600 text-white font-medium py-2 px-6 rounded-lg transition duration-200 flex items-center justify-center">
                            <i class="fas fa-save mr-2"></i>Guardar borrador
                        </button>
                        <div class="flex gap-4">
                            <button type="button"
                                    class="bg-gray-600 hover:bg-gray-700 text-white font-medium py-2 px-6 rounded-lg transition duration-200 flex items-center justify-center"
                                    onclick="location.href='/proyectos/pages/responsableDeproyecto/registroProyecto/registroProyecto6.jsp'">
                                <i class="fas fa-arrow-left mr-2"></i>Anterior
                            </button>
                            <button type="button" id="btnSiguiente"
                                    class="bg-[#7A1737] hover:bg-[#5c0f2a] text-white font-medium py-2 px-6 rounded-lg transition duration-200 flex items-center justify-center">
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
        // Lista de entregables predefinidos
        const entregables = [
            // Productos Académicos
            { value: 'libros-derivados', text: 'Libros derivados de la propuesta', category: 'academicos' },
            { value: 'propiedad-intelectual', text: 'Propiedad intelectual e industrial', category: 'academicos' },
            { value: 'informes-tecnicos', text: 'Informes técnicos especializados', category: 'academicos' },
            { value: 'desarrollo-tecnologico', text: 'Desarrollo tecnológico e innovación', category: 'academicos' },
            
            // Productos de acceso universal del conocimiento
            { value: 'difusion-divulgacion', text: 'Actividades de difusión y divulgación', category: 'acceso-universal' },
            { value: 'infografias', text: 'Infografías explicativas', category: 'acceso-universal' },
            { value: 'folletos', text: 'Folletos informativos', category: 'acceso-universal' },
            { value: 'libros-divulgacion', text: 'Libros de divulgación científica', category: 'acceso-universal' },
            { value: 'material-audiovisual', text: 'Material audiovisual educativo', category: 'acceso-universal' },
            { value: 'podcast', text: 'Podcast y programas de audio', category: 'acceso-universal' },
            { value: 'otros-divulgacion', text: 'Otros productos de divulgación', category: 'acceso-universal' },
            
            // Formación de capacidades en HCTI y vocaciones científicas
            { value: 'tesis-grado', text: 'Tesis de grado o posgrado', category: 'formacion' },
            { value: 'tesina', text: 'Tesinas de investigación', category: 'formacion' },
            { value: 'memoria-residencias', text: 'Memorias de residencias profesionales', category: 'formacion' },
            
            // Fortalecimiento de infraestructura
            { value: 'equipamiento-maquinaria', text: 'Equipamiento de maquinaria', category: 'infraestructura' },
            { value: 'equipo-laboratorio', text: 'Equipo de laboratorio', category: 'infraestructura' },
            { value: 'software-especializado', text: 'Software especializado', category: 'infraestructura' },
            { value: 'infraestructura-redes', text: 'Infraestructura de redes', category: 'infraestructura' },
            
            // Otros entregables comunes
            { value: 'articulo-cientifico', text: 'Artículo científico', category: 'otros' },
            { value: 'ponencia-congreso', text: 'Ponencia en congreso', category: 'otros' },
            { value: 'poster-cientifico', text: 'Póster científico', category: 'otros' },
            { value: 'manual-tecnico', text: 'Manual técnico', category: 'otros' },
            { value: 'prototipo', text: 'Prototipo funcional', category: 'otros' },
            { value: 'base-datos', text: 'Base de datos especializada', category: 'otros' },
            { value: 'informe-final', text: 'Informe final de investigación', category: 'otros' }
        ];

        // Event delegation global corregida para evitar conflictos
        document.addEventListener('click', function(event) {
            // Manejar clics en botones de agregar actividad
            const addBtn = event.target.closest('button.agregar-actividad');
            if (addBtn) {
                event.preventDefault();
                event.stopPropagation();
                const semestreNum = addBtn.dataset.semestre;
                console.log('Agregando actividad para semestre (click):', semestreNum, 'botonId:', addBtn.id);
                // Pasamos el botón para localizar la sección correcta en el DOM
                agregarActividadTabla(addBtn);
                return;
            }

            // Manejar clics en botones de eliminar actividad
            const delBtn = event.target.closest('button.eliminar-actividad');
            if (delBtn) {
                event.preventDefault();
                event.stopPropagation();
                const actividadId = delBtn.dataset.actividad;
                const semestreNum = delBtn.dataset.semestre;
                eliminarActividad(actividadId, semestreNum);
                return;
            }

            // Manejar clics en botones de eliminar etiquetas
            const removeTagBtn = event.target.closest('.remove-tag');
            if (removeTagBtn) {
                event.preventDefault();
                event.stopPropagation();
                const value = removeTagBtn.getAttribute('data-value');
                const checkbox = removeTagBtn.closest('.entregables-container').querySelector(`input[value="${value}"]`);
                if (checkbox) {
                    checkbox.checked = false;
                    // Disparar evento change manualmente
                    const event = new Event('change', { bubbles: true });
                    checkbox.dispatchEvent(event);
                }
                return;
            }
        });

        // Función para crear el selector de entregables
        function crearEntregablesSelector(semestreNum, actividadId) {
            const container = document.createElement('div');
            container.className = 'entregables-container';
            
            // Título para el selector de entregables (ahora es clickeable)
            const title = document.createElement('div');
            title.className = 'entregables-title';
            title.innerHTML = '<i class="fas fa-chevron-right"></i>Selecciona los entregables:';
            
            const counter = document.createElement('div');
            counter.className = 'entregables-counter';
            counter.textContent = 'No hay entregables seleccionados';
            
            // CONTENEDOR PRINCIPAL PARA ETIQUETAS VISIBLES
            const tagsContainer = document.createElement('div');
            tagsContainer.className = 'selected-tags-container';
            
            const dropdown = document.createElement('div');
            dropdown.className = 'entregables-dropdown';
            
            // Agrupar entregables por categoría
            const categorias = {
                'academicos': '📚 Productos Académicos',
                'acceso-universal': '🌐 Acceso Universal del Conocimiento',
                'formacion': '🎓 Formación de Capacidades',
                'infraestructura': '🏗️ Fortalecimiento de Infraestructura',
                'otros': '📦 Otros Entregables'
            };
            
            // Crear opciones por categoría
            Object.keys(categorias).forEach(categoria => {
                const group = document.createElement('div');
                group.className = 'entregable-group';
                
                const groupTitle = document.createElement('div');
                groupTitle.className = 'entregable-group-title';
                groupTitle.textContent = categorias[categoria];
                group.appendChild(groupTitle);
                
                entregables
                    .filter(entregable => entregable.category === categoria)
                    .forEach(entregable => {
                        const item = document.createElement('div');
                        item.className = 'entregable-item';
                        
                        const checkbox = document.createElement('input');
                        checkbox.type = 'checkbox';
                        checkbox.className = 'entregable-checkbox';
                        checkbox.name = `actividadEntregable${semestreNum}_${actividadId}[]`;
                        checkbox.value = entregable.value;
                        checkbox.id = `entregable_${semestreNum}_${actividadId}_${entregable.value}`;
                        
                        const label = document.createElement('label');
                        label.className = 'entregable-label';
                        label.htmlFor = checkbox.id;
                        label.textContent = entregable.text;
                        
                        // Event listener CORREGIDO para el checkbox
                        checkbox.addEventListener('change', function(e) {
                            e.stopPropagation();
                            updateSelectionState();
                        });
                        
                        // Prevenir doble clic en el item
                        item.addEventListener('click', function(e) {
                            if (e.target !== checkbox) {
                                e.preventDefault();
                                e.stopPropagation();
                                checkbox.checked = !checkbox.checked;
                                checkbox.dispatchEvent(new Event('change'));
                            }
                        });
                        
                        item.appendChild(checkbox);
                        item.appendChild(label);
                        group.appendChild(item);
                    });
                
                dropdown.appendChild(group);
            });
            
            // Función para actualizar el estado de selección
            function updateSelectionState() {
                const checkboxes = dropdown.querySelectorAll('input[type="checkbox"]');
                const selected = Array.from(checkboxes).filter(cb => cb.checked);
                
                // Actualizar contador
                if (selected.length > 0) {
                    counter.textContent = `${selected.length} entregable(s) seleccionado(s)`;
                    counter.classList.add('has-selection');
                } else {
                    counter.textContent = 'No hay entregables seleccionados';
                    counter.classList.remove('has-selection');
                }
                
                // Actualizar etiquetas visibles
                updateTags(selected);
            }
            
            // Función para actualizar las etiquetas visibles
            function updateTags(selectedCheckboxes) {
                // Limpiar el contenedor
                tagsContainer.innerHTML = '';
                
                // Crear contenedor para las etiquetas
                const tagsDiv = document.createElement('div');
                tagsDiv.className = 'selected-tags';
                
                if (selectedCheckboxes.length === 0) {
                    const emptyMsg = document.createElement('div');
                    emptyMsg.className = 'empty-selection';
                    emptyMsg.textContent = 'No hay entregables seleccionados';
                    tagsContainer.appendChild(emptyMsg);
                } else {
                    selectedCheckboxes.forEach(checkbox => {
                        const entregableValue = checkbox.value;
                        const entregable = entregables.find(e => e.value === entregableValue);
                        
                        if (entregable) {
                            const tag = document.createElement('div');
                            tag.className = 'selected-tag';

                            const textSpan = document.createElement('span');
                            textSpan.className = 'tag-text';
                            textSpan.textContent = entregable.text;

                            const removeBtn = document.createElement('span');
                            removeBtn.className = 'remove-tag';
                            removeBtn.setAttribute('data-value', entregableValue);
                            removeBtn.innerHTML = '<i class="fas fa-times"></i>';
                            removeBtn.addEventListener('click', function(e) {
                                e.stopPropagation();
                                const value = this.getAttribute('data-value');
                                const checkboxToUncheck = dropdown.querySelector(`input[value="${value}"]`);
                                if (checkboxToUncheck) {
                                    checkboxToUncheck.checked = false;
                                    checkboxToUncheck.dispatchEvent(new Event('change'));
                                }
                            });

                            tag.appendChild(textSpan);
                            tag.appendChild(removeBtn);
                            tagsDiv.appendChild(tag);
                        }
                    });
                    tagsContainer.appendChild(tagsDiv);
                }
            }
            
            // Event listener para el título (desplegar/contraer)
            title.addEventListener('click', function(e) {
                e.stopPropagation();
                const isExpanded = title.classList.contains('expanded');
                
                if (isExpanded) {
                    // Contraer
                    title.classList.remove('expanded');
                    dropdown.classList.remove('show');
                } else {
                    // Expandir
                    title.classList.add('expanded');
                    dropdown.classList.add('show');
                }
            });
            
            // Cerrar dropdown al hacer clic fuera
            document.addEventListener('click', function(e) {
                if (!container.contains(e.target)) {
                    title.classList.remove('expanded');
                    dropdown.classList.remove('show');
                }
            });
            
            // Agregar elementos en el orden correcto
            container.appendChild(title);
            container.appendChild(dropdown);
            container.appendChild(counter);
            container.appendChild(tagsContainer);
            
            // Inicializar el estado
            updateTags([]);
            
            return container;
        }

        // Función para agregar una actividad a la tabla
        function agregarActividadTabla(semestreSource) {
            // semestreSource puede ser el número de semestre o el botón que lo inició
            let semestreNum;
            let container;

            if (typeof semestreSource === 'string' || typeof semestreSource === 'number') {
                semestreNum = semestreSource;
                container = document.getElementById('actividadesTable' + semestreNum);
            } else if (semestreSource instanceof Element) {
                const boton = semestreSource;
                // Buscar la sección de semestre más cercana y obtener su número desde el badge o data
                const semestreSection = boton.closest('.semestre-section');
                if (semestreSection) {
                    // intentar extraer el número desde el texto del badge o del contenido del header
                    const badge = semestreSection.querySelector('.badge-semestre');
                    if (badge) {
                        const match = badge.textContent.match(/\d+/);
                        semestreNum = match ? match[0] : boton.dataset.semestre;
                    } else {
                        semestreNum = boton.dataset.semestre;
                    }
                    container = semestreSection.querySelector('#actividadesTable' + semestreNum);
                } else {
                    // fallback
                    semestreNum = boton.dataset.semestre;
                    container = document.getElementById('actividadesTable' + semestreNum);
                }
            }

            console.log('Agregando actividad para semestre (resolved):', semestreNum);
            const emptyRow = document.getElementById('emptyRow' + semestreNum);
            
            // Ocultar fila vacía si existe
            if (emptyRow) {
                emptyRow.style.display = 'none';
            }
            
            const actividadId = Date.now(); // ID único basado en timestamp
            
            const actividadRow = document.createElement('tr');
            actividadRow.id = 'actividad-' + actividadId;
            actividadRow.innerHTML = '<td>' +
                    '<input type="text" ' +
                           'name="actividadNombre' + semestreNum + '[]" ' +
                           'class="actividad-nombre-input"' +
                           'placeholder="Nombre de la actividad"' +
                           'required>' +
                '</td>' +
                '<td class="entregables-cell">' +
                    '<!-- El selector de entregables se agregará dinámicamente -->' +
                '</td>' +
                '<td>' +
                    '<button type="button" ' +
                            'class="eliminar-actividad btn-remove text-xs py-2 px-3 rounded flex items-center justify-center w-full"' +
                            'data-actividad="' + actividadId + '"' +
                            'data-semestre="' + semestreNum + '">' +
                        '<i class="fas fa-trash"></i>' +
                    '</button>' +
                '</td>';
            
            // Agregar el selector de entregables
            const tdEntregable = actividadRow.querySelector('td:nth-child(2)');
            const entregablesSelector = crearEntregablesSelector(semestreNum, actividadId);
            tdEntregable.appendChild(entregablesSelector);
            
            // Insertar la nueva fila AL FINAL del tbody
            if (container) {
                container.appendChild(actividadRow);
            } else {
                console.error('No se encontró el contenedor de actividades para el semestre:', semestreNum);
            }
        }

        // Función para eliminar una actividad
        function eliminarActividad(actividadId, semestreNum) {
            const actividadRow = document.getElementById('actividad-' + actividadId);
            if (actividadRow) {
                actividadRow.remove();

                // Mostrar fila vacía si no hay más actividades reales (filas con id actividad-...)
                const container = document.getElementById('actividadesTable' + semestreNum);
                const actividades = container.querySelectorAll('tr[id^="actividad-"]');
                if (actividades.length === 0) {
                    const emptyRow = document.getElementById('emptyRow' + semestreNum);
                    if (emptyRow) {
                        emptyRow.style.display = '';
                    }
                }
            }
        }

        // Función para mostrar mensaje temporal (igual que formulario 6)
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

        // Función para guardar borrador
        async function guardarBorrador(formId, pagina, button) {
            console.log('[cronograma] Iniciando guardado de borrador...');
            
            // Deshabilitar el botón y mostrar mensaje de "Guardando..."
            const originalText = button.innerHTML;
            button.disabled = true;
            button.innerHTML = '<i class="fas fa-spinner fa-spin mr-2"></i>Guardando...';
            
            // Pequeña pausa para que la UI se actualice
            await new Promise(resolve => setTimeout(resolve, 100));
            
            // Validar que cada semestre tenga al menos una actividad
            let semestresValidos = true;
            for (let i = 1; i <= 2; i++) {
                const actividades = document.querySelectorAll('#actividadesTable' + i + ' tr[id^="actividad-"]');
                if (actividades.length === 0) {
                    button.disabled = false;
                    button.innerHTML = originalText;
                    mostrarMensaje('El semestre ' + i + ' no tiene actividades. Por favor, agregue al menos una actividad.', 'error', button);
                    semestresValidos = false;
                    break;
                }
            }
            
            if (!semestresValidos) {
                console.error('[cronograma] ❌ Validación fallida: faltan actividades');
                return;
            }
            
            // Recopilar datos de semestres
            const semestres = [];
            
            for (let i = 1; i <= 2; i++) {
                console.log('\n[cronograma] ========== PROCESANDO SEMESTRE ' + i + ' ==========');
                
                const descripcion = document.getElementById('descripcionSemestre' + i)?.value || '';
                const meta = document.getElementById('metaSemestre' + i)?.value || '';
                
                console.log('[cronograma] Descripción S' + i + ': "' + descripcion + '"');
                console.log('[cronograma] Meta S' + i + ': "' + meta + '"');
                
                // Recopilar actividades de este semestre
                const selector = '#actividadesTable' + i + ' tr[id^="actividad-"]';
                console.log('[cronograma] Buscando con selector: "' + selector + '"');
                
                const actividadesRows = document.querySelectorAll(selector);
                console.log('[cronograma] Filas encontradas: ' + actividadesRows.length);
                
                const actividades = [];
                
                actividadesRows.forEach((row, index) => {
                    console.log('[cronograma] --- Procesando fila ' + (index + 1) + ' (ID: ' + row.id + ') ---');
                    
                    const nombreInput = row.querySelector('input[name^="actividadNombre"]');
                    const nombre = nombreInput?.value || '';
                    console.log('[cronograma]   Nombre: "' + nombre + '"');
                    
                    // Recopilar entregables seleccionados
                    const checkboxes = row.querySelectorAll('input[type="checkbox"]:checked');
                    console.log('[cronograma]   Checkboxes marcados: ' + checkboxes.length);
                    
                    const entregables = Array.from(checkboxes).map(cb => {
                        console.log('[cronograma]     - ' + cb.value);
                        return cb.value;
                    });
                    
                    if (nombre.trim() !== '') {
                        actividades.push({
                            nombre: nombre,
                            entregables: entregables
                        });
                        console.log('[cronograma]   ✓ Actividad agregada: "' + nombre + '" con ' + entregables.length + ' entregable(s)');
                    } else {
                        console.log('[cronograma]   ⚠ Actividad omitida (nombre vacío)');
                    }
                });
                
                semestres.push({
                    numero: i,
                    descripcion_semestre: descripcion,
                    meta_semestre: meta,
                    actividades: actividades
                });
                
                console.log('[cronograma] ========== SEMESTRE ' + i + ' COMPLETADO: ' + actividades.length + ' actividades ==========\n');
            }
            
            const jsonData = {
                cronograma: {
                    semestres: semestres
                }
            };
            
            console.log('[cronograma] JSON completo a guardar:', JSON.stringify(jsonData, null, 2));
            
            try {
                localStorage.setItem('proyecto_borrador_pagina7', JSON.stringify(jsonData));
                console.log('[cronograma] ✅ Borrador guardado exitosamente');
                
                // Pequeña pausa antes de verificar
                await new Promise(resolve => setTimeout(resolve, 50));
                
                // Verificación
                const verify = localStorage.getItem('proyecto_borrador_cronograma');
                if (verify) {
                    const parsed = JSON.parse(verify);
                    console.log('[cronograma] ✅ Verificación exitosa - datos recuperables');
                    console.log('[cronograma] Verificación - Total semestres:', parsed.cronograma.semestres.length);
                    parsed.cronograma.semestres.forEach(s => {
                        console.log(`[cronograma] Verificación - Semestre ${s.numero}: ${s.actividades.length} actividades`);
                    });
                } else {
                    console.error('[cronograma] ❌ Error: No se pudo verificar el guardado');
                }
                
                // Restaurar botón
                button.disabled = false;
                button.innerHTML = originalText;
                
                mostrarMensaje('Borrador guardado exitosamente', 'success', button);
            } catch (e) {
                console.error('[cronograma] ❌ Error al guardar borrador:', e);
                button.disabled = false;
                button.innerHTML = originalText;
                mostrarMensaje('Error al guardar el borrador', 'error', button);
            }
        }
        
        // Función para cargar borrador
        async function cargarBorrador() {
            console.log('[cronograma] 📥 Iniciando carga de borrador...');
            const savedData = localStorage.getItem('proyecto_borrador_pagina7');
            
            if (!savedData) {
                console.log('[cronograma] ℹ️ No hay borrador guardado');
                return;
            }
            
            try {
                const data = JSON.parse(savedData);
                console.log('[cronograma] 📦 Borrador encontrado:', data);
                
                if (data.cronograma && data.cronograma.semestres) {
                    console.log('[cronograma] Total de semestres a cargar:', data.cronograma.semestres.length);
                    
                    // Procesar semestres secuencialmente
                    for (const semestre of data.cronograma.semestres) {
                        const semestreNum = semestre.numero;
                        
                        console.log('\n[cronograma] ===== CARGANDO SEMESTRE', semestreNum, '=====');
                        
                        // Verificar que el elemento existe ANTES de intentar cargar
                        const containerCheck = document.getElementById('actividadesTable' + semestreNum);
                        if (!containerCheck) {
                            console.error('[cronograma] ERROR CRITICO: No existe #actividadesTable' + semestreNum + ' en el DOM');
                            continue;
                        }
                        console.log('[cronograma] Contenedor #actividadesTable' + semestreNum + ' encontrado');
                        
                        // Cargar descripción y meta
                        const descripcionEl = document.getElementById('descripcionSemestre' + semestreNum);
                        const metaEl = document.getElementById('metaSemestre' + semestreNum);
                        
                        if (descripcionEl) {
                            descripcionEl.value = semestre.descripcion_semestre || '';
                            console.log('[cronograma] Descripcion S' + semestreNum + ':', semestre.descripcion_semestre);
                        } else {
                            console.warn('[cronograma] No se encontro #descripcionSemestre' + semestreNum);
                        }
                        
                        if (metaEl) {
                            metaEl.value = semestre.meta_semestre || '';
                            console.log('[cronograma] Meta S' + semestreNum + ':', semestre.meta_semestre);
                        } else {
                            console.warn('[cronograma] No se encontro #metaSemestre' + semestreNum);
                        }
                        
                        // Cargar actividades secuencialmente
                        if (semestre.actividades && semestre.actividades.length > 0) {
                            console.log('[cronograma] Cargando', semestre.actividades.length, 'actividades para semestre', semestreNum);
                            
                            for (let i = 0; i < semestre.actividades.length; i++) {
                                const actividad = semestre.actividades[i];
                                console.log('\n[cronograma] Actividad', (i + 1), '/', semestre.actividades.length, 'del Semestre', semestreNum);
                                console.log('[cronograma]    Nombre:', actividad.nombre);
                                console.log('[cronograma]    Entregables:', actividad.entregables ? actividad.entregables.length : 0);
                                if (actividad.entregables) {
                                    console.log('[cronograma]    Lista:', actividad.entregables);
                                }
                                
                                // IMPORTANTE: Pasar el número de semestre como STRING explícito
                                console.log('[cronograma] Llamando agregarActividadTabla(' + semestreNum + ')');
                                agregarActividadTabla(String(semestreNum));
                                
                                // Esperar a que se agregue al DOM
                                await new Promise(resolve => setTimeout(resolve, 150));
                                
                                const container = document.getElementById('actividadesTable' + semestreNum);
                                if (!container) {
                                    console.error('[cronograma] Container desaparecio despues de agregar actividad');
                                    continue;
                                }
                                
                                const actividadesRows = container.querySelectorAll('tr[id^="actividad-"]');
                                console.log('[cronograma]    Filas totales en semestre', semestreNum, ':', actividadesRows.length);
                                
                                const lastRow = actividadesRows[actividadesRows.length - 1];
                                
                                if (lastRow) {
                                    console.log('[cronograma]    Ultima fila ID:', lastRow.id);
                                    
                                    // Cargar nombre de actividad
                                    const nombreInput = lastRow.querySelector('input[name^="actividadNombre"]');
                                    if (nombreInput && actividad.nombre) {
                                        nombreInput.value = actividad.nombre;
                                        console.log('[cronograma]    NOMBRE CARGADO:', actividad.nombre);
                                    } else {
                                        console.error('[cronograma]    No se encontro input de nombre o nombre vacio');
                                    }
                                    
                                    // Marcar los checkboxes de entregables seleccionados
                                    if (actividad.entregables && actividad.entregables.length > 0) {
                                        console.log('[cronograma]    Marcando', actividad.entregables.length, 'entregables');
                                        
                                        for (const entregableValue of actividad.entregables) {
                                            const checkbox = lastRow.querySelector('input[type="checkbox"][value="' + entregableValue + '"]');
                                            if (checkbox) {
                                                checkbox.checked = true;
                                                checkbox.dispatchEvent(new Event('change'));
                                                console.log('[cronograma]       MARCADO:', entregableValue);
                                            } else {
                                                console.warn('[cronograma]       NO ENCONTRADO:', entregableValue);
                                            }
                                        }
                                    }
                                } else {
                                    console.error('[cronograma]    No se encontro la ultima fila agregada');
                                }
                            }
                            
                            console.log('[cronograma] Semestre', semestreNum, 'completado:', semestre.actividades.length, 'actividades cargadas');
                        } else {
                            console.log('[cronograma] Semestre', semestreNum, 'no tiene actividades');
                        }
                    }
                    
                    console.log('\n[cronograma] 🎉 ===== CARGA COMPLETA ===== ');
                }
            } catch (error) {
                console.error('[cronograma] ❌ Error al cargar borrador:', error);
                console.error('[cronograma] Stack trace:', error.stack);
            }
        }

        // Generar 2 semestres por defecto al cargar la página
        document.addEventListener('DOMContentLoaded', async function() {
            console.log('[cronograma] Semestres estáticos cargados, iniciando carga de borrador...');
            // Cargar el borrador directamente, ya que las tablas existen
            await cargarBorrador();

            // CONTROL DE NAVEGACIÓN (igual que formulario 6)
            const KEY = 'proyecto_borrador_pagina7_saved';
            const buttons = Array.from(document.querySelectorAll('button'));
            const guardarBtn = buttons.find(b => (b.getAttribute('onclick')||'').includes('guardarBorrador') || /guardar borrador/i.test(b.textContent));
            const siguienteBtn = document.getElementById('btnSiguiente');

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
                console.warn('No se encontraron botones Guardar/Siguiente en cronograma');
                return;
            }

            // Estado inicial desde localStorage
            let saved = localStorage.getItem(KEY) === '1';
            setDisabled(siguienteBtn, !saved);

            // Cuando se pulsa guardar, marcar y habilitar siguiente
            guardarBtn.addEventListener('click', function(){
                // El guardado se hace en guardarBorrador(), aquí solo marcamos después
                setTimeout(() => {
                    // Verificar si el guardado fue exitoso
                    const verify = localStorage.getItem('proyecto_borrador_pagina7');
                    if (verify) {
                        localStorage.setItem(KEY,'1');
                        saved = true;
                        setDisabled(siguienteBtn, false);
                        console.log('Borrador cronograma guardado -> Siguiente habilitado');
                    }
                }, 100);
            });

            // Agregar evento al botón siguiente para manejar navegación y advertencias
            siguienteBtn.addEventListener('click', function(e){
                e.preventDefault();
                e.stopPropagation();

                // Verificar si está "deshabilitado" (visualmente)
                if(siguienteBtn.getAttribute('data-disabled') === 'true'){
                    mostrarMensaje('Debe guardar el borrador antes de continuar', 'error', siguienteBtn);
                    return false;
                }

                // Si está habilitado, navegar a la siguiente página
                window.location.href = '/proyectos/pages/responsableDeproyecto/registroProyecto/registroProyecto8.jsp';
            });

            // Si el formulario cambia después de guardar, volver a marcar como no guardado y bloquear
            const semestresContainer = document.getElementById('semestresContainer');
            if(semestresContainer){
                // Observar cambios en inputs, textareas y checkboxes
                semestresContainer.addEventListener('input', function(){
                    if(saved){
                        saved = false;
                        localStorage.setItem(KEY,'0');
                        setDisabled(siguienteBtn, true);
                        console.log('Formulario cronograma modificado después de guardar: Siguiente bloqueado.');
                    }
                });

                semestresContainer.addEventListener('change', function(){
                    if(saved){
                        saved = false;
                        localStorage.setItem(KEY,'0');
                        setDisabled(siguienteBtn, true);
                        console.log('Formulario cronograma modificado después de guardar: Siguiente bloqueado.');
                    }
                });

                // Advertir al usuario si intenta abandonar la página con cambios no guardados
                window.addEventListener('beforeunload', function(e){
                    try{
                        if(!saved){
                            var msg = 'Tiene cambios sin guardar. ¿Desea salir sin guardar?';
                            e.preventDefault(); 
                            e.returnValue = msg; 
                            return msg;
                        }
                    }catch(err){ 
                        return undefined; 
                    }
                });
            }
        });
    </script>
</body>
</html>
