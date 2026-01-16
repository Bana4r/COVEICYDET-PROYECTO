<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.UUID" %>
<%@ page import="java.net.*" %>
<%@ page import="java.io.*" %>

<%@ include file="/WEB-INF/conexion.jsp" %>
<%@ include file="/WEB-INF/correo.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");
    String email = request.getParameter("email");

        if (email != null && !email.isEmpty()) {
            PreparedStatement ps = null;
            boolean usuarioExiste = false;
            String token = UUID.randomUUID().toString();

        try {

            // 3. ACTUALIZAR EL TOKEN EN LA BASE DE DATOS
            String sql = "UPDATE usuarios SET token_cambiocontrasena = ? WHERE correo_electronico = ?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, token);
            ps.setString(2, email);
            
            int filas = ps.executeUpdate();
            
            if (filas > 0) {
                usuarioExiste = true;
                
                // 4. CONSTRUIR EL LINK
                String baseURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath();
                String linkRecuperacion = baseURL + "/pages/recuperarContrasena/recuperarContrasena.jsp?t=" + token;

                // 5. ENVÍO DE CORREO USANDO mailApiUrl del include
                String asunto = URLEncoder.encode("Cambio de contraseña - COVEICYDET", "UTF-8");
                String mensajeCuerpo = "Para cambiar la contraseña ingrese al siguiente link: " + linkRecuperacion + " . Pedirá ingresar su nueva contraseña y aceptar, una vez realizados los cambios la nueva contraseña será aplicada.";
                String mensajeEncoded = URLEncoder.encode(mensajeCuerpo, "UTF-8");

                String apiURL = mailApiUrl + "?DESTINATARIO=" + email + 
                                "&ASUNTO=" + asunto + 
                                "&MENSAJE=" + mensajeEncoded;

                URL url = new URL(apiURL);
                HttpURLConnection connection = (HttpURLConnection) url.openConnection();
                connection.setRequestMethod("GET");
                connection.setRequestProperty("User-Agent", "Mozilla/5.0");
                connection.setConnectTimeout(10000);
                connection.setReadTimeout(10000);
                connection.connect();
                
                int responseCode = connection.getResponseCode();
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if(ps != null) try { ps.close(); } catch(Exception e){}
            if(conn != null) try { conn.close(); } catch(Exception e){}
        }
    }

    // Redirigir al login con mensaje de éxito
    response.sendRedirect(request.getContextPath() + "/pages/login/login.jsp?msg=recuperacion_enviada");
%>