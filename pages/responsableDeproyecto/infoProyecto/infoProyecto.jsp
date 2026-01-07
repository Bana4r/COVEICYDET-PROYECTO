<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%-- 1. VALIDACIÓN DE SESIÓN (Conservado del original) --%>
<% if (!"responsable".equals(String.valueOf(session.getAttribute("rol")))) { 
    String n=request.getRequestURI()+(request.getQueryString()!=null?("?"+request.getQueryString()):"");
    response.sendRedirect(request.getContextPath()+"/pages/login/login.jsp?next="+java.net.URLEncoder.encode(n,"UTF-8")); 
    return; 
} %>

<%!
    // 2. CREDENCIALES DE ACCESO (Tomadas de infoProyectoBAK.jsp)
    private static final String DB_URL = "jdbc:postgresql://localhost:5432/proyectos";
    private static final String DB_USER = "dbusr25";
    private static final String DB_PASSWORD = "mxToro24000Chocolate";

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

    String mensajeError = null;
    
    if (proyectoId == null || proyectoId.trim().isEmpty()) {
        mensajeError = "ID de proyecto requerido";
    } else {
        try {
            Class.forName("org.postgresql.Driver");
            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
                
                // --- 1. CONSULTA PRINCIPAL (Basada en tabla 'Proyectos' y 'Convocatoria') ---
                String sqlP = "SELECT p.*, c.nombre_convocatoria " +
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
                        } else {
                            mensajeError = "El proyecto no existe en la base de datos.";
                        }
                    }
                }

                if (mensajeError == null) {
                    // --- 2. RESPONSABLES (Tabla: Proyecto_Responsables JOIN Responsables) ---
                    // El diagrama muestra que 'Responsables' tiene los datos personales y se une por id_responsables
                    String sqlResp = "SELECT r.nombre_completo, r.correo_electronico, r.telefono, pr.tipo_responsable " +
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
                                m.put("disciplina", rs.getString("disciplina")); // Nota: 'disiplina' en diagrama, corregir si en BD es 'disciplina'
                                m.put("rol", rs.getString("actividades_realizar"));
                                m.put("inst", rs.getString("institucion_adscripcion"));
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
                                organizaciones.add(m);
                            }
                        }
                    }

                    // --- 6. CRONOGRAMA (Tabla: Cronograma_Actividades JOIN actividades JOIN semestres) ---
                    // El diagrama conecta Cronograma con Actividades (detalle) y Semestres (tiempo)
                    String sqlCron = "SELECT s.descripcion_semestre, a.nombre_actividad, a.entregables " +
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
                                cronograma.add(m);
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            mensajeError = "Error de Sistema: " + e.getMessage();
        }
    }
%>

<!DOCTYPE html>
<html lang="es">
<%@ include file="../header.jsp" %>
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <script src="https://cdn.tailwindcss.com"></script>
  <title>Detalle del Proyecto</title>
  <style>
    .section-header { @apply text-xl font-bold text-gray-800 border-b-2 border-blue-100 pb-2 mb-4 mt-8; }
    .field-label { @apply text-xs font-bold text-gray-500 uppercase tracking-wider; }
    .field-value { @apply text-sm text-gray-900 font-medium mt-1; }
    .text-block { @apply bg-gray-50 p-4 rounded-md text-sm text-gray-700 whitespace-pre-line leading-relaxed border border-gray-100; }
  </style>
