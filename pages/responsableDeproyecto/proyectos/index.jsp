<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Properties" %>
<% if (!"responsable".equals(String.valueOf(session.getAttribute("rol")))) { String n=request.getRequestURI()+(request.getQueryString()!=null?("?"+request.getQueryString()):""); response.sendRedirect(request.getContextPath()+"/pages/login/login.jsp?next="+java.net.URLEncoder.encode(n,"UTF-8")); return; } %>

<%@ include file="../../../WEB-INF/conexion.jsp" %>

<%!
    /**
     * Mapea los estados de la BD a los códigos numéricos del frontend
     */
    private String mapearEstadoBD(String estadoBD) {
        if (estadoBD == null) return "1";

        switch (estadoBD.toLowerCase()) {
            case "borrador": return "1";
            case "enviado": return "2";
            case "en_revision": return "3";
            case "validado": return "4";
            case "en_evaluacion_externa": return "5";
            case "en_evaluacion_interna": return "6";
            case "aprobado": return "7";
            case "rechazado": return "-1";
            case "convenio": return "8";
            case "facturacion": return "9";
            case "ministracion": return "10";
            case "recalendarizacion": return "11";
            case "seguimiento": return "12";
            case "reporte_semestral": return "13.1";
            case "reporte_final": return "14";
            case "auditoria": return "15";
            case "comite_tecnico": return "16";
            case "acta_conclusion": return "18";
            case "finalizado": return "19";
            default: return "1";
        }
    }

    /**
     * Obtiene el mapa de estados desde la base de datos
     */
    private Map<String, String> obtenerMapaEstados(Connection conn) throws SQLException {
        Map<String, String> estados = new HashMap<>();

        String sql = "SELECT id_estado, nombre_estado FROM estado_proyecto ORDER BY id_estado";
        try (PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                String idEstado = rs.getString("id_estado");
                String nombreEstado = rs.getString("nombre_estado");
                estados.put(idEstado, nombreEstado);
            }
        }

        return estados;
    }

    /**
     * Obtiene la clase CSS para el estado
     */
    private String obtenerClaseEstado(String estado) {
        if (estado == null) return "bg-gray-100 text-gray-800";

        switch (estado) {
            case "1":
            case "7":
                return "bg-green-100 text-green-800";
            case "2":
            case "3":
                return "bg-yellow-100 text-yellow-800";
            case "4":
            case "19":
                return "bg-blue-100 text-blue-800";
            case "15":
                return "bg-purple-100 text-purple-800";
            case "-1":
                return "bg-red-100 text-red-800";
            default:
                return "bg-gray-100 text-gray-800";
        }
    }
%>

<%
    // Obtener el ID del usuario de la sesión
    Integer userId = (Integer) session.getAttribute("id_usuario");
    
    // Estados posibles - deben obtenerse de la base de datos
    Map<String, String> estados = new HashMap<>();
    boolean estadosCargados = false;
    boolean conexionExitosa = false;
    String mensajeError = null;

    // Verificar que el usuario tenga ID en la sesión
    if (userId == null) {
        mensajeError = "Sesión inválida. Por favor, inicie sesión nuevamente.";
    } else {
        if (conn != null) {
            conexionExitosa = true;
            try {
                // Primero obtener los estados desde la base de datos
                estados = obtenerMapaEstados(conn);
                estadosCargados = true;

                // Luego obtener los proyectos
                // Consulta SQL para obtener proyectos del usuario logueado con sus estados
                String sql = "SELECT " +
                           "p.id_proyecto, " +
                           "p.titulo, " +
                           "p.fecha_creacion, " +
                           "p.estado_proyecto AS estado_original, " +
                           "COALESCE(ep.id_estado::TEXT, p.estado_proyecto) AS estado_codigo, " +
                           "COALESCE(ep.nombre_estado, p.estado_proyecto) AS estado_nombre " +
                           "FROM proyectos p " +
                           "INNER JOIN proyecto_usuarios pu ON p.id_proyecto = pu.id_proyecto " +
                           "LEFT JOIN estado_proyecto ep ON LOWER(TRIM(p.estado_proyecto)) = LOWER(TRIM(ep.nombre_estado)) OR p.estado_proyecto = CAST(ep.id_estado AS TEXT) " +
                           "WHERE pu.id_usuario = ? " +
                           "ORDER BY p.fecha_creacion DESC";

                try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setInt(1, userId);
                    try (ResultSet rs = stmt.executeQuery()) {
                        List<Map<String, Object>> proyectos = new ArrayList<>();

                        while (rs.next()) {
                            Map<String, Object> proyecto = new HashMap<>();
                            proyecto.put("id", rs.getString("id_proyecto"));
                            proyecto.put("nombre", rs.getString("titulo"));
                            proyecto.put("estado_original", rs.getString("estado_original")); // Estado original desde la BD
                            proyecto.put("estado_codigo", rs.getString("estado_codigo")); // Código del estado
                            proyecto.put("estado_nombre", rs.getString("estado_nombre")); // Nombre del estado
                            proyecto.put("fechaCreacion", rs.getTimestamp("fecha_creacion"));

                            proyectos.add(proyecto);
                        }

                        // Asignar la lista de proyectos al alcance adecuado
                        pageContext.setAttribute("proyectos", proyectos);
                    }
                }
            } catch (SQLException e) {
                System.err.println("Error de base de datos: " + e.getMessage());
                e.printStackTrace();
                mensajeError = "Error de conexión a la base de datos: " + e.getMessage();
            } finally {
                // Cerrar la conexión aquí ya que no se usará más en esta página
                if (conn != null) {
                    try { conn.close(); } catch (SQLException e) { /* Ignored */ }
                }
            }
        } else {
            mensajeError = dbError;
        }
    }

    // Obtener la lista de proyectos del contexto de página
    List<Map<String, Object>> proyectos = (List<Map<String, Object>>) pageContext.getAttribute("proyectos");
    if (proyectos == null) {
        proyectos = new ArrayList<>();
    }
    SimpleDateFormat formatoFecha = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>

