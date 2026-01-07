<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.util.*, javax.servlet.http.*" %>
<%@ page import="java.util.Base64" %>

<%
    String appPath = request.getServletContext().getRealPath("/");
    String jsonResponse = "";

    try {
        // 1. OBTENER USUARIO DE LA SESIÓN (Seguro y sin BD)
        // -------------------------------------------------
        HttpSession sesion = request.getSession(false);
        Object idUsuarioObj = (sesion != null) ? sesion.getAttribute("id_usuario") : null;

        if (idUsuarioObj == null) {
            throw new Exception("La sesión ha expirado o el usuario no está logueado.");
        }
        
        String idUsuario = idUsuarioObj.toString(); // "15", "20", etc.
        // -------------------------------------------------

        // 2. Obtener datos del archivo
        String base64Data = request.getParameter("fileData");
        String originalFileName = request.getParameter("fileName");

        if (base64Data == null || base64Data.isEmpty() || originalFileName == null || originalFileName.isEmpty()) {
            throw new Exception("No se recibieron datos de archivo.");
        }

        // 3. Crear ruta segmentada: /uploads/{idUsuario}/
        String UPLOAD_DIRECTORY = appPath + "uploads" + File.separator + idUsuario;

        // Decodificar Base64
        String base64String = base64Data.substring(base64Data.indexOf(',') + 1);
        byte[] fileBytes = Base64.getDecoder().decode(base64String);

        // Generar nombre único
        String uniqueID = UUID.randomUUID().toString();
        String fileExtension = "";
        int i = originalFileName.lastIndexOf('.');
        if (i > 0) fileExtension = originalFileName.substring(i);
        String uniqueFileName = uniqueID + fileExtension;

        // 4. Crear directorios
        File uploadDir = new File(UPLOAD_DIRECTORY);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs(); // Crea /uploads/ Y /uploads/idUsuario/
        }

        // 5. Guardar archivo
        File file = new File(UPLOAD_DIRECTORY + File.separator + uniqueFileName);
        try (OutputStream output = new FileOutputStream(file)) {
            output.write(fileBytes);
        }
        
        // 6. Respuesta JSON con la ruta web correcta
        String webUrl = request.getContextPath() + "/uploads/" + idUsuario + "/" + uniqueFileName;
        
        jsonResponse = String.format("{\"success\": true, \"webUrl\": \"%s\", \"originalName\": \"%s\"}",
            webUrl.replace("\\", "\\\\"),
            originalFileName.replace("\"", "\\\"")
        );

    } catch (Exception e) {
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        jsonResponse = String.format("{\"success\": false, \"message\": \"Error: %s\"}", 
            e.getMessage().replace("\"", "\\\"")
        );
    }

    response.getWriter().write(jsonResponse);
%>