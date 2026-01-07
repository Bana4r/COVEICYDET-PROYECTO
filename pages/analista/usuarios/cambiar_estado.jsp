<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%-- VALIDACIÓN DE SESIÓN --%>
<% 
    if (!"analista".equals(String.valueOf(session.getAttribute("rol")))) { 
        response.sendRedirect(request.getContextPath()+"/pages/login/login.jsp"); 
        return; 
    } 
%>

<%!
    // Configuración de la base de datos
    private static final String DB_URL = "jdbc:postgresql://localhost:5432/proyectos?useUnicode=true&characterEncoding=UTF-8";
    private static final String DB_USER = "dbusr25";
    private static final String DB_PASSWORD = "mxToro24000Chocolate";
%>

<%
    String idStr = request.getParameter("id");
    String estadoStr = request.getParameter("estado");
    
    if (idStr != null && estadoStr != null) {
        try {
            int idUsuario = Integer.parseInt(idStr);
            int nuevoEstado = Integer.parseInt(estadoStr);
            
            Class.forName("org.postgresql.Driver");
            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
                String sql = "UPDATE usuarios SET estado = ? WHERE id_usuario = ?";
                try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setInt(1, nuevoEstado);
                    stmt.setInt(2, idUsuario);
                    stmt.executeUpdate();
                }
            }
            
            // Redirigir con éxito
            response.sendRedirect("usuarios.jsp?msg=estado_actualizado");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("usuarios.jsp?error=error_actualizacion");
        }
    } else {
        response.sendRedirect("usuarios.jsp?error=parametros_faltantes");
    }
%>