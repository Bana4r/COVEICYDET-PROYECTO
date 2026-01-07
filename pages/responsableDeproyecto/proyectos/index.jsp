<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Properties" %>
<% if (!"responsable".equals(String.valueOf(session.getAttribute("rol")))) { String n=request.getRequestURI()+(request.getQueryString()!=null?("?"+request.getQueryString()):""); response.sendRedirect(request.getContextPath()+"/pages/login/login.jsp?next="+java.net.URLEncoder.encode(n,"UTF-8")); return; } %>
<%!
    // Configuración de la base de datos
    private static final String DB_URL = "jdbc:postgresql://localhost:5432/proyectos?useUnicode=true&characterEncoding=UTF-8";
    private static final String DB_USER = "dbusr25";
    private static final String DB_PASSWORD = "mxToro24000Chocolate";
    
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
     * Mapa de estados para el frontend
     */
    private Map<String, String> obtenerMapaEstados() {
        Map<String, String> estados = new HashMap<>();
        estados.put("1", "Iniciado");
        estados.put("2", "Enviado");
        estados.put("3", "En validación");
        estados.put("4", "Validado");
        estados.put("5", "En evaluación externa");
        estados.put("6", "En evaluación interna");
        estados.put("7", "Aceptado");
        estados.put("-1", "Rechazado");
        estados.put("8", "En elaboración de Convenio de Asignación de Recursos");
        estados.put("9", "En proceso de facturación");
        estados.put("10", "En proceso de ministración de recursos");
        estados.put("11", "Recalendarización");
        estados.put("12", "En seguimiento: Alta de estudiantes, etc");
        estados.put("13.1", "Entregó Reporte semestral - por revisar");
        estados.put("13.2", "Entregó Reporte semestral – completo");
        estados.put("13.3", "Entregó Reporte semestral - incompleto");
        estados.put("14", "Entregó Reporte Final");
        estados.put("14.1", "Entregó Reporte Final - completo");
        estados.put("14.2", "Entregó Reporte Final – con observaciones");
        estados.put("14.3", "Entregó Reporte Final – fuera de tiempo");
        estados.put("15", "En auditoría de despacho externo");
        estados.put("15.1", "En auditoría de despacho externo – aprobado");
        estados.put("15.2", "En auditoría de despacho externo – con observaciones");
        estados.put("16", "En Comité Técnico de Evaluación");
        estados.put("18", "En elaboración de acta conclusión");
        estados.put("19", "Finalizado");
        
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
    
    // Lógica del servlet movida al JSP
    List<Map<String, Object>> proyectos = new ArrayList<>();
    boolean conexionExitosa = false;
    String mensajeError = null;
    
    // Verificar que el usuario tenga ID en la sesión
    if (userId == null) {
        mensajeError = "Sesión inválida. Por favor, inicie sesión nuevamente.";
    } else {
        try {
            // Cargar el driver de PostgreSQL
            Class.forName("org.postgresql.Driver");
            
            // Establecer propiedades de conexión para UTF-8
            Properties props = new Properties();
            props.setProperty("user", DB_USER);
            props.setProperty("password", DB_PASSWORD);
            props.setProperty("useUnicode", "true");
            props.setProperty("characterEncoding", "UTF-8");
            
            // Establecer conexión
            try (Connection conn = DriverManager.getConnection(DB_URL, props)) {
                conexionExitosa = true;
                
                // Consulta SQL para obtener proyectos del usuario logueado
                String sql = "SELECT " +
                           "p.id_proyecto, " +
                           "p.titulo, " +
                           "p.fecha_creacion " +
                           "FROM proyectos p " +
                           "INNER JOIN proyecto_usuarios pu ON p.id_proyecto = pu.id_proyecto " +
                           "WHERE pu.id_usuario = ? " +
                           "ORDER BY p.fecha_creacion DESC";
                
                try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setInt(1, userId);
                    try (ResultSet rs = stmt.executeQuery()) {
                        
                        while (rs.next()) {
                            Map<String, Object> proyecto = new HashMap<>();
                            proyecto.put("id", rs.getString("id_proyecto"));
                            proyecto.put("nombre", rs.getString("titulo"));
                            proyecto.put("estado", "1"); // Estado por defecto: Iniciado
                            proyecto.put("fechaCreacion", rs.getTimestamp("fecha_creacion"));
                            
                            proyectos.add(proyecto);
                        }
                    }
                }
            }
            
        } catch (ClassNotFoundException e) {
            System.err.println("Error: No se encontró el driver de PostgreSQL");
            e.printStackTrace();
            mensajeError = "Driver de base de datos no encontrado.";
            
        } catch (SQLException e) {
            System.err.println("Error de base de datos: " + e.getMessage());
            e.printStackTrace();
            mensajeError = "Error de conexión a la base de datos: " + e.getMessage();
        }
    }

    // Estados posibles
    Map<String, String> estados = obtenerMapaEstados();
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
            
            <% if (proyectos.isEmpty() && conexionExitosa && userId != null) { %>
                <div class="bg-yellow-100 border border-yellow-400 text-yellow-700 px-4 py-3 rounded mb-6">
                    No tienes proyectos registrados.
                </div>
            <% } %>
            
            <!-- Mostrar total de proyectos -->
            <% if (proyectos.size() > 0) { %>
                <p class="text-gray-600 mb-6">Total de proyectos: <%= proyectos.size() %></p>
            <% } %>
            
            <div class="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
                <% 
                for (Map<String, Object> proyecto : proyectos) {
                    String id = (String) proyecto.get("id");
                    String nombre = (String) proyecto.get("nombre");
                    String estado = (String) proyecto.get("estado");
        
                    String estadoTexto = estados.get(estado);
                    if (estadoTexto == null) estadoTexto = "Estado desconocido";
        
                    String claseEstado = obtenerClaseEstado(estado);
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
            
            <!-- Mensaje cuando no hay proyectos -->
            <% if (proyectos.isEmpty() && mensajeError == null && userId != null) { %>
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