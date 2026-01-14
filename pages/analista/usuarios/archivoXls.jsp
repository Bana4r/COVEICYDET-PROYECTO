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
    String nombreArchivo = "usuarios_responsables_" + new SimpleDateFormat("yyyyMMdd_HHmmss").format(new java.util.Date()) + ".xls";
    response.setHeader("Content-Disposition", "attachment; filename=" + nombreArchivo);
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    // Lista para almacenar usuarios
    List<Map<String, Object>> usuariosResponsables = new ArrayList<>();
    String mensajeError = null;

    SimpleDateFormat formatoFecha = new SimpleDateFormat("dd/MM/yyyy HH:mm");

    if (conn != null) {
        try {
            String sql = "SELECT " +
                       "u.id_usuario, " +
                       "u.nombre, " +
                       "u.primer_apellido, " +
                       "u.segundo_apellido, " +
                       "u.RFC, " +
                       "u.correo_electronico, " +
                       "u.estado, " + 
                       "eu.estado as nombre_estado, " +
                       "t.tipo_usuario as rol, " +
                       
                       // Conteos de proyectos
                       "COUNT(p.id_proyecto) as total_proyectos, " +
                       "COUNT(CASE WHEN p.estado_proyecto = 'Borrador' THEN 1 END) as proyectos_borrador, " +
                       "COUNT(CASE WHEN p.estado_proyecto = 'Enviado' THEN 1 END) as proyectos_enviados, " +
                       "COUNT(CASE WHEN p.estado_proyecto = 'En Revisión' THEN 1 END) as proyectos_revision, " +
                       "COUNT(CASE WHEN p.estado_proyecto = 'Aprobado' THEN 1 END) as proyectos_aprobados, " +
                       "COUNT(CASE WHEN p.estado_proyecto = 'Rechazado' THEN 1 END) as proyectos_rechazados, " +
                       "COUNT(CASE WHEN p.estado_proyecto = 'Finalizado' THEN 1 END) as proyectos_finalizados, " +
                       "MAX(p.fecha_creacion) as ultima_actividad " +
                       
                       "FROM usuarios u " +
                       "JOIN tipo_usuario t ON u.tipousuario = t.id_tipo_usuario " + 
                       "LEFT JOIN estado_usuario eu ON u.estado = eu.id " +
                       "LEFT JOIN proyecto_usuarios pu ON u.id_usuario = pu.id_usuario " +
                       "LEFT JOIN Proyectos p ON pu.id_proyecto = p.id_proyecto " +
                       
                       "WHERE t.tipo_usuario = 'responsable' " +
                       
                       "GROUP BY u.id_usuario, u.nombre, u.primer_apellido, u.segundo_apellido, u.RFC, " +
                       "u.correo_electronico, u.estado, eu.estado, t.tipo_usuario " +
                       "ORDER BY u.nombre, u.primer_apellido";
                       
            try (PreparedStatement stmt = conn.prepareStatement(sql);
                 ResultSet rs = stmt.executeQuery()) {
                
                while (rs.next()) {
                    Map<String, Object> usuario = new HashMap<>();
                    usuario.put("id", rs.getInt("id_usuario"));
                    usuario.put("nombre", rs.getString("nombre"));
                    usuario.put("primerApellido", rs.getString("primer_apellido"));
                    usuario.put("segundoApellido", rs.getString("segundo_apellido"));
                    usuario.put("rfc", rs.getString("RFC"));
                    usuario.put("correo", rs.getString("correo_electronico"));
                    usuario.put("estadoId", rs.getInt("estado"));
                    usuario.put("estadoNombre", rs.getString("nombre_estado"));
                    usuario.put("rol", rs.getString("rol"));
                    
                    // Estadísticas de proyectos
                    usuario.put("totalProyectos", rs.getInt("total_proyectos"));
                    usuario.put("proyectosBorrador", rs.getInt("proyectos_borrador"));
                    usuario.put("proyectosEnviados", rs.getInt("proyectos_enviados"));
                    usuario.put("proyectosRevision", rs.getInt("proyectos_revision"));
                    usuario.put("proyectosAprobados", rs.getInt("proyectos_aprobados"));
                    usuario.put("proyectosRechazados", rs.getInt("proyectos_rechazados"));
                    usuario.put("proyectosFinalizados", rs.getInt("proyectos_finalizados"));
                    usuario.put("ultimaActividad", rs.getTimestamp("ultima_actividad"));
                    
                    usuariosResponsables.add(usuario);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error de base de datos en archivoXls.jsp: " + e.getMessage());
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
  <Title>Usuarios Responsables - COVEICYDET</Title>
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
  
  <!-- Estilo para estado activo -->
  <Style ss:ID="Activo">
   <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
   <Borders>
    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#CCCCCC"/>
    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#CCCCCC"/>
    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#CCCCCC"/>
    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#CCCCCC"/>
   </Borders>
   <Font ss:Bold="1" ss:Color="#166534" ss:Size="10"/>
   <Interior ss:Color="#DCFCE7" ss:Pattern="Solid"/>
  </Style>
  
  <!-- Estilo para estado inactivo -->
  <Style ss:ID="Inactivo">
   <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
   <Borders>
    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#CCCCCC"/>
    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#CCCCCC"/>
    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#CCCCCC"/>
    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#CCCCCC"/>
   </Borders>
   <Font ss:Bold="1" ss:Color="#991B1B" ss:Size="10"/>
   <Interior ss:Color="#FEE2E2" ss:Pattern="Solid"/>
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
 
 <Worksheet ss:Name="Usuarios Responsables">
  <Table ss:DefaultColumnWidth="100" ss:DefaultRowHeight="20">
   <!-- Definir anchos de columnas -->
   <Column ss:Index="1" ss:Width="50"/>   <!-- ID -->
   <Column ss:Index="2" ss:Width="120"/>  <!-- Nombre -->
   <Column ss:Index="3" ss:Width="100"/>  <!-- Primer Apellido -->
   <Column ss:Index="4" ss:Width="100"/>  <!-- Segundo Apellido -->
   <Column ss:Index="5" ss:Width="120"/>  <!-- RFC -->
   <Column ss:Index="6" ss:Width="200"/>  <!-- Correo -->
   <Column ss:Index="7" ss:Width="80"/>   <!-- Estado -->
   <Column ss:Index="8" ss:Width="100"/>  <!-- Rol -->
   <Column ss:Index="9" ss:Width="80"/>   <!-- Total Proyectos -->
   <Column ss:Index="10" ss:Width="80"/>  <!-- Borrador -->
   <Column ss:Index="11" ss:Width="80"/>  <!-- Enviados -->
   <Column ss:Index="12" ss:Width="85"/>  <!-- En Revisión -->
   <Column ss:Index="13" ss:Width="80"/>  <!-- Aprobados -->
   <Column ss:Index="14" ss:Width="80"/>  <!-- Rechazados -->
   <Column ss:Index="15" ss:Width="80"/>  <!-- Finalizados -->
   <Column ss:Index="16" ss:Width="140"/> <!-- Última Actividad -->
   
   <!-- Título del reporte -->
   <Row ss:Height="30">
    <Cell ss:MergeAcross="15" ss:StyleID="Title">
     <Data ss:Type="String">REPORTE DE USUARIOS RESPONSABLES - COVEICYDET</Data>
    </Cell>
   </Row>
   
   <!-- Subtítulo con fecha de generación -->
   <Row ss:Height="20">
    <Cell ss:MergeAcross="15" ss:StyleID="Subtitle">
     <Data ss:Type="String">Generado el: <%= formatoFecha.format(new java.util.Date()) %> | Total de registros: <%= usuariosResponsables.size() %></Data>
    </Cell>
   </Row>
   
   <!-- Fila vacía -->
   <Row ss:Height="10"/>
   
   <!-- Encabezados de columnas -->
   <Row ss:Height="35">
    <Cell ss:StyleID="Header"><Data ss:Type="String">ID</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">Nombre</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">Primer Apellido</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">Segundo Apellido</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">RFC</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">Correo Electrónico</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">Estado</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">Rol</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">Total Proyectos</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">Borrador</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">Enviados</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">En Revisión</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">Aprobados</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">Rechazados</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">Finalizados</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">Última Actividad</Data></Cell>
   </Row>
   
   <% if (mensajeError != null) { %>
   <!-- Fila de error -->
   <Row>
    <Cell ss:MergeAcross="15" ss:StyleID="Data">
     <Data ss:Type="String">Error: <%= mensajeError %></Data>
    </Cell>
   </Row>
   <% } else if (usuariosResponsables.isEmpty()) { %>
   <!-- Fila sin datos -->
   <Row>
    <Cell ss:MergeAcross="15" ss:StyleID="Data">
     <Data ss:Type="String">No hay usuarios responsables registrados en el sistema.</Data>
    </Cell>
   </Row>
   <% } else { %>
   <!-- Datos de usuarios -->
   <%
   for (Map<String, Object> usuario : usuariosResponsables) {
       Integer id = (Integer) usuario.get("id");
       String nombre = (String) usuario.get("nombre");
       String primerApellido = (String) usuario.get("primerApellido");
       String segundoApellido = (String) usuario.get("segundoApellido");
       String rfc = (String) usuario.get("rfc");
       String correo = (String) usuario.get("correo");
       Integer estadoId = (Integer) usuario.get("estadoId");
       String estadoNombre = (String) usuario.get("estadoNombre");
       String rol = (String) usuario.get("rol");
       Integer totalProyectosUsuario = (Integer) usuario.get("totalProyectos");
       Integer proyectosBorrador = (Integer) usuario.get("proyectosBorrador");
       Integer proyectosEnviados = (Integer) usuario.get("proyectosEnviados");
       Integer proyectosRevision = (Integer) usuario.get("proyectosRevision");
       Integer proyectosAprobados = (Integer) usuario.get("proyectosAprobados");
       Integer proyectosRechazados = (Integer) usuario.get("proyectosRechazados");
       Integer proyectosFinalizados = (Integer) usuario.get("proyectosFinalizados");
       Timestamp ultimaActividad = (Timestamp) usuario.get("ultimaActividad");
       
       boolean isActivo = estadoId != null && estadoId == 2;
       String estadoTexto = estadoNombre != null ? estadoNombre : (isActivo ? "Activo" : "Inactivo");
       String estiloEstado = isActivo ? "Activo" : "Inactivo";
   %>
   <Row ss:Height="22">
    <Cell ss:StyleID="Number"><Data ss:Type="Number"><%= id != null ? id : 0 %></Data></Cell>
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= nombre != null ? nombre : "" %></Data></Cell>
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= primerApellido != null ? primerApellido : "" %></Data></Cell>
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= segundoApellido != null ? segundoApellido : "" %></Data></Cell>
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= rfc != null ? rfc : "" %></Data></Cell>
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= correo != null ? correo : "" %></Data></Cell>
    <Cell ss:StyleID="<%= estiloEstado %>"><Data ss:Type="String"><%= estadoTexto %></Data></Cell>
    <Cell ss:StyleID="Data"><Data ss:Type="String"><%= rol != null ? rol : "" %></Data></Cell>
    <Cell ss:StyleID="Number"><Data ss:Type="Number"><%= totalProyectosUsuario != null ? totalProyectosUsuario : 0 %></Data></Cell>
    <Cell ss:StyleID="Number"><Data ss:Type="Number"><%= proyectosBorrador != null ? proyectosBorrador : 0 %></Data></Cell>
    <Cell ss:StyleID="Number"><Data ss:Type="Number"><%= proyectosEnviados != null ? proyectosEnviados : 0 %></Data></Cell>
    <Cell ss:StyleID="Number"><Data ss:Type="Number"><%= proyectosRevision != null ? proyectosRevision : 0 %></Data></Cell>
    <Cell ss:StyleID="Number"><Data ss:Type="Number"><%= proyectosAprobados != null ? proyectosAprobados : 0 %></Data></Cell>
    <Cell ss:StyleID="Number"><Data ss:Type="Number"><%= proyectosRechazados != null ? proyectosRechazados : 0 %></Data></Cell>
    <Cell ss:StyleID="Number"><Data ss:Type="Number"><%= proyectosFinalizados != null ? proyectosFinalizados : 0 %></Data></Cell>
    <Cell ss:StyleID="Date"><Data ss:Type="String"><%= ultimaActividad != null ? formatoFecha.format(ultimaActividad) : "Sin actividad" %></Data></Cell>
   </Row>
   <% } %>
   <% } %>
   
  </Table>
  
  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
   <PageSetup>
    <Layout x:Orientation="Landscape"/>
    <Header x:Data="&amp;C&amp;&quot;Arial,Bold&quot;&amp;14COVEICYDET - Usuarios Responsables"/>
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
     <Data ss:Type="String">RESUMEN ESTADÍSTICO</Data>
    </Cell>
   </Row>
   
   <Row ss:Height="10"/>
   
   <Row ss:Height="25">
    <Cell ss:StyleID="Header"><Data ss:Type="String">Concepto</Data></Cell>
    <Cell ss:StyleID="Header"><Data ss:Type="String">Cantidad</Data></Cell>
   </Row>
   
   <%
   int totalUsuariosResumen = usuariosResponsables.size();
   int totalProyectosResumen = 0;
   int totalBorradorResumen = 0;
   int totalEnviadosResumen = 0;
   int totalRevisionResumen = 0;
   int totalAprobadosResumen = 0;
   int totalRechazadosResumen = 0;
   int totalFinalizadosResumen = 0;
   int usuariosActivos = 0;
   int usuariosInactivos = 0;
   
   for (Map<String, Object> u : usuariosResponsables) {
       totalProyectosResumen += (Integer) u.get("totalProyectos");
       totalBorradorResumen += (Integer) u.get("proyectosBorrador");
       totalEnviadosResumen += (Integer) u.get("proyectosEnviados");
       totalRevisionResumen += (Integer) u.get("proyectosRevision");
       totalAprobadosResumen += (Integer) u.get("proyectosAprobados");
       totalRechazadosResumen += (Integer) u.get("proyectosRechazados");
       totalFinalizadosResumen += (Integer) u.get("proyectosFinalizados");
       
       Integer estado = (Integer) u.get("estadoId");
       if (estado != null && estado == 2) {
           usuariosActivos++;
       } else {
           usuariosInactivos++;
       }
   }
   %>
   
   <Row ss:Height="22">
    <Cell ss:StyleID="Data"><Data ss:Type="String">Total de Usuarios Responsables</Data></Cell>
    <Cell ss:StyleID="Number"><Data ss:Type="Number"><%= totalUsuariosResumen %></Data></Cell>
   </Row>
   
   <Row ss:Height="22">
    <Cell ss:StyleID="Data"><Data ss:Type="String">Usuarios Activos</Data></Cell>
    <Cell ss:StyleID="Activo"><Data ss:Type="Number"><%= usuariosActivos %></Data></Cell>
   </Row>
   
   <Row ss:Height="22">
    <Cell ss:StyleID="Data"><Data ss:Type="String">Usuarios Inactivos</Data></Cell>
    <Cell ss:StyleID="Inactivo"><Data ss:Type="Number"><%= usuariosInactivos %></Data></Cell>
   </Row>
   
   <Row ss:Height="10"/>
   
   <Row ss:Height="22">
    <Cell ss:StyleID="Data"><Data ss:Type="String">Total de Proyectos</Data></Cell>
    <Cell ss:StyleID="Number"><Data ss:Type="Number"><%= totalProyectosResumen %></Data></Cell>
   </Row>
   
   <Row ss:Height="22">
    <Cell ss:StyleID="Data"><Data ss:Type="String">Proyectos en Borrador</Data></Cell>
    <Cell ss:StyleID="Number"><Data ss:Type="Number"><%= totalBorradorResumen %></Data></Cell>
   </Row>
   
   <Row ss:Height="22">
    <Cell ss:StyleID="Data"><Data ss:Type="String">Proyectos Enviados</Data></Cell>
    <Cell ss:StyleID="Number"><Data ss:Type="Number"><%= totalEnviadosResumen %></Data></Cell>
   </Row>
   
   <Row ss:Height="22">
    <Cell ss:StyleID="Data"><Data ss:Type="String">Proyectos En Revisión</Data></Cell>
    <Cell ss:StyleID="Number"><Data ss:Type="Number"><%= totalRevisionResumen %></Data></Cell>
   </Row>
   
   <Row ss:Height="22">
    <Cell ss:StyleID="Data"><Data ss:Type="String">Proyectos Aprobados</Data></Cell>
    <Cell ss:StyleID="Number"><Data ss:Type="Number"><%= totalAprobadosResumen %></Data></Cell>
   </Row>
   
   <Row ss:Height="22">
    <Cell ss:StyleID="Data"><Data ss:Type="String">Proyectos Rechazados</Data></Cell>
    <Cell ss:StyleID="Number"><Data ss:Type="Number"><%= totalRechazadosResumen %></Data></Cell>
   </Row>
   
   <Row ss:Height="22">
    <Cell ss:StyleID="Data"><Data ss:Type="String">Proyectos Finalizados</Data></Cell>
    <Cell ss:StyleID="Number"><Data ss:Type="Number"><%= totalFinalizadosResumen %></Data></Cell>
   </Row>
   
   <Row ss:Height="10"/>
   
   <Row ss:Height="22">
    <Cell ss:StyleID="Subtitle"><Data ss:Type="String">Promedio de proyectos por usuario:</Data></Cell>
    <Cell ss:StyleID="Number"><Data ss:Type="Number"><%= totalUsuariosResumen > 0 ? String.format("%.2f", (double)totalProyectosResumen/totalUsuariosResumen) : "0" %></Data></Cell>
   </Row>
   
  </Table>
  
  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
   <PageSetup>
    <Layout x:Orientation="Portrait"/>
   </PageSetup>
  </WorksheetOptions>
 </Worksheet>
 
</Workbook>
