<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.security.MessageDigest" %>
<%@ page import="java.nio.charset.StandardCharsets" %>

<%!
    // MISMA LÓGICA DE HASH QUE EN EL REGISTRO
    private static final String APP_SALT = "C0v31cYd3T_Pr0y3ct0_2025_#Secreto!";
    public String hashPassword(String password) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            String input = APP_SALT + password;
            byte[] encodedhash = digest.digest(input.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : encodedhash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
%>

<%
    request.setCharacterEncoding("UTF-8");
    String token = request.getParameter("token");
    String password = request.getParameter("password");

    if (token != null && password != null) {
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            Class.forName("org.postgresql.Driver");
            String dbURL = "jdbc:postgresql://localhost:5432/proyectos";
            conn = DriverManager.getConnection(dbURL, "dbusr25", "mxToro24000Chocolate");

            // Hashear nueva contraseña
            String passwordHashed = hashPassword(password);

            // Actualizar contraseña y borrar token para que no se use de nuevo
            String sql = "UPDATE usuarios SET contrasena = ?, token_cambiocontrasena = NULL WHERE token_cambiocontrasena = ?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, passwordHashed);
            ps.setString(2, token);
            
            int filas = ps.executeUpdate();
            
            if (filas > 0) {
                response.sendRedirect(request.getContextPath() + "/pages/login/login.jsp?msg=password_actualizado");
            } else {
                response.sendRedirect(request.getContextPath() + "/pages/login/login.jsp?error=token_invalido_pass");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/pages/login/login.jsp?error=bd_error");
        } finally {
            if(ps != null) try{ps.close();}catch(Exception e){}
            if(conn != null) try{conn.close();}catch(Exception e){}
        }
    } else {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
    }
%>