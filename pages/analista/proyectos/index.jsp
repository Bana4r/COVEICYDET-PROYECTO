<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Properties" %>
<% if (!"analista".equals(String.valueOf(session.getAttribute("rol")))) { String n=request.getRequestURI()+(request.getQueryString()!=null?("?"+request.getQueryString()):"");
response.sendRedirect(request.getContextPath()+"/pages/login/login.jsp?next="+java.net.URLEncoder.encode(n,"UTF-8")); return; } %>

<%@ include file="/WEB-INF/conexion.jsp" %>

<% 
    // Listas para los filtros (se llenarán dinámicamente)
    Set<String> convocatoriasSet = new HashSet<>();
    Set<String> institucionesSet = new HashSet<>();
    Set<String> estadosSet = new HashSet<>();

    List<Map<String, Object>> proyectosList = new ArrayList<>();
    String mensajeError = null;

    try {
        // Usar la conexión proporcionada por conexion.jsp
        if (conn == null) {
            throw new Exception("No se pudo establecer conexión con la base de datos. " + dbError);
        }
            // Consulta mejorada para traer más campos
            String sql = "SELECT " +
                       "p.id_proyecto, " +
                       "p.titulo, " +
                       "p.estado_proyecto, " +
                       "p.fecha_creacion, " +
                       "p.institucion_proponente, " +
                       "p.area_conocimiento, " +
                       "p.sector_impacto_proyecto, " +
                       "p.nivel_tlr, " +
                       "p.nivel_slr, " +
                       "p.resumen_ejecutivo, " +
                       "p.doc_extenso, " +
                       "c.nombre_convocatoria, " +
                       "u.nombre, " +
                       "u.primer_apellido, " +
                       "u.segundo_apellido, " +
                       "u.correo_electronico " +
                       "FROM Proyectos p " +
                       "LEFT JOIN proyecto_usuarios pu ON p.id_proyecto = pu.id_proyecto " +
                       "LEFT JOIN usuarios u ON pu.id_usuario = u.id_usuario " +
                       "LEFT JOIN convocatoria c ON p.convocatoria_id = c.id_convocatoria " +
                       "ORDER BY p.fecha_creacion DESC";

            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                try (ResultSet rs = stmt.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> p = new HashMap<>();
                        p.put("id", rs.getString("id_proyecto") != null ? rs.getString("id_proyecto") : "???"); // Formato ID visual
                        p.put("titulo", rs.getString("titulo"));
                        
                        // Mapeo de estado para el frontend
                        String estadoBD = rs.getString("estado_proyecto");
                        String estadoFrontend = "Pendiente"; // Default
                        
                        // Lógica de mapeo simplificada para la UI
                        if (estadoBD != null) {
                            String e = estadoBD.toLowerCase().trim();
                            
                            // Finalizados (Separado de Aprobados)
                            if (e.equals("finalizado") || e.equals("completado") || e.equals("19")) {
                                estadoFrontend = "Finalizado";
                            }
                            // Aprobados
                            else if (e.equals("aprobado") || e.equals("7")) {
                                estadoFrontend = "Aprobado";
                            }
                            // Rechazados
                            else if (e.equals("rechazado") || e.equals("-1")) {
                                estadoFrontend = "Rechazado";
                            }
                            // En revisión / Proceso
                            else if (e.contains("revision") || e.contains("evaluacion") || e.contains("proceso") || 
                                     e.equals("3") || e.equals("4") || e.equals("5") || e.equals("6") || e.equals("en_revision")) {
                                estadoFrontend = "En Revisión";
                            }
                            // Borradores / Enviados / Pendientes
                            else if (e.equals("borrador") || e.equals("enviado") || e.equals("1") || e.equals("2")) {
                                estadoFrontend = "Pendiente";
                            }
                            // Fallback para debug: Si no cae en ninguno, mostrar el valor original (para saber qué es)
                            else {
                                estadoFrontend = estadoBD + " (?)"; 
                            }
                        }
                        p.put("estado", estadoFrontend);
                        estadosSet.add(estadoFrontend); // Agregar al set de filtros

                        // Fecha
                        Timestamp ts = rs.getTimestamp("fecha_creacion");
                        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
                        p.put("fecha", ts != null ? sdf.format(ts) : "");

                        // Otros campos
                        String inst = rs.getString("institucion_proponente");
                        p.put("institucion", inst != null ? inst : "No especificada");
                        if (inst != null && !inst.isEmpty()) institucionesSet.add(inst);

                        String conv = rs.getString("nombre_convocatoria");
                        p.put("convocatoria", conv != null ? conv : "Sin convocatoria");
                        if (conv != null && !conv.isEmpty()) convocatoriasSet.add(conv);

                        p.put("area", rs.getString("area_conocimiento") != null ? rs.getString("area_conocimiento") : "No especificada");
                        p.put("sector", rs.getString("sector_impacto_proyecto") != null ? rs.getString("sector_impacto_proyecto") : "No especificado");
                        p.put("tlr", rs.getString("nivel_tlr") != null ? rs.getString("nivel_tlr") : "N/A");
                        p.put("slr", rs.getString("nivel_slr") != null ? rs.getString("nivel_slr") : "N/A");
                        
                        String resumen = rs.getString("resumen_ejecutivo");
                        p.put("resumen", resumen != null ? resumen.replaceAll("[\"']", "") : "Sin resumen disponible"); // Limpiar comillas para JS

                        // Responsable
                        String nombreUsr = rs.getString("nombre");
                        String ape1 = rs.getString("primer_apellido");
                        String ape2 = rs.getString("segundo_apellido");
                        String nombreCompleto = (nombreUsr != null ? nombreUsr : "") + " " + 
                                              (ape1 != null ? ape1 : "") + " " + 
                                              (ape2 != null ? ape2 : "");
                        p.put("responsable", nombreCompleto.trim().isEmpty() ? "Sin asignar" : nombreCompleto.trim());
                        p.put("email", rs.getString("correo_electronico") != null ? rs.getString("correo_electronico") : "");
                        p.put("telefono", "No disponible"); // No está en la consulta actual
                        p.put("doc_extenso", rs.getString("doc_extenso") != null ? rs.getString("doc_extenso") : ""); // Nombre del documento extenso

                        proyectosList.add(p);
                    }
                }
            }
    } catch (Exception e) {
        mensajeError = e.getMessage();
        e.printStackTrace();
    } finally {
        // Cerrar la conexión proporcionada por conexion.jsp
        if (conn != null) {
            try { conn.close(); } catch (SQLException e) { /* ignorar */ }
        }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panel del Analista</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --primary: #7A1737;
            --primary-light: #A8253C;
            --secondary: #B28854;
            --secondary-light: #d4b683;
        }
        
        .status-badge {
            padding: 0.25rem 0.75rem;
            border-radius: 9999px;
            font-size: 0.75rem;
            font-weight: 600;
        }
        
        .status-pendiente { background-color: #fef3c7; color: #92400e; }
        .status-revision { background-color: #dbeafe; color: #1e40af; }
        .status-aprobado { background-color: #d1fae5; color: #065f46; }
        .status-rechazado { background-color: #fee2e2; color: #991b1b; }
        .status-finalizado { background-color: #e0e7ff; color: #3730a3; }
        
        .filter-card {
            transition: all 0.3s ease;
        }
        
        .filter-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }
        
        .project-card {
            transition: all 0.3s ease;
            border-left: 4px solid transparent;
        }
        
        .project-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(0, 0, 0, 0.1);
            border-left-color: var(--primary);
        }
        
        .btn-primary {
            background: linear-gradient(90deg, var(--primary) 0%, var(--primary-light) 100%);
            color: white;
            transition: all 0.3s;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 15px rgba(122, 23, 55, 0.3);
        }
        
        .btn-secondary {
            background: linear-gradient(90deg, var(--secondary) 0%, var(--secondary-light) 100%);
            color: white;
            transition: all 0.3s;
        }
        
        .btn-secondary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 15px rgba(178, 136, 84, 0.3);
        }
        
        .stat-card {
            background: white;
            border-radius: 12px;
            padding: 1.5rem;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            transition: all 0.3s;
        }
        
        .stat-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.1);
        }
        
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.8);
            z-index: 1000;
            align-items: center;
            justify-content: center;
        }
        
        .modal-content {
            background: white;
            border-radius: 12px;
            width: 90%;
            max-width: 800px;
            max-height: 90vh;
            overflow-y: auto;
        }
        
        /* Animaciones */
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .fade-in {
            animation: fadeIn 0.3s ease-out;
        }
    </style>
