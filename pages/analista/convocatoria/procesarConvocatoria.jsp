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

                    // Insertar presupuestos relacionados (si vienen en el formulario)
                    String[] tipos = request.getParameterValues("tipo_presupuesto[]");
                    if (tipos == null) tipos = request.getParameterValues("tipo_presupuesto");
                    String[] montos = request.getParameterValues("monto[]");
                    if (montos == null) montos = request.getParameterValues("monto");
                    String[] descripciones = request.getParameterValues("descripcion_presupuesto[]");
                    if (descripciones == null) descripciones = request.getParameterValues("descripcion_presupuesto");

                    if (tipos != null && montos != null) {
                        String sqlPres = "INSERT INTO presupuesto_tipo (nombre, limite_presupuesto, id_convocatoria, descripcion) VALUES (?, ?, ?, ?)";
                        try (PreparedStatement pstPres = conn.prepareStatement(sqlPres)) {
                            int max = Math.min(5, Math.min(tipos.length, montos.length));
                            for (int i = 0; i < max; i++) {
                                String t = tipos[i] != null ? tipos[i].trim() : "";
                                String m = montos[i] != null ? montos[i].trim() : "";
                                String d = (descripciones != null && i < descripciones.length && descripciones[i] != null) ? descripciones[i].trim() : "";
                                if (t.isEmpty()) continue;
                                try {
                                    java.math.BigDecimal bd = new java.math.BigDecimal(m.replace("\u00A0", "")).setScale(2, java.math.RoundingMode.HALF_UP);
                                    pstPres.setString(1, t);
                                    pstPres.setBigDecimal(2, bd);
                                    pstPres.setInt(3, nuevoId);
                                    pstPres.setString(4, d);
                                    pstPres.addBatch();
                                } catch (Exception ex) {
                                    // si monto inválido, saltar esa fila
                                    continue;
                                }
                            }
                            pstPres.executeBatch();
                        }
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
                    // Actualizar presupuestos: eliminar existentes y reinsertar los enviados
                    String sqlDel = "DELETE FROM presupuesto_tipo WHERE id_convocatoria = ?";
                    try (PreparedStatement pstDel = conn.prepareStatement(sqlDel)) {
                        pstDel.setInt(1, id);
                        pstDel.executeUpdate();
                    }

                    String[] tipos = request.getParameterValues("tipo_presupuesto[]");
                    if (tipos == null) tipos = request.getParameterValues("tipo_presupuesto");
                    String[] montos = request.getParameterValues("monto[]");
                    if (montos == null) montos = request.getParameterValues("monto");
                    String[] descripciones = request.getParameterValues("descripcion_presupuesto[]");
                    if (descripciones == null) descripciones = request.getParameterValues("descripcion_presupuesto");

                    if (tipos != null && montos != null) {
                        String sqlPres = "INSERT INTO presupuesto_tipo (nombre, limite_presupuesto, id_convocatoria, descripcion) VALUES (?, ?, ?, ?)";
                        try (PreparedStatement pstPres = conn.prepareStatement(sqlPres)) {
                            int max = Math.min(5, Math.min(tipos.length, montos.length));
                            for (int i = 0; i < max; i++) {
                                String t = tipos[i] != null ? tipos[i].trim() : "";
                                String m = montos[i] != null ? montos[i].trim() : "";
                                String d = (descripciones != null && i < descripciones.length && descripciones[i] != null) ? descripciones[i].trim() : "";
                                if (t.isEmpty()) continue;
                                try {
                                    java.math.BigDecimal bd = new java.math.BigDecimal(m.replace("\u00A0", "")).setScale(2, java.math.RoundingMode.HALF_UP);
                                    pstPres.setString(1, t);
                                    pstPres.setBigDecimal(2, bd);
                                    pstPres.setInt(3, id);
                                    pstPres.setString(4, d);
                                    pstPres.addBatch();
                                } catch (Exception ex) {
                                    continue;
                                }
                            }
                            pstPres.executeBatch();
                        }
                    }

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
                    // Agregar presupuestos asociados
                    String sqlPres = "SELECT nombre, limite_presupuesto, descripcion FROM presupuesto_tipo WHERE id_convocatoria = ? ORDER BY id_presupuesto";
                    try (PreparedStatement pstPres = conn.prepareStatement(sqlPres)) {
                        pstPres.setInt(1, rs.getInt("id_convocatoria"));
                        ResultSet rsPres = pstPres.executeQuery();
                        StringBuilder presBuf = new StringBuilder();
                        presBuf.append(",\"presupuestos\":[");
                        boolean firstPres = true;
                        while (rsPres.next()) {
                            if (!firstPres) presBuf.append(',');
                            firstPres = false;
                            String nom = rsPres.getString("nombre");
                            if (nom != null) {
                                nom = nom.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t");
                            } else nom = "";
                            String lim = rsPres.getBigDecimal("limite_presupuesto") != null ? rsPres.getBigDecimal("limite_presupuesto").toString() : "0";
                            String desc = rsPres.getString("descripcion");
                            if (desc != null) {
                                desc = desc.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t");
                            } else desc = "";
                            presBuf.append('{');
                            presBuf.append("\"nombre\":\"").append(nom).append("\",");
                            presBuf.append("\"monto\":\"").append(lim).append("\",");
                            presBuf.append("\"descripcion\":\"").append(desc).append("\"");
                            presBuf.append('}');
                        }
                        presBuf.append(']');
                        json.append(presBuf.toString());
                    }

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
