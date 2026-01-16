<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%-- Validación de sesión --%>
<% if (!"analista".equals(String.valueOf(session.getAttribute("rol")))) { 
    String n = request.getRequestURI() + (request.getQueryString() != null ? ("?" + request.getQueryString()) : "");
    response.sendRedirect(request.getContextPath() + "/pages/login/login.jsp?next=" + java.net.URLEncoder.encode(n, "UTF-8")); 
    return; 
} %>

<%@ include file="/WEB-INF/conexion.jsp" %>

<%
    // Cargar estados de convocatoria desde la base de datos
    List<Map<String, Object>> estadosConvocatoria = new ArrayList<>();
    
    // Cargar convocatorias desde la base de datos
    List<Map<String, Object>> convocatorias = new ArrayList<>();
    int totalActivas = 0;
    int totalPendientes = 0;
    int totalFinalizadas = 0;
    
    SimpleDateFormat sdfDisplay = new SimpleDateFormat("dd/MM/yyyy");
    
    if (conn != null) {
        try {
            // Cargar estados disponibles
            String sqlEstados = "SELECT id_estado, estado FROM estado_convocatoria ORDER BY id_estado";
            try (PreparedStatement stmtEstados = conn.prepareStatement(sqlEstados);
                 ResultSet rsEstados = stmtEstados.executeQuery()) {
                while (rsEstados.next()) {
                    Map<String, Object> est = new HashMap<>();
                    est.put("id", rsEstados.getInt("id_estado"));
                    est.put("nombre", rsEstados.getString("estado"));
                    estadosConvocatoria.add(est);
                }
            }
            
            String sql = "SELECT c.id_convocatoria, c.nombre_convocatoria, c.estado, c.fecha_inicio, c.fecha_cierre, " +
                        "ec.estado as nombre_estado " +
                        "FROM convocatoria c " +
                        "LEFT JOIN estado_convocatoria ec ON c.estado = ec.id_estado " +
                        "ORDER BY c.id_convocatoria DESC";
            
            try (PreparedStatement stmt = conn.prepareStatement(sql);
                 ResultSet rs = stmt.executeQuery()) {
                
                while (rs.next()) {
                    Map<String, Object> conv = new HashMap<>();
                    conv.put("id", rs.getInt("id_convocatoria"));
                    conv.put("nombre", rs.getString("nombre_convocatoria"));
                    
                    // Fechas
                    java.sql.Date fechaInicio = rs.getDate("fecha_inicio");
                    java.sql.Date fechaCierre = rs.getDate("fecha_cierre");
                    conv.put("fechaInicio", fechaInicio != null ? sdfDisplay.format(fechaInicio) : "Sin definir");
                    conv.put("fechaCierre", fechaCierre != null ? sdfDisplay.format(fechaCierre) : "Sin definir");
                    conv.put("fechaInicioRaw", fechaInicio != null ? fechaInicio.toString() : "");
                    conv.put("fechaCierreRaw", fechaCierre != null ? fechaCierre.toString() : "");
                    
                    // Estado
                    String estadoNombre = rs.getString("nombre_estado");
                    int estadoId = rs.getInt("estado");
                    if (estadoNombre == null || estadoNombre.isEmpty()) {
                        switch(estadoId) {
                            case 1: estadoNombre = "pendiente"; break;
                            case 2: estadoNombre = "activa"; break;
                            case 3: estadoNombre = "cerrada"; break;
                            case 4: estadoNombre = "finalizada"; break;
                            default: estadoNombre = "pendiente";
                        }
                    }
                    conv.put("estado", estadoNombre.toLowerCase());
                    conv.put("estadoId", estadoId);
                    
                    // Contadores
                    if ("activa".equalsIgnoreCase(estadoNombre)) totalActivas++;
                    else if ("pendiente".equalsIgnoreCase(estadoNombre)) totalPendientes++;
                    else if ("finalizada".equalsIgnoreCase(estadoNombre) || "cerrada".equalsIgnoreCase(estadoNombre)) totalFinalizadas++;
                    
                    convocatorias.add(conv);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panel del Analista - Convocatorias</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --primary: #7A1737;
            --primary-light: #A8253C;
            --secondary: #B28854;
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
            max-width: 600px;
            max-height: 90vh;
            overflow-y: auto;
        }
        
        .stat-card {
            background: white;
            border-radius: 12px;
            padding: 1.5rem;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
        }
        
        .status-activa { background-color: #d1fae5; color: #065f46; }
        .status-pendiente { background-color: #fef3c7; color: #92400e; }
        .status-cerrada { background-color: #e0e7ff; color: #3730a3; }
        .status-finalizada { background-color: #dbeafe; color: #1e40af; }
    </style>
</head>

<%@ include file="../header.jsp" %>

<body class="bg-gray-50 min-h-screen">
    


    <!-- Contenido principal -->
    <div class="container mx-auto px-4 py-6">
        <div class="flex justify-between items-center mb-6">
            <h2 class="text-2xl font-bold text-gray-800">Gestión de Convocatorias</h2>
            <button onclick="abrirModalConvocatoria()" class="btn-primary px-6 py-3 rounded-lg font-semibold flex items-center">
                <i class="fas fa-plus-circle mr-2"></i> Nueva Convocatoria
            </button>
        </div>

        <!-- Estadísticas dinámicas -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
            <div class="stat-card">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-sm text-gray-500">Convocatorias Activas</p>
                        <p class="text-2xl font-bold text-blue-600"><%= totalActivas %></p>
                    </div>
                    <div class="bg-blue-100 p-3 rounded-lg">
                        <i class="fas fa-calendar-check text-blue-600 text-xl"></i>
                    </div>
                </div>
            </div>
            
            <div class="stat-card">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-sm text-gray-500">Pendientes</p>
                        <p class="text-2xl font-bold text-yellow-600"><%= totalPendientes %></p>
                    </div>
                    <div class="bg-yellow-100 p-3 rounded-lg">
                        <i class="fas fa-clock text-yellow-600 text-xl"></i>
                    </div>
                </div>
            </div>
            
            <div class="stat-card">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-sm text-gray-500">Finalizadas/Cerradas</p>
                        <p class="text-2xl font-bold text-green-600"><%= totalFinalizadas %></p>
                    </div>
                    <div class="bg-green-100 p-3 rounded-lg">
                        <i class="fas fa-check-circle text-green-600 text-xl"></i>
                    </div>
                </div>
            </div>
        </div>

        <!-- Lista de convocatorias -->
        <div class="bg-white rounded-xl shadow-md overflow-hidden">
            <div class="px-6 py-4 border-b border-gray-200">
                <h3 class="text-lg font-semibold text-gray-800">
                    <i class="fas fa-list mr-2 text-[#7A1737]"></i> 
                    Lista de Convocatorias (<%= convocatorias.size() %>)
                </h3>
            </div>
            
            <div class="overflow-x-auto">
                <table class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-gray-50">
                        <tr>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Nombre</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Fecha Inicio</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Fecha Fin</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Estado</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Acciones</th>
                        </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-200" id="tabla-convocatorias">
                        <% if (convocatorias.isEmpty()) { %>
                            <tr>
                                <td colspan="6" class="px-6 py-8 text-center text-gray-500">
                                    <i class="fas fa-inbox text-4xl mb-2"></i>
                                    <p>No hay convocatorias registradas</p>
                                </td>
                            </tr>
                        <% } else { 
                            for (Map<String, Object> conv : convocatorias) { 
                                String estado = (String) conv.get("estado");
                                String claseEstado = "status-pendiente";
                                if ("activa".equals(estado)) claseEstado = "status-activa";
                                else if ("cerrada".equals(estado)) claseEstado = "status-cerrada";
                                else if ("finalizada".equals(estado)) claseEstado = "status-finalizada";
                        %>
                            <tr class="hover:bg-gray-50" id="fila-<%= conv.get("id") %>">
                                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-[#7A1737]">
                                    C-<%= conv.get("id") %>
                                </td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                                    <%= conv.get("nombre") %>
                                </td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                    <%= conv.get("fechaInicio") %>
                                </td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                    <%= conv.get("fechaCierre") %>
                                </td>
                                <td class="px-6 py-4 whitespace-nowrap">
                                    <span class="px-2 py-1 text-xs font-semibold rounded-full <%= claseEstado %>">
                                        <%= estado.substring(0,1).toUpperCase() + estado.substring(1) %>
                                    </span>
                                </td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                                    <button onclick="editarConvocatoria(<%= conv.get("id") %>)" 
                                            class="text-blue-600 hover:text-blue-800 mr-3" title="Editar">
                                        <i class="fas fa-edit"></i>
                                    </button>
                                    <button onclick="eliminarConvocatoria(<%= conv.get("id") %>, '<%= ((String)conv.get("nombre")).replace("'", "\\'") %>')" 
                                            class="text-red-600 hover:text-red-800" title="Eliminar">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </td>
                            </tr>
                        <% } } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Modal para agregar/editar convocatoria -->
    <div id="modal-convocatoria" class="modal">
        <div class="modal-content">
            <div class="bg-gradient-to-r from-[#7A1737] to-[#A8253C] text-white p-4 rounded-t-lg flex justify-between items-center">
                <h3 class="font-bold text-lg" id="modal-convocatoria-titulo">Nueva Convocatoria</h3>
                <button onclick="cerrarModalConvocatoria()" class="text-white hover:text-gray-200">
                    <i class="fas fa-times text-xl"></i>
                </button>
            </div>
            <div class="p-6">
                <form id="form-convocatoria" onsubmit="return guardarConvocatoria(event)">
                    <input type="hidden" id="convocatoria-id" name="id" value="">
                    <input type="hidden" id="convocatoria-accion" name="accion" value="crear">
                    
                    <div class="space-y-6">
                        <!-- Nombre -->
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">
                                <span class="text-red-500">*</span> Nombre de la convocatoria
                            </label>
                            <input type="text" name="nombre" id="nombre-convocatoria" required
                                   class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#7A1737] focus:border-transparent"
                                   placeholder="Ej: Convocatoria Nacional 2024">
                        </div>

                        <!-- Fechas -->
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">
                                    <span class="text-red-500">*</span> Fecha de inicio
                                </label>
                                <input type="date" name="fechaInicio" id="fecha-inicio" required
                                       class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#7A1737] focus:border-transparent">
                            </div>
                            
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">
                                    <span class="text-red-500">*</span> Fecha de cierre
                                </label>
                                <input type="date" name="fechaCierre" id="fecha-cierre" required
                                       class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#7A1737] focus:border-transparent">
                            </div>
                        </div>

                        <!-- Estado -->
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">
                                <span class="text-red-500">*</span> Estado
                            </label>
                            <select name="estado" id="estado-convocatoria" required
                                    class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#7A1737] focus:border-transparent">
                                <option value="">Seleccione un estado</option>
                                <% for (Map<String, Object> est : estadosConvocatoria) { 
                                    String nombreEstado = (String) est.get("nombre");
                                    String valorEstado = nombreEstado.toLowerCase();
                                %>
                                <option value="<%= valorEstado %>"><%= nombreEstado.substring(0,1).toUpperCase() + nombreEstado.substring(1).toLowerCase() %></option>
                                <% } %>
                            </select>
                        </div>

                        <!-- Botones -->
                        <div class="border-t pt-6 mt-6">
                            <div class="flex justify-end space-x-3">
                                <button type="button" onclick="cerrarModalConvocatoria()" 
                                        class="px-6 py-3 border border-gray-300 rounded-lg font-medium text-gray-700 hover:bg-gray-50">
                                    Cancelar
                                </button>
                                <button type="submit" id="btn-guardar"
                                        class="btn-primary px-6 py-3 rounded-lg font-semibold flex items-center">
                                    <i class="fas fa-save mr-2"></i> Guardar
                                </button>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>

<%@ include file="/footer.jsp" %>

    <script>
        const contextPath = '<%= request.getContextPath() %>';
        
        // Abrir modal para nueva convocatoria
        function abrirModalConvocatoria() {
            document.getElementById('form-convocatoria').reset();
            document.getElementById('modal-convocatoria-titulo').textContent = 'Nueva Convocatoria';
            document.getElementById('convocatoria-id').value = '';
            document.getElementById('convocatoria-accion').value = 'crear';
            document.getElementById('modal-convocatoria').style.display = 'flex';
        }

        // Cerrar modal
        function cerrarModalConvocatoria() {
            document.getElementById('modal-convocatoria').style.display = 'none';
        }

        // Validar fechas
        document.getElementById('fecha-inicio').addEventListener('change', function() {
            document.getElementById('fecha-cierre').min = this.value;
        });

        // Guardar convocatoria (crear o editar)
        async function guardarConvocatoria(event) {
            event.preventDefault();
            
            const form = document.getElementById('form-convocatoria');
            const formData = new FormData(form);
            
            // Validar fechas
            const fechaInicio = new Date(formData.get('fechaInicio'));
            const fechaCierre = new Date(formData.get('fechaCierre'));
            
            if (fechaCierre < fechaInicio) {
                mostrarNotificacion('La fecha de cierre debe ser posterior a la fecha de inicio', 'error');
                return false;
            }
            
            try {
                const response = await fetch(contextPath + '/pages/analista/convocatoria/procesarConvocatoria.jsp', {
                    method: 'POST',
                    body: new URLSearchParams(formData)
                });
                
                const data = await response.json();
                
                if (data.success) {
                    mostrarNotificacion(data.mensaje, 'success');
                    cerrarModalConvocatoria();
                    // Recargar la página para ver los cambios
                    setTimeout(() => location.reload(), 1000);
                } else {
                    mostrarNotificacion(data.error || 'Error al guardar', 'error');
                }
            } catch (error) {
                mostrarNotificacion('Error de conexión: ' + error.message, 'error');
            }
            
            return false;
        }

        // Editar convocatoria
        async function editarConvocatoria(id) {
            mostrarNotificacion('Cargando datos...', 'info');
            
            try {
                const response = await fetch(contextPath + '/pages/analista/convocatoria/procesarConvocatoria.jsp?accion=obtener&id=' + id);
                const data = await response.json();
                
                if (data.success) {
                    const conv = data.convocatoria;
                    document.getElementById('modal-convocatoria-titulo').textContent = 'Editar Convocatoria: C-' + id;
                    document.getElementById('convocatoria-id').value = id;
                    document.getElementById('convocatoria-accion').value = 'editar';
                    document.getElementById('nombre-convocatoria').value = conv.nombre;
                    document.getElementById('fecha-inicio').value = conv.fechaInicio;
                    document.getElementById('fecha-cierre').value = conv.fechaCierre;
                    document.getElementById('estado-convocatoria').value = conv.estado;
                    
                    document.getElementById('modal-convocatoria').style.display = 'flex';
                } else {
                    mostrarNotificacion(data.error || 'Error al cargar datos', 'error');
                }
            } catch (error) {
                mostrarNotificacion('Error de conexión', 'error');
            }
        }

        // Eliminar convocatoria
        async function eliminarConvocatoria(id, nombre) {
            if (!confirm('¿Eliminar la convocatoria "' + nombre + '"?\n\nEsta acción no se puede deshacer.')) {
                return;
            }
            
            try {
                const response = await fetch(contextPath + '/pages/analista/convocatoria/procesarConvocatoria.jsp', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'accion=eliminar&id=' + id
                });
                
                const data = await response.json();
                
                if (data.success) {
                    mostrarNotificacion(data.mensaje, 'success');
                    document.getElementById('fila-' + id)?.remove();
                } else {
                    mostrarNotificacion(data.error || 'Error al eliminar', 'error');
                }
            } catch (error) {
                mostrarNotificacion('Error de conexión', 'error');
            }
        }

        // Mostrar notificaciones
        function mostrarNotificacion(mensaje, tipo) {
            let claseCSS = 'bg-gray-800 text-white';
            let icono = 'info-circle';
            
            if (tipo === 'success') {
                claseCSS = 'bg-green-500 text-white';
                icono = 'check-circle';
            } else if (tipo === 'error') {
                claseCSS = 'bg-red-500 text-white';
                icono = 'exclamation-circle';
            } else if (tipo === 'info') {
                claseCSS = 'bg-blue-500 text-white';
                icono = 'info-circle';
            }
            
            const notification = document.createElement('div');
            notification.className = 'fixed top-4 right-4 px-4 py-3 rounded-lg shadow-lg z-[1100] transition-all duration-300 flex items-center gap-3 ' + claseCSS;
            notification.innerHTML = '<i class="fas fa-' + icono + '"></i><span>' + mensaje + '</span>';
            document.body.appendChild(notification);
            
            setTimeout(() => {
                notification.style.opacity = '0';
                setTimeout(() => notification.remove(), 300);
            }, 3000);
        }

        // Cerrar modal con Escape o clic fuera
        document.addEventListener('keydown', e => { if (e.key === 'Escape') cerrarModalConvocatoria(); });
        document.getElementById('modal-convocatoria').addEventListener('click', e => { if (e.target === e.currentTarget) cerrarModalConvocatoria(); });
    </script>
</body>
</html>