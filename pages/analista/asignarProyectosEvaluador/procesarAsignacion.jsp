<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="javax.sql.*" %>
<%@ page buffer="none" %>
<%@ include file="/WEB-INF/utilidadesAreas.jsp" %>
<%
    // Evitar caché
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    // Verificar sesión del analista
    if (session.getAttribute("id_usuario") == null) {
        response.sendRedirect(request.getContextPath() + "/pages/login/login.jsp");
        return;
    }

    Integer idUsuarioAnalista = (Integer) session.getAttribute("id_usuario");
    String nombreAnalista = (String) session.getAttribute("nombre");

    // Obtener parámetros
    String[] proyectoIds = request.getParameterValues("proyecto_ids");
    String evaluadorId = request.getParameter("evaluador_id");
    String accion = request.getParameter("accion");

    String mensaje = "";
    String tipoMensaje = "";

    if (accion == null || accion.isEmpty()) {
        // Cargar datos para mostrar la página
        mensaje = "";
        tipoMensaje = "";
    } else if ("asignar".equals(accion)) {
        // Procesar asignación
        // Primero incluir conexión (declara connLocal)
        %>
        <%@ include file="/WEB-INF/conexion.jsp" %>
        <%
        
        Connection connLocal = conn;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            if (connLocal == null || connLocal.isClosed()) {
                throw new Exception("No se pudo establecer conexión con la base de datos");
            }

            // Validar parámetros
            if (proyectoIds == null || proyectoIds.length == 0) {
                mensaje = "Debe seleccionar al menos un proyecto";
                tipoMensaje = "error";
            } else if (evaluadorId == null || evaluadorId.isEmpty()) {
                mensaje = "Debe seleccionar un evaluador";
                tipoMensaje = "error";
            } else {
                int idEvaluador = Integer.parseInt(evaluadorId);
                int proyectosAsignados = 0;
                int proyectosYaAsignados = 0;
                int proyectosIncompatibles = 0;
                StringBuilder detallesAsignacion = new StringBuilder();

                // Verificar que el evaluador existe y es tipo 3
                String checkEvaluador = "SELECT u.id_usuario, u.nombre, u.primer_apellido, u.segundo_apellido, e.area_conocimiento " +
                                       "FROM usuarios u " +
                                       "LEFT JOIN evaluadores e ON u.id_usuario = e.id_usuario " +
                                       "WHERE u.id_usuario = ? AND u.tipousuario = 3 AND u.estado = 2";
                PreparedStatement checkStmt = connLocal.prepareStatement(checkEvaluador);
                checkStmt.setInt(1, idEvaluador);
                ResultSet checkRs = checkStmt.executeQuery();

                if (!checkRs.next()) {
                    mensaje = "El evaluador seleccionado no es válido o no está activo";
                    tipoMensaje = "error";
                } else {
                    String nombreEvaluador = checkRs.getString("nombre") + " " +
                                           checkRs.getString("primer_apellido") + " " +
                                           (checkRs.getString("segundo_apellido") != null ? checkRs.getString("segundo_apellido") : "");
                    String areaEvaluador = checkRs.getString("area_conocimiento");

                    // Verificar que el evaluador no tenga más de 3 proyectos asignados
                    String checkProyectosEvaluador = "SELECT COUNT(*) as count FROM evaluador_proyecto WHERE id_usuario = ? AND estado_evaluacion NOT IN (3)";
                    PreparedStatement checkProyStmt = connLocal.prepareStatement(checkProyectosEvaluador);
                    checkProyStmt.setInt(1, idEvaluador);
                    ResultSet checkProyRs = checkProyStmt.executeQuery();
                    
                    int proyectosActuales = 0;
                    if (checkProyRs.next()) {
                        proyectosActuales = checkProyRs.getInt("count");
                    }
                    checkProyRs.close();
                    checkProyStmt.close();
                    
                    if (proyectosActuales >= 3) {
                        mensaje = "El evaluador " + nombreEvaluador + " ya tiene el máximo de 3 proyectos asignados";
                        tipoMensaje = "error";
                    } else {

                    // Procesar cada proyecto seleccionado
                    for (String proyectoId : proyectoIds) {
                        int idProyecto = Integer.parseInt(proyectoId);

                        // Obtener área y título del proyecto
                        String getInfoProyecto = "SELECT area_conocimiento, titulo FROM proyectos WHERE id_proyecto = ?";
                        PreparedStatement areaStmt = connLocal.prepareStatement(getInfoProyecto);
                        areaStmt.setInt(1, idProyecto);
                        ResultSet areaRs = areaStmt.executeQuery();

                        String areaProyecto = null;
                        String tituloProyecto = "";
                        if (areaRs.next()) {
                            areaProyecto = areaRs.getString("area_conocimiento");
                            tituloProyecto = areaRs.getString("titulo");
                        }
                        areaRs.close();
                        areaStmt.close();

                        // Verificar compatibilidad de áreas (si ambas están definidas)
                        if (areaEvaluador != null && !areaEvaluador.isEmpty() &&
                            areaProyecto != null && !areaProyecto.isEmpty()) {

                            boolean sonCompatibles = esAreaCompatible(areaEvaluador, areaProyecto);
                            
                            System.out.println(">>> [ASIGNACION] Área Evaluador: '" + areaEvaluador + "'");
                            System.out.println(">>> [ASIGNACION] Área Proyecto: '" + areaProyecto + "'");
                            System.out.println(">>> [ASIGNACION] ¿Compatibles? " + sonCompatibles);

                            if (!sonCompatibles) {
                                proyectosIncompatibles++;
                                detallesAsignacion.append("<br><small class='text-red-600'>⚠️ '")
                                    .append(tituloProyecto.length() > 50 ? tituloProyecto.substring(0, 50) + "..." : tituloProyecto)
                                    .append("' (Eval: '").append(areaEvaluador)
                                    .append("' vs Proy: '").append(areaProyecto).append("')</small>");
                                continue; // Saltar este proyecto por incompatibilidad
                            }
                        }

                        // Verificar si ya está asignado a este evaluador
                        String checkAsignacion = "SELECT COUNT(*) FROM evaluador_proyecto WHERE id_proyecto = ? AND id_usuario = ?";
                        PreparedStatement checkAsigStmt = connLocal.prepareStatement(checkAsignacion);
                        checkAsigStmt.setInt(1, idProyecto);
                        checkAsigStmt.setInt(2, idEvaluador);
                        ResultSet checkAsigRs = checkAsigStmt.executeQuery();

                        if (checkAsigRs.next() && checkAsigRs.getInt(1) > 0) {
                            proyectosYaAsignados++;
                            continue;
                        }
                        checkAsigRs.close();
                        checkAsigStmt.close();

                        // Verificar si el proyecto ya tiene asignación
                        String checkProyectoAsignado = "SELECT COUNT(*) FROM evaluador_proyecto WHERE id_proyecto = ?";
                        PreparedStatement checkProyectoStmt = connLocal.prepareStatement(checkProyectoAsignado);
                        checkProyectoStmt.setInt(1, idProyecto);
                        ResultSet checkProyectoRs = checkProyectoStmt.executeQuery();

                        if (checkProyectoRs.next() && checkProyectoRs.getInt(1) >= 2) {
                            // Ya tiene 2 evaluadores (límite típico)
                            proyectosYaAsignados++;
                            checkProyectoRs.close();
                            checkProyectoStmt.close();
                            continue;
                        }
                        checkProyectoRs.close();
                        checkProyectoStmt.close();

                        // Insertar asignación
                        String insertAsignacion = "INSERT INTO evaluador_proyecto (id_usuario, id_proyecto, estado_evaluacion, fecha_asignacion) " +
                                                 "VALUES (?, ?, 1, CURRENT_TIMESTAMP)";
                        pstmt = connLocal.prepareStatement(insertAsignacion);
                        pstmt.setInt(1, idEvaluador);
                        pstmt.setInt(2, idProyecto);
                        int filas = pstmt.executeUpdate();
                        pstmt.close();

                        if (filas > 0) {
                            proyectosAsignados++;

                            // Obtener título del proyecto para el mensaje
                            String getTitulo = "SELECT titulo FROM proyectos WHERE id_proyecto = ?";
                            PreparedStatement tituloStmt = connLocal.prepareStatement(getTitulo);
                            tituloStmt.setInt(1, idProyecto);
                            ResultSet tituloRs = tituloStmt.executeQuery();
                            if (tituloRs.next()) {
                                detallesAsignacion.append("- ").append(tituloRs.getString("titulo")).append("<br>");
                            }
                            tituloRs.close();
                            tituloStmt.close();
                        }
                    }

                    if (proyectosAsignados > 0) {
                        mensaje = "Se asignaron " + proyectosAsignados + " proyecto(s) al evaluador " + nombreEvaluador + "<br>" + detallesAsignacion.toString();
                        tipoMensaje = "success";
                        
                        // Agregar advertencia si hubo proyectos incompatibles
                        if (proyectosIncompatibles > 0) {
                            mensaje += "<br><br><strong>Nota:</strong> " + proyectosIncompatibles + 
                                      " proyecto(s) no se asignaron porque el área del evaluador no es compatible.";
                        }

                        // Actualizar estado del proyecto si es necesario
                        for (String proyectoId : proyectoIds) {
                            int idProyecto = Integer.parseInt(proyectoId);

                            // Verificar si ahora tiene al menos un evaluador
                            String countEvaluadores = "SELECT COUNT(*) FROM evaluador_proyecto WHERE id_proyecto = ?";
                            PreparedStatement countStmt = connLocal.prepareStatement(countEvaluadores);
                            countStmt.setInt(1, idProyecto);
                            ResultSet countRs = countStmt.executeQuery();

                            if (countRs.next() && countRs.getInt(1) >= 1) {
                                // Actualizar estado a "En evaluación" (id=8)
                                String updateEstado = "UPDATE proyectos SET estado_proyecto = '8' WHERE id_proyecto = ? AND estado_proyecto = '3'";
                                PreparedStatement updateStmt = connLocal.prepareStatement(updateEstado);
                                updateStmt.setInt(1, idProyecto);
                                updateStmt.executeUpdate();
                                updateStmt.close();
                            }
                            countRs.close();
                            countStmt.close();
                        }
                    } else if (proyectosIncompatibles > 0) {
                        mensaje = "Ningún proyecto pudo ser asignado porque el área del evaluador no es compatible con los proyectos seleccionados.";
                        tipoMensaje = "warning";
                    } else if (proyectosYaAsignados > 0) {
                        mensaje = "Los proyectos seleccionados ya estaban asignados a este evaluador o tienen el máximo de evaluadores";
                        tipoMensaje = "warning";
                    }
                    }
                }
                checkRs.close();
                checkStmt.close();
            }

        } catch (Exception e) {
            mensaje = "Error al asignar proyectos: " + e.getMessage();
            tipoMensaje = "error";
            e.printStackTrace();
        } finally {
            try {
                if (pstmt != null) pstmt.close();
                if (rs != null) rs.close();
                if (connLocal != null && !connLocal.isClosed()) connLocal.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    // Guardar mensaje en sesión y redirigir
    if (!mensaje.isEmpty()) {
        session.setAttribute("mensaje_asignacion", mensaje);
        session.setAttribute("tipo_mensaje_asignacion", tipoMensaje);
    }

    // Redirigir de vuelta al index
    response.sendRedirect(request.getContextPath() + "/pages/analista/asignarProyectosEvaluador/index.jsp");
%>
