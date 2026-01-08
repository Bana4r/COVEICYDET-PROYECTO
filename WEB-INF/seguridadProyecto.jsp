<%@ page pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    // Este archivo no debe tener etiquetas HTML, solo lógica Java
    Integer idUsuarioSeguridad = (Integer) session.getAttribute("id_usuario");

    if (idUsuarioSeguridad != null) {
        boolean tieneProyectoActivo = false;
        
        // Usamos la conexión que ya debe estar abierta o abrimos una nueva
        // Nota: Asumimos que quien incluye este archivo ya tiene acceso a las credenciales o al pool
        String urlSec = "jdbc:postgresql://localhost:5432/proyectos";
        String userSec = "dbusr25";
        String passSec = "mxToro24000Chocolate";

        try {
            Class.forName("org.postgresql.Driver");
            try (Connection connSec = DriverManager.getConnection(urlSec, userSec, passSec);
                 PreparedStatement psSec = connSec.prepareStatement(
                    "SELECT p.estado_proyecto " +
                    "FROM proyectos p " +
                    "JOIN proyecto_usuarios pu ON p.id_proyecto = pu.id_proyecto " +
                    "WHERE pu.id_usuario = ? " +
                    "ORDER BY p.id_proyecto DESC LIMIT 1")) {

                psSec.setInt(1, idUsuarioSeguridad);
                try (ResultSet rsSec = psSec.executeQuery()) {
                    if (rsSec.next()) {
                        String estado = rsSec.getString("estado_proyecto");
                        if (estado != null && !"Finalizado".equalsIgnoreCase(estado)) {
                            tieneProyectoActivo = true;
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