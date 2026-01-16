<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%@ include file="WEB-INF/conexion.jsp" %>

<%
    String token = request.getParameter("t");
    boolean activado = false;
    
    if (token != null && !token.isEmpty()) {
        PreparedStatement ps = null;

        try {
            // La conexión 'conn' ya viene del include
            if (conn != null) {
                String sql = "UPDATE usuarios SET estado= 2, token_activacion = NULL WHERE token_activacion = ?";
                
                ps = conn.prepareStatement(sql);
                ps.setString(1, token);
                
                int filas = ps.executeUpdate();
                if (filas > 0) {
                    activado = true;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if(ps != null) try { ps.close(); } catch(Exception e){}
            if(conn != null) try { conn.close(); } catch(Exception e){}
        }
    }

    // Redirigir según resultado
    if (activado) {
        session.setAttribute("activacion_msg", "cuenta_activada");
        response.sendRedirect(request.getContextPath() + "/registroexitoso/");
    } else {
        // Token inválido o expirado - redirigir al login con error
        session.setAttribute("activacion_error", "El enlace de activación es inválido o ya fue utilizado.");
        response.sendRedirect(request.getContextPath() + "/");
    }
%>