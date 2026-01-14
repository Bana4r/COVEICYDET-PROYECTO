<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%-- VALIDACIÓN DE SESIÓN --%>
<% 
    if (!"analista".equals(String.valueOf(session.getAttribute("rol")))) { 
        response.sendRedirect(request.getContextPath()+"/pages/login/login.jsp"); 
        return; 
    } 
%>

<%@ include file="/WEB-INF/conexion.jsp" %>

<%
    String idStr = request.getParameter("id");
    String estadoStr = request.getParameter("estado");
    
    if (idStr != null && estadoStr != null) {
        if (conn != null) {
            try {
                int idUsuario = Integer.parseInt(idStr);
                int nuevoEstado = Integer.parseInt(estadoStr);
                
                String sql = "UPDATE usuarios SET estado = ? WHERE id_usuario = ?";
                try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setInt(1, nuevoEstado);
                    stmt.setInt(2, idUsuario);
                    stmt.executeUpdate();
                }
                
                // Redirigir con éxito
                response.sendRedirect("index.jsp?msg=estado_actualizado");
                
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("index.jsp?error=error_actualizacion");
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
            // Error de conexión
            response.sendRedirect("index.jsp?error=conexion_fallida");
        }
    } else {
        response.sendRedirect("index.jsp?error=parametros_faltantes");
    }
%>