</head>
<body class="bg-gray-100">
<div class="max-w-7xl mx-auto p-6">

    <% if (mensajeError != null) { %>
        <div class="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 mb-6 rounded shadow" role="alert">
            <p class="font-bold">Error</p>
            <p><%= mensajeError %></p>
            <a href="proyectos.jsp" class="underline mt-2 block">Volver al listado</a>
        </div>
    <% } else if (proyecto.isEmpty()) { %>
        <div class="text-center py-10"><p class="text-gray-500">Cargando...</p></div>
    <% } else { %>

    <div class="bg-white shadow-lg rounded-lg overflow-hidden mb-6">
        <div class="bg-blue-600 p-6">
            <div class="flex justify-between items-start">
                <div class="text-white">
                    <span class="bg-blue-800 text-xs px-2 py-1 rounded mb-2 inline-block">ID: <%= proyecto.get("id") %></span>
                    <h1 class="text-2xl font-bold"><%= escapeXml((String)proyecto.get("titulo")) %></h1>
                    <p class="text-blue-100 mt-1"><%= escapeXml((String)proyecto.get("convocatoria")) %></p>
                </div>
                <div class="text-right text-blue-100 text-sm">
                    <p>Creado: <%= formatearFecha(proyecto.get("fecha")) %></p>
                </div>
            </div>
        </div>
        
        <div class="p-6 grid grid-cols-1 md:grid-cols-4 gap-6 bg-white">
            <div>
                <p class="field-label">Institución Proponente</p>
                <p class="field-value"><%= escapeXml((String)proyecto.get("institucion")) %></p>
            </div>
            <div>
                <p class="field-label">Área de Adscripción</p>
                <p class="field-value"><%= escapeXml((String)proyecto.get("area")) %></p>
            </div>
            <div>
                <p class="field-label">Municipio</p>
                <p class="field-value"><%= escapeXml((String)proyecto.get("municipio")) %></p>
            </div>
            <div>
                <p class="field-label">Sector de Impacto</p>
                <p class="field-value"><%= escapeXml((String)proyecto.get("sector")) %></p>
            </div>
        </div>
        
        <div class="px-6 pb-6 grid grid-cols-1 md:grid-cols-4 gap-6">
            <div>
                <p class="field-label">Nivel TRL</p>
                <span class="inline-block bg-gray-200 rounded px-2 py-1 text-xs font-bold text-gray-700 mt-1"><%= escapeXml((String)proyecto.get("tlr")) %></span>
            </div>
            <div>
                <p class="field-label">Nivel SLR</p>
                <span class="inline-block bg-gray-200 rounded px-2 py-1 text-xs font-bold text-gray-700 mt-1"><%= escapeXml((String)proyecto.get("slr")) %></span>
            </div>
            <div class="col-span-2">
                <p class="field-label">Área de Conocimiento</p>
                <p class="field-value"><%= escapeXml((String)proyecto.get("area_conocimiento")) %></p>
            </div>
        </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        
        <div class="lg:col-span-2 space-y-8">
            
            <div class="bg-white shadow rounded-lg p-6">
                <h2 class="section-header !mt-0">Descripción del Proyecto</h2>
                
                <div class="mb-6">
                    <p class="field-label mb-2">Resumen Ejecutivo</p>
                    <div class="text-block"><%= escapeXml((String)proyecto.get("resumen")) %></div>
                </div>
                
                <div class="mb-6">
                    <p class="field-label mb-2">Objetivo General</p>
                    <div class="text-block"><%= escapeXml((String)proyecto.get("obj_gral")) %></div>
                </div>
                
                <div>
                    <p class="field-label mb-2">Objetivos Específicos</p>
                    <div class="text-block"><%= escapeXml((String)proyecto.get("obj_esp")) %></div>
                </div>
            </div>

            <div class="bg-white shadow rounded-lg p-6">
                <h2 class="section-header !mt-0">Contexto y Metodología</h2>
                
                <details class="mb-4 group">
                    <summary class="font-semibold cursor-pointer bg-gray-50 p-3 rounded hover:bg-gray-100 flex justify-between">
                        Antecedentes y Pertinencia <span class="text-gray-400 text-xs">▼</span>
                    </summary>
                    <div class="p-4 border-t">
                        <p class="field-label mt-2">Antecedentes</p>
                        <p class="text-sm mb-4 text-gray-700"><%= escapeXml((String)proyecto.get("antecedentes")) %></p>
                        <p class="field-label">Pertinencia</p>
                        <p class="text-sm text-gray-700"><%= escapeXml((String)proyecto.get("pertinencia")) %></p>
                    </div>
                </details>

                <details class="mb-4 group">
                    <summary class="font-semibold cursor-pointer bg-gray-50 p-3 rounded hover:bg-gray-100 flex justify-between">
                        Metodología y Riesgos <span class="text-gray-400 text-xs">▼</span>
                    </summary>
                    <div class="p-4 border-t">
                        <p class="field-label mt-2">Preguntas de Investigación</p>
                        <p class="text-sm mb-4 text-gray-700"><%= escapeXml((String)proyecto.get("preguntas")) %></p>
                        <p class="field-label">Resumen Metodológico</p>
                        <div class="text-block mb-4"><%= escapeXml((String)proyecto.get("metodologia")) %></div>
                        <p class="field-label text-red-500">Factores de Riesgo y Mitigación</p>
                        <p class="text-sm text-gray-700"><%= escapeXml((String)proyecto.get("riesgos")) %></p>
                    </div>
                </details>
                
                 <div class="mt-4">
                    <p class="field-label mb-2">Resultados Esperados</p>
                    <div class="text-block bg-blue-50 border-blue-100"><%= escapeXml((String)proyecto.get("resultados")) %></div>
                </div>
            </div>

            <div class="bg-white shadow rounded-lg p-6">
                <h2 class="section-header !mt-0">Impactos</h2>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div class="p-3 border rounded hover:bg-gray-50">
                        <p class="text-blue-600 font-bold text-xs uppercase mb-1">Social</p>
                        <p class="text-sm text-gray-800"><%= escapeXml((String)proyecto.get("imp_social")) %></p>
                    </div>
                    <div class="p-3 border rounded hover:bg-gray-50">
                        <p class="text-green-600 font-bold text-xs uppercase mb-1">Ambiental</p>
                        <p class="text-sm text-gray-800"><%= escapeXml((String)proyecto.get("imp_amb")) %></p>
                    </div>
                    <div class="p-3 border rounded hover:bg-gray-50">
                        <p class="text-yellow-600 font-bold text-xs uppercase mb-1">Económico</p>
                        <p class="text-sm text-gray-800"><%= escapeXml((String)proyecto.get("imp_eco")) %></p>
                    </div>
                    <div class="p-3 border rounded hover:bg-gray-50">
                        <p class="text-purple-600 font-bold text-xs uppercase mb-1">Científico / Tecnológico</p>
                        <p class="text-sm text-gray-800"><%= escapeXml((String)proyecto.get("imp_cient")) %></p>
                    </div>
                </div>
            </div>
            
             <div class="bg-white shadow rounded-lg p-6">
                <h2 class="section-header !mt-0">Cronograma</h2>
                <% if(cronograma.isEmpty()) { %>
                    <p class="text-sm text-gray-500 italic">No hay actividades registradas.</p>
                <% } else { %>
                    <div class="overflow-x-auto">
                        <table class="min-w-full text-sm text-left">
                            <thead class="bg-gray-100 text-gray-600 font-bold uppercase text-xs">
                                <tr>
                                    <th class="px-4 py-2">Periodo</th>
                                    <th class="px-4 py-2">Actividad</th>
                                    <th class="px-4 py-2">Entregable</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-gray-200">
                                <% for(Map<String,Object> c : cronograma) { %>
                                <tr>
                                    <td class="px-4 py-2 font-medium"><%= escapeXml((String)c.get("semestre")) %></td>
                                    <td class="px-4 py-2"><%= escapeXml((String)c.get("actividad")) %></td>
                                    <td class="px-4 py-2 text-gray-500"><%= escapeXml((String)c.get("entregable")) %></td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                <% } %>
            </div>

        </div>

        <div class="space-y-6">
            
            <div class="bg-white shadow rounded-lg p-5">
                <h3 class="font-bold text-gray-800 border-b pb-2 mb-3">Responsables</h3>
                <% for(Map<String,Object> r : responsables) { %>
                    <div class="mb-3 last:mb-0">
                        <p class="text-xs font-bold text-blue-600 uppercase"><%= escapeXml((String)r.get("rol")) %></p>
                        <p class="font-medium text-sm"><%= escapeXml((String)r.get("nombre")) %></p>
                        <p class="text-xs text-gray-500"><%= escapeXml((String)r.get("email")) %></p>
                    </div>
                <% } %>
            </div>

            <div class="bg-white shadow rounded-lg p-5">
                <h3 class="font-bold text-gray-800 border-b pb-2 mb-3">Estudiantes</h3>
                <% if(estudiantes.isEmpty()){ %><p class="text-xs text-gray-500">Sin registros.</p><% } %>
                <% for(Map<String,Object> e : estudiantes) { %>
                    <div class="mb-3 bg-blue-50 p-2 rounded">
                        <p class="font-bold text-sm"><%= escapeXml((String)e.get("nombre")) %></p>
                        <p class="text-xs text-gray-600"><%= escapeXml((String)e.get("inst")) %></p>
                        <p class="text-xs text-blue-600 mt-1"><%= escapeXml((String)e.get("nivel")) %> - <%= escapeXml((String)e.get("programa")) %></p>
                    </div>
                <% } %>
            </div>

            <div class="bg-white shadow rounded-lg p-5">
                <h3 class="font-bold text-gray-800 border-b pb-2 mb-3">Investigadores / Colaboradores</h3>
                <% if(grupoTrabajo.isEmpty()){ %><p class="text-xs text-gray-500">Sin registros.</p><% } %>
                <% for(Map<String,Object> g : grupoTrabajo) { %>
                    <div class="mb-3 border-b last:border-0 pb-2">
                        <p class="font-medium text-sm"><%= escapeXml((String)g.get("nombre")) %></p>
                        <p class="text-xs text-gray-500"><%= escapeXml((String)g.get("grado")) %> - <%= escapeXml((String)g.get("disciplina")) %></p>
                        <p class="text-xs italic text-gray-400 mt-1"><%= escapeXml((String)g.get("rol")) %></p>
                    </div>
                <% } %>
            </div>

            <div class="bg-white shadow rounded-lg p-5">
                <h3 class="font-bold text-gray-800 border-b pb-2 mb-3">Alianzas</h3>
                <% if(organizaciones.isEmpty()){ %><p class="text-xs text-gray-500">Sin registros.</p><% } %>
                <% for(Map<String,Object> o : organizaciones) { %>
                    <div class="mb-3 bg-yellow-50 p-2 rounded border border-yellow-100">
                        <p class="font-bold text-sm text-gray-800"><%= escapeXml((String)o.get("nombre")) %></p>
                        <p class="text-xs text-gray-600">Contacto: <%= escapeXml((String)o.get("resp")) %></p>
                        <p class="text-xs mt-1 text-gray-500"><%= escapeXml((String)o.get("actividad")) %></p>
                    </div>
                <% } %>
            </div>
            
            <div class="pt-4">
                <a href="/proyectos/pages/responsableDeproyecto/proyectos/proyectos.jsp" class="block w-full py-2 px-4 bg-gray-200 hover:bg-gray-300 text-center rounded text-gray-700 font-bold text-sm transition">
                    ← Volver al listado
                </a>
            </div>

        </div>
    </div>

    <% } %>

</div>
</body>
<%@ include file="/footer.jsp" %>
</html>