<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.File, java.util.logging.Logger" %>

<%
    String jsonResponse = "";
    Logger logger = Logger.getLogger("deleteFile.jsp");

    try {
        // 1. SEGURIDAD: Obtener el ID del usuario desde la sesión
        // Si no hay sesión, no permitimos borrar nada.
        HttpSession sesion = request.getSession(false);
        Object idUsuarioObj = (sesion != null) ? sesion.getAttribute("id_usuario") : null;

        if (idUsuarioObj == null) {
            throw new SecurityException("No hay sesión activa. No se puede eliminar el archivo.");
        }
        String idUsuario = idUsuarioObj.toString();

        // 2. Obtener la URL del archivo que viene del cliente
        String fileUrl = request.getParameter("fileUrl");
        if (fileUrl == null || fileUrl.isEmpty()) {
            throw new Exception("No se especificó la URL del archivo (fileUrl).");
        }

        // 3. Obtener SOLO el nombre del archivo
        // Ignoramos las carpetas que vengan en la URL para evitar trucos.
        // Ejemplo entrada: ".../uploads/15/mi_foto.png" -> "mi_foto.png"
        String fileName = fileUrl.substring(fileUrl.lastIndexOf('/') + 1);

        // 4. Sanear el nombre del archivo (evitar Path Traversal básico)
        if (fileName.contains("..") || fileName.contains("/") || fileName.contains("\\")) {
            throw new SecurityException("Nombre de archivo no válido.");
        }

        // 5. Construir la ruta usando el ID de SESIÓN
        // Ruta base: /var/.../proyectos/uploads/
        String appPath = request.getServletContext().getRealPath("/");
        
        // Ruta carpeta usuario: /var/.../proyectos/uploads/{ID_USUARIO}/
        File userDir = new File(appPath + "uploads" + File.separator + idUsuario);
        
        // Archivo final
        File fileToDelete = new File(userDir, fileName);

        // 6. Verificaciones extra de seguridad
        // Nos aseguramos que el archivo realmente esté dentro de la carpeta del usuario
        String userDirCanonical = userDir.getCanonicalPath();
        String fileToDeleteCanonical = fileToDelete.getCanonicalPath();

        if (!fileToDeleteCanonical.startsWith(userDirCanonical)) {
            throw new SecurityException("Intento de borrar un archivo fuera de su carpeta.");
        }

        // 7. Borrar el archivo
        if (fileToDelete.exists()) {
            if (fileToDelete.delete()) {
                jsonResponse = "{\"success\": true, \"message\": \"Archivo eliminado exitosamente.\"}";
            } else {
                throw new Exception("No se pudo eliminar el archivo del servidor (error de sistema).");
            }
        } else {
            // Si el archivo no existe, devolvemos success true para que la interfaz se limpie
            jsonResponse = "{\"success\": true, \"message\": \"El archivo ya no existía.\"}";
        }

    } catch (Exception e) {
        logger.severe("Error al eliminar archivo: " + e.getMessage());
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        // Escapamos comillas para el JSON
        jsonResponse = String.format("{\"success\": false, \"message\": \"Error: %s\"}", 
            e.getMessage().replace("\"", "\\\"")
        );
    }

    // 8. Enviar respuesta
    response.getWriter().write(jsonResponse);
%>