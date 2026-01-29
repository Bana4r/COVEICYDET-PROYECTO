<%@ page language="java" contentType="application/vnd.ms-excel; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%-- VALIDACIÓN DE SESIÓN --%>
<% 
    if (!"analista".equals(String.valueOf(session.getAttribute("rol")))) { 
        String n=request.getRequestURI()+(request.getQueryString()!=null?("?"+request.getQueryString()):"");
        response.sendRedirect(request.getContextPath()+"/pages/login/login.jsp?next="+java.net.URLEncoder.encode(n,"UTF-8")); 
        return; 
    } 
%>

<%@ include file="/WEB-INF/conexion.jsp"%>

<%
    String nombreArchivo = "BASE_DATOS_MAESTRA_PROYECTOS_" + new SimpleDateFormat("yyyyMMdd_HHmm").format(new java.util.Date()) + ".xls";
    response.setHeader("Content-Disposition", "attachment; filename=" + nombreArchivo);
    
    List<Map<String, Object>> proyectosList = new ArrayList<>();

    if (conn != null) {
        try {
            // SQL ULTRA-EXTENSO: Cruce de todas las tablas del esquema
            String sql = "SELECT p.*, c.nombre_convocatoria, " +
                // ESTADO DEL PROYECTO (Texto)
                "CASE " +
                "  WHEN p.estado_proyecto ~ '^[0-9]+$' THEN (SELECT nombre_estado FROM estado_proyecto WHERE id_estado = p.estado_proyecto::integer) " +
                "  ELSE p.estado_proyecto " +
                "END AS nombre_estado_proyecto, " +
                
                // Datos del Usuario que registró (incluye RFC)
                "(SELECT u.rfc || ' | ' || u.correo_electronico FROM usuarios u JOIN proyecto_usuarios pu ON u.id_usuario = pu.id_usuario WHERE pu.id_proyecto = p.id_proyecto LIMIT 1) as datos_registro, " +
                
                // Responsable TÉCNICO (Separado)
                "(SELECT nombre_completo FROM responsable r JOIN proyecto_responsables pr ON r.id_responsable = pr.id_responsable WHERE pr.id_proyecto = p.id_proyecto AND pr.tipo_responsable = 'tecnico' LIMIT 1) as resp_tecnico_nombre, " +
                "(SELECT correo_electronico FROM responsable r JOIN proyecto_responsables pr ON r.id_responsable = pr.id_responsable WHERE pr.id_proyecto = p.id_proyecto AND pr.tipo_responsable = 'tecnico' LIMIT 1) as resp_tecnico_email, " +
                "(SELECT telefono FROM responsable r JOIN proyecto_responsables pr ON r.id_responsable = pr.id_responsable WHERE pr.id_proyecto = p.id_proyecto AND pr.tipo_responsable = 'tecnico' LIMIT 1) as resp_tecnico_tel, " +
                
                // Responsable LEGAL (Separado)
                "(SELECT nombre_completo FROM responsable r JOIN proyecto_responsables pr ON r.id_responsable = pr.id_responsable WHERE pr.id_proyecto = p.id_proyecto AND pr.tipo_responsable = 'legal' LIMIT 1) as resp_legal_nombre, " +
                "(SELECT correo_electronico FROM responsable r JOIN proyecto_responsables pr ON r.id_responsable = pr.id_responsable WHERE pr.id_proyecto = p.id_proyecto AND pr.tipo_responsable = 'legal' LIMIT 1) as resp_legal_email, " +
                "(SELECT telefono FROM responsable r JOIN proyecto_responsables pr ON r.id_responsable = pr.id_responsable WHERE pr.id_proyecto = p.id_proyecto AND pr.tipo_responsable = 'legal' LIMIT 1) as resp_legal_tel, " +
                
                // Responsable ADMINISTRATIVO (Separado)
                "(SELECT nombre_completo FROM responsable r JOIN proyecto_responsables pr ON r.id_responsable = pr.id_responsable WHERE pr.id_proyecto = p.id_proyecto AND pr.tipo_responsable = 'administrativo' LIMIT 1) as resp_admin_nombre, " +
                "(SELECT correo_electronico FROM responsable r JOIN proyecto_responsables pr ON r.id_responsable = pr.id_responsable WHERE pr.id_proyecto = p.id_proyecto AND pr.tipo_responsable = 'administrativo' LIMIT 1) as resp_admin_email, " +
                "(SELECT telefono FROM responsable r JOIN proyecto_responsables pr ON r.id_responsable = pr.id_responsable WHERE pr.id_proyecto = p.id_proyecto AND pr.tipo_responsable = 'administrativo' LIMIT 1) as resp_admin_tel, " +
                
                // Grupo de Trabajo (Participantes)
                "(SELECT STRING_AGG(nombre_completo || ' [' || institucion_adscripcion || ' - ' || grado_academico || ']', ' / ') FROM participante pa JOIN gruposdetrabajo gt ON pa.id_gt_participante = gt.id_gt_participante WHERE gt.id_proyecto = p.id_proyecto) as detalle_gt, " +
                
                // Estudiantes
                "(SELECT STRING_AGG(e.nombre_completo || ' [' || e.institucion || ' - ' || e.nivel_academico || ']', ' / ') FROM estudiantes e JOIN estudiantes_participantes ep ON e.id_estudiante = ep.id_estudiante WHERE ep.id_proyecto = p.id_proyecto) as detalle_estudiantes, " +
                
                // Organizaciones Sociales
                "(SELECT STRING_AGG(o.nombre_razon_social || ' (Contacto: ' || o.responsable || ' - ' || o.correo_electronico || ')', ' / ') FROM organizacion_social o JOIN proyecto_organizaciones po ON o.org_social_id = po.org_social_id WHERE po.id_proyecto = p.id_proyecto) as detalle_orgs, " +
                
                // Presupuesto Total y Detallado (Con salto de línea XML entity &#10;)
                "(SELECT SUM(monto) FROM semestres_proyecto WHERE id_proyecto = p.id_proyecto) as total_presupuesto, " +
                "(SELECT STRING_AGG('S' || sp.id_semestre || ' - ' || par.nombre || ': $' || sp.monto, '&#10;') FROM semestres_proyecto sp JOIN partidas par ON sp.id_partidas = par.id_partidas WHERE sp.id_proyecto = p.id_proyecto) as desglose_partidas, " +
                
                // Cronograma
                "(SELECT STRING_AGG('S' || id_semestre || ': ' || nombre_actividad || ' (Entregable: ' || entregables || ')', ' | ') FROM cronograma_actividades ca JOIN actividades a ON ca.id_actividad = a.id_actividad WHERE ca.id_proyecto = p.id_proyecto) as cronograma_completo " +
                
                "FROM proyectos p " +
                "LEFT JOIN convocatoria c ON p.convocatoria_id = c.id_convocatoria " +
                "ORDER BY p.id_proyecto ASC";

            try (PreparedStatement stmt = conn.prepareStatement(sql);
                 ResultSet rs = stmt.executeQuery()) {
                ResultSetMetaData md = rs.getMetaData();
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    for (int i = 1; i <= md.getColumnCount(); i++) {
                        row.put(md.getColumnName(i), rs.getObject(i));
                    }
                    proyectosList.add(row);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); } finally { if (conn != null) conn.close(); }
    }
