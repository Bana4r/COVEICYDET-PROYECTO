<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%@ include file="/WEB-INF/conexion.jsp" %>

<%-- 1. VALIDACIÓN DE SESIÓN (Conservado del original) --%>
<% if (!"responsable".equals(String.valueOf(session.getAttribute("rol")))) { 
    String n=request.getRequestURI()+(request.getQueryString()!=null?("?"+request.getQueryString()):"");
    response.sendRedirect(request.getContextPath()+"/pages/login/login.jsp?next="+java.net.URLEncoder.encode(n,"UTF-8")); 
    return; 
} %>

<%!
    // UTILIDADES
    private String escapeXml(String input) {
        if (input == null) return "";
        return input.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
    
    private String formatearFecha(Object fecha) {
        if (fecha == null) return "";
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
        if (fecha instanceof Timestamp) return sdf.format((Timestamp)fecha);
        else if (fecha instanceof java.sql.Date) return sdf.format((java.sql.Date)fecha);
        return "";
    }
%>

<%
    String proyectoId = request.getParameter("id");
    
    // Estructuras para almacenar los datos del nuevo esquema
    Map<String, Object> proyecto = new HashMap<>();
    List<Map<String, Object>> responsables = new ArrayList<>();
    List<Map<String, Object>> estudiantes = new ArrayList<>();
    List<Map<String, Object>> grupoTrabajo = new ArrayList<>(); // Tabla 'participante'
    List<Map<String, Object>> organizaciones = new ArrayList<>();
    List<Map<String, Object>> cronograma = new ArrayList<>();
    List<Map<String, Object>> documentos = new ArrayList<>(); // Nueva: Documentos

    String mensajeError = null;
    
    if (proyectoId == null || proyectoId.trim().isEmpty()) {
        mensajeError = "ID de proyecto requerido";
    } else if (conn == null) {
        mensajeError = "Error de conexión: " + dbError;
    } else {
        try {
            // --- 0. VALIDACIÓN DE PERMISOS ---
            // Verificar que el usuario responsable tenga asignado este proyecto
            Integer usuarioIdSesion = (Integer) session.getAttribute("id_usuario");
            boolean tienePermiso = false;
            
            if (usuarioIdSesion != null) {
                String sqlPermiso = "SELECT 1 FROM proyecto_usuarios WHERE id_proyecto = ? AND id_usuario = ?";
                try (PreparedStatement stmtPermiso = conn.prepareStatement(sqlPermiso)) {
                    stmtPermiso.setInt(1, Integer.parseInt(proyectoId));
                    stmtPermiso.setInt(2, usuarioIdSesion);
                    try (ResultSet rsPermiso = stmtPermiso.executeQuery()) {
                        if (rsPermiso.next()) {
                            tienePermiso = true;
                        }
                    }
                }
            }

            if (!tienePermiso) {
                mensajeError = "No está autorizado para visualizar este proyecto.";
            } else {
                // --- 1. CONSULTA PRINCIPAL (Basada en tabla 'Proyectos' y 'Convocatoria') ---
                String sqlP = "SELECT p.*, c.nombre_convocatoria, p.doc_extenso " +
                              "FROM Proyectos p " +
                              "LEFT JOIN Convocatoria c ON p.convocatoria_id = c.id_convocatoria " +
                              "WHERE p.id_proyecto = ?";
                              
                try (PreparedStatement stmt = conn.prepareStatement(sqlP)) {
                    stmt.setInt(1, Integer.parseInt(proyectoId));
                    try (ResultSet rs = stmt.executeQuery()) {
                        if (rs.next()) {
                            // Datos de Identificación
                            proyecto.put("id", rs.getString("id_proyecto"));
                            proyecto.put("titulo", rs.getString("titulo"));
                            proyecto.put("convocatoria", rs.getString("nombre_convocatoria"));
                            proyecto.put("fecha", rs.getTimestamp("fecha_creacion"));
                            
                            // Datos Institucionales (Nombres exactos del diagrama)
                            proyecto.put("institucion", rs.getString("institucion_proponente"));
                            proyecto.put("area", rs.getString("area_adscripcion"));
                            proyecto.put("municipio", rs.getString("Municipio"));
                            
                            // Datos Técnicos
                            proyecto.put("sector", rs.getString("sector_impacto_proyecto"));
                            proyecto.put("slr", rs.getString("nivel_slr"));
                            proyecto.put("tlr", rs.getString("nivel_tlr"));
                            proyecto.put("area_conocimiento", rs.getString("area_conocimiento"));
                            
                            // Textos Largos (Descripción)
                            proyecto.put("resumen", rs.getString("resumen_ejecutivo"));
                            proyecto.put("antecedentes", rs.getString("antecedentes"));
                            proyecto.put("pertinencia", rs.getString("pertinencia"));
                            proyecto.put("preguntas", rs.getString("preguntas_investigacion"));
                            proyecto.put("obj_gral", rs.getString("objetivos_general"));
                            proyecto.put("obj_esp", rs.getString("objetivos_especificos"));
                            proyecto.put("riesgos", rs.getString("factores_riesgo_mitigacion"));
                            proyecto.put("metodologia", rs.getString("resumen_metodologia"));
                            proyecto.put("resultados", rs.getString("resultados_esperados"));
                            
                            // Impactos
                            proyecto.put("imp_social", rs.getString("impacto_social"));
                            proyecto.put("imp_amb", rs.getString("impacto_ambiental"));
                            proyecto.put("imp_eco", rs.getString("impacto_economico"));
                            proyecto.put("imp_cient", rs.getString("impacto_cientificoTecnologico"));
                            
                            // Documento probatorio (TRL/SLR)
                            proyecto.put("doc_probatorio", rs.getString("doc_probatorio"));

                            // Documento extenso
                            proyecto.put("doc_extenso", rs.getString("doc_extenso"));
                        } else {
                            mensajeError = "El proyecto no existe en la base de datos.";
                        }
                    }
                }
            } // Fin check permiso

            if (mensajeError == null) {
                // --- 2. RESPONSABLES (Tabla: Proyecto_Responsables JOIN Responsables) ---
                String sqlResp = "SELECT r.nombre_completo, r.correo_electronico, r.telefono, r.ine, r.carta_aval, pr.tipo_responsable " +
                                 "FROM responsable r " +
                                 "JOIN proyecto_responsables pr ON r.id_responsable = pr.id_responsable " +
                                 "WHERE pr.id_proyecto = ?";
                try(PreparedStatement stmt = conn.prepareStatement(sqlResp)){
                    stmt.setInt(1, Integer.parseInt(proyectoId));
                    try(ResultSet rs = stmt.executeQuery()){
                        while(rs.next()){
                            Map<String,Object> m = new HashMap<>();
                            m.put("nombre", rs.getString("nombre_completo"));
                            m.put("rol", rs.getString("tipo_responsable"));
                            m.put("email", rs.getString("correo_electronico"));
                            m.put("tel", rs.getString("telefono"));
                            m.put("ine", rs.getString("ine"));
                            m.put("carta_aval", rs.getString("carta_aval"));
                            responsables.add(m);
                        }
                    }
                }

                // --- 3. ESTUDIANTES (Tabla: Estudiantes JOIN estudiantes_participantes) ---
                String sqlEst = "SELECT e.* FROM Estudiantes e " +
                                "JOIN estudiantes_participantes ep ON e.id_estudiante = ep.id_estudiante " +
                                "WHERE ep.id_proyecto = ?";
                try(PreparedStatement stmt = conn.prepareStatement(sqlEst)){
                    stmt.setInt(1, Integer.parseInt(proyectoId));
                    try(ResultSet rs = stmt.executeQuery()){
                        while(rs.next()){
                            Map<String,Object> m = new HashMap<>();
                            m.put("nombre", rs.getString("nombre_completo"));
                            m.put("nivel", rs.getString("nivel_academico"));
                            m.put("programa", rs.getString("programa_educativo"));
                            m.put("inst", rs.getString("institucion"));
                            // Recuperar la carta de colaboración
                            m.put("carta", rs.getString("carta_colaboracion"));
                            estudiantes.add(m);
                        }
                    }
                }
                            
                // --- 4. GRUPO DE TRABAJO (Tabla: participante JOIN gruposDeTrabajo) ---
                String sqlGT = "SELECT p.* FROM participante p " +
                "JOIN gruposDeTrabajo gt ON p.id_gt_participante = gt.id_gt_participante " +
                "WHERE gt.id_proyecto = ?";
                try(PreparedStatement stmt = conn.prepareStatement(sqlGT)){
                stmt.setInt(1, Integer.parseInt(proyectoId));
                try(ResultSet rs = stmt.executeQuery()){
                while(rs.next()){
                Map<String,Object> m = new HashMap<>();
                m.put("nombre", rs.getString("nombre_completo"));
                m.put("grado", rs.getString("grado_academico"));
                m.put("disciplina", rs.getString("disciplina"));
                m.put("rol", rs.getString("actividades_realizar"));
                m.put("inst", rs.getString("institucion_adscripcion"));
                // Recuperar comprobante
                m.put("comprobante", rs.getString("doc_comprobante_adscripcion"));
                grupoTrabajo.add(m);
                }
                }
                }
                // --- 5. ORGANIZACIONES (Tabla: organizacion_social JOIN proyecto_organizaciones) ---
                String sqlOrg = "SELECT os.* FROM organizacion_social os " +
                                "JOIN proyecto_organizaciones po ON os.org_social_id = po.org_social_id " +
                                "WHERE po.id_proyecto = ?";
                try(PreparedStatement stmt = conn.prepareStatement(sqlOrg)){
                    stmt.setInt(1, Integer.parseInt(proyectoId));
                    try(ResultSet rs = stmt.executeQuery()){
                        while(rs.next()){
                            Map<String,Object> m = new HashMap<>();
                            m.put("nombre", rs.getString("nombre_razon_social"));
                            m.put("resp", rs.getString("responsable"));
                            m.put("actividad", rs.getString("desc_actividad"));
                            // Recuperar comprobante de organización
                            m.put("comprobante", rs.getString("doc_comprobante_adscripcion"));
                            organizaciones.add(m);
                        }
                    }
                }
                            
                // --- 6. CRONOGRAMA (Tabla: Cronograma_Actividades JOIN actividades JOIN semestres) ---
                String sqlCron = "SELECT s.descripcion_semestre, a.nombre_actividad, a.entregables, s.meta_semestre " +
                                 "FROM Cronograma_Actividades ca " +
                                 "JOIN actividades a ON ca.id_actividad = a.id_actividad " +
                                 "JOIN semestres s ON ca.id_semestre = s.id_semestre " +
                                 "WHERE ca.id_proyecto = ? " +
                                 "ORDER BY s.id_semestre";
                try(PreparedStatement stmt = conn.prepareStatement(sqlCron)){
                    stmt.setInt(1, Integer.parseInt(proyectoId));
                    try(ResultSet rs = stmt.executeQuery()){
                        while(rs.next()){
                            Map<String,Object> m = new HashMap<>();
                            m.put("semestre", rs.getString("descripcion_semestre"));
                            m.put("actividad", rs.getString("nombre_actividad"));
                            m.put("entregable", rs.getString("entregables"));
                            m.put("meta", rs.getString("meta_semestre")); // Nueva columna 'meta'
                            cronograma.add(m);
                        }
                    }
                }

                // --- 7. USUARIO (Tabla: Usuarios JOIN proyecto_usuarios) ---
                String comprobanteVigenciaTemp = null;
                String sqlUsuario = "SELECT u.comprobantevigencia FROM usuarios u " +
                                    "JOIN proyecto_usuarios pu ON u.id_usuario = pu.id_usuario " +
                                    "WHERE pu.id_proyecto = ?";
                try(PreparedStatement stmt = conn.prepareStatement(sqlUsuario)){
                    stmt.setInt(1, Integer.parseInt(proyectoId));
                    try(ResultSet rs = stmt.executeQuery()){
                        if(rs.next()){
                            comprobanteVigenciaTemp = rs.getString("comprobantevigencia");
                        }
                    }
                }
                final String comprobanteVigencia = comprobanteVigenciaTemp;

                // --- 8. DOCUMENTOS (Nueva sección) ---
                // En producción, esto debería venir de una tabla de documentos
                // Por ahora, simulamos los documentos principales
                documentos.add(new HashMap<String, Object>() {{
                    put("nombre", "Comprobante de Vigencia del Padrón");
                    put("descripcion", "Acredita vigencia en el Padrón Veracruzano de Investigadores");
                    put("tipo", "pdf");

                    if (comprobanteVigencia != null && !comprobanteVigencia.trim().isEmpty()) {
                        if (comprobanteVigencia.startsWith(request.getContextPath())) {
                            put("ruta", comprobanteVigencia);
                        } else {
                            put("ruta", request.getContextPath() + (comprobanteVigencia.startsWith("/") ? "" : "/") + comprobanteVigencia);
                        }
                    } else {
                        put("ruta", "/documentos/comprobante_vigencia.pdf");
                    }
                }});
                String rutaProbatorio = (String)proyecto.get("doc_probatorio");
                if (rutaProbatorio != null && !rutaProbatorio.trim().isEmpty()) {
                    Map<String, Object> docMat = new HashMap<>();
                    docMat.put("nombre", "Niveles de Maduración (TLR/SLR)");
                    docMat.put("descripcion", "Documento técnico de validación de madurez tecnológica");
                    docMat.put("tipo", "pdf");

                    if (rutaProbatorio.startsWith(request.getContextPath())) {
                        docMat.put("ruta", rutaProbatorio);
                    } else {
                        docMat.put("ruta", request.getContextPath() + (rutaProbatorio.startsWith("/") ? "" : "/") + rutaProbatorio);
                    }
                    documentos.add(docMat);
                }
                documentos.add(new HashMap<String, Object>() {{
                    put("nombre", "INE del Representante Técnico");
                    put("descripcion", "Identificación oficial del representante del proyecto");
                    put("tipo", "pdf");
                    
                    String rutaIne = null;
                    for(Map<String, Object> resp : responsables) {
                        String rol = (String)resp.get("rol");
                        if(rol != null && (rol.toLowerCase().contains("técnico") || rol.toLowerCase().contains("tecnico"))) {
                            rutaIne = (String)resp.get("ine");
                            break;
                        }
                    }
                    
                    if (rutaIne != null && !rutaIne.trim().isEmpty()) {
                        if (rutaIne.startsWith(request.getContextPath())) {
                            put("ruta", rutaIne);
                        } else {
                            put("ruta", request.getContextPath() + (rutaIne.startsWith("/") ? "" : "/") + rutaIne);
                        }
                    } else {
                        put("ruta", "/documentos/ine_representante.pdf");
                    }
                }});
                documentos.add(new HashMap<String, Object>() {{
                    put("nombre", "Carta Aval del Representante Legal");
                    put("descripcion", "Autorización formal de la institución");
                    put("tipo", "pdf");

                    String rutaCartaAval = null;
                    for(Map<String, Object> resp : responsables) {
                        String rol = (String)resp.get("rol");
                        if(rol != null && (rol.toLowerCase().contains("legal") || rol.toLowerCase().contains("representante legal"))) {
                            rutaCartaAval = (String)resp.get("carta_aval");
                            break;
                        }
                    }

                    if (rutaCartaAval != null && !rutaCartaAval.trim().isEmpty()) {
                        if (rutaCartaAval.startsWith(request.getContextPath())) {
                            put("ruta", rutaCartaAval);
                        } else {
                            put("ruta", request.getContextPath() + (rutaCartaAval.startsWith("/") ? "" : "/") + rutaCartaAval);
                        }
                    } else {
                        put("ruta", "/documentos/carta_aval.pdf");
                    }
                }});
            }
        } catch (Exception e) {
            e.printStackTrace();
            mensajeError = "Error de Sistema: " + e.getMessage();
        }
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>COVEICYDET - Detalle del Proyecto</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/viewerjs/1.11.6/viewer.min.css">
  <style>
    :root {
      --primary: #7A1737;
      --primary-light: #A8253C;
      --primary-dark: #5c0f2a;
      --secondary: #B28854;
      --secondary-light: #d4b683;
      --light-bg: #f8f9fa;
    }
    
    body {
      background: linear-gradient(135deg, #f8f9fa 0%, #f1f3f4 100%);
      min-height: 100vh;
      font-family: 'Segoe UI', system-ui, sans-serif;
    }
    
    .section-header {
      font-size: 1.1rem;
      font-weight: 600;
      color: var(--primary);
      margin-bottom: 1.5rem;
      padding-bottom: 0.75rem;
      border-bottom: 2px solid #e2e8f0;
      display: flex;
      align-items: center;
    }
    
    .section-header i {
      margin-right: 0.75rem;
      color: var(--primary-light);
    }
    
    .card {
      background-color: white;
      border-radius: 12px;
      box-shadow: 0 2px 16px rgba(0, 0, 0, 0.06);
      transition: all 0.3s ease;
      border: 1px solid #e2e8f0;
      overflow: hidden;
    }
    
    .card:hover {
      box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
    }
    
    .field-label {
      font-size: 0.75rem;
      font-weight: 600;
      color: #64748b;
      text-transform: uppercase;
      letter-spacing: 0.5px;
      margin-bottom: 0.375rem;
    }
    
    .field-value {
      font-size: 0.95rem;
      color: #1e293b;
      font-weight: 500;
      line-height: 1.4;
    }
    
    .text-block {
      background-color: #f8fafc;
      border-radius: 8px;
      padding: 1.125rem;
      font-size: 0.9rem;
      color: #475569;
      line-height: 1.6;
      border-left: 4px solid #cbd5e1;
    }
    
    .badge {
      display: inline-flex;
      align-items: center;
      padding: 0.375rem 0.875rem;
      border-radius: 6px;
      font-size: 0.75rem;
      font-weight: 600;
      letter-spacing: 0.3px;
      height: fit-content;
    }
    
    .badge-primary {
      background-color: rgba(122, 23, 55, 0.08);
      color: var(--primary);
      border: 1px solid rgba(122, 23, 55, 0.2);
    }
    
    .badge-secondary {
      background-color: rgba(178, 136, 84, 0.08);
      color: var(--secondary);
      border: 1px solid rgba(178, 136, 84, 0.2);
    }
    
    .badge-success {
      background-color: rgba(16, 185, 129, 0.08);
      color: #065f46;
      border: 1px solid rgba(16, 185, 129, 0.2);
    }
    
    .badge-info {
      background-color: rgba(59, 130, 246, 0.08);
      color: #1e40af;
      border: 1px solid rgba(59, 130, 246, 0.2);
    }
    
    .badge-warning {
      background-color: rgba(245, 158, 11, 0.08);
      color: #92400e;
      border: 1px solid rgba(245, 158, 11, 0.2);
    }
    
    .person-card {
      background: white;
      border-radius: 10px;
      padding: 1.125rem;
      border: 1px solid #e2e8f0;
      transition: all 0.2s;
      display: flex;
      align-items: flex-start;
    }
    
    .person-card:hover {
      transform: translateY(-2px);
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
      border-color: #cbd5e1;
    }
    
    .person-icon {
      width: 48px;
      height: 48px;
      border-radius: 10px;
      display: flex;
      align-items: center;
      justify-content: center;
      margin-right: 1rem;
      flex-shrink: 0;
      font-size: 1.25rem;
    }
    
    .person-icon.primary {
      background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
      color: white;
    }
    
    .person-icon.blue {
      background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
      color: white;
    }
    
    .person-icon.green {
      background: linear-gradient(135deg, #10b981 0%, #047857 100%);
      color: white;
    }
    
    .person-icon.amber {
      background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
      color: white;
    }
    
    .person-info {
      flex: 1;
    }
    
    .person-role {
      font-size: 0.75rem;
      font-weight: 600;
      color: var(--primary);
      text-transform: uppercase;
      letter-spacing: 0.5px;
      margin-bottom: 0.25rem;
    }
    
    .person-name {
      font-size: 1rem;
      font-weight: 600;
      color: #1e293b;
      margin-bottom: 0.5rem;
    }
    
    .person-details {
      font-size: 0.85rem;
      color: #64748b;
      margin-bottom: 0.75rem;
    }
    
    .person-details i {
      margin-right: 0.5rem;
      width: 16px;
      text-align: center;
    }
    
    .person-tags {
      display: flex;
      flex-wrap: wrap;
      gap: 0.5rem;
    }
    
    .impact-card {
      background: white;
      border-radius: 10px;
      padding: 1.5rem;
      border: 1px solid #e2e8f0;
      transition: all 0.3s;
      border-top: 4px solid;
      height: 100%;
    }
    
    .impact-card:hover {
      transform: translateY(-3px);
      box-shadow: 0 6px 20px rgba(0, 0, 0, 0.1);
    }
    
    .impact-card.social {
      border-top-color: #3b82f6;
    }
    
    .impact-card.environmental {
      border-top-color: #10b981;
    }
    
    .impact-card.economic {
      border-top-color: #f59e0b;
    }
    
    .impact-card.scientific {
      border-top-color: #8b5cf6;
    }
    
    .header-decoration {
      background: linear-gradient(90deg, var(--primary) 0%, var(--primary-light) 100%);
      position: relative;
      overflow: hidden;
    }
    
    .header-decoration::after {
      content: '';
      position: absolute;
      top: 0;
      right: 0;
      width: 120px;
      height: 100%;
      background: linear-gradient(90deg, transparent 0%, rgba(255, 255, 255, 0.1) 100%);
    }
    
    .btn-primary {
      background: linear-gradient(90deg, var(--primary) 0%, var(--primary-light) 100%);
      color: white;
      font-weight: 600;
      padding: 0.75rem 1.5rem;
      border-radius: 8px;
      transition: all 0.3s;
      border: none;
      cursor: pointer;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      gap: 0.5rem;
    }
    
    .btn-primary:hover {
      transform: translateY(-2px);
      box-shadow: 0 8px 20px rgba(122, 23, 55, 0.3);
    }
    
    .btn-secondary {
      background: linear-gradient(90deg, var(--secondary) 0%, var(--secondary-light) 100%);
      color: white;
      font-weight: 600;
      padding: 0.75rem 1.5rem;
      border-radius: 8px;
      transition: all 0.3s;
      border: none;
      cursor: pointer;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      gap: 0.5rem;
    }
    
    .btn-secondary:hover {
      transform: translateY(-2px);
      box-shadow: 0 8px 20px rgba(178, 136, 84, 0.3);
    }
    
    .btn-outline {
      background: transparent;
      color: var(--primary);
      font-weight: 600;
      padding: 0.75rem 1.5rem;
      border-radius: 8px;
      transition: all 0.3s;
      border: 2px solid var(--primary);
      cursor: pointer;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      gap: 0.5rem;
    }
    
    .btn-outline:hover {
      background-color: rgba(122, 23, 55, 0.05);
      transform: translateY(-2px);
    }
    
    .accordion {
      border-radius: 10px;
      overflow: hidden;
      margin-bottom: 0.75rem;
      border: 1px solid #e2e8f0;
    }
    
    .accordion-header {
      background-color: #f8fafc;
      padding: 1.125rem 1.5rem;
      cursor: pointer;
      display: flex;
      justify-content: space-between;
      align-items: center;
      border-bottom: 1px solid #e2e8f0;
    }
    
    .accordion-header:hover {
      background-color: #f1f5f9;
    }
    
    .accordion-content {
      padding: 1.5rem;
      background-color: white;
    }
    
    .table-container {
      overflow-x: auto;
      border-radius: 10px;
      border: 1px solid #e2e8f0;
      background: white;
    }
    
    .table-container table {
      width: 100%;
      min-width: 600px;
    }
    
    .table-container th {
      background-color: #f8fafc;
      font-weight: 600;
      color: #475569;
      text-transform: uppercase;
      font-size: 0.75rem;
      letter-spacing: 0.5px;
      padding: 1rem 1.25rem;
      border-bottom: 2px solid #e2e8f0;
    }
    
    .table-container td {
      padding: 1rem 1.25rem;
      border-bottom: 1px solid #f1f5f9;
      color: #475569;
      font-size: 0.875rem;
    }
    
    .table-container tr:last-child td {
      border-bottom: none;
    }
    
    .table-container tr:hover {
      background-color: #f8fafc;
    }
    
    /* Estilos para documentos */
    .document-card {
      background: white;
      border-radius: 8px;
      padding: 1rem;
      border: 1px solid #e2e8f0;
      transition: all 0.2s;
      display: flex;
      align-items: center;
      justify-content: space-between;
    }
    
    .document-card:hover {
      border-color: var(--primary-light);
      background-color: #f8fafc;
    }
    
    .document-info {
      display: flex;
      align-items: center;
      gap: 1rem;
      flex: 1;
    }
    
    .document-icon {
      width: 40px;
      height: 40px;
      border-radius: 8px;
      display: flex;
      align-items: center;
      justify-content: center;
      flex-shrink: 0;
      font-size: 1.125rem;
    }
    
    .document-icon.pdf {
      background-color: rgba(239, 68, 68, 0.1);
      color: #dc2626;
    }
    
    .document-icon.uploaded {
      background-color: rgba(16, 185, 129, 0.1);
      color: #059669;
    }
    
    .document-details {
      flex: 1;
    }
    
    .document-title {
      font-size: 0.875rem;
      font-weight: 600;
      color: #1e293b;
      margin-bottom: 0.25rem;
    }
    
    .document-description {
      font-size: 0.75rem;
      color: #64748b;
    }
    
    .document-meta {
      display: flex;
      align-items: center;
      gap: 0.75rem;
      font-size: 0.75rem;
      color: #94a3b8;
    }
    
    .document-status {
      font-size: 0.7rem;
      padding: 0.25rem 0.75rem;
      border-radius: 9999px;
      font-weight: 600;
    }
    
    .status-uploaded {
      background-color: rgba(16, 185, 129, 0.1);
      color: #059669;
    }
    
    /* Sección de documentos principales mejorada */
    .documentos-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
      gap: 1rem;
      margin-bottom: 2rem;
    }
    
    .documento-principal {
      background: white;
      border-radius: 10px;
      padding: 1.25rem;
      border: 1px solid #e2e8f0;
      transition: all 0.2s;
      display: flex;
      align-items: flex-start;
      gap: 1rem;
    }
    
    .documento-principal:hover {
      transform: translateY(-2px);
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
      border-color: var(--primary-light);
    }
    
    .documento-principal-icon {
      width: 50px;
      height: 50px;
      border-radius: 10px;
      display: flex;
      align-items: center;
      justify-content: center;
      flex-shrink: 0;
      font-size: 1.25rem;
      background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
      color: white;
    }
    
    .documento-principal-content {
      flex: 1;
    }
    
    .documento-principal-title {
      font-size: 0.95rem;
      font-weight: 600;
      color: #1e293b;
      margin-bottom: 0.375rem;
    }
    
    .documento-principal-desc {
      font-size: 0.8rem;
      color: #64748b;
      margin-bottom: 0.75rem;
    }
    
    .documento-principal-meta {
      display: flex;
      align-items: center;
      gap: 1rem;
      font-size: 0.75rem;
      color: #94a3b8;
    }
    
    /* Modal para visualizar PDF */
    .modal {
      display: none;
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background-color: rgba(0, 0, 0, 0.8);
      z-index: 1000;
      align-items: center;
      justify-content: center;
    }
    
    .modal-content {
      background: white;
      border-radius: 12px;
      width: 90%;
      max-width: 900px;
      max-height: 90vh;
      overflow: hidden;
      display: flex;
      flex-direction: column;
    }
    
    .modal-header {
      padding: 1rem 1.5rem;
      background: var(--primary);
      color: white;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    
    .modal-body {
      flex: 1;
      padding: 0;
      overflow: hidden;
    }
    
    .pdf-viewer {
      width: 100%;
      height: 70vh;
      border: none;
    }
    
    .modal-close {
      background: none;
      border: none;
      color: white;
      font-size: 1.5rem;
      cursor: pointer;
      padding: 0;
      width: 32px;
      height: 32px;
      display: flex;
      align-items: center;
      justify-content: center;
      border-radius: 4px;
    }
    
    .modal-close:hover {
      background-color: rgba(255, 255, 255, 0.1);
    }
    
    /* Proyecto header */
    .project-header {
      background: linear-gradient(90deg, var(--primary) 0%, var(--primary-light) 100%);
      padding: 2rem;
      border-radius: 12px 12px 0 0;
    }
    
    .project-id {
      background-color: rgba(255, 255, 255, 0.2);
      color: white;
      padding: 0.5rem 1rem;
      border-radius: 6px;
      font-size: 0.875rem;
      font-weight: 600;
      display: inline-flex;
      align-items: center;
      gap: 0.5rem;
    }
    
    /* Footer */
    .footer {
      background: linear-gradient(90deg, #1e293b 0%, #334155 100%);
      color: white;
      padding: 1.5rem;
      text-align: center;
      font-size: 0.875rem;
    }
    
    /* Scrollbar styling */
    ::-webkit-scrollbar {
      width: 6px;
      height: 6px;
    }
    
    ::-webkit-scrollbar-track {
      background: #f1f5f9;
      border-radius: 3px;
    }
    
    ::-webkit-scrollbar-thumb {
      background: #cbd5e1;
      border-radius: 3px;
    }
    
    ::-webkit-scrollbar-thumb:hover {
      background: #94a3b8;
    }
  </style>
</head>
<body class="min-h-screen antialiased flex flex-col">

<%@ include file="../header.jsp" %>

<!-- Modal para visualizar PDF -->
<div id="pdfModal" class="modal">
  <div class="modal-content">
    <div class="modal-header">
      <h3 id="pdfTitle" class="font-bold">Visualizando documento</h3>
      <button class="modal-close" onclick="closePDFModal()">
        <i class="fas fa-times"></i>
      </button>
    </div>
    <div class="modal-body">
      <iframe id="pdfFrame" class="pdf-viewer" src="" frameborder="0"></iframe>
    </div>
  </div>
</div>

<!-- Contenido principal -->
<div class="flex-1 px-4 py-6 md:px-6">
  <div class="max-w-7xl mx-auto">
    
    <% if (mensajeError != null) { %>
      <div class="mb-6 card p-6 border-l-4 border-red-500">
        <div class="flex">
          <div class="flex-shrink-0">
            <i class="fas fa-exclamation-triangle text-red-500 text-xl"></i>
          </div>
          <div class="ml-3">
            <h3 class="text-sm font-medium text-red-800">Error</h3>
            <div class="mt-2 text-sm text-red-700">
              <p><%= mensajeError %></p>
            </div>
            <div class="mt-4">
              <a href="index.jsp" class="text-sm font-medium text-red-600 hover:text-red-500">
                ← Volver al listado de proyectos
              </a>
            </div>
          </div>
        </div>
      </div>
    <% } else if (proyecto.isEmpty()) { %>
      <div class="text-center py-12">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-[#7A1737] mx-auto"></div>
        <p class="mt-4 text-gray-600">Cargando información del proyecto...</p>
      </div>
    <% } else { %>
    
    <!-- Cabecera del proyecto -->
    <div class="card mb-8">
      <div class="project-header">
        <div class="flex flex-col md:flex-row md:items-center md:justify-between mb-6">
          <div class="mb-4 md:mb-0">
            <div class="flex items-center gap-3 mb-4">
              <div class="project-id">
                <i class="fas fa-hashtag"></i>
                ID: <%= proyecto.get("id") %>
              </div>
            </div>
            <h1 class="text-2xl md:text-3xl font-bold text-white mb-3"><%= escapeXml((String)proyecto.get("titulo")) %></h1>
            <p class="text-white/90 text-sm md:text-base flex items-center gap-2">
              <i class="fas fa-calendar-alt"></i>
              Convocatoria: <%= escapeXml((String)proyecto.get("convocatoria")) %>
            </p>
          </div>
          
          <div class="flex gap-3">
            <a href="/proyectos/pages/responsableDeproyecto/proyectos/index.jsp" 
               class="btn-outline !text-white !border-white/50">
              <i class="fas fa-arrow-left"></i>
              <span class="hidden md:inline">Volver</span>
            </a>
            
            <button onclick="descargarPDFCompleto()" class="btn-secondary">
              <i class="fas fa-download"></i>
              <span class="hidden md:inline">Documento Extenso</span>
            </button>
          </div>
        </div>
        
        <div class="pt-4 border-t border-white/20">
          <div class="grid grid-cols-1 md:grid-cols-4 gap-4 text-white/90 text-sm">
            <div>
              <p class="field-label !text-white/70">Creado</p>
              <p class="field-value !text-white flex items-center gap-2">
                <i class="fas fa-clock"></i>
                <%= formatearFecha(proyecto.get("fecha")) %>
              </p>
            </div>
            <div>
              <p class="field-label !text-white/70">Institución</p>
              <p class="field-value !text-white"><%= escapeXml((String)proyecto.get("institucion")) %></p>
            </div>
            <div>
              <p class="field-label !text-white/70">Área</p>
              <p class="field-value !text-white"><%= escapeXml((String)proyecto.get("area")) %></p>
            </div>
            <div>
              <p class="field-label !text-white/70">Municipio</p>
              <p class="field-value !text-white"><%= escapeXml((String)proyecto.get("municipio")) %></p>
            </div>
          </div>
        </div>
      </div>
      
      <div class="p-6 bg-white">
        <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
          <div>
            <p class="field-label">Sector de Impacto</p>
            <p class="field-value"><%= escapeXml((String)proyecto.get("sector")) %></p>
          </div>
          
          <div>
            <p class="field-label">Nivel TLR</p>
            <span class="badge badge-primary"><%= escapeXml((String)proyecto.get("tlr")) %></span>
          </div>
          
          <div>
            <p class="field-label">Nivel SLR</p>
            <span class="badge badge-secondary"><%= escapeXml((String)proyecto.get("slr")) %></span>
          </div>
          
          <div>
            <p class="field-label">Área de Conocimiento</p>
            <p class="field-value"><%= escapeXml((String)proyecto.get("area_conocimiento")) %></p>
          </div>
        </div>
      </div>
    </div>

    <!-- Documentos principales - Versión mejorada -->
    <div class="card p-6 mb-8">
      <h2 class="section-header">
        <i class="fas fa-file-alt"></i> Documentos Principales del Proyecto
      </h2>
      
      <div class="documentos-grid">
        <% for(Map<String,Object> doc : documentos) { %>
          <div class="documento-principal">
            <div class="documento-principal-icon">
              <i class="fas fa-file-pdf"></i>
            </div>
            <div class="documento-principal-content">
              <div class="documento-principal-title"><%= escapeXml((String)doc.get("nombre")) %></div>
              <div class="documento-principal-desc"><%= escapeXml((String)doc.get("descripcion")) %></div>
              <div class="documento-principal-meta">
                <span><i class="fas fa-calendar-alt"></i> <%= escapeXml((String)doc.get("fecha")) %></span>
                <span><i class="fas fa-file-alt"></i> <%= escapeXml((String)doc.get("tamaño")) %></span>
                <span class="document-status status-uploaded">
                  <i class="fas fa-check-circle"></i> Subido
                </span>
              </div>
              <div class="flex gap-2 mt-3">
                <button onclick="visualizarPDF('<%= escapeXml((String)doc.get("ruta")) %>', '<%= escapeXml((String)doc.get("nombre")) %>')" 
                        class="btn-primary !py-2 !px-3 !text-sm flex-1">
                  <i class="fas fa-eye"></i>
                  Visualizar
                </button>
                <button onclick="descargarPDF('<%= escapeXml((String)doc.get("ruta")) %>', '<%= escapeXml((String)doc.get("nombre")) %>')" 
                        class="btn-secondary !py-2 !px-3 !text-sm">
                  <i class="fas fa-download"></i>
                </button>
              </div>
            </div>
          </div>
        <% } %>
      </div>
    </div>

    <!-- Layout principal -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
      
      <!-- Columna principal -->
      <div class="lg:col-span-2 space-y-8">
        
        <!-- Descripción del Proyecto -->
        <div class="card p-6">
          <h2 class="section-header">
            <i class="fas fa-align-left"></i> Descripción del Proyecto
          </h2>
          
          <div class="mb-6">
            <p class="field-label mb-3">Resumen Ejecutivo</p>
            <div class="text-block"><%= escapeXml((String)proyecto.get("resumen")) %></div>
          </div>
          
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <p class="field-label mb-3">Objetivo General</p>
              <div class="text-block bg-blue-50 border-l-4 border-blue-500">
                <div class="flex items-start gap-2">
                  <i class="fas fa-bullseye text-blue-500 mt-0.5"></i>
                  <span><%= escapeXml((String)proyecto.get("obj_gral")) %></span>
                </div>
              </div>
            </div>
            
            <div>
              <p class="field-label mb-3">Objetivos Específicos</p>
              <div class="text-block bg-green-50 border-l-4 border-green-500">
                <div class="flex items-start gap-2">
                  <i class="fas fa-list-check text-green-500 mt-0.5"></i>
                  <span><%= escapeXml((String)proyecto.get("obj_esp")) %></span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Contexto y Metodología -->
        <div class="card p-6">
          <h2 class="section-header">
            <i class="fas fa-book-open"></i> Contexto y Metodología
          </h2>
          
          <div class="space-y-4">
            <div class="accordion">
              <div class="accordion-header">
                <div class="flex items-center gap-3">
                  <i class="fas fa-history text-[#7A1737]"></i>
                  <span class="font-medium">Antecedentes y Pertinencia</span>
                </div>
                <i class="fas fa-chevron-down text-gray-400 transition-transform"></i>
              </div>
              <div class="accordion-content">
                <div class="mb-4">
                  <p class="field-label mb-2">Antecedentes</p>
                  <p class="text-sm text-gray-700"><%= escapeXml((String)proyecto.get("antecedentes")) %></p>
                </div>
                <div>
                  <p class="field-label mb-2">Pertinencia</p>
                  <p class="text-sm text-gray-700"><%= escapeXml((String)proyecto.get("pertinencia")) %></p>
                </div>
              </div>
            </div>
            
            <div class="accordion">
              <div class="accordion-header">
                <div class="flex items-center gap-3">
                  <i class="fas fa-flask text-[#7A1737]"></i>
                  <span class="font-medium">Metodología y Riesgos</span>
                </div>
                <i class="fas fa-chevron-down text-gray-400 transition-transform"></i>
              </div>
              <div class="accordion-content">
                <div class="mb-4">
                  <p class="field-label mb-2">Preguntas de Investigación</p>
                  <p class="text-sm text-gray-700"><%= escapeXml((String)proyecto.get("preguntas")) %></p>
                </div>
                <div class="mb-4">
                  <p class="field-label mb-2">Resumen Metodológico</p>
                  <div class="text-block"><%= escapeXml((String)proyecto.get("metodologia")) %></div>
                </div>
                <div>
                  <p class="field-label mb-2 text-red-600">Factores de Riesgo y Mitigación</p>
                  <div class="text-block bg-red-50 border-l-4 border-red-500">
                    <div class="flex items-start gap-2">
                      <i class="fas fa-exclamation-triangle text-red-500 mt-0.5"></i>
                      <span><%= escapeXml((String)proyecto.get("riesgos")) %></span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          
          <div class="mt-6">
            <p class="field-label mb-3">Resultados Esperados</p>
            <div class="text-block bg-purple-50 border-l-4 border-purple-500">
              <div class="flex items-start gap-2">
                <i class="fas fa-chart-line text-purple-500 mt-0.5"></i>
                <span><%= escapeXml((String)proyecto.get("resultados")) %></span>
              </div>
            </div>
          </div>
        </div>

        <!-- Impactos -->
        <div class="card p-6">
          <h2 class="section-header">
            <i class="fas fa-chart-bar"></i> Impactos del Proyecto
          </h2>
          
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div class="impact-card social">
              <div class="flex flex-col h-full">
                <div class="flex items-start gap-3 mb-3">
                  <div class="bg-blue-100 p-3 rounded-lg">
                    <i class="fas fa-users text-blue-600 text-lg"></i>
                  </div>
                  <div>
                    <h4 class="font-bold text-blue-700 text-sm uppercase mb-1">Impacto Social</h4>
                    <p class="text-sm text-gray-700"><%= escapeXml((String)proyecto.get("imp_social")) %></p>
                  </div>
                </div>
              </div>
            </div>
            
            <div class="impact-card environmental">
              <div class="flex flex-col h-full">
                <div class="flex items-start gap-3 mb-3">
                  <div class="bg-green-100 p-3 rounded-lg">
                    <i class="fas fa-leaf text-green-600 text-lg"></i>
                  </div>
                  <div>
                    <h4 class="font-bold text-green-700 text-sm uppercase mb-1">Impacto Ambiental</h4>
                    <p class="text-sm text-gray-700"><%= escapeXml((String)proyecto.get("imp_amb")) %></p>
                  </div>
                </div>
              </div>
            </div>
            
            <div class="impact-card economic">
              <div class="flex flex-col h-full">
                <div class="flex items-start gap-3 mb-3">
                  <div class="bg-yellow-100 p-3 rounded-lg">
                    <i class="fas fa-chart-line text-yellow-600 text-lg"></i>
                  </div>
                  <div>
                    <h4 class="font-bold text-yellow-700 text-sm uppercase mb-1">Impacto Económico</h4>
                    <p class="text-sm text-gray-700"><%= escapeXml((String)proyecto.get("imp_eco")) %></p>
                  </div>
                </div>
              </div>
            </div>
            
            <div class="impact-card scientific">
              <div class="flex flex-col h-full">
                <div class="flex items-start gap-3 mb-3">
                  <div class="bg-purple-100 p-3 rounded-lg">
                    <i class="fas fa-microscope text-purple-600 text-lg"></i>
                  </div>
                  <div>
                    <h4 class="font-bold text-purple-700 text-sm uppercase mb-1">Impacto Científico/Tecnológico</h4>
                    <p class="text-sm text-gray-700"><%= escapeXml((String)proyecto.get("imp_cient")) %></p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Cronograma -->
        <div class="card p-6">
          <h2 class="section-header">
            <i class="fas fa-calendar-alt"></i> Cronograma de Actividades
          </h2>
          
          <% if(cronograma.isEmpty()) { %>
            <div class="text-center py-8">
              <i class="fas fa-calendar-times text-gray-300 text-4xl mb-3"></i>
              <p class="text-gray-500">No hay actividades registradas en el cronograma.</p>
            </div>
          <% } else { %>
            <div class="table-container">
              <table>
                <thead>
                  <tr>
                    <th class="text-left">Descripcion del semestre</th>
                    <th class ="text-left"> Meta del semestre</th>
                    <th class="text-left">Actividad</th>
                    <th class="text-left">Entregable</th>
                  </tr>
                </thead>
                <tbody>
                  <% for(Map<String,Object> c : cronograma) { %>
                  <tr>
                    <td>
                      <span class="flex items-center">
                        <i class="mr-2"></i> <%= escapeXml((String)c.get("semestre")) %>
                      </span>
                    </td>
                    <td class="font-medium"><%= escapeXml((String)c.get("meta")) %></td>
                    <td class="font-medium"><%= escapeXml((String)c.get("actividad")) %></td>
                    <td>
                      <div class="flex items-center gap-2">
                        <i class="fas fa-file-export text-gray-400"></i>
                        <span class="text-gray-600"><%= escapeXml((String)c.get("entregable")) %></span>
                      </div>
                    </td>
                  </tr>
                  <% } %>
                </tbody>
              </table>
            </div>
          <% } %>
        </div>
      </div>

      <!-- Barra lateral -->
      <div class="space-y-8">
        
        <!-- Responsables -->
        <div class="card p-6">
          <h3 class="section-header !text-base">
            <i class="fas fa-user-tie"></i> Responsables
          </h3>
          <div class="space-y-4">
            <% for(Map<String,Object> r : responsables) { %>
              <div class="person-card">
                <div class="person-icon primary">
                  <i class="fas fa-user"></i>
                </div>
                <div class="person-info">
                  <div class="person-role"><%= escapeXml((String)r.get("rol")) %></div>
                  <div class="person-name"><%= escapeXml((String)r.get("nombre")) %></div>
                  <div class="person-details">
                    <div><i class="fas fa-envelope"></i> <%= escapeXml((String)r.get("email")) %></div>
                    <div><i class="fas fa-phone"></i> <%= escapeXml((String)r.get("tel")) %></div>
                  </div>
                </div>
              </div>
            <% } %>
          </div>
        </div>

        <!-- Estudiantes -->
        <div class="card p-6">
          <h3 class="section-header !text-base">
            <i class="fas fa-graduation-cap"></i> Estudiantes Participantes
          </h3>
          <div class="space-y-4">
            <% if(estudiantes.isEmpty()){ %>
              <div class="text-center py-4">
                <i class="fas fa-user-graduate text-gray-300 text-3xl mb-2"></i>
                <p class="text-xs text-gray-500">No hay estudiantes registrados.</p>
              </div>
            <% } %>
            <% for(Map<String,Object> e : estudiantes) { %>
              <div class="person-card">
                <div class="person-icon blue">
                  <i class="fas fa-user-graduate"></i>
                </div>
                <div class="person-info">
                  <div class="person-name"><%= escapeXml((String)e.get("nombre")) %></div>
                  <div class="person-details">
                    <div><i class="fas fa-university"></i> <%= escapeXml((String)e.get("inst")) %></div>
                  </div>
                  <div class="person-tags mb-2">
                    <span class="badge badge-success"><%= escapeXml((String)e.get("nivel")) %></span>
                    <span class="badge badge-info"><%= escapeXml((String)e.get("programa")) %></span>
                  </div>
                  <% if(e.get("carta") != null && !((String)e.get("carta")).isEmpty()) { %>
                    <button onclick="visualizarPDF('<%= escapeXml((String)e.get("carta")) %>', 'Carta Intención - <%= escapeXml((String)e.get("nombre")) %>')" 
                            class="text-xs flex items-center gap-1 text-blue-600 hover:text-blue-800 font-semibold mt-1">
                      <i class="fas fa-file-pdf"></i> Ver Carta de Intención
                    </button>
                  <% } %>
                </div>
              </div>
            <% } %>
          </div>
        </div>

        <!-- Grupo de Trabajo -->
        <div class="card p-6">
          <h3 class="section-header !text-base">
            <i class="fas fa-users-gear"></i> Grupo de Trabajo
          </h3>
          <div class="space-y-4">
            <% if(grupoTrabajo.isEmpty()){ %>
              <div class="text-center py-4">
                <i class="fas fa-users text-gray-300 text-3xl mb-2"></i>
                <p class="text-xs text-gray-500">No hay investigadores registrados.</p>
              </div>
            <% } %>
            <% for(Map<String,Object> g : grupoTrabajo) { %>
              <div class="person-card">
                <div class="person-icon green">
                  <i class="fas fa-user-check"></i>
                </div>
                <div class="person-info">
                  <div class="person-name"><%= escapeXml((String)g.get("nombre")) %></div>
                  <div class="person-details">
                    <div><i class="fas fa-building"></i> <%= escapeXml((String)g.get("inst")) %></div>
                    <div><i class="fas fa-tasks"></i> <%= escapeXml((String)g.get("rol")) %></div>
                  </div>
                  <div class="person-tags mb-2">
                    <span class="badge badge-primary"><%= escapeXml((String)g.get("grado")) %></span>
                    <span class="badge badge-secondary"><%= escapeXml((String)g.get("disciplina")) %></span>
                  </div>
                  <% if(g.get("comprobante") != null && !((String)g.get("comprobante")).isEmpty()) { %>
                    <button onclick="visualizarPDF('<%= escapeXml((String)g.get("comprobante")) %>', 'Comprobante - <%= escapeXml((String)g.get("nombre")) %>')" 
                            class="text-xs flex items-center gap-1 text-green-600 hover:text-green-800 font-semibold mt-1">
                      <i class="fas fa-file-contract"></i> Ver Comprobante
                    </button>
                  <% } %>
                </div>
              </div>
            <% } %>
          </div>
        </div>

        <!-- Alianzas -->
        <div class="card p-6">
          <h3 class="section-header !text-base">
            <i class="fas fa-handshake"></i> Alianzas Estratégicas
          </h3>
          <div class="space-y-4">
            <% if(organizaciones.isEmpty()){ %>
              <div class="text-center py-4">
                <i class="fas fa-handshake text-gray-300 text-3xl mb-2"></i>
                <p class="text-xs text-gray-500">No hay alianzas registradas.</p>
              </div>
            <% } %>
            <% for(Map<String,Object> o : organizaciones) { %>
              <div class="person-card">
                <div class="person-icon amber">
                  <i class="fas fa-building"></i>
                </div>
                <div class="person-info">
                  <div class="person-name"><%= escapeXml((String)o.get("nombre")) %></div>
                  <div class="person-details">
                    <div><i class="fas fa-user-tie"></i> <%= escapeXml((String)o.get("resp")) %></div>
                  </div>
                  <div class="mt-2 p-2 bg-gray-50 rounded border text-xs text-gray-600">
                    <i class="fas fa-briefcase mr-1"></i> <%= escapeXml((String)o.get("actividad")) %>
                  </div>
                  <% if(o.get("comprobante") != null && !((String)o.get("comprobante")).isEmpty()) { %>
                    <button onclick="visualizarPDF('<%= escapeXml((String)o.get("comprobante")) %>', 'Comprobante - <%= escapeXml((String)o.get("nombre")) %>')" 
                            class="text-xs flex items-center gap-1 text-amber-600 hover:text-amber-800 font-semibold mt-2">
                      <i class="fas fa-file-contract"></i> Ver Comprobante
                    </button>
                  <% } %>
                </div>
              </div>
            <% } %>
          </div>
        </div>
        
        <!-- Botón de volver -->
        <div class="card p-6">
          <a href="/proyectos/pages/responsableDeproyecto/proyectos/" class="btn-outline w-full">
            <i class="fas fa-arrow-left"></i>
            Volver al Listado de Proyectos
          </a>
        </div>

      </div>
    </div>

    <% } %>
    
  </div>
</div>

<%@ include file="/footer.jsp" %>

<script src="https://cdnjs.cloudflare.com/ajax/libs/viewerjs/1.11.6/viewer.min.js"></script>
<script>
  // Funcionalidad para los acordeones
  document.addEventListener('DOMContentLoaded', function() {
    const accordionHeaders = document.querySelectorAll('.accordion-header');
    
    accordionHeaders.forEach(header => {
      header.addEventListener('click', function() {
        const content = this.nextElementSibling;
        const icon = this.querySelector('.fa-chevron-down');
        
        if (content.style.display === 'block') {
          content.style.display = 'none';
          icon.style.transform = 'rotate(0deg)';
        } else {
          content.style.display = 'block';
          icon.style.transform = 'rotate(180deg)';
        }
      });
    });
    
    // Inicializar acordeones cerrados
    document.querySelectorAll('.accordion-content').forEach(content => {
      content.style.display = 'none';
    });
  });

  // Funciones para manejar PDFs
  function visualizarPDF(ruta, nombre) {
    const modal = document.getElementById('pdfModal');
    const pdfFrame = document.getElementById('pdfFrame');
    const pdfTitle = document.getElementById('pdfTitle');
    
    pdfFrame.src = ruta;
    pdfTitle.textContent = nombre;
    modal.style.display = 'flex';
    
    // Evitar que el modal se cierre al hacer clic en el contenido
    modal.addEventListener('click', function(e) {
      if (e.target === modal) {
        closePDFModal();
      }
    });
  }
  
  function closePDFModal() {
    const modal = document.getElementById('pdfModal');
    const pdfFrame = document.getElementById('pdfFrame');
    
    pdfFrame.src = '';
    modal.style.display = 'none';
  }
  
  function descargarPDF(ruta, nombre) {
    // En un sistema real, esta sería una llamada al servidor
    // Por ahora simulamos la descarga
    const link = document.createElement('a');
    link.href = ruta;
    link.download = nombre + '.pdf';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    
    mostrarNotificacion(`Documento "${nombre}" descargado exitosamente`, 'success');
  }
  
  function descargarPDFCompleto() {
    <% 
       String docPath = (String)proyecto.get("doc_extenso");
       String finalPath = "";
       if(docPath != null && !docPath.trim().isEmpty()) {
           if(docPath.startsWith(request.getContextPath())) {
               finalPath = docPath;
           } else {
               finalPath = request.getContextPath() + (docPath.startsWith("/") ? "" : "/") + docPath;
           }
       }
    %>
    var url = '<%= finalPath %>';
    
    if(!url) {
        mostrarNotificacion('El documento extenso no está disponible.', 'info'); 
        return;
    }

    // En un sistema real, esto generaría un PDF con toda la información del proyecto
    mostrarNotificacion('Descargando documento extenso...', 'info');
    
    setTimeout(() => {
      const link = document.createElement('a');
      // usa un href y usa el  String docExtenso = rs.getString("doc_extenso"); para obtener la ruta correcta
      link.href = url;
      link.download = 'Proyecto_' + '<%= proyecto.get("id") %>' + '_COVEICYDET.pdf';
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    }, 1500);
  }
  
  // Función para mostrar notificaciones
  function mostrarNotificacion(mensaje, tipo) {
    const notification = document.createElement('div');
    
    var bgClass = 'bg-gray-800 text-white';
    var iconClass = 'info-circle';
    
    if (tipo === 'success') {
        bgClass = 'bg-green-500 text-white';
        iconClass = 'check-circle';
    } else if (tipo === 'info') {
        bgClass = 'bg-blue-500 text-white';
    }
    
    notification.className = 'fixed top-4 right-4 px-4 py-3 rounded-lg shadow-lg z-50 transition-all duration-300 flex items-center gap-3 ' + bgClass;
    
    notification.innerHTML = '<i class="fas fa-' + iconClass + '"></i><span>' + mensaje + '</span>';
    
    document.body.appendChild(notification);
    
    setTimeout(() => {
      notification.style.opacity = '0';
      setTimeout(() => {
        notification.remove();
      }, 300);
    }, 3000);
  }
  
  // Cerrar modal con Escape
  document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
      closePDFModal();
    }
  });
</script>
</body>
</html>
