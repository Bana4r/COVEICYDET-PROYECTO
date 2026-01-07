<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.UUID" %>
<%@ page import="java.net.*" %>
<%@ page import="java.io.*" %>

<%
    request.setCharacterEncoding("UTF-8");
    String email = request.getParameter("email");

    if (email != null && !email.isEmpty()) {
        Connection conn = null;
        PreparedStatement ps = null;
        boolean usuarioExiste = false;
        String token = UUID.randomUUID().toString();

        try {
            // 1. CONEXIÓN A BD
            Class.forName("org.postgresql.Driver");
            String dbURL = "jdbc:postgresql://localhost:5432/proyectos";
            String dbUser = "dbusr25";
            String dbPass = "mxToro24000Chocolate";
            conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

            // 2. ACTUALIZAR EL TOKEN EN LA BASE DE DATOS
            // Solo si el correo existe y el usuario está activo (o registrado)
            String sql = "UPDATE usuarios SET token_cambiocontrasena = ? WHERE correo_electronico = ?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, token);
            ps.setString(2, email);
            
            int filas = ps.executeUpdate();
            
            if (filas > 0) {
                usuarioExiste = true;
                
                // 3. CONSTRUIR EL LINK
                String baseURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath();
                String linkRecuperacion = baseURL + "/pages/recuperarContrasena/recuperarContrasena.jsp?t=" + token;

                // 4. ENVÍO DE CORREO (USANDO TU API)
                String asunto = URLEncoder.encode("Cambio de contraseña - COVEICYDET", "UTF-8");
                String mensajeCuerpo = "Para cambiar la contraseña ingrese al siguiente link: " + linkRecuperacion + " . Pedirá ingresar su nueva contraseña y aceptar, una vez realizados los cambios la nueva contraseña será aplicada.";
                String mensajeEncoded = URLEncoder.encode(mensajeCuerpo, "UTF-8");

                String apiURL = "https://covecyt.gob.mx/libmail.php?DESTINATARIO=" + email + 
                                "&ASUNTO=" + asunto + 
                                "&MENSAJE=" + mensajeEncoded;

                URL url = new URL(apiURL);
                HttpURLConnection connection = (HttpURLConnection) url.openConnection();
                connection.setRequestMethod("GET");
                connection.setRequestProperty("User-Agent", "Mozilla/5.0");
                connection.setConnectTimeout(10000);
                connection.setReadTimeout(10000);
                connection.connect();
                
                // Es necesario leer la respuesta para ejecutar la petición
                int responseCode = connection.getResponseCode();
            }

        } catch (Exception e) {
            e.printStackTrace();
            // En producción podrías redirigir a una página de error genérica
        } finally {
            if(ps != null) try { ps.close(); } catch(Exception e){}
            if(conn != null) try { conn.close(); } catch(Exception e){}
        }
    }

    // REDIRECCIÓN FINAL AL LOGIN (Siempre redirige al login, exista o no el correo por seguridad)
    // Esto mostrará el popup de SweetAlert
    response.sendRedirect(request.getContextPath() + "/pages/login/login.jsp?msg=recuperacion_enviada");
%>