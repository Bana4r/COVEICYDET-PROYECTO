<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.math.BigDecimal" %>
<%@ include file="/WEB-INF/conexion.jsp" %>
<%
    // getTiposPresupuesto.jsp
    // Endpoint para obtener tipos de presupuesto por convocatoria
    
    // Evitar cache
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    // Validar sesión
    if (session == null || session.getAttribute("id_usuario") == null) {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        out.print("{\"error\": \"No autorizado\"}");
        return;
    }

    String idConvocatoriaStr = request.getParameter("id_convocatoria");
    StringBuilder jsonBuilder = new StringBuilder();
    
    jsonBuilder.append("[");

    PreparedStatement stmt = null;
    ResultSet rs = null;
    
    try {
        if (conn == null || conn.isClosed()) {
            throw new SQLException("No hay conexión a base de datos disponible");
        }

        if (idConvocatoriaStr != null && !idConvocatoriaStr.trim().isEmpty()) {
            int idConvocatoria = Integer.parseInt(idConvocatoriaStr);
            
            String sql = "SELECT id_presupuesto, nombre, limite_presupuesto FROM presupuesto_tipo WHERE id_convocatoria = ? ORDER BY nombre";
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, idConvocatoria);
            rs = stmt.executeQuery();
            
            boolean first = true;
            while (rs.next()) {
                if (!first) {
                    jsonBuilder.append(",");
                }
                
                int id = rs.getInt("id_presupuesto");
                String nombre = rs.getString("nombre");
                if (nombre == null) nombre = "";
                // Escapar comillas dobles y caracteres especiales para JSON
                nombre = nombre.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
                
                BigDecimal limite = rs.getBigDecimal("limite_presupuesto");
                if (limite == null) limite = BigDecimal.ZERO;
                
                jsonBuilder.append("{");
                jsonBuilder.append("\"id\":").append(id).append(",");
                jsonBuilder.append("\"nombre\":\"").append(nombre).append("\",");
                jsonBuilder.append("\"limite\":").append(limite.toPlainString());
                jsonBuilder.append("}");
                
                first = false;
            }
        }
    } catch (NumberFormatException e) {
        // ID de convocatoria inválido
        System.err.println("getTiposPresupuesto: ID convocatoria inválido: " + idConvocatoriaStr);
    } catch (Exception e) {
        System.err.println("getTiposPresupuesto Error: " + e.getMessage());
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
    }
    
    jsonBuilder.append("]");
    out.print(jsonBuilder.toString());
%>
