<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%><%@ page import="java.sql.*" %><%@ page trimDirectiveWhitespaces="true" %><%@ include file="/WEB-INF/conexion.jsp" %><%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    if (!"analista".equals(String.valueOf(session.getAttribute("rol")))) {
        response.setStatus(401);
        out.print("{\"success\":false,\"error\":\"No autorizado\"}");
        return;
    }
    
    String accion = request.getParameter("accion");
    StringBuilder json = new StringBuilder();
    
    if (conn == null) {
        out.print("{\"success\":false,\"error\":\"Error de conexion a la base de datos\"}");
        return;
    }
    
    try {
        if ("crear".equals(accion)) {
            String nombre = request.getParameter("nombre");
            String fechaInicio = request.getParameter("fechaInicio");
            String fechaCierre = request.getParameter("fechaCierre");
            String estadoStr = request.getParameter("estado");
            
            int estadoId = 1;
            if ("activa".equals(estadoStr)) estadoId = 2;
            else if ("cerrada".equals(estadoStr)) estadoId = 3;
            else if ("finalizada".equals(estadoStr)) estadoId = 4;
            
            String sql = "INSERT INTO convocatoria (nombre_convocatoria, estado, fecha_inicio, fecha_cierre) VALUES (?, ?, ?, ?)";
            try (PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                stmt.setString(1, nombre);
                stmt.setInt(2, estadoId);
                stmt.setDate(3, java.sql.Date.valueOf(fechaInicio));
                stmt.setDate(4, java.sql.Date.valueOf(fechaCierre));
                
                int filas = stmt.executeUpdate();
                if (filas > 0) {
                    ResultSet rs = stmt.getGeneratedKeys();
                    int nuevoId = 0;
                    if (rs.next()) {
                        nuevoId = rs.getInt(1);
                    }
                    json.append("{\"success\":true,\"mensaje\":\"Convocatoria creada exitosamente\",\"id\":").append(nuevoId).append("}");
                } else {
                    json.append("{\"success\":false,\"error\":\"No se pudo crear la convocatoria\"}");
                }
            }
            
        } else if ("editar".equals(accion)) {
            int id = Integer.parseInt(request.getParameter("id"));
            String nombre = request.getParameter("nombre");
            String fechaInicio = request.getParameter("fechaInicio");
            String fechaCierre = request.getParameter("fechaCierre");
            String estadoStr = request.getParameter("estado");
            
            int estadoId = 1;
            if ("activa".equals(estadoStr)) estadoId = 2;
            else if ("cerrada".equals(estadoStr)) estadoId = 3;
            else if ("finalizada".equals(estadoStr)) estadoId = 4;
            
            String sql = "UPDATE convocatoria SET nombre_convocatoria = ?, estado = ?, fecha_inicio = ?, fecha_cierre = ? WHERE id_convocatoria = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, nombre);
                stmt.setInt(2, estadoId);
                stmt.setDate(3, java.sql.Date.valueOf(fechaInicio));
                stmt.setDate(4, java.sql.Date.valueOf(fechaCierre));
                stmt.setInt(5, id);
                
                int filas = stmt.executeUpdate();
                if (filas > 0) {
                    json.append("{\"success\":true,\"mensaje\":\"Convocatoria actualizada exitosamente\"}");
                } else {
                    json.append("{\"success\":false,\"error\":\"No se encontro la convocatoria\"}");
                }
            }
            
        } else if ("eliminar".equals(accion)) {
            int id = Integer.parseInt(request.getParameter("id"));
            
            String sqlCheck = "SELECT COUNT(*) FROM proyectos WHERE convocatoria_id = ?";
            try (PreparedStatement stmtCheck = conn.prepareStatement(sqlCheck)) {
                stmtCheck.setInt(1, id);
                ResultSet rs = stmtCheck.executeQuery();
                if (rs.next() && rs.getInt(1) > 0) {
                    json.append("{\"success\":false,\"error\":\"No se puede eliminar: tiene proyectos asociados\"}");
                } else {
                    String sql = "DELETE FROM convocatoria WHERE id_convocatoria = ?";
                    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                        stmt.setInt(1, id);
                        int filas = stmt.executeUpdate();
                        if (filas > 0) {
                            json.append("{\"success\":true,\"mensaje\":\"Convocatoria eliminada exitosamente\"}");
                        } else {
                            json.append("{\"success\":false,\"error\":\"No se encontro la convocatoria\"}");
                        }
                    }
                }
            }
            
        } else if ("obtener".equals(accion)) {
            int id = Integer.parseInt(request.getParameter("id"));
            
            String sql = "SELECT c.*, ec.estado as nombre_estado FROM convocatoria c " +
                        "LEFT JOIN estado_convocatoria ec ON c.estado = ec.id_estado " +
                        "WHERE c.id_convocatoria = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, id);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    String estadoNombre = rs.getString("nombre_estado");
                    if (estadoNombre == null) {
                        int estadoId = rs.getInt("estado");
                        switch(estadoId) {
                            case 1: estadoNombre = "pendiente"; break;
                            case 2: estadoNombre = "activa"; break;
                            case 3: estadoNombre = "cerrada"; break;
                            case 4: estadoNombre = "finalizada"; break;
                            default: estadoNombre = "pendiente";
                        }
                    }
                    
                    String nombreConv = rs.getString("nombre_convocatoria");
                    if (nombreConv != null) {
                        nombreConv = nombreConv.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t");
                    } else {
                        nombreConv = "";
                    }
                    
                    String fechaIni = rs.getDate("fecha_inicio") != null ? rs.getDate("fecha_inicio").toString() : "";
                    String fechaCie = rs.getDate("fecha_cierre") != null ? rs.getDate("fecha_cierre").toString() : "";
                    
                    json.append("{\"success\":true,\"convocatoria\":{");
                    json.append("\"id\":").append(rs.getInt("id_convocatoria")).append(",");
                    json.append("\"nombre\":\"").append(nombreConv).append("\",");
                    json.append("\"fechaInicio\":\"").append(fechaIni).append("\",");
                    json.append("\"fechaCierre\":\"").append(fechaCie).append("\",");
                    json.append("\"estado\":\"").append(estadoNombre.toLowerCase()).append("\"");
                    json.append("}}");
                } else {
                    json.append("{\"success\":false,\"error\":\"Convocatoria no encontrada\"}");
                }
            }
        } else {
            json.append("{\"success\":false,\"error\":\"Accion no valida\"}");
        }
        
    } catch (NumberFormatException e) {
        json.setLength(0);
        json.append("{\"success\":false,\"error\":\"ID invalido\"}");
    } catch (IllegalArgumentException e) {
        json.setLength(0);
        json.append("{\"success\":false,\"error\":\"Formato de fecha invalido\"}");
    } catch (Exception e) {
        json.setLength(0);
        String errorMsg = e.getMessage();
        if (errorMsg != null) {
            errorMsg = errorMsg.replace("\\", "\\\\").replace("\"", "'").replace("\n", " ").replace("\r", " ");
        } else {
            errorMsg = "Error desconocido";
        }
        json.append("{\"success\":false,\"error\":\"").append(errorMsg).append("\"}");
    } finally {
        if (conn != null) {
            try { conn.close(); } catch (Exception e) {}
        }
    }
    
    out.print(json.toString());
%>
