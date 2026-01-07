<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%!
    // IMPORTANTE: Esta variable debe ser IDÉNTICA a la de tu procesar_login.jsp
    private static final String APP_SALT = "C0v31cYd3T_Pr0y3ct0_2025_#Secreto!";

    public String hashPassword(String password) {
        try {
            java.security.MessageDigest digest = java.security.MessageDigest.getInstance("SHA-256");
            String input = APP_SALT + password; // Misma fórmula que en el login
            byte[] encodedhash = digest.digest(input.getBytes(java.nio.charset.StandardCharsets.UTF_8));
            
            StringBuilder hexString = new StringBuilder();
            for (byte b : encodedhash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (Exception e) {
            return "Error: " + e.getMessage();
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Generador de Hashes</title>
    <style>body { font-family: monospace; padding: 20px; }</style>
</head>
<body>
    <h2>Generador de Hashes (SHA-256 + Salt)</h2>
    <hr>
    
    <% 
        String[] claves = {"analista1", "analista2", "analista3", "analista4", "123456"};
        
        for(String clave : claves) {
    %>
        <p>
            <strong>Usuario:</strong> <%= clave %><br>
            <strong>Hash para BD:</strong> 
            <span style="background: #eee; padding: 2px;">
                <%= hashPassword(clave) %>
            </span>
        </p>
    <% } %>
    
    <div style="margin-top:20px; color: red;">
        Nota: Borra este archivo cuando termines de configurar la base de datos.
    </div>
</body>
</html>