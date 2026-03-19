<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.util.*" %>
<%@ page import="java.util.Base64" %>
<%@ page import="java.nio.file.*" %>
<%@ page import="java.util.logging.*" %>

<%
    Logger logger = Logger.getLogger("upload.jsp");
    String appPath = request.getServletContext().getRealPath("/");
    String jsonResponse = "";

    try {
        // 1. OBTENER USUARIO DE LA SESIÓN
        HttpSession sesion = request.getSession(false);
        if (sesion == null) {
            throw new Exception("No hay sesión activa");
        }
        
        Object idUsuarioObj = sesion.getAttribute("id_usuario");
        if (idUsuarioObj == null) {
            throw new Exception("La sesión ha expirado o el usuario no está logueado.");
        }

        String idUsuario = idUsuarioObj.toString();
        logger.info(">>> [UPLOAD] Usuario ID: " + idUsuario);

        // 2. Obtener datos del archivo
        String base64Data = request.getParameter("fileData");
        String originalFileName = request.getParameter("fileName");
        String tipoArchivo = request.getParameter("tipoArchivo");

        logger.info(">>> [UPLOAD] fileName: " + originalFileName);
        logger.info(">>> [UPLOAD] tipoArchivo: " + tipoArchivo);

        if (base64Data == null || base64Data.isEmpty()) {
            throw new Exception("No se recibieron datos de archivo (base64Data vacío)");
        }
        
        if (originalFileName == null || originalFileName.isEmpty()) {
            throw new Exception("No se recibió el nombre del archivo");
        }

        // 3. Crear ruta segmentada: /uploads/evaluadores/{idUsuario}/
        String UPLOAD_DIRECTORY = appPath + "uploads" + File.separator + "evaluadores" + File.separator + idUsuario;
        logger.info(">>> [UPLOAD] Directorio: " + UPLOAD_DIRECTORY);

        // Decodificar Base64
        String base64String = base64Data.substring(base64Data.indexOf(',') + 1);
        byte[] fileBytes = Base64.getDecoder().decode(base64String);
        logger.info(">>> [UPLOAD] Tamaño archivo: " + fileBytes.length + " bytes");

        // Generar nombre único
        String uniqueID = UUID.randomUUID().toString();
        String fileExtension = "";
        int i = originalFileName.lastIndexOf('.');
        if (i > 0) fileExtension = originalFileName.substring(i);
        String uniqueFileName = tipoArchivo + "_" + uniqueID + fileExtension;

        // 4. Crear directorios
        File uploadDir = new File(UPLOAD_DIRECTORY);
        if (!uploadDir.exists()) {
            boolean created = uploadDir.mkdirs();
            logger.info(">>> [UPLOAD] Directorio creado: " + created);
        }

        // 5. Guardar archivo
        File file = new File(UPLOAD_DIRECTORY + File.separator + uniqueFileName);
        try (OutputStream output = new FileOutputStream(file)) {
            output.write(fileBytes);
            output.flush();
        }
        logger.info(">>> [UPLOAD] Archivo guardado: " + file.getAbsolutePath());

        // 6. Respuesta JSON con la ruta web correcta
        String webUrl = request.getContextPath() + "/uploads/evaluadores/" + idUsuario + "/" + uniqueFileName;

        jsonResponse = String.format("{\"success\": true, \"webUrl\": \"%s\", \"originalName\": \"%s\", \"tipoArchivo\": \"%s\"}",
            webUrl.replace("\\", "\\\\"),
            originalFileName.replace("\"", "\\\""),
            tipoArchivo
        );

    } catch (Exception e) {
        logger.severe(">>> [UPLOAD] Error: " + e.getMessage());
        e.printStackTrace();
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        jsonResponse = String.format("{\"success\": false, \"message\": \"Error: %s\"}",
            e.getMessage().replace("\"", "\\\"")
        );
    }

    response.getWriter().write(jsonResponse);
    response.getWriter().flush();
%>
