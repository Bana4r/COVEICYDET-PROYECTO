<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%@ include file="../../../WEB-INF/conexion.jsp" %>

<%
    // 1. Obtener ID del usuario antes de cerrar sesión
    Integer idUsuario = (Integer) session.getAttribute("id_usuario");

    // 2. Borrar token de la base de datos
    if (idUsuario != null && conn != null) {
        PreparedStatement ps = null;
        try {
            String sql = "UPDATE usuarios SET token_sesion = NULL WHERE id_usuario = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, idUsuario);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (ps != null) try { ps.close(); } catch (SQLException e) {}
        }
    }

    // 3. Borrar cookie del navegador
    Cookie cookieToken = new Cookie("auth_token", "");
    cookieToken.setMaxAge(0);
    cookieToken.setPath("/");
    response.addCookie(cookieToken);

    // 4. Destruir sesión
    session.invalidate();

    // 5. Redirigir al login de evaluadores
    response.sendRedirect(request.getContextPath() + "/pages/evaluador/login/login.jsp");
%>
