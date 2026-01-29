<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ include file="/WEB-INF/conexion.jsp" %>
<%
    // Limpiar cualquier espacio en blanco o salida previa generada por los includes
    try {
        if (!response.isCommitted()) {
            response.reset();
        }
    } catch (Exception e) {}

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
                jsonBuilder.append("\"nombre\": \"").append(escapeJson(rs.getString("nombre_estado"))).append("\"");
                jsonBuilder.append("}");
                first = false;
            }
            jsonBuilder.append("]}");
            
            out.print(jsonBuilder.toString());
            
            rs.close();
            stmt.close();
        } catch (Exception e) {
            out.print("{\"success\": false, \"message\": \"Error getEstados: " + e.getMessage().replace("\"", "\\\"") + "}");
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
        String motivo = request.getParameter("motivo");
        
        if (idProyecto == null || idProyecto.isEmpty() || nuevoEstado == null || nuevoEstado.isEmpty() || motivo == null || motivo.trim().isEmpty()) {
            out.print("{\"success\": false, \"message\": \"Parámetros incompletos: Faltan datos o motivo\"}");
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
            
            // Establecer variable de sesión para el trigger
            String sqlConfig = "SELECT set_config('app.motivo_ultimo_cambio', ?, false)";
            PreparedStatement stmtConfig = conn.prepareStatement(sqlConfig);
            stmtConfig.setString(1, motivo);
            stmtConfig.executeQuery();
            stmtConfig.close();

            // Actualizar el estado del proyecto con el ID numérico
            String sqlUpdate = "UPDATE proyectos SET estado_proyecto = ? WHERE id_proyecto = ?";
            PreparedStatement stmtUpdate = conn.prepareStatement(sqlUpdate);
            stmtUpdate.setInt(1, Integer.parseInt(nuevoEstado));
            stmtUpdate.setInt(2, Integer.parseInt(idProyecto));
            
            int filasAfectadas = stmtUpdate.executeUpdate();
            stmtUpdate.close();
            
            if (filasAfectadas > 0) {
                // Actualizar historial con usuario (si el trigger no lo maneja, lo hacemos aquí como respaldo)
                // Es probable que el trigger ya haya insertado el registro, así que actualizamos el usuario
                try {
                    Object usuarioIdObj = session.getAttribute("id_usuario");
                    Integer usuarioId = (usuarioIdObj != null) ? (Integer) usuarioIdObj : null;
                    
                    if (usuarioId != null) {
                        String sqlHistorial = "UPDATE historial_estado_proyectos SET id_usuario = ? " +
                                            "WHERE id_historial = (SELECT MAX(id_historial) FROM historial_estado_proyectos WHERE id_proyecto = ?)";
                        PreparedStatement stmtHist = conn.prepareStatement(sqlHistorial);
                        stmtHist.setInt(1, usuarioId);
                        stmtHist.setInt(2, Integer.parseInt(idProyecto));
                        stmtHist.executeUpdate();
                        stmtHist.close();
                    }
                } catch (Exception exHist) {
                    System.err.println("Error actualizando usuario historial: " + exHist.getMessage());
                }
                
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
    out.print("{\"success\": false, \"message\": \"Acción no reconocida: " + action + "}");
%> 
<%!
    // Función auxiliar para escapar JSON manualmente
    public String escapeJson(String input) {
        if (input == null) return "";
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < input.length(); i++) {
            char ch = input.charAt(i);
            switch (ch) {
                case '"': sb.append("\""); break;
                case '\\': sb.append("\\\\"); break;
                case '\b': sb.append("\\b"); break;
                case '\f': sb.append("\\f"); break;
                case '\n': sb.append("\\n"); break;
                case '\r': sb.append("\\r"); break;
                case '\t': sb.append("\\t"); break;
                case '/': sb.append("\\/"); break;
                default:
                    if (ch >= '\u0000' && ch <= '\u001F') {
                        String ss = Integer.toHexString(ch);
                        sb.append("\\u");
                        for (int k = 0; k < 4 - ss.length(); k++) {
                            sb.append('0');
                        }
                        sb.append(ss.toUpperCase());
                    } else {
                        sb.append(ch);
                    }
            }
        }
        return sb.toString();
    }
%>