<!DOCTYPE html>
<html lang="es">
    <%@ include file="../header.jsp" %>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <script src="https://cdn.tailwindcss.com"></script>
        <title>Lista de Proyectos</title>
    </head>
    <body>
        <div class="container mx-auto p-6">
            <h1 class="text-3xl font-bold text-gray-800 mb-6">Lista de Proyectos</h1>
            
            <!-- Mostrar mensajes de error o información -->
            <% if (mensajeError != null) { %>
                <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-6">
                    <%= mensajeError %>
                </div>
            <% } %>

            <% if (proyectos.isEmpty() && conexionExitosa && userId != null && estadosCargados) { %>
                <div class="bg-yellow-100 border border-yellow-400 text-yellow-700 px-4 py-3 rounded mb-6">
                    No tienes proyectos registrados.
                </div>
            <% } %>

            <!-- Mostrar total de proyectos -->
            <% if (proyectos.size() > 0 && estadosCargados) { %>
                <p class="text-gray-600 mb-6">Total de proyectos: <%= proyectos.size() %></p>
            <% } %>

            <% if (!estadosCargados && mensajeError == null) { %>
                <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-6">
                    Ha ocurrido un error inesperado al cargar los estados de los proyectos.
                </div>
            <% } else { %>
            <div class="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
                <%
                for (Map<String, Object> proyecto : proyectos) {
                    String id = (String) proyecto.get("id");
                    String nombre = (String) proyecto.get("nombre");
                    String estadoOriginal = (String) proyecto.get("estado_original");
                    String estadoCodigo = (String) proyecto.get("estado_codigo");
                    String estadoNombre = (String) proyecto.get("estado_nombre");

                    String estadoTexto;

                    // Prioridad 1: Si tenemos un nombre de estado desde la tabla estado_proyecto (y es diferente al original), usarlo
                    if (estadoNombre != null && !estadoNombre.trim().isEmpty() &&
                        !estadoNombre.equals(estadoOriginal)) {
                        estadoTexto = estadoNombre;
                    } else if (estadoNombre != null && !estadoNombre.trim().isEmpty() &&
                               estadoNombre.equals(estadoOriginal)) {
                        // Si estadoNombre y estadoOriginal son iguales, significa que no hubo coincidencia en la tabla estado_proyecto
                        // En este caso, usar la función de mapeo para convertir el estado original a su equivalente mostrable
                        String codigoMapeado = mapearEstadoBD(estadoOriginal);
                        estadoTexto = estados.get(codigoMapeado);

                        // Si aún no se encuentra, usar el estado original
                        if (estadoTexto == null) {
                            estadoTexto = estadoOriginal != null ? estadoOriginal : "Estado desconocido";
                        }
                    } else {
                        // Si no hay estadoNombre, usar la función de mapeo
                        String codigoMapeado = mapearEstadoBD(estadoOriginal);
                        estadoTexto = estados.get(codigoMapeado);

                        // Si no se encontró en el mapa de estados de la DB, usar el nombre del estado original
                        if (estadoTexto == null) {
                            estadoTexto = estadoOriginal != null ? estadoOriginal : "Estado desconocido";
                        }
                    }

                    String claseEstado = obtenerClaseEstado(estadoCodigo);
                %>
                    <div class="bg-white rounded-lg shadow-md p-6 border border-gray-200">
                        <h2 class="text-xl font-semibold text-gray-800 mb-2">
                            <%= nombre != null ? nombre : "Sin título" %>
                        </h2>
                        <p class="text-gray-600 mb-4">
                            Descripción del <%= nombre != null ? nombre : "proyecto" %>
                        </p>
                        <div class="flex justify-between items-center">
                            <span class="px-3 py-1 rounded-full text-sm <%= claseEstado %>">
                                <%= estadoTexto %>
                            </span>
                            <a href="/proyectos/pages/responsableDeproyecto/infoProyecto/infoProyecto.jsp?id=<%= id %>"
                               class="text-blue-600 hover:text-blue-800 font-medium">
                                Ver detalles
                            </a>
                        </div>
                    </div>
                <% } %>
            </div>
            <% } %>

            <!-- Mensaje cuando no hay proyectos -->
            <% if (proyectos.isEmpty() && mensajeError == null && userId != null && estadosCargados) { %>
                <div class="text-center py-12">
                    <p class="text-gray-500 text-lg">No tienes proyectos para mostrar.</p>
                </div>
            <% } %>
        </div>
        
        <!-- Espaciado antes del footer -->
        <div class="mt-20 mb-16"></div>
    </body>
    <%@ include file="/footer.jsp" %>
</html>