<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // Configurar respuesta JSON
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    // Solo permitir método POST para mayor seguridad
    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.setStatus(405);
        out.print("{\"success\": false, \"error\": \"Método no permitido. Use POST.\"}");
        return;
    }
    
    // VALIDACIÓN DE SESIÓN
    if (!"analista".equals(String.valueOf(session.getAttribute("rol")))) { 
        response.setStatus(401);
        out.print("{\"success\": false, \"error\": \"No autorizado. Inicie sesión como analista.\"}");
        return; 
    }
    
    // VALIDACIÓN DE TOKEN CSRF
    String tokenEnviado = request.getParameter("csrf_token");
    String tokenSesion = (String) session.getAttribute("csrf_token");
    
    if (tokenSesion == null || tokenEnviado == null || !tokenSesion.equals(tokenEnviado)) {
        response.setStatus(403);
        out.print("{\"success\": false, \"error\": \"Token de seguridad inválido. Recargue la página e intente de nuevo.\"}");
        return;
    }
%>

<%@ include file="/WEB-INF/conexion.jsp" %>

<%
    String idStr = request.getParameter("id");
    String estadoStr = request.getParameter("estado");
    
    if (idStr == null || estadoStr == null || idStr.trim().isEmpty() || estadoStr.trim().isEmpty()) {
        response.setStatus(400);
        out.print("{\"success\": false, \"error\": \"Parámetros faltantes o inválidos.\"}");
        return;
    }
    
    if (conn != null) {
        try {
            int idUsuario = Integer.parseInt(idStr);
            int nuevoEstado = Integer.parseInt(estadoStr);
            
            // Validar que el estado sea válido (1 = inactivo, 2 = activo)
            if (nuevoEstado != 1 && nuevoEstado != 2) {
                response.setStatus(400);
                out.print("{\"success\": false, \"error\": \"Estado inválido.\"}");
                return;
            }
            
            // VALIDACIÓN DE PERMISOS: Solo permitir modificar usuarios con rol "responsable"
            // Esto previene que un analista pueda modificar a otros analistas o administradores
            String sqlVerificar = "SELECT u.id_usuario, t.tipo_usuario " +
                                  "FROM usuarios u " +
                                  "JOIN tipo_usuario t ON u.tipousuario = t.id_tipo_usuario " +
                                  "WHERE u.id_usuario = ?";
            
            try (PreparedStatement stmtVerificar = conn.prepareStatement(sqlVerificar)) {
                stmtVerificar.setInt(1, idUsuario);
                try (ResultSet rs = stmtVerificar.executeQuery()) {
                    if (!rs.next()) {
                        response.setStatus(404);
                        out.print("{\"success\": false, \"error\": \"Usuario no encontrado.\"}");
                        return;
                    }
                    
                    String rolUsuario = rs.getString("tipo_usuario");
                    // Solo permitir modificar usuarios con rol "responsable"
                    if (!"responsable".equalsIgnoreCase(rolUsuario)) {
                        response.setStatus(403);
                        out.print("{\"success\": false, \"error\": \"No tiene permisos para modificar este tipo de usuario.\"}");
                        return;
                    }
                }
            }
            
            // Actualizar el estado del usuario
            String sql = "UPDATE usuarios SET estado = ? WHERE id_usuario = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, nuevoEstado);
                stmt.setInt(2, idUsuario);
                int filasAfectadas = stmt.executeUpdate();
                
                if (filasAfectadas > 0) {
                    String mensaje = nuevoEstado == 2 ? "Usuario activado correctamente." : "Usuario desactivado correctamente.";
                    out.print("{\"success\": true, \"message\": \"" + mensaje + "\", \"nuevoEstado\": " + nuevoEstado + "}");
                } else {
                    response.setStatus(404);
                    out.print("{\"success\": false, \"error\": \"No se pudo actualizar el usuario.\"}");
                }
            }
            
        } catch (NumberFormatException e) {
            response.setStatus(400);
            out.print("{\"success\": false, \"error\": \"ID o estado inválido.\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(500);
            out.print("{\"success\": false, \"error\": \"Error interno del servidor.\"}");
        } finally {
            try {
                if (conn != null && !conn.isClosed()) {
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    } else {
        response.setStatus(500);
        out.print("{\"success\": false, \"error\": \"Error de conexión a la base de datos.\"}");
    }
%>