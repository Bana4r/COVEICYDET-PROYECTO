<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.File, java.util.logging.Logger" %>

<%
    Logger logger = Logger.getLogger("deleteFile.jsp");
    String jsonResponse = "";

    try {
        // 1. SEGURIDAD: Obtener el ID del usuario desde la sesión
        HttpSession sesion = request.getSession(false);
        Object idUsuarioObj = (sesion != null) ? sesion.getAttribute("id_usuario") : null;

        if (idUsuarioObj == null) {
            throw new SecurityException("No hay sesión activa. No se puede eliminar el archivo.");
        }
        String idUsuario = idUsuarioObj.toString();
        logger.info(">>> [DELETE] Usuario ID: " + idUsuario);

        // 2. Obtener la URL del archivo que viene del cliente
        String fileUrl = request.getParameter("fileUrl");
        logger.info(">>> [DELETE] fileUrl: " + fileUrl);
        
        if (fileUrl == null || fileUrl.isEmpty()) {
            throw new Exception("No se especificó la URL del archivo (fileUrl).");
        }

        // 3. Obtener SOLO el nombre del archivo
        String fileName = fileUrl.substring(fileUrl.lastIndexOf('/') + 1);
        logger.info(">>> [DELETE] fileName: " + fileName);

        // 4. Sanear el nombre del archivo (evitar Path Traversal)
        if (fileName.contains("..") || fileName.contains("/") || fileName.contains("\\")) {
            throw new SecurityException("Nombre de archivo no válido: " + fileName);
        }

        // 5. Construir la ruta usando el ID de SESIÓN
        String appPath = request.getServletContext().getRealPath("/");
        File userDir = new File(appPath + "uploads" + File.separator + "evaluadores" + File.separator + idUsuario);
        File fileToDelete = new File(userDir, fileName);

        logger.info(">>> [DELETE] Ruta completa: " + fileToDelete.getAbsolutePath());

        // 6. Verificaciones extra de seguridad
        String userDirCanonical = userDir.getCanonicalPath();
        String fileToDeleteCanonical = fileToDelete.getCanonicalPath();

        if (!fileToDeleteCanonical.startsWith(userDirCanonical)) {
            throw new SecurityException("Intento de borrar un archivo fuera de su carpeta.");
        }

        // 7. Borrar el archivo
        if (fileToDelete.exists()) {
            if (fileToDelete.delete()) {
                jsonResponse = "{\"success\": true, \"message\": \"Archivo eliminado exitosamente.\"}";
                logger.info(">>> [DELETE] Archivo eliminado: " + fileName);
            } else {
                throw new Exception("No se pudo eliminar el archivo del servidor (error de sistema).");
            }
        } else {
            logger.warning(">>> [DELETE] El archivo no existía: " + fileName);
            jsonResponse = "{\"success\": true, \"message\": \"El archivo ya no existía.\"}";
        }

    } catch (Exception e) {
        logger.severe(">>> [DELETE] Error: " + e.getMessage());
        e.printStackTrace();
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        jsonResponse = String.format("{\"success\": false, \"message\": \"Error: %s\"}",
            e.getMessage().replace("\"", "\\\"")
        );
    }

    response.getWriter().write(jsonResponse);
    response.getWriter().flush();
%>