</head>
<body class="bg-gray-50 min-h-screen">
    <%@ include file="../header.jsp" %>

    <!-- Filtros de búsqueda -->
    <div class="container mx-auto px-4 py-6">
        <% if (mensajeError != null) { %>
            <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mb-4" role="alert">
                <strong class="font-bold">Error:</strong>
                <span class="block sm:inline"><%= mensajeError %></span>
            </div>
        <% } %>

        <div class="filter-card bg-white rounded-xl shadow-md p-6 mb-6 fade-in">
            <h2 class="text-lg font-semibold text-gray-800 mb-4 flex items-center">
                <i class="fas fa-filter mr-2 text-[#7A1737]"></i> Filtros de Búsqueda
            </h2>
            
            <div class="space-y-4">
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                    <!-- Búsqueda general -->
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">
                            <i class="fas fa-search mr-1"></i> Búsqueda general
                        </label>
                        <input type="text" id="busqueda" 
                               class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#7A1737] focus:border-transparent"
                               placeholder="Buscar por título, resumen o institución...">
                    </div>
                    
                    <!-- Filtro por convocatoria -->
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">
                            <i class="fas fa-calendar mr-1"></i> Convocatoria
                        </label>
                        <select id="convocatoria" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#7A1737] focus:border-transparent">
                            <option value="">Todas las convocatorias</option>
                            <% for (String c : convocatoriasSet) { %>
                                <option value="<%= c %>"><%= c %></option>
                            <% } %>
                        </select>
                    </div>
                    
                    <!-- Filtro por institución -->
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">
                            <i class="fas fa-university mr-1"></i> Institución
                        </label>
                        <select id="institucion" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#7A1737] focus:border-transparent">
                            <option value="">Todas las instituciones</option>
                            <% for (String i : institucionesSet) { %>
                                <option value="<%= i %>"><%= i %></option>
                            <% } %>
                        </select>
                    </div>
                </div>
                
                <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <!-- Filtro por estado -->
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">
                            <i class="fas fa-tasks mr-1"></i> Estado del Proyecto
                        </label>
                        <select id="estado" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#7A1737] focus:border-transparent">
                            <% for (String e : estadosSet) { %>
                                <option value="<%= e %>"><%= e %></option>
                            <% } %>
                            <option value="">Todos los estados</option>
                        </select>
                    </div>
                    
                    <!-- Botones de acción -->
                    <div class="md:col-span-2 flex items-end space-x-3">
                        <button onclick="filtrarProyectos()" class="btn-primary px-6 py-2 rounded-lg font-semibold flex items-center">
                            <i class="fas fa-filter mr-2"></i> Aplicar Filtros
                        </button>
                        <button onclick="limpiarFiltros()" class="bg-gray-200 hover:bg-gray-300 text-gray-800 px-6 py-2 rounded-lg font-semibold flex items-center transition">
                            <i class="fas fa-redo mr-2"></i> Limpiar Filtros
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Estadísticas rápidas -->
        <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
            <div class="stat-card fade-in">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-sm text-gray-500">Total Proyectos</p>
                        <p class="text-2xl font-bold text-gray-800" id="total-proyectos">0</p>
                    </div>
                    <div class="bg-blue-100 p-3 rounded-lg">
                        <i class="fas fa-project-diagram text-blue-600 text-xl"></i>
                    </div>
                </div>
            </div>
            
            <div class="stat-card fade-in">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-sm text-gray-500">En Revisión</p>
                        <p class="text-2xl font-bold text-yellow-600" id="en-revision">0</p>
                    </div>
                    <div class="bg-yellow-100 p-3 rounded-lg">
                        <i class="fas fa-clock text-yellow-600 text-xl"></i>
                    </div>
                </div>
            </div>
            
            <div class="stat-card fade-in">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-sm text-gray-500">Aprobados</p>
                        <p class="text-2xl font-bold text-green-600" id="aprobados">0</p>
                    </div>
                    <div class="bg-green-100 p-3 rounded-lg">
                        <i class="fas fa-check-circle text-green-600 text-xl"></i>
                    </div>
                </div>
            </div>
            
            <div class="stat-card fade-in">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-sm text-gray-500">Convocatorias</p>
                        <p class="text-2xl font-bold text-purple-600"><%= convocatoriasSet.size() %></p>
                    </div>
                    <div class="bg-purple-100 p-3 rounded-lg">
                        <i class="fas fa-calendar-alt text-purple-600 text-xl"></i>
                    </div>
                </div>
            </div>
        </div>

        <!-- Lista de proyectos -->
        <div class="bg-white rounded-xl shadow-md overflow-hidden fade-in">
            <div class="px-6 py-4 border-b border-gray-200 flex justify-between items-center">
                <h2 class="text-lg font-semibold text-gray-800">
                    <i class="fas fa-list mr-2 text-[#7A1737]"></i> 
                    Proyectos Encontrados (<span id="resultados-count">0</span>)
                </h2>
                <div class="flex items-center space-x-4">
                    <a href="archivoXls.jsp" class="inline-flex items-center bg-[#B28854] hover:bg-[#9A7148] text-white px-4 py-2 rounded-lg font-medium transition duration-200">
                        <i class="fas fa-file-excel mr-2"></i>
                        Descargar Excel
                    </a>
                    <div class="text-sm text-gray-500">
                        <button onclick="toggleVista()" class="flex items-center space-x-1 text-[#7A1737] hover:text-[#A8253C]">
                            <i class="fas fa-th" id="vista-icon"></i>
                            <span id="vista-text">Vista cuadrícula</span>
                        </button>
                    </div>
                </div>
            </div>
            
            <!-- Vista tabla -->
            <div id="vista-tabla" class="overflow-x-auto">
                <table class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-gray-50">
                        <tr>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider w-2/5">Título del Proyecto</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider w-1/6">Institución</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider w-1/6">Convocatoria</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Estado</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Fecha</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Acciones</th>
                        </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-200" id="tabla-proyectos">
                        <!-- Los proyectos se cargan dinámicamente aquí -->
                    </tbody>
                </table>
            </div>
            
            <!-- Vista cuadrícula -->
            <div id="vista-cuadricula" class="hidden p-6">
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6" id="grid-proyectos">
                    <!-- Los proyectos en vista cuadrícula se cargan aquí -->
                </div>
            </div>
            
            <!-- Paginación -->
            <div class="px-6 py-4 border-t border-gray-200 flex items-center justify-between">
                <div class="text-sm text-gray-500">
                    Mostrando <span id="mostrando-desde">0</span> a <span id="mostrando-hasta">0</span> de <span id="total-proyectos-pag">0</span> resultados
                </div>
                <div class="flex space-x-2">
                    <button onclick="cambiarPagina(-1)" class="px-3 py-1 border border-gray-300 rounded-md text-sm text-gray-700 hover:bg-gray-50">
                        <i class="fas fa-chevron-left"></i>
                    </button>
                    <span class="px-3 py-1 text-sm text-gray-700">Página <span id="pagina-actual">1</span></span>
                    <button onclick="cambiarPagina(1)" class="px-3 py-1 border border-gray-300 rounded-md text-sm text-gray-700 hover:bg-gray-50">
                        <i class="fas fa-chevron-right"></i>
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal de detalles rápidos -->
    <div id="modal-detalles" class="modal">
        <div class="modal-content">
            <div class="bg-gradient-to-r from-[#7A1737] to-[#A8253C] text-white p-4 rounded-t-lg flex justify-between items-center">
                <h3 class="font-bold text-lg" id="modal-titulo">Detalles del Proyecto</h3>
                <button onclick="cerrarModal()" class="text-white hover:text-gray-200">
                    <i class="fas fa-times text-xl"></i>
                </button>
            </div>
            <div class="p-6" id="modal-contenido">
                <!-- Contenido dinámico -->
            </div>
        </div>
    </div>
        
    </div>
    <%@ include file="/footer.jsp" %>

    <script>
        // Datos de proyectos inyectados desde JSP
        const proyectos = [
            <% 
            for (int i = 0; i < proyectosList.size(); i++) {
                Map<String, Object> p = proyectosList.get(i);
            %>
            {
                id: "<%= p.get("id") %>",
                titulo: `<%= p.get("titulo") %>`,
                fecha: "<%= p.get("fecha") %>",
                estado: "<%= p.get("estado") %>",
                institucion: `<%= p.get("institucion") %>`,
                area: `<%= p.get("area") %>`,
                convocatoria: `<%= p.get("convocatoria") %>`,
                sector: `<%= p.get("sector") %>`,
                tlr: "<%= p.get("tlr") %>",
                slr: "<%= p.get("slr") %>",
                resumen: `<%= p.get("resumen") %>`,
                responsable: `<%= p.get("responsable") %>`,
                email: "<%= p.get("email") %>",
                telefono: "<%= p.get("telefono") %>",
                doc_extenso: "<%= p.get("doc_extenso") %>"
            }<%= i < proyectosList.size() - 1 ? "," : "" %>
            <% } %>
        ];

        // Variables de estado
        let proyectosFiltrados = [...proyectos];
        let paginaActual = 1;
        let proyectosPorPagina = 5;
        let vistaActual = 'tabla'; // 'tabla' o 'cuadricula'

        // Inicializar la página
        document.addEventListener('DOMContentLoaded', function() {
            cargarProyectos();
            actualizarEstadisticas();
            actualizarPaginacion();
        });

        // Función para cargar proyectos
        function cargarProyectos() {
            const tablaBody = document.getElementById('tabla-proyectos');
            const gridContainer = document.getElementById('grid-proyectos');
            
            // Calcular índices para paginación
            const inicio = (paginaActual - 1) * proyectosPorPagina;
            const fin = inicio + proyectosPorPagina;
            const proyectosPagina = proyectosFiltrados.slice(inicio, fin);
            
            // Limpiar contenedores
            tablaBody.innerHTML = '';
            gridContainer.innerHTML = '';
            
            if (proyectosPagina.length === 0) {
                tablaBody.innerHTML = '<tr><td colspan="7" class="px-6 py-4 text-center text-gray-500">No se encontraron proyectos</td></tr>';
                gridContainer.innerHTML = '<div class="col-span-3 text-center text-gray-500">No se encontraron proyectos</div>';
                document.getElementById('resultados-count').textContent = 0;
                return;
            }

            // Cargar en tabla
            proyectosPagina.forEach(proyecto => {
                const fila = document.createElement('tr');
                fila.className = 'project-card hover:bg-gray-50';
                fila.innerHTML = `
                    <td class="px-6 py-4 whitespace-nowrap">
                        <div class="text-sm font-medium text-[#7A1737]">
\${proyecto.id}</div>
                    </td>
                    <td class="px-6 py-4">
                        <div class="text-sm font-semibold text-gray-900">
\${proyecto.titulo}</div>
                        <div class="text-sm text-gray-500">
\${proyecto.resumen.substring(0, 60)}...</div>
                    </td>
                    <td class="px-6 py-4">
                        <div class="text-sm text-gray-900">
\${proyecto.institucion}</div>
                    </td>
                    <td class="px-6 py-4">
                        <div class="text-sm text-gray-900">
\${proyecto.convocatoria}</div>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap">
                        <span class="status-badge 
\${getClaseEstado(proyecto.estado)}">
\${proyecto.estado}</span>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        
\${proyecto.fecha}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                        <button onclick="verDetalles('\${proyecto.id}')" class="text-[#7A1737] hover:text-[#A8253C] mr-3" title="Ver Detalles">
                            <i class="fas fa-eye"></i>
                        </button>
                        <button onclick="descargarProyecto('\${proyecto.id}')" class="text-[#B28854] hover:text-[#d4b683] mr-3" title="Descargar">
                            <i class="fas fa-download"></i>
                        </button>
                    </td>
                `;
                tablaBody.appendChild(fila);
            });
            
            // Cargar en cuadrícula
            proyectosPagina.forEach(proyecto => {
                const card = document.createElement('div');
                card.className = 'project-card bg-white rounded-lg shadow-md overflow-hidden border border-gray-200';
                card.innerHTML = `
                    <div class="p-5">
                        <div class="flex justify-between items-start mb-3">
                            <div>
                                <span class="text-xs font-semibold text-[#7A1737]">
\${proyecto.id}</span>
                                <h3 class="font-bold text-gray-800 text-sm mt-1">
\${proyecto.titulo}</h3>
                            </div>
                            <span class="status-badge 
\${getClaseEstado(proyecto.estado)} text-xs">
\${proyecto.estado}</span>
                        </div>
                        
                        <p class="text-gray-600 text-sm mb-4">
\${proyecto.resumen.substring(0, 100)}...</p>
                        
                        <div class="space-y-2 text-xs text-gray-500 mb-4">
                            <div class="flex items-center">
                                <i class="fas fa-university mr-2 w-4"></i>
                                <span>
\${proyecto.institucion}</span>
                            </div>
                            <div class="flex items-center">
                                <i class="fas fa-calendar mr-2 w-4"></i>
                                <span>
\${proyecto.convocatoria}</span>
                            </div>
                            <div class="flex items-center">
                                <i class="fas fa-user-tie mr-2 w-4"></i>
                                <span>
\${proyecto.responsable}</span>
                            </div>
                        </div>
                        
                        <div class="flex justify-between items-center">
                            <div>
                                <span class="text-xs text-gray-500">
\${proyecto.fecha}</span>
                            </div>
                            <div class="flex space-x-2">
                                <button onclick="verDetalles('\${proyecto.id}')" class="text-[#7A1737] hover:text-[#A8253C] text-sm">
                                    <i class="fas fa-eye"></i>
                                </button>
                                <button onclick="descargarProyecto('\${proyecto.id}')" class="text-[#B28854] hover:text-[#d4b683] text-sm">
                                    <i class="fas fa-download"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                `;
                gridContainer.appendChild(card);
            });
            
            // Actualizar contadores
            document.getElementById('resultados-count').textContent = proyectosFiltrados.length;
        }

        // Función para obtener clase CSS según estado
        function getClaseEstado(estado) {
            switch(estado) {
                case 'Pendiente': return 'status-pendiente';
                case 'En Revisión': return 'status-revision';
                case 'Aprobado': return 'status-aprobado';
                case 'Rechazado': return 'status-rechazado';
                case 'Finalizado': return 'status-finalizado';
                default: return 'status-pendiente';
            }
        }

        // Función para filtrar proyectos
        function filtrarProyectos() {
            const busqueda = document.getElementById('busqueda').value.toLowerCase();
            const convocatoria = document.getElementById('convocatoria').value;
            const institucion = document.getElementById('institucion').value;
            const estado = document.getElementById('estado').value;
            
            proyectosFiltrados = proyectos.filter(proyecto => {
                // Filtro por búsqueda general
                if (busqueda && 
                    !proyecto.titulo.toLowerCase().includes(busqueda) &&
                    !proyecto.resumen.toLowerCase().includes(busqueda) &&
                    !proyecto.institucion.toLowerCase().includes(busqueda) &&
                    !proyecto.responsable.toLowerCase().includes(busqueda)) {
                    return false;
                }
                
                // Filtro por convocatoria
                if (convocatoria && proyecto.convocatoria !== convocatoria) {
                    return false;
                }
                
                // Filtro por institución
                if (institucion && proyecto.institucion !== institucion) {
                    return false;
                }
                
                // Filtro por estado
                if (estado && proyecto.estado !== estado) {
                    return false;
                }
                
                return true;
            });
            
            paginaActual = 1;
            cargarProyectos();
            actualizarEstadisticas();
            actualizarPaginacion();
        }

        // Función para limpiar filtros
        function limpiarFiltros() {
            document.getElementById('busqueda').value = '';
            document.getElementById('convocatoria').value = '';
            document.getElementById('institucion').value = '';
            document.getElementById('estado').value = '';
            
            proyectosFiltrados = [...proyectos];
            paginaActual = 1;
            cargarProyectos();
            actualizarEstadisticas();
            actualizarPaginacion();
        }

        // Función para actualizar estadísticas
        function actualizarEstadisticas() {
            const totalProyectos = proyectosFiltrados.length;
            const enRevision = proyectosFiltrados.filter(p => p.estado === 'En Revisión').length;
            const aprobados = proyectosFiltrados.filter(p => p.estado === 'Aprobado').length;
            
            document.getElementById('total-proyectos').textContent = totalProyectos;
            document.getElementById('en-revision').textContent = enRevision;
            document.getElementById('aprobados').textContent = aprobados;
        }

        // Función para actualizar paginación
        function actualizarPaginacion() {
            const totalProyectos = proyectosFiltrados.length;
            if (totalProyectos === 0) {
                 document.getElementById('mostrando-desde').textContent = 0;
                 document.getElementById('mostrando-hasta').textContent = 0;
                 document.getElementById('total-proyectos-pag').textContent = 0;
                 document.getElementById('pagina-actual').textContent = 1;
                 return;
            }

            const inicio = (paginaActual - 1) * proyectosPorPagina + 1;
            const fin = Math.min(paginaActual * proyectosPorPagina, totalProyectos);
            const totalPaginas = Math.ceil(totalProyectos / proyectosPorPagina);
            
            document.getElementById('mostrando-desde').textContent = inicio;
            document.getElementById('mostrando-hasta').textContent = fin;
            document.getElementById('total-proyectos-pag').textContent = totalProyectos;
            document.getElementById('pagina-actual').textContent = paginaActual;
            
            // Ocultar/mostrar botones de paginación según sea necesario
            const botonAnterior = document.querySelector('button[onclick="cambiarPagina(-1)"]');
            const botonSiguiente = document.querySelector('button[onclick="cambiarPagina(1)"]');
            
            if (paginaActual === 1) {
                botonAnterior.disabled = true;
                botonAnterior.classList.add('opacity-50', 'cursor-not-allowed');
            } else {
                botonAnterior.disabled = false;
                botonAnterior.classList.remove('opacity-50', 'cursor-not-allowed');
            }
            
            if (paginaActual === totalPaginas || totalPaginas === 0) {
                botonSiguiente.disabled = true;
                botonSiguiente.classList.add('opacity-50', 'cursor-not-allowed');
            } else {
                botonSiguiente.disabled = false;
                botonSiguiente.classList.remove('opacity-50', 'cursor-not-allowed');
            }
        }

        // Función para cambiar página
        function cambiarPagina(direccion) {
            const totalPaginas = Math.ceil(proyectosFiltrados.length / proyectosPorPagina);
            const nuevaPagina = paginaActual + direccion;
            
            if (nuevaPagina >= 1 && nuevaPagina <= totalPaginas) {
                paginaActual = nuevaPagina;
                cargarProyectos();
                actualizarPaginacion();
                
                // Scroll suave hacia arriba
                window.scrollTo({
                    top: document.querySelector('.bg-white.rounded-xl.shadow-md').offsetTop - 20,
                    behavior: 'smooth'
                });
            }
        }

        // Función para ver detalles del proyecto
        function verDetalles(idProyecto) {
            const proyecto = proyectos.find(p => p.id === idProyecto);
            if (!proyecto) return;
            
            document.getElementById('modal-titulo').textContent = `Proyecto: 
\${proyecto.id}`;
            
            const contenido = `
                <div class="space-y-4">
                    <div class="bg-gray-50 p-4 rounded-lg">
                        <h4 class="font-semibold text-gray-800 mb-2">
\${proyecto.titulo}</h4>
                        <p class="text-gray-600 text-sm">
\${proyecto.resumen}</p>
                    </div>
                    
                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <p class="text-xs text-gray-500">Institución</p>
                            <p class="font-medium">
\${proyecto.institucion}</p>
                        </div>
                        <div>
                            <p class="text-xs text-gray-500">Convocatoria</p>
                            <p class="font-medium">
\${proyecto.convocatoria}</p>
                        </div>
                        <div>
                            <p class="text-xs text-gray-500">Área</p>
                            <p class="font-medium">
\${proyecto.area}</p>
                        </div>
                        <div>
                            <p class="text-xs text-gray-500">Sector</p>
                            <p class="font-medium">
\${proyecto.sector}</p>
                        </div>
                        <div>
                            <p class="text-xs text-gray-500">TLR</p>
                            <p class="font-medium">
\${proyecto.tlr}</p>
                        </div>
                        <div>
                            <p class="text-xs text-gray-500">SLR</p>
                            <p class="font-medium">
\${proyecto.slr}</p>
                        </div>
                    </div>
                    
                    <div class="border-t pt-4">
                        <h5 class="font-semibold text-gray-800 mb-2">Responsable</h5>
                        <div class="flex items-center space-x-3">
                            <div class="bg-[#7A1737] text-white p-2 rounded-full">
                                <i class="fas fa-user"></i>
                            </div>
                            <div>
                                <p class="font-medium">
\${proyecto.responsable}</p>
                                <p class="text-sm text-gray-600">
\${proyecto.email}</p>
                                <p class="text-sm text-gray-600">
\${proyecto.telefono}</p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="border-t pt-4 mt-4">
                        <div class="flex justify-between items-center">
                            <div>
                                <p class="text-xs text-gray-500">Estado Actual</p>
                                <span class="status-badge 
\${getClaseEstado(proyecto.estado)}">
\${proyecto.estado}</span>
                            </div>
                            <div class="text-right">
                                <p class="text-xs text-gray-500">Fecha de registro</p>
                                <p class="font-medium">
\${proyecto.fecha}</p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="border-t pt-4">
                        <h5 class="font-semibold text-gray-800 mb-3">Acciones disponibles</h5>
                        <div class="grid grid-cols-1 gap-3">
                            <a href="/proyectos/pages/analista/infoProyecto/infoProyecto.jsp?id=\${proyecto.id}" 
                               class="bg-[#7A1737] text-white py-3 px-4 rounded-lg text-center hover:bg-[#A8253C] transition flex items-center justify-center">
                                <i class="fas fa-external-link-alt mr-2"></i>
                                Ver información completa del proyecto
                            </a>
                        </div>
                    </div>
                </div>
            `;
            
            document.getElementById('modal-contenido').innerHTML = contenido;
            document.getElementById('modal-detalles').style.display = 'flex';
        }

        // Función para cerrar modal
        function cerrarModal() {
            document.getElementById('modal-detalles').style.display = 'none';
        }

        // Función para descargar proyecto
        function descargarProyecto(idProyecto) {
            const proyecto = proyectos.find(p => p.id === idProyecto);
            
            if (!proyecto) {
                mostrarNotificacion('Proyecto no encontrado', 'error');
                return;
            }
            
            const docExtenso = proyecto.doc_extenso;

            if (!docExtenso || docExtenso.trim() === '' || docExtenso === 'null') {
                mostrarNotificacion('El documento no está disponible para descarga.', 'info');
                return;
            }

            const contextPath = '<%= request.getContextPath() %>';
            let rutaDescarga = '';
            
            // Construir la ruta completa
            if (docExtenso.startsWith('http')) {
                rutaDescarga = docExtenso;
            } else if (docExtenso.startsWith(contextPath)) {
                rutaDescarga = docExtenso;
            } else {
                rutaDescarga = contextPath + (docExtenso.startsWith('/') ? '' : '/') + docExtenso;
            }

            mostrarNotificacion(`Iniciando descarga del documento extenso con id ${idProyecto}...`, 'info');

            setTimeout(() => {
                const link = document.createElement('a');
                link.href = rutaDescarga;
                link.download = docExtenso.split('/').pop();
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
            }, 1500);
        }

        // Función para evaluar proyecto
        function evaluarProyecto(idProyecto) {
            mostrarNotificacion(`Redirigiendo a evaluación del proyecto 
\${idProyecto}...`, 'info');
            
            // En una implementación real, redirigiría a la página de evaluación
            setTimeout(() => {
                window.open(`evaluacionProyecto.html?id=
\${idProyecto}`, '_blank');
            }, 500);
        }

        // Función para mostrar notificaciones
        function mostrarNotificacion(mensaje, tipo) {
            const notification = document.createElement('div');
            notification.className = `fixed top-4 right-4 px-4 py-3 rounded-lg shadow-lg z-50 transition-all duration-300 flex items-center gap-3 
\${tipo === 'success' ? 'bg-green-500 text-white' : 
tipo === 'info' ? 'bg-blue-500 text-white' : 
'bg-gray-800 text-white'}`;
            notification.innerHTML = `
                <i class="fas fa-
\${tipo === 'success' ? 'check-circle' : 'info-circle'}"></i>
                <span>
\${mensaje}</span>
            `;
            document.body.appendChild(notification);
            
            setTimeout(() => {
                notification.style.opacity = '0';
                setTimeout(() => {
                    notification.remove();
                }, 300);
            }, 3000);
        }

        // Función para cambiar entre vista tabla y cuadrícula
        function toggleVista() {
            const vistaTabla = document.getElementById('vista-tabla');
            const vistaCuadricula = document.getElementById('vista-cuadricula');
            const icono = document.getElementById('vista-icon');
            const texto = document.getElementById('vista-text');
            
            if (vistaActual === 'tabla') {
                vistaTabla.classList.add('hidden');
                vistaCuadricula.classList.remove('hidden');
                icono.className = 'fas fa-list';
                texto.textContent = 'Vista tabla';
                vistaActual = 'cuadricula';
            } else {
                vistaTabla.classList.remove('hidden');
                vistaCuadricula.classList.add('hidden');
                icono.className = 'fas fa-th';
                texto.textContent = 'Vista cuadrícula';
                vistaActual = 'tabla';
            }
        }

        // Función para logout
        function logout() {
            if (confirm('¿Estás seguro de que deseas cerrar sesión?')) {
                mostrarNotificacion('Cerrando sesión...', 'info');
                setTimeout(() => {
                    window.location.href = 'login.html';
                }, 1000);
            }
        }

        // Cerrar modal con Escape
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                cerrarModal();
            }
        });

        // Cerrar modal al hacer clic fuera
        document.getElementById('modal-detalles').addEventListener('click', function(e) {
            if (e.target === this) {
                cerrarModal();
            }
        });
    </script>
</body>
</html>
