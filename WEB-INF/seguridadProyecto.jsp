<%@ page pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Properties" %>
<%@ page import="java.io.*" %>
<%
    // Este archivo no debe tener etiquetas HTML, solo lógica Java
    Integer idUsuarioSeguridad = (Integer) session.getAttribute("id_usuario");

    if (idUsuarioSeguridad != null) {
        boolean tieneProyectoActivo = false;
        
        try {
            // Cargar configuración centralizada
            Properties propsSec = new Properties();
            String pathSec = application.getRealPath("/WEB-INF/classes/db.properties");
            
            if (pathSec != null && new java.io.File(pathSec).exists()) {
                try (FileInputStream fis = new FileInputStream(pathSec)) {
                    propsSec.load(fis);
                }
            } else {
                try (InputStream is = this.getClass().getResourceAsStream("/db.properties")) {
                    if (is != null) propsSec.load(is);
                }
            }

            Class.forName("org.postgresql.Driver");
            try (Connection connSec = DriverManager.getConnection(
                    propsSec.getProperty("db.url"), 
                    propsSec.getProperty("db.user"), 
                    propsSec.getProperty("db.pass"));
                 PreparedStatement psSec = connSec.prepareStatement(
                    "SELECT p.estado_proyecto, p.convocatoria_id, " +
                    "(SELECT COUNT(*) FROM convocatoria WHERE estado = 2) as hay_activa, " +
                    "(SELECT COUNT(*) FROM convocatoria WHERE estado = 2 AND id_convocatoria = p.convocatoria_id) as es_misma_activa " +
                    "FROM proyectos p " +
                    "JOIN proyecto_usuarios pu ON p.id_proyecto = pu.id_proyecto " +
                    "WHERE pu.id_usuario = ? " +
                    "ORDER BY p.id_proyecto DESC LIMIT 1")) {

                psSec.setInt(1, idUsuarioSeguridad);
                try (ResultSet rsSec = psSec.executeQuery()) {
                    if (rsSec.next()) {
                        String estado = rsSec.getString("estado_proyecto");
                        int hayActiva = rsSec.getInt("hay_activa");
                        int esMismaActiva = rsSec.getInt("es_misma_activa");
                        
                        if (estado != null) {
                            estado = estado.trim();
                            
                            if ("7".equals(estado)) {
                                // Cancelado -> Permite acceso
                                tieneProyectoActivo = false;
                            } else if (!"5".equals(estado)) {
                                // En curso -> Bloquea
                                tieneProyectoActivo = true;
                            } else {
                                // Finalizado
                                if (hayActiva == 0) {
                                    tieneProyectoActivo = true; // No hay convocatoria
                                } else if (esMismaActiva > 0) {
                                    tieneProyectoActivo = true; // Ya postuló a esta
                                } else {
                                    tieneProyectoActivo = false; // Nueva convocatoria disponible
                                }
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (tieneProyectoActivo) {
            response.sendRedirect(request.getContextPath() + "/pages/responsableDeproyecto/paginaPrincipal/index.jsp");
            return;
        }
    }
%>