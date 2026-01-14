<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%-- VALIDACIÓN DE SESIÓN --%>
<% 
    if (!"analista".equals(String.valueOf(session.getAttribute("rol")))) { 
        String n=request.getRequestURI()+(request.getQueryString()!=null?("?"+request.getQueryString()):"");
        response.sendRedirect(request.getContextPath()+"/pages/login/login.jsp?next="+java.net.URLEncoder.encode(n,"UTF-8")); 
        return; 
    } 
%>

<%@ include file="/WEB-INF/conexion.jsp"%>

<%
    // Lógica para obtener usuarios responsables
    List<Map<String, Object>> usuariosResponsables = new ArrayList<>();
    boolean conexionExitosa = false;
    String mensajeError = null;
    int totalUsuarios = 0;
    int totalProyectos = 0;

    // Verificar si la conexión del archivo conexion.jsp fue exitosa
    if (conn != null) {
        conexionExitosa = true;
        try {

            // --- SQL ACTUALIZADO AL NUEVO ESQUEMA ---
            // 1. Usa 'usuario' en singular.
            // 2. Usa comillas para "1er_apellido" y "2do_apellido".
            // 3. Hace JOIN con 'proyecto_usuarios' para contar los proyectos.
            // --- SQL CORREGIDO ---
            String sql = "SELECT " +
                       "u.id_usuario, " +
                       "u.nombre, " +
                       "u.primer_apellido, " +
                       "u.segundo_apellido, " +
                       "u.RFC, " +
                       "u.correo_electronico, " +
                       "u.estado, " + 
                       "t.tipo_usuario as rol, " +  
                       "u.comprobantevigencia," +
                       
                       // Conteos
                       "COUNT(p.id_proyecto) as total_proyectos, " +
                       "COUNT(CASE WHEN p.estado_proyecto = 'borrador' THEN 1 END) as proyectos_borrador, " +
                       "COUNT(CASE WHEN p.estado_proyecto = 'enviado' THEN 1 END) as proyectos_enviados, " +
                       "COUNT(CASE WHEN p.estado_proyecto = 'aprobado' THEN 1 END) as proyectos_aprobados, " +
                       "COUNT(CASE WHEN p.estado_proyecto = 'finalizado' THEN 1 END) as proyectos_finalizados, " +
                       "MAX(p.fecha_creacion) as ultima_actividad " +
                       
                       "FROM usuarios u " +
                       // CORRECCIÓN AQUÍ: La tabla se llama tipo_usuario, no tipousuario
                       "JOIN tipo_usuario t ON u.tipousuario = t.id_tipo_usuario " + 
                       
                       "LEFT JOIN proyecto_usuarios pu ON u.id_usuario = pu.id_usuario " +
                       "LEFT JOIN Proyectos p ON pu.id_proyecto = p.id_proyecto " +
                       
                       // CORRECCIÓN AQUÍ: La columna de texto es t.tipo_usuario
                       "WHERE t.tipo_usuario = 'responsable' " +
                       
                       "GROUP BY u.id_usuario, u.nombre, u.primer_apellido, u.segundo_apellido, u.RFC, u.correo_electronico, u.estado, t.tipo_usuario " +
                       "ORDER BY u.nombre, u.primer_apellido";
                       
            try (PreparedStatement stmt = conn.prepareStatement(sql);
                 ResultSet rs = stmt.executeQuery()) {
                
                while (rs.next()) {
                    Map<String, Object> usuario = new HashMap<>();
                    // Mapeo exacto de las nuevas columnas
                    usuario.put("id", rs.getInt("id_usuario"));
                    usuario.put("nombre", rs.getString("nombre"));
                    usuario.put("primerApellido", rs.getString("primer_apellido"));
                    usuario.put("segundoApellido", rs.getString("segundo_apellido"));
                    usuario.put("rfc", rs.getString("RFC"));
                    usuario.put("correo", rs.getString("correo_electronico"));
                    usuario.put("estado", rs.getInt("estado"));
                    usuario.put("rol", rs.getString("rol"));
                    usuario.put("comprobantevigencia", rs.getString("comprobantevigencia"));
                    // Estadísticas
                    int total = rs.getInt("total_proyectos");
                    usuario.put("totalProyectos", total);
                    usuario.put("proyectosBorrador", rs.getInt("proyectos_borrador"));
                    usuario.put("proyectosEnviados", rs.getInt("proyectos_enviados"));
                    usuario.put("proyectosAprobados", rs.getInt("proyectos_aprobados"));
                    usuario.put("proyectosFinalizados", rs.getInt("proyectos_finalizados"));
                    usuario.put("ultimaActividad", rs.getTimestamp("ultima_actividad"));
                    
                    usuariosResponsables.add(usuario);
                    totalProyectos += total;
                }
                
                totalUsuarios = usuariosResponsables.size();
            }
        } catch (SQLException e) {
            System.err.println("Error de base de datos: " + e.getMessage());
            e.printStackTrace();
            mensajeError = "Error de conexión a la base de datos: " + e.getMessage();
        } finally {
            // Cerrar la conexión
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { /* ignorar */ }
            }
        }
    } else {
        // Si la conexión falló, mostrar el error del archivo conexion.jsp
        mensajeError = dbError != null && !dbError.isEmpty() ? dbError : "No se pudo establecer conexión con la base de datos.";
    }

    SimpleDateFormat formatoFecha = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <script src="https://cdn.tailwindcss.com"></script>
    <title>COVEICYDET - Usuarios Responsables</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');
        
        :root {
            --primary: #7A1737;
            --secondary: #A8253C;
        }
        
        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
        }
        
        .hero-pattern {
            background-color: #7A1737;
            background-image: radial-gradient(#B28854 0.5px, transparent 0.5px), radial-gradient(#B28854 0.5px, #7A1737 0.5px);
            background-size: 20px 20px;
            background-position: 0 0, 10px 10px;
        }
        
        .card-hover {
            transition: all 0.3s ease;
        }
        
        .card-hover:hover {
            transform: translateY(-2px);
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
        }
        .descargar-excel {
            display: inline-block;
            background-color: #c19140;
            color: white;
            padding: 0.5rem 1rem;
            border-radius: 0.375rem;
            text-decoration: none;
            font-weight: 500;
            transition: background-color 0.2s;
        }
        .descarga-comprobante-vigencia {
            display: inline-block;
            background-color: #b07f2f;
            color: white;
            padding: 0.5rem 1rem;
            border-radius: 0.375rem;
            text-decoration: none;
            font-weight: 500;
            transition: background-color 0.2s;
        }

        /*modal styles*/
        .modal-close {
          background: none;
          border: none;
          color: white;
          font-size: 1.5rem;
          cursor: pointer;
          padding: 0;
          width: 32px;
          height: 32px;
          display: flex;
          align-items: center;
          justify-content: center;
          border-radius: 4px;
        }
        
        .modal-close:hover {
          background-color: rgba(255, 255, 255, 0.1);
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
          max-width: 900px;
          max-height: 90vh;
          overflow: hidden;
          display: flex;
          flex-direction: column;
        }

        .modal-header {
          padding: 1rem 1.5rem;
          background: var(--primary);
          color: white;
          display: flex;
          justify-content: space-between;
          align-items: center;
        }

        .modal-body {
          flex: 1;
          padding: 0;
          overflow: hidden;
        }

        .pdf-viewer {
          width: 100%;
          height: 70vh;
          border: none;
        }
    </style>
</head>
<body class="min-h-screen">
    <%@ include file="../header.jsp" %>

    <div id="pdfModal" class="modal">
      <div class="modal-content">
        <div class="modal-header">
          <h3 id="pdfTitle" class="font-bold">Visualizando documento</h3>
          <button class="modal-close" onclick="closePDFModal()">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
            </svg>
          </button>
        </div>
        <div class="modal-body">
          <iframe id="pdfFrame" class="pdf-viewer" src="" frameborder="0"></iframe>
        </div>
      </div>
    </div>
    
    <section class="hero-pattern text-white py-8">
        <div class="container mx-auto px-4 text-center">
            <h1 class="text-3xl md:text-4xl font-bold mb-4">Usuarios Responsables</h1>
            <p class="text-lg">Gestión y supervisión de responsables de proyecto</p>
        </div>
    </section>
    
    <div class="container mx-auto p-6">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
            <div class="bg-white rounded-xl p-6 shadow-lg text-center card-hover">
                <div class="bg-blue-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
                    <svg class="w-8 h-8 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.25 2.25 0 11-4.5 0 2.25 2.25 0 014.5 0z"></path>
                    </svg>
                </div>
                
                <h3 class="text-xl font-semibold mb-2">Total Responsables</h3>
                <p class="text-3xl font-bold text-gray-800"><%= totalUsuarios %></p>
                <p class="text-sm text-gray-500 mt-1">Usuarios registrados</p>
            </div>
            
            <div class="bg-white rounded-xl p-6 shadow-lg text-center card-hover">
                <div class="bg-green-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
                    <svg class="w-8 h-8 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                    </svg>
                </div>
                <h3 class="text-xl font-semibold mb-2">Total Proyectos</h3>
                <p class="text-3xl font-bold text-gray-800"><%= totalProyectos %></p>
                <p class="text-sm text-gray-500 mt-1">De todos los responsables</p>
            </div>
        </div>
        
        <% if (mensajeError != null) { %>
            <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-6">
                <%= mensajeError %>
            </div>
        <% } %>
        
        <% if (usuariosResponsables.isEmpty() && conexionExitosa) { %>
            <div class="bg-yellow-100 border border-yellow-400 text-yellow-700 px-4 py-3 rounded mb-6">
                No hay usuarios responsables registrados en el sistema.
            </div>
        <% } %>
        
        <% if (!usuariosResponsables.isEmpty()) { %>
            <div class="bg-white rounded-xl shadow-lg overflow-hidden mb-6">
                <div class="px-6 py-4 bg-gradient-to-r from-[#7A1737] to-[#A8253C] text-white flex justify-between items-center">
                    <div>
                        <h2 class="text-xl font-bold">Directorio de Usuarios Responsables</h2>
                        <p class="text-sm opacity-90">Información de contacto y perfil de cada responsable registrado</p>
                    </div>
                    <a href="archivoXls.jsp" class="inline-flex items-center bg-[#B28854] hover:bg-[#9A7148] text-white px-4 py-2 rounded-lg font-medium transition duration-200">
                        <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                        </svg>
                        Descargar Excel
                    </a>
                </div>
            </div>
            
            <div class="grid gap-6 md:grid-cols-2 lg:grid-cols-1">
                <%
                for (Map<String, Object> usuario : usuariosResponsables) {
                    Integer id = (Integer) usuario.get("id");
                    String nombre = (String) usuario.get("nombre");
                    String primerApellido = (String) usuario.get("primerApellido");
                    String segundoApellido = (String) usuario.get("segundoApellido");
                    String rfc = (String) usuario.get("rfc");
                    String correo = (String) usuario.get("correo");
                    Integer estado = (Integer) usuario.get("estado");
                    Integer totalProyectosUsuario = (Integer) usuario.get("totalProyectos");
                    Integer proyectosBorrador = (Integer) usuario.get("proyectosBorrador");
                    Integer proyectosEnviados = (Integer) usuario.get("proyectosEnviados");
                    Integer proyectosAprobados = (Integer) usuario.get("proyectosAprobados");
                    Integer proyectosFinalizados = (Integer) usuario.get("proyectosFinalizados");
                    Timestamp ultimaActividad = (Timestamp) usuario.get("ultimaActividad");
                    
                    String nombreCompletoUsuario = nombre + " " + (primerApellido != null ? primerApellido : "") + " " + (segundoApellido != null ? segundoApellido : "");
                    boolean isActivo = estado != null && estado == 2;
                %>
                    <div class="bg-white rounded-xl shadow-lg border border-gray-200 card-hover">
                        <div class="p-6 border-b border-gray-200">
                            <div class="flex items-center space-x-4">
                                <div class="flex-shrink-0">
                                    <div class="h-16 w-16 rounded-full bg-gradient-to-r from-[#7A1737] to-[#A8253C] flex items-center justify-center">
                                        <span class="text-xl font-bold text-white">
                                            <%= nombre != null && nombre.length() > 0 ? nombre.substring(0, 1).toUpperCase() : "?" %>
                                        </span>
                                    </div>
                                </div>
                                <div class="flex-1 min-w-0">
                                    <h3 class="text-xl font-bold text-gray-900 truncate"><%= nombreCompletoUsuario.trim() %></h3>
                                    <p class="text-sm font-medium text-[#7A1737]">Responsable de Proyecto</p>
                                    <p class="text-sm text-gray-500">ID de Usuario: <%= id %></p>
                                </div>
                                <!-- boton color cafe -->
                                <%
                                    String comprobanteVigencia = (String) usuario.get("comprobantevigencia");
                                    boolean tieneComprobante = comprobanteVigencia != null && !comprobanteVigencia.trim().isEmpty();
                                    String rutaComprobante = "";
                                    if (tieneComprobante) {
                                        if (comprobanteVigencia.startsWith("http://") || comprobanteVigencia.startsWith("https://")) {
                                            rutaComprobante = comprobanteVigencia;
                                        } else {
                                            // la ruta es uploads/{id}
                                            rutaComprobante = request.getContextPath() + "/" + comprobanteVigencia;
                                        }
                                    }
                                %>
                                <% if (tieneComprobante) { %>
                                    <button onclick="visualizarPDF('<%= rutaComprobante %>', 'Comprobante de Vigencia - <%= nombreCompletoUsuario.trim().replace("'", "\\'") %>')" 
                                            class="descarga-comprobante-vigencia ml-4 flex items-center">
                                        <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>
                                        </svg>
                                        Ver Comprobante Vigencia
                                    </button>
                                    <% } else { %>
                                    <span class="text-gray-400 text-sm flex items-center">
                                        <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12c0 4.418-4.03 8-9 8s-9-3.582-9-8 4.03-8 9-8 9 3.582 9 8z"></path>
                                        </svg>
                                        Sin Comprobante
                                    </span>
                                    <% } %>
                                <div class="flex-shrink-0">
                                    <% if (isActivo) { %>
                                        <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-green-100 text-green-800">
                                            <svg class="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                                                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path>
                                            </svg>
                                            Activo
                                        </span>
                                    <% } else { %>
                                        <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-red-100 text-red-800">
                                            <svg class="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                                                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"></path>
                                            </svg>
                                            Inactivo
                                        </span>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                        
                        <div class="p-6">
                            <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                                <div class="lg:col-span-1">
                                    <h4 class="text-lg font-semibold text-gray-900 mb-4 flex items-center">
                                        <svg class="w-5 h-5 mr-2 text-[#7A1737]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                                        </svg>
                                        Información Personal
                                    </h4>
                                    <div class="space-y-3">
                                        <div class="flex items-start">
                                            <span class="text-sm font-medium text-gray-500 w-16">Nombre:</span>
                                            <span class="text-sm text-gray-900"><%= nombreCompletoUsuario.trim() %></span>
                                        </div>
                                        <div class="flex items-start">
                                            <span class="text-sm font-medium text-gray-500 w-16">RFC:</span>
                                            <span class="text-sm text-gray-900 font-mono"><%= rfc != null ? rfc : "No registrado" %></span>
                                        </div>
                                        <div class="flex items-start">
                                            <span class="text-sm font-medium text-gray-500 w-16">Email:</span>
                                            <a href="mailto:<%= correo %>" class="text-sm text-[#7A1737] hover:text-[#A8253C] break-all">
                                                <%= correo %>
                                            </a>
                                        </div>
                                    </div>
                                </div>
                                
                                <div class="lg:col-span-1">
                                    <h4 class="text-lg font-semibold text-gray-900 mb-4 flex items-center">
                                        <svg class="w-5 h-5 mr-2 text-[#7A1737]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
                                        </svg>
                                        Proyectos
                                    </h4>
                                    <div class="space-y-3">
                                        <div class="flex justify-between items-center">
                                            <span class="text-sm font-medium text-gray-600">Total de proyectos:</span>
                                            <span class="text-lg font-bold text-[#7A1737]"><%= totalProyectosUsuario %></span>
                                        </div>
                                        <div class="space-y-2">
                                            <% if (proyectosBorrador > 0) { %>
                                                <div class="flex justify-between items-center">
                                                    <span class="text-xs text-gray-600">En borrador:</span>
                                                    <span class="px-2 py-1 text-xs font-medium rounded bg-gray-100 text-gray-800"><%= proyectosBorrador %></span>
                                                </div>
                                            <% } %>
                                            <% if (proyectosEnviados > 0) { %>
                                                <div class="flex justify-between items-center">
                                                    <span class="text-xs text-gray-600">Enviados:</span>
                                                    <span class="px-2 py-1 text-xs font-medium rounded bg-yellow-100 text-yellow-800"><%= proyectosEnviados %></span>
                                                </div>
                                            <% } %>
                                            <% if (proyectosAprobados > 0) { %>
                                                <div class="flex justify-between items-center">
                                                    <span class="text-xs text-gray-600">Aprobados:</span>
                                                    <span class="px-2 py-1 text-xs font-medium rounded bg-green-100 text-green-800"><%= proyectosAprobados %></span>
                                                </div>
                                            <% } %>
                                            <% if (proyectosFinalizados > 0) { %>
                                                <div class="flex justify-between items-center">
                                                    <span class="text-xs text-gray-600">Finalizados:</span>
                                                    <span class="px-2 py-1 text-xs font-medium rounded bg-purple-100 text-purple-800"><%= proyectosFinalizados %></span>
                                                </div>
                                            <% } %>
                                        </div>
                                    </div>
                                </div>
                                
                                <div class="lg:col-span-1">
                                    <h4 class="text-lg font-semibold text-gray-900 mb-4 flex items-center">
                                        <svg class="w-5 h-5 mr-2 text-[#7A1737]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                                        </svg>
                                        Actividad
                                    </h4>
                                    <div class="space-y-4">
                                        <div>
                                            <span class="text-sm font-medium text-gray-600">Última actividad:</span>
                                            <p class="text-sm text-gray-900 mt-1">
                                                <%= ultimaActividad != null ? formatoFecha.format(ultimaActividad) : "Sin actividad registrada" %>
                                            </p>
                                        </div>
                                        
                                        <div class="pt-2 space-y-2">
                                            <button onclick="copyToClipboard(event, '<%= correo %>')" 
                                                    class="w-full bg-[#7A1737] hover:bg-[#A8253C] text-white text-sm font-medium py-2 px-4 rounded-lg transition duration-200 flex items-center justify-center">
                                                <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z"></path>
                                                </svg>
                                                Copiar Email
                                            </button>
                                            
                                            <% if (isActivo) { %>
                                                <a href="cambiar_estado.jsp?id=<%= id %>&estado=1" onclick="return confirm('¿Estás seguro de desactivar a este usuario? No podrá iniciar sesión.');"
                                                   class="w-full bg-red-600 hover:bg-red-700 text-white text-sm font-medium py-2 px-4 rounded-lg transition duration-200 flex items-center justify-center">
                                                    <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18.364 18.364A9 9 0 005.636 5.636m12.728 12.728A9 9 0 015.636 5.636m12.728 12.728L5.636 5.636"></path>
                                                    </svg>
                                                    Desactivar Usuario
                                                </a>
                                            <% } else { %>
                                                <a href="cambiar_estado.jsp?id=<%= id %>&estado=2" onclick="return confirm('¿Estás seguro de reactivar a este usuario?');"
                                                   class="w-full bg-green-600 hover:bg-green-700 text-white text-sm font-medium py-2 px-4 rounded-lg transition duration-200 flex items-center justify-center">
                                                    <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                                                    </svg>
                                                    Activar Usuario
                                                </a>
                                            <% } %>
                                            
                                            <% if (totalProyectosUsuario > 0) { %>
                                                <a href="/proyectos/pages/analista/proyectos/" 
                                                   class="w-full bg-[#B28854] hover:bg-[#9A7148] text-white text-sm font-medium py-2 px-4 rounded-lg transition duration-200 flex items-center justify-center">
                                                    <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                                                    </svg>
                                                    Ver Proyectos
                                                </a>
                                            <% } %>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } %>
        
        <% if (usuariosResponsables.isEmpty() && mensajeError == null) { %>
            <div class="text-center py-12">
                <p class="text-gray-500 text-lg">No hay usuarios responsables para mostrar.</p>
            </div>
        <% } %>
    </div>
    
    <div class="mt-20 mb-16"></div>
    
    <%@ include file="/footer.jsp" %>
    
    <script>
        // Función para copiar email al portapapeles (compatible con HTTP)
        function copyToClipboard(event, email) {
            let success = false;
            
            // Método 1: Usar navigator.clipboard si está disponible (HTTPS/localhost)
            if (navigator.clipboard && navigator.clipboard.writeText) {
                navigator.clipboard.writeText(email).then(function() {
                    showCopySuccess(event);
                }).catch(function() {
                    // Si falla, intentar método alternativo
                    success = fallbackCopyToClipboard(email);
                    if (success) {
                        showCopySuccess(event);
                    } else {
                        alert('No se pudo copiar el email al portapapeles');
                    }
                });
            } else {
                // Método 2: Fallback para HTTP usando execCommand
                success = fallbackCopyToClipboard(email);
                if (success) {
                    showCopySuccess(event);
                } else {
                    alert('No se pudo copiar el email al portapapeles');
                }
            }
        }
        
        // Método alternativo para copiar (funciona en HTTP)
        function fallbackCopyToClipboard(text) {
            const textArea = document.createElement('textarea');
            textArea.value = text;
            textArea.style.position = 'fixed';
            textArea.style.left = '-9999px';
            textArea.style.top = '-9999px';
            document.body.appendChild(textArea);
            textArea.focus();
            textArea.select();
            
            let success = false;
            try {
                success = document.execCommand('copy');
            } catch (err) {
                console.error('Error al copiar:', err);
            }
            
            document.body.removeChild(textArea);
            return success;
        }
        
        // Mostrar confirmación visual de copia exitosa
        function showCopySuccess(event) {
            const originalButton = event.target.closest('button');
            const originalContent = originalButton.innerHTML;
            
            originalButton.innerHTML = `
                <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                </svg>
                ¡Copiado!
            `;
            originalButton.classList.remove('bg-[#7A1737]', 'hover:bg-[#A8253C]');
            originalButton.classList.add('bg-green-600', 'hover:bg-green-700');
            setTimeout(() => {
                originalButton.innerHTML = originalContent;
                originalButton.classList.remove('bg-green-600', 'hover:bg-green-700');
                originalButton.classList.add('bg-[#7A1737]', 'hover:bg-[#A8253C]');
            }, 2000);
        }

        function visualizarPDF(ruta, nombre) {
          const modal = document.getElementById('pdfModal');
          const pdfFrame = document.getElementById('pdfFrame');
          const pdfTitle = document.getElementById('pdfTitle');

          pdfFrame.src = ruta;
          pdfTitle.textContent = nombre;
          modal.style.display = 'flex';

          // Evitar que el modal se cierre al hacer clic en el contenido
          modal.addEventListener('click', function(e) {
            if (e.target === modal) {
              closePDFModal();
            }
          });
        }

        function closePDFModal() {
          const modal = document.getElementById('pdfModal');
          const pdfFrame = document.getElementById('pdfFrame');

          pdfFrame.src = '';
          modal.style.display = 'none';
        }
        
        // Agregar efecto de hover mejorado a las tarjetas
        document.addEventListener('DOMContentLoaded', function() {
            const cards = document.querySelectorAll('.card-hover');
            cards.forEach(card => {
                card.addEventListener('mouseenter', function() {
                    this.style.transform = 'translateY(-4px)';
                });
                card.addEventListener('mouseleave', function() {
                    this.style.transform = 'translateY(0)';
                });
            });
        });
    </script>
</body>
</html>