%>

<?xml version="1.0" encoding="UTF-8"?>
<?mso-application progid="Excel.Sheet"?>
<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet">
 <Styles>
  <Style ss:ID="Header"><Font ss:Bold="1" ss:Color="#FFFFFF"/><Interior ss:Color="#7A1737" ss:Pattern="Solid"/><Alignment ss:Vertical="Center" ss:Horizontal="Center" ss:WrapText="1"/></Style>
  <Style ss:ID="Data"><Alignment ss:Vertical="Top" ss:WrapText="1"/></Style>
  <Style ss:ID="Money"><NumberFormat ss:Format="Currency"/><Alignment ss:Vertical="Top"/></Style>
  <Style ss:ID="ID"><Alignment ss:Horizontal="Center" ss:Vertical="Center"/><Font ss:Bold="1"/></Style>
 </Styles>
 <Worksheet ss:Name="PROYECTOS_FULL_DATA">
  <Table>
   <!-- Definición de anchos de columna -->
   <Column ss:Width="40"/>  <!-- ID -->
   <Column ss:Width="250"/> <!-- Titulo -->
   <Column ss:Width="120"/> <!-- Convocatoria -->
   <Column ss:Width="100"/> <!-- Estado -->
   <Column ss:Width="100"/> <!-- Presupuesto -->
   <Column ss:Width="300"/> <!-- Desglose -->
   <Column ss:Width="150"/> <!-- Institucion -->
   <Column ss:Width="150"/> <!-- Municipio -->
   <Column ss:Width="200"/> <!-- Registro -->
   
   <!-- Resp Tecnico -->
   <Column ss:Width="200"/> <Column ss:Width="150"/> <Column ss:Width="100"/>
   <!-- Resp Legal -->
   <Column ss:Width="200"/> <Column ss:Width="150"/> <Column ss:Width="100"/>
   <!-- Resp Admin -->
   <Column ss:Width="200"/> <Column ss:Width="150"/> <Column ss:Width="100"/>
   
   <Column ss:Width="300"/> <!-- Grupo Trabajo -->
   <Column ss:Width="200"/> <!-- Estudiantes -->
   <Column ss:Width="200"/> <!-- Organizaciones -->
   <Column ss:Width="80"/>  <!-- TRL -->
   <Column ss:Width="300"/> <!-- Resumen -->
   <Column ss:Width="300"/> <!-- Obj General -->
   <Column ss:Width="300"/> <!-- Obj Esp -->
   <Column ss:Width="300"/> <!-- Metodologia -->
   <Column ss:Width="300"/> <!-- Cronograma -->
   <Column ss:Width="200"/> <!-- Imp Social -->
   <Column ss:Width="200"/> <!-- Imp Amb -->
   <Column ss:Width="200"/> <!-- Imp Eco -->
   <Column ss:Width="200"/> <!-- Imp Cient -->
   
   <Row ss:Height="45">
    <Cell ss:StyleID="Header"><Data ss:Type="String">ID</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">TITULO DEL PROYECTO</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">CONVOCATORIA</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">ESTADO</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">PRESUPUESTO TOTAL</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">DESGLOSE POR PARTIDAS</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">INSTITUCION</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">MUNICIPIO</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">REGISTRO (RFC/CORREO)</Data></Cell>
    
    <Cell ss:StyleID="Header"><Data ss:Type="String">RESPONSABLE TÉCNICO</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">EMAIL TÉCNICO</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">TELÉFONO TÉCNICO</Data></Cell>
    
    <Cell ss:StyleID="Header"><Data ss:Type="String">RESPONSABLE LEGAL</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">EMAIL LEGAL</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">TELÉFONO LEGAL</Data></Cell>
    
    <Cell ss:StyleID="Header"><Data ss:Type="String">RESPONSABLE ADMON</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">EMAIL ADMON</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">TELÉFONO ADMON</Data></Cell>
    
    <Cell ss:StyleID="Header"><Data ss:Type="String">GRUPO DE TRABAJO</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">ESTUDIANTES</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">ORGANIZACIONES VINCULADAS</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">NIVEL TRL/SRL</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">RESUMEN EJECUTIVO</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">OBJETIVO GENERAL</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">OBJETIVOS ESPECÍFICOS</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">METODOLOGÍA</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">CRONOGRAMA Y ENTREGABLES</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">IMPACTO SOCIAL</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">IMPACTO AMBIENTAL</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">IMPACTO ECONÓMICO</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">IMPACTO CIENTÍFICO</Data></Cell>
   </Row>

   <% for (Map<String, Object> p : proyectosList) { %>
   <Row ss:AutoFitHeight="1">
    <Cell ss:StyleID="ID"><Data ss:Type="Number"><%= p.get("id_proyecto") %></Data></Cell>
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= p.get("titulo") %></Data></Cell>
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= p.get("nombre_convocatoria") %></Data></Cell>
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= p.get("nombre_estado_proyecto") %></Data></Cell>
    <Cell ss:StyleID="Money"><Data ss:Type="Number"><%= p.get("total_presupuesto") != null ? p.get("total_presupuesto") : 0 %></Data></Cell>
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= p.get("desglose_partidas") %></Data></Cell>
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= p.get("institucion_proponente") %></Data></Cell>
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= p.get("municipio") %></Data></Cell>
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= p.get("datos_registro") %></Data></Cell>
    
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= p.get("resp_tecnico_nombre") %></Data></Cell>
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= p.get("resp_tecnico_email") %></Data></Cell>
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= p.get("resp_tecnico_tel") %></Data></Cell>
    
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= p.get("resp_legal_nombre") %></Data></Cell>
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= p.get("resp_legal_email") %></Data></Cell>
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= p.get("resp_legal_tel") %></Data></Cell>
    
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= p.get("resp_admin_nombre") %></Data></Cell>
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= p.get("resp_admin_email") %></Data></Cell>
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= p.get("resp_admin_tel") %></Data></Cell>
    
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= p.get("detalle_gt") %></Data></Cell>
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= p.get("detalle_estudiantes") %></Data></Cell>
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= p.get("detalle_orgs") %></Data></Cell>
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= p.get("nivel_tlr") + " / " + p.get("nivel_slr") %></Data></Cell>
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= p.get("resumen_ejecutivo") %></Data></Cell>
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= p.get("objetivos_general") %></Data></Cell>
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= p.get("objetivos_especificos") %></Data></Cell>
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= p.get("resumen_metodologia") %></Data></Cell>
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= p.get("cronograma_completo") %></Data></Cell>
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= p.get("impacto_social") %></Data></Cell>
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= p.get("impacto_ambiental") %></Data></Cell>
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= p.get("impacto_economico") %></Data></Cell>
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= p.get("impacto_cientificotecnologico") %></Data></Cell>
   </Row>
   <% } %>
  </Table>
 </Worksheet>
</Workbook>