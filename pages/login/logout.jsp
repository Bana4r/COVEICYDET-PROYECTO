<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
  // 1. OBTENER ID ANTES DE CERRAR LA SESIÓN
  // Necesitamos saber quién es para borrar SU token en la BD
  Integer idUsuario = (Integer) session.getAttribute("id_usuario");

  // 2. BORRAR EL TOKEN DE LA BASE DE DATOS (SEGURIDAD)
  if (idUsuario != null) {
    Connection conn = null;
    PreparedStatement ps = null;
    try {
      Class.forName("org.postgresql.Driver");
      conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/proyectos", "dbusr25", "mxToro24000Chocolate");
            
      // Ponemos el token en NULL para invalidarlo
      String sql = "UPDATE usuarios SET token_sesion = NULL WHERE id_usuario = ?";
      ps = conn.prepareStatement(sql);
      ps.setInt(1, idUsuario);
      ps.executeUpdate();
            
    } catch (Exception e) {
      e.printStackTrace();
      System.out.println("Error al borrar token en logout: " + e.getMessage());
    } finally {
      if (ps != null) try { ps.close(); } catch (SQLException e) {}
      if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
  }

  // 3. BORRAR LA COOKIE DEL NAVEGADOR
  // Creamos una cookie con el mismo nombre pero valor vacío y vida 0
  Cookie cookieToken = new Cookie("auth_token", "");
  cookieToken.setMaxAge(0); // 0 segundos = borrar inmediatamente
  cookieToken.setPath("/"); // Importante: mismo path que cuando se creó
  response.addCookie(cookieToken);

  // 4. DESTRUIR LA SESIÓN DEL SERVIDOR
  session.invalidate();

  // 5. REDIRIGIR AL LOGIN
  response.sendRedirect(request.getContextPath() + "/pages/login/login.jsp");
%>
