<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>

<%@ include file="../../WEB-INF/conexion.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    
    // Verificar autenticación
    Integer idUsuario = (Integer) session.getAttribute("id_usuario");
    String rol = (String) session.getAttribute("rol");
    
    if (idUsuario == null || !"evaluador".equals(rol)) {
        response.sendRedirect("../login/login.jsp");
        return;
    }

    // Obtener datos del formulario
    String nombreCompleto = request.getParameter("nombreCompleto");
    String doctorado = request.getParameter("doctorado");
    String institucion = request.getParameter("institucion");
    String areaConocimiento = request.getParameter("areaConocimiento");

    // Rutas de los archivos (vienen del formulario oculto)
    String rutaGrado = request.getParameter("rutaGrado");
    String rutaINE = request.getParameter("rutaINE");
    String rutaAdscripcion = request.getParameter("rutaAdscripcion");
    String rutaCVU = request.getParameter("rutaCVU");

    System.out.println(">>> [EVALUADOR] Procesando datos para ID: " + idUsuario);
    System.out.println(">>> [EVALUADOR] Nombre: " + nombreCompleto);
    System.out.println(">>> [EVALUADOR] Rutas - Grado: " + rutaGrado + ", INE: " + rutaINE);

    // Validar datos requeridos
    if (nombreCompleto == null || nombreCompleto.isEmpty() ||
        doctorado == null || doctorado.isEmpty() ||
        institucion == null || institucion.isEmpty() ||
        areaConocimiento == null || areaConocimiento.isEmpty()) {
        session.setAttribute("error_datos", "Todos los campos de texto son requeridos");
        response.sendRedirect("DatosEvaluador.jsp");
        return;
    }

    // Validar archivos requeridos
    if (rutaGrado == null || rutaGrado.isEmpty() ||
        rutaINE == null || rutaINE.isEmpty() ||
        rutaAdscripcion == null || rutaAdscripcion.isEmpty() ||
        rutaCVU == null || rutaCVU.isEmpty()) {
        session.setAttribute("error_datos", "Todos los archivos PDF son requeridos");
        response.sendRedirect("DatosEvaluador.jsp");
        return;
    }

    // Insertar/Actualizar SOLO en tabla evaluadores
    // La tabla usuarios ya tiene los datos básicos del registro (email, password, tipousuario=3)
    // Los datos reales del perfil se guardan en evaluadores.nombre_completo
    PreparedStatement ps = null;
    try {
        System.out.println(">>> [EVALUADOR] Procesando datos del perfil para ID: " + idUsuario);
        System.out.println(">>> [EVALUADOR] Nombre completo: " + nombreCompleto);

        // Verificar si ya existe registro en evaluadores
        String sqlCheck = "SELECT id_usuario FROM evaluadores WHERE id_usuario = ?";
        ps = conn.prepareStatement(sqlCheck);
        ps.setInt(1, idUsuario);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            // Actualizar registro existente
            rs.close();
            ps.close();

            String sqlUpdate = "UPDATE evaluadores SET nombre_completo = ?, doctorado = ?, " +
                              "institucion = ?, area_conocimiento = ?, ruta_grado = ?, ruta_ine = ?, " +
                              "ruta_adscripcion = ?, ruta_cvu = ?, fecha_actualizacion = NOW() " +
                              "WHERE id_usuario = ?";
            ps = conn.prepareStatement(sqlUpdate);
            ps.setString(1, nombreCompleto);
            ps.setString(2, doctorado);
            ps.setString(3, institucion);
            ps.setString(4, areaConocimiento);
            ps.setString(5, rutaGrado);
            ps.setString(6, rutaINE);
            ps.setString(7, rutaAdscripcion);
            ps.setString(8, rutaCVU);
            ps.setInt(9, idUsuario);
            ps.executeUpdate();

            System.out.println(">>> [EVALUADOR] Datos actualizados en evaluadores para ID: " + idUsuario);
        } else {
            // Insertar nuevo registro
            rs.close();
            ps.close();

            String sqlInsert = "INSERT INTO evaluadores (id_usuario, nombre_completo, doctorado, " +
                              "institucion, area_conocimiento, ruta_grado, ruta_ine, ruta_adscripcion, " +
                              "ruta_cvu, fecha_registro) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";
            ps = conn.prepareStatement(sqlInsert);
            ps.setInt(1, idUsuario);
            ps.setString(2, nombreCompleto);
            ps.setString(3, doctorado);
            ps.setString(4, institucion);
            ps.setString(5, areaConocimiento);
            ps.setString(6, rutaGrado);
            ps.setString(7, rutaINE);
            ps.setString(8, rutaAdscripcion);
            ps.setString(9, rutaCVU);
            ps.executeUpdate();

            System.out.println(">>> [EVALUADOR] Datos insertados en evaluadores para ID: " + idUsuario);
        }

        // Actualizar nombre en sesión (usar nombre_completo de evaluadores)
        session.setAttribute("nombre", nombreCompleto);

        // Redirigir con mensaje de éxito
        session.setAttribute("datos_guardados", "true");
        response.sendRedirect("DatosEvaluador.jsp");

    } catch (SQLException e) {
        session.setAttribute("error_datos", "Error en base de datos: " + e.getMessage());
        e.printStackTrace();
        response.sendRedirect("DatosEvaluador.jsp");
    } finally {
        if (ps != null) try { ps.close(); } catch (Exception e) {}
    }
%>
