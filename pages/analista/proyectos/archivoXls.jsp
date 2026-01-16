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
    // Configurar headers para descarga de Excel
    String nombreArchivo = "proyectos_" + new SimpleDateFormat("yyyyMMdd_HHmmss").format(new java.util.Date()) + ".xls";
    response.setHeader("Content-Disposition", "attachment; filename=" + nombreArchivo);
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    // Lista para almacenar proyectos
    List<Map<String, Object>> proyectosList = new ArrayList<>();
    String mensajeError = null;

    SimpleDateFormat formatoFecha = new SimpleDateFormat("dd/MM/yyyy HH:mm");

    // Contadores para resumen
    int totalPendientes = 0;
    int totalEnRevision = 0;
    int totalAprobados = 0;
    int totalRechazados = 0;
    int totalFinalizados = 0;

    if (conn != null) {
        try {
            String sql = "SELECT " +
                       "p.id_proyecto, " +
                       "p.titulo, " +
                       "p.estado_proyecto, " +
                       "p.fecha_creacion, " +
                       "p.institucion_proponente, " +
                       "p.area_conocimiento, " +
                       "p.sector_impacto_proyecto, " +
                       "p.nivel_tlr, " +
                       "p.nivel_slr, " +
                       "p.resumen_ejecutivo, " +
                       "c.nombre_convocatoria, " +
                       "u.nombre, " +
                       "u.primer_apellido, " +
                       "u.segundo_apellido, " +
                       "u.correo_electronico " +
                       "FROM Proyectos p " +
                       "LEFT JOIN proyecto_usuarios pu ON p.id_proyecto = pu.id_proyecto " +
                       "LEFT JOIN usuarios u ON pu.id_usuario = u.id_usuario " +
                       "LEFT JOIN convocatoria c ON p.convocatoria_id = c.id_convocatoria " +
                       "ORDER BY p.fecha_creacion DESC";
                       
            try (PreparedStatement stmt = conn.prepareStatement(sql);
                 ResultSet rs = stmt.executeQuery()) {
                
                while (rs.next()) {
                    Map<String, Object> proyecto = new HashMap<>();
                    proyecto.put("id", rs.getInt("id_proyecto"));
                    proyecto.put("titulo", rs.getString("titulo"));
                    
                    // Mapeo de estado
                    String estadoBD = rs.getString("estado_proyecto");
                    String estadoFrontend = "Pendiente";
                    
                    if (estadoBD != null) {
                        String e = estadoBD.toLowerCase().trim();
                        
                        if (e.equals("finalizado") || e.equals("completado") || e.equals("19")) {
                            estadoFrontend = "Finalizado";
                            totalFinalizados++;
                        } else if (e.equals("aprobado") || e.equals("7")) {
                            estadoFrontend = "Aprobado";
                            totalAprobados++;
                        } else if (e.equals("rechazado") || e.equals("-1")) {
                            estadoFrontend = "Rechazado";
                            totalRechazados++;
                        } else if (e.contains("revision") || e.contains("evaluacion") || e.contains("proceso") || 
                                 e.equals("3") || e.equals("4") || e.equals("5") || e.equals("6") || e.equals("en_revision")) {
                            estadoFrontend = "En Revisión";
                            totalEnRevision++;
                        } else if (e.equals("borrador") || e.equals("enviado") || e.equals("1") || e.equals("2")) {
                            estadoFrontend = "Pendiente";
                            totalPendientes++;
                        } else {
                            estadoFrontend = estadoBD;
                            totalPendientes++;
                        }
                    } else {
                        totalPendientes++;
                    }
                    proyecto.put("estado", estadoFrontend);
                    proyecto.put("estadoOriginal", estadoBD);

                    // Fecha
                    Timestamp ts = rs.getTimestamp("fecha_creacion");
                    proyecto.put("fecha", ts);

                    // Otros campos
                    proyecto.put("institucion", rs.getString("institucion_proponente"));
                    proyecto.put("convocatoria", rs.getString("nombre_convocatoria"));
                    proyecto.put("area", rs.getString("area_conocimiento"));
                    proyecto.put("sector", rs.getString("sector_impacto_proyecto"));
                    proyecto.put("tlr", rs.getString("nivel_tlr"));
                    proyecto.put("slr", rs.getString("nivel_slr"));
                    proyecto.put("resumen", rs.getString("resumen_ejecutivo"));

                    // Responsable
                    String nombreUsr = rs.getString("nombre");
                    String ape1 = rs.getString("primer_apellido");
                    String ape2 = rs.getString("segundo_apellido");
                    String nombreCompleto = (nombreUsr != null ? nombreUsr : "") + " " + 
                                          (ape1 != null ? ape1 : "") + " " + 
                                          (ape2 != null ? ape2 : "");
                    proyecto.put("responsable", nombreCompleto.trim().isEmpty() ? "Sin asignar" : nombreCompleto.trim());
                    proyecto.put("email", rs.getString("correo_electronico"));

                    proyectosList.add(proyecto);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error de base de datos en archivoXls.jsp (proyectos): " + e.getMessage());
            e.printStackTrace();
            mensajeError = "Error de conexión a la base de datos: " + e.getMessage();
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { /* ignorar */ }
            }
        }
    } else {
        mensajeError = dbError != null && !dbError.isEmpty() ? dbError : "No se pudo establecer conexión con la base de datos.";
    }
%>

<?xml version="1.0" encoding="UTF-8"?>
<?mso-application progid="Excel.Sheet"?>
<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
 xmlns:o="urn:schemas-microsoft-com:office:office"
 xmlns:x="urn:schemas-microsoft-com:office:excel"
 xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
 xmlns:html="http://www.w3.org/TR/REC-html40">
 
 <DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">
  <Title>Proyectos - COVEICYDET</Title>
  <Author>Sistema COVEICYDET</Author>
  <Created><%= new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(new java.util.Date()) %></Created>
 </DocumentProperties>
 
 <Styles>
  <!-- Estilo para encabezados -->
  <Style ss:ID="Header">
   <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>
   <Borders>
    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>
    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#000000"/>
    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#000000"/>
    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2" ss:Color="#000000"/>
   </Borders>
   <Font ss:Bold="1" ss:Color="#FFFFFF" ss:Size="11"/>
   <Interior ss:Color="#7A1737" ss:Pattern="Solid"/>
  </Style>
  
  <!-- Estilo para título principal -->
  <Style ss:ID="Title">
   <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
   <Font ss:Bold="1" ss:Color="#7A1737" ss:Size="16"/>
  </Style>
  
  <!-- Estilo para subtítulo -->
  <Style ss:ID="Subtitle">
   <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
   <Font ss:Color="#666666" ss:Size="10"/>
  </Style>
  
  <!-- Estilo para celdas de datos -->
  <Style ss:ID="Data">
   <Alignment ss:Vertical="Center" ss:WrapText="1"/>
   <Borders>
    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#CCCCCC"/>
    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#CCCCCC"/>
    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#CCCCCC"/>
    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#CCCCCC"/>
   </Borders>
   <Font ss:Size="10"/>
  </Style>
  
  <!-- Estilo para celdas numéricas -->
  <Style ss:ID="Number">
   <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
   <Borders>
    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#CCCCCC"/>
    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#CCCCCC"/>
    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#CCCCCC"/>
    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#CCCCCC"/>
   </Borders>
   <Font ss:Size="10"/>
   <NumberFormat ss:Format="0"/>
  </Style>
  
  <!-- Estilo para estado Pendiente -->
  <Style ss:ID="Pendiente">
   <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
   <Borders>
    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#CCCCCC"/>
    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#CCCCCC"/>
    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#CCCCCC"/>
    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#CCCCCC"/>
   </Borders>
   <Font ss:Bold="1" ss:Color="#92400e" ss:Size="10"/>
   <Interior ss:Color="#fef3c7" ss:Pattern="Solid"/>
  </Style>
  
  <!-- Estilo para estado En Revisión -->
  <Style ss:ID="EnRevision">
   <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
   <Borders>
    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#CCCCCC"/>
    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#CCCCCC"/>
    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#CCCCCC"/>
    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#CCCCCC"/>
   </Borders>
   <Font ss:Bold="1" ss:Color="#1e40af" ss:Size="10"/>
   <Interior ss:Color="#dbeafe" ss:Pattern="Solid"/>
  </Style>
  
  <!-- Estilo para estado Aprobado -->
  <Style ss:ID="Aprobado">
   <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
   <Borders>
    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#CCCCCC"/>
    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#CCCCCC"/>
    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#CCCCCC"/>
    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#CCCCCC"/>
   </Borders>
   <Font ss:Bold="1" ss:Color="#065f46" ss:Size="10"/>
   <Interior ss:Color="#d1fae5" ss:Pattern="Solid"/>
  </Style>
  
  <!-- Estilo para estado Rechazado -->
  <Style ss:ID="Rechazado">
   <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
   <Borders>
    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#CCCCCC"/>
    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#CCCCCC"/>
    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#CCCCCC"/>
    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#CCCCCC"/>
   </Borders>
   <Font ss:Bold="1" ss:Color="#991b1b" ss:Size="10"/>
   <Interior ss:Color="#fee2e2" ss:Pattern="Solid"/>
  </Style>
  
  <!-- Estilo para estado Finalizado -->
  <Style ss:ID="Finalizado">
   <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
   <Borders>
    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#CCCCCC"/>
    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#CCCCCC"/>
    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#CCCCCC"/>
    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#CCCCCC"/>
   </Borders>
   <Font ss:Bold="1" ss:Color="#3730a3" ss:Size="10"/>
   <Interior ss:Color="#e0e7ff" ss:Pattern="Solid"/>
  </Style>
  
  <!-- Estilo para fechas -->
  <Style ss:ID="Date">
   <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
   <Borders>
    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#CCCCCC"/>
    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#CCCCCC"/>
    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#CCCCCC"/>
    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#CCCCCC"/>
   </Borders>
   <Font ss:Size="10"/>
  </Style>
 </Styles>
 
 <Worksheet ss:Name="Proyectos">
  <Table ss:DefaultColumnWidth="100" ss:DefaultRowHeight="20">
   <!-- Definir anchos de columnas -->
   <Column ss:Index="1" ss:Width="50"/>   <!-- ID -->
   <Column ss:Index="2" ss:Width="250"/>  <!-- Título -->
   <Column ss:Index="3" ss:Width="150"/>  <!-- Institución -->
   <Column ss:Index="4" ss:Width="150"/>  <!-- Convocatoria -->
   <Column ss:Index="5" ss:Width="100"/>  <!-- Estado -->
   <Column ss:Index="6" ss:Width="120"/>  <!-- Fecha -->
   <Column ss:Index="7" ss:Width="150"/>  <!-- Responsable -->
   <Column ss:Index="8" ss:Width="180"/>  <!-- Email -->
   <Column ss:Index="9" ss:Width="120"/>  <!-- Área -->
   <Column ss:Index="10" ss:Width="120"/> <!-- Sector -->
   <Column ss:Index="11" ss:Width="60"/>  <!-- TLR -->
   <Column ss:Index="12" ss:Width="60"/>  <!-- SLR -->
   
   <!-- Título del reporte -->
   <Row ss:Height="30">
    <Cell ss:MergeAcross="11" ss:StyleID="Title">
     <Data ss:Type="String">REPORTE DE PROYECTOS - COVEICYDET</Data>
    </Cell>
   </Row>
   
   <!-- Subtítulo con fecha de generación -->
   <Row ss:Height="20">
    <Cell ss:MergeAcross="11" ss:StyleID="Subtitle">
     <Data ss:Type="String">Generado el: <%= formatoFecha.format(new java.util.Date()) %> | Total de registros: <%= proyectosList.size() %></Data>
    </Cell>
   </Row>
   
   <!-- Fila vacía -->
   <Row ss:Height="10"/>
   
   <!-- Encabezados de columnas -->
   <Row ss:Height="35">
    <Cell ss:StyleID="Header"><Data ss:Type="String">ID</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">Título del Proyecto</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">Institución</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">Convocatoria</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">Estado</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">Fecha Creación</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">Responsable</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">Correo Electrónico</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">Área</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">Sector</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">TLR</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">SLR</Data></Cell>
   </Row>
   
   <% if (mensajeError != null) { %>
   <!-- Fila de error -->
   <Row>
    <Cell ss:MergeAcross="11" ss:StyleID="Data">
     <Data ss:Type="String">Error: <%= mensajeError %></Data>
    </Cell>
   </Row>
   <% } else if (proyectosList.isEmpty()) { %>
   <!-- Fila sin datos -->
   <Row>
    <Cell ss:MergeAcross="11" ss:StyleID="Data">
     <Data ss:Type="String">No hay proyectos registrados en el sistema.</Data>
    </Cell>
   </Row>
   <% } else { %>
   <!-- Datos de proyectos -->
   <%
   for (Map<String, Object> proyecto : proyectosList) {
       Integer id = (Integer) proyecto.get("id");
       String titulo = (String) proyecto.get("titulo");
       String institucion = (String) proyecto.get("institucion");
       String convocatoria = (String) proyecto.get("convocatoria");
       String estado = (String) proyecto.get("estado");
       Timestamp fecha = (Timestamp) proyecto.get("fecha");
       String responsable = (String) proyecto.get("responsable");
       String email = (String) proyecto.get("email");
       String area = (String) proyecto.get("area");
       String sector = (String) proyecto.get("sector");
       String tlr = (String) proyecto.get("tlr");
       String slr = (String) proyecto.get("slr");
       
       // Determinar estilo según estado
       String estiloEstado = "Data";
       if (estado != null) {
           if (estado.equals("Pendiente")) estiloEstado = "Pendiente";
           else if (estado.equals("En Revisión")) estiloEstado = "EnRevision";
           else if (estado.equals("Aprobado")) estiloEstado = "Aprobado";
           else if (estado.equals("Rechazado")) estiloEstado = "Rechazado";
           else if (estado.equals("Finalizado")) estiloEstado = "Finalizado";
       }
   %>
   <Row ss:Height="22">
    <Cell ss:StyleID="Number"><Data ss:Type="Number"><%= id != null ? id : 0 %></Data></Cell>
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= titulo != null ? titulo : "" %></Data></Cell>
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= institucion != null ? institucion : "No especificada" %></Data></Cell>
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= convocatoria != null ? convocatoria : "Sin convocatoria" %></Data></Cell>
    <Cell ss:StyleID="<%= estiloEstado %>"><Data ss:Type="String"><%= estado != null ? estado : "" %></Data></Cell>
    <Cell ss:StyleID="Date"><Data ss:Type="String"><%= fecha != null ? formatoFecha.format(fecha) : "" %></Data></Cell>
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= responsable != null ? responsable : "Sin asignar" %></Data></Cell>
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= email != null ? email : "" %></Data></Cell>
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= area != null ? area : "No especificada" %></Data></Cell>
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= sector != null ? sector : "No especificado" %></Data></Cell>
    <Cell ss:StyleID="Number"><Data ss:Type="String"><%= tlr != null ? tlr : "N/A" %></Data></Cell>
    <Cell ss:StyleID="Number"><Data ss:Type="String"><%= slr != null ? slr : "N/A" %></Data></Cell>
   </Row>
   <% } %>
   <% } %>
   
  </Table>
  
  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
   <PageSetup>
    <Layout x:Orientation="Landscape"/>
    <Header x:Data="&amp;C&amp;&quot;Arial,Bold&quot;&amp;14COVEICYDET - Proyectos"/>
    <Footer x:Data="&amp;CPage &amp;P of &amp;N"/>
   </PageSetup>
   <FitToPage/>
   <Print>
    <FitWidth>1</FitWidth>
    <FitHeight>0</FitHeight>
   </Print>
   <FreezePanes/>
   <FrozenNoSplit/>
   <SplitHorizontal>4</SplitHorizontal>
   <TopRowBottomPane>4</TopRowBottomPane>
   <ActivePane>2</ActivePane>
  </WorksheetOptions>
 </Worksheet>
 
 <!-- Segunda hoja: Resumen estadístico -->
 <Worksheet ss:Name="Resumen">
  <Table ss:DefaultColumnWidth="150" ss:DefaultRowHeight="20">
   <Column ss:Index="1" ss:Width="200"/>
   <Column ss:Index="2" ss:Width="100"/>
   
   <Row ss:Height="30">
    <Cell ss:MergeAcross="1" ss:StyleID="Title">
     <Data ss:Type="String">RESUMEN ESTADÍSTICO DE PROYECTOS</Data>
    </Cell>
   </Row>
   
   <Row ss:Height="10"/>
   
   <Row ss:Height="25">
    <Cell ss:StyleID="Header"><Data ss:Type="String">Concepto</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">Cantidad</Data></Cell>
   </Row>
   
   <Row ss:Height="22">
    <Cell ss:StyleID="Data"><Data ss:Type="String">Total de Proyectos</Data></Cell>
    <Cell ss:StyleID="Number"><Data ss:Type="Number"><%= proyectosList.size() %></Data></Cell>
   </Row>
   
   <Row ss:Height="10"/>
   
   <Row ss:Height="22">
    <Cell ss:StyleID="Data"><Data ss:Type="String">Proyectos Pendientes</Data></Cell>
    <Cell ss:StyleID="Pendiente"><Data ss:Type="Number"><%= totalPendientes %></Data></Cell>
   </Row>
   
   <Row ss:Height="22">
    <Cell ss:StyleID="Data"><Data ss:Type="String">Proyectos En Revisión</Data></Cell>
    <Cell ss:StyleID="EnRevision"><Data ss:Type="Number"><%= totalEnRevision %></Data></Cell>
   </Row>
   
   <Row ss:Height="22">
    <Cell ss:StyleID="Data"><Data ss:Type="String">Proyectos Aprobados</Data></Cell>
    <Cell ss:StyleID="Aprobado"><Data ss:Type="Number"><%= totalAprobados %></Data></Cell>
   </Row>
   
   <Row ss:Height="22">
    <Cell ss:StyleID="Data"><Data ss:Type="String">Proyectos Rechazados</Data></Cell>
    <Cell ss:StyleID="Rechazado"><Data ss:Type="Number"><%= totalRechazados %></Data></Cell>
   </Row>
   
   <Row ss:Height="22">
    <Cell ss:StyleID="Data"><Data ss:Type="String">Proyectos Finalizados</Data></Cell>
    <Cell ss:StyleID="Finalizado"><Data ss:Type="Number"><%= totalFinalizados %></Data></Cell>
   </Row>
   
   <Row ss:Height="10"/>
   
   <Row ss:Height="22">
    <Cell ss:StyleID="Subtitle"><Data ss:Type="String">Fecha de generación:</Data></Cell>
    <Cell ss:StyleID="Date"><Data ss:Type="String"><%= formatoFecha.format(new java.util.Date()) %></Data></Cell>
   </Row>
   
  </Table>
  
  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
   <PageSetup>
    <Layout x:Orientation="Portrait"/>
   </PageSetup>
  </WorksheetOptions>
 </Worksheet>
 
</Workbook>
