<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    String token = request.getParameter("t");
    boolean activado = false;
    
    if (token != null && !token.isEmpty()) {
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            Class.forName("org.postgresql.Driver");
            String dbURL = "jdbc:postgresql://localhost:5432/proyectos"; // Cambia esto
            String dbUser = "dbusr25"; // Cambia esto
            String dbPass = "mxToro24000Chocolate"; // Cambia esto

            conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
            
            String sql = "UPDATE usuarios SET estado= 2, token_activacion = NULL WHERE token_activacion = ?";
            
            ps = conn.prepareStatement(sql);
            ps.setString(1, token);
            
            int filas = ps.executeUpdate();
            if (filas > 0) {
                activado = true;
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if(ps != null) try { ps.close(); } catch(Exception e){}
            if(conn != null) try { conn.close(); } catch(Exception e){}
        }
    }

    if (activado) {
        // Redirigir al login con mensaje de éxito
        response.sendRedirect("pages/login/login.jsp?msg=cuenta_activada");
    } else {
        // Redirigir con error (token inválido o expirado)
        response.sendRedirect("pages/login/login.jsp?error=token_invalido");
    }
%>