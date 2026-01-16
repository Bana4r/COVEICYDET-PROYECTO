<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ include file="/WEB-INF/conexion.jsp" %>
<%
    // Configurar respuesta JSON
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    // Verificar que sea analista
    if (!"analista".equals(String.valueOf(session.getAttribute("rol")))) {
        response.setStatus(403);
        out.print("{\"success\": false, \"message\": \"No autorizado\"}");
        return;
    }
    
    String action = request.getParameter("action");
    
    // Debug: Si no hay acción
    if (action == null || action.isEmpty()) {
        out.print("{\"success\": false, \"message\": \"No se especificó acción\"}");
        return;
    }
    
    // Si la acción es obtener estados disponibles
    if ("getEstados".equals(action)) {
        try {
            if (conn == null) {
                out.print("{\"success\": false, \"message\": \"Error de conexión a la base de datos\"}");
                return;
            }
            
            String sql = "SELECT id_estado, nombre_estado FROM estado_proyecto ORDER BY id_estado";
            PreparedStatement stmt = conn.prepareStatement(sql);
            ResultSet rs = stmt.executeQuery();
            
            StringBuilder jsonBuilder = new StringBuilder();
            jsonBuilder.append("{\"success\": true, \"estados\": [");
            
            boolean first = true;
            while (rs.next()) {
                if (!first) jsonBuilder.append(",");
                jsonBuilder.append("{");
                jsonBuilder.append("\"id\": ").append(rs.getInt("id_estado")).append(",");
                jsonBuilder.append("\"nombre\": \"").append(rs.getString("nombre_estado").replace("\"", "\\\"")).append("\"");
                jsonBuilder.append("}");
                first = false;
            }
            jsonBuilder.append("]}");
            
            out.print(jsonBuilder.toString());
            
            rs.close();
            stmt.close();
        } catch (Exception e) {
            out.print("{\"success\": false, \"message\": \"Error getEstados: " + e.getMessage().replace("\"", "\\\"") + "\"}");
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { }
            }
        }
        return;
    }
    
    // Acción para cambiar el estado
    if ("cambiarEstado".equals(action)) {
        String idProyecto = request.getParameter("idProyecto");
        String nuevoEstado = request.getParameter("nuevoEstado");
        
        if (idProyecto == null || idProyecto.isEmpty() || nuevoEstado == null || nuevoEstado.isEmpty()) {
            out.print("{\"success\": false, \"message\": \"Parámetros incompletos\"}");
            return;
        }
        
        try {
            if (conn == null) {
                out.print("{\"success\": false, \"message\": \"Error de conexión a la base de datos\"}");
                return;
            }
            
            // Primero obtener el nombre del estado para mostrarlo en la respuesta
            String sqlEstado = "SELECT nombre_estado FROM estado_proyecto WHERE id_estado = ?";
            PreparedStatement stmtEstado = conn.prepareStatement(sqlEstado);
            stmtEstado.setInt(1, Integer.parseInt(nuevoEstado));
            ResultSet rsEstado = stmtEstado.executeQuery();
            
            String nombreEstado = "";
            if (rsEstado.next()) {
                nombreEstado = rsEstado.getString("nombre_estado");
            } else {
                out.print("{\"success\": false, \"message\": \"Estado con id " + nuevoEstado + " no encontrado en tabla estado_proyecto\"}");
                rsEstado.close();
                stmtEstado.close();
                return;
            }
            rsEstado.close();
            stmtEstado.close();
            
            // Actualizar el estado del proyecto con el ID numérico
            String sqlUpdate = "UPDATE proyectos SET estado_proyecto = ? WHERE id_proyecto = ?";
            PreparedStatement stmtUpdate = conn.prepareStatement(sqlUpdate);
            stmtUpdate.setInt(1, Integer.parseInt(nuevoEstado));
            stmtUpdate.setInt(2, Integer.parseInt(idProyecto));
            
            int filasAfectadas = stmtUpdate.executeUpdate();
            stmtUpdate.close();
            
            if (filasAfectadas > 0) {
                out.print("{\"success\": true, \"message\": \"Estado actualizado correctamente\", \"nuevoEstado\": \"" + nombreEstado.replace("\"", "\\\"") + "\", \"idEstado\": " + nuevoEstado + "}");
            } else {
                out.print("{\"success\": false, \"message\": \"No se encontró el proyecto con id " + idProyecto + "\"}");
            }
            
        } catch (NumberFormatException e) {
            out.print("{\"success\": false, \"message\": \"ID de proyecto o estado inválido: " + e.getMessage() + "\"}");
        } catch (Exception e) {
            out.print("{\"success\": false, \"message\": \"Error cambiarEstado: " + e.getMessage().replace("\"", "\\\"") + "\"}");
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { }
            }
        }
        return;
    }
    
    // Si no se reconoce la acción
    out.print("{\"success\": false, \"message\": \"Acción no reconocida: " + action + "\"}");
%>
