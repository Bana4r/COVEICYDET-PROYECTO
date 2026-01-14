<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page errorPage="" %>

<%-- SEGURIDAD --%>
<% 
if (session.getAttribute("rol") == null || !"analista".equals(String.valueOf(session.getAttribute("rol")))) { 
    response.sendRedirect(request.getContextPath()+"/pages/login/login.jsp"); 
    return; 
} 
%>

<%!
    // --- UTILIDADES ---
    public String escapeXml(Object input) {
        if (input == null) return "";
        return String.valueOf(input).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
    
    public String marcar(Object valorBD, String valorFila) {
        if (valorBD != null && String.valueOf(valorBD).trim().equalsIgnoreCase(valorFila.trim())) {
            return "X";
        }
        return "";
    }
%>

<%
    String proyectoId = request.getParameter("id");
    
    // Variables para datos
    Map<String, Object> proyecto = new HashMap<>();
    Map<String, String> respLegal = new HashMap<>();
    Map<String, String> respTecnico = new HashMap<>();
    Map<String, String> respAdmin = new HashMap<>();
    List<Map<String, Object>> cronograma = new ArrayList<>();
    List<Map<String, Object>> presupuesto = new ArrayList<>();
    // --- NUEVA LISTA PARA CONVOCATORIAS ---
    List<String> listaConvocatorias = new ArrayList<>(); 
    
    String mensajeError = null;
    String errorTecnico = "";

    if (proyectoId == null || proyectoId.trim().isEmpty()) {
        mensajeError = "No se recibió el ID del proyecto.";
    } else {
        // Incluir conexión centralizada
        %>
        <%@ include file="/WEB-INF/conexion.jsp" %>
        <%
        try {
            if (conn == null || dbError.length() > 0) {
                throw new Exception("Error de conexión: " + dbError);
            }
            
            // 1. DATOS GENERALES
            String sqlP = "SELECT p.*, c.nombre_convocatoria FROM Proyectos p " +
                          "LEFT JOIN Convocatoria c ON p.convocatoria_id = c.id_convocatoria " +
                          "WHERE p.id_proyecto = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sqlP)) {
                stmt.setInt(1, Integer.parseInt(proyectoId));
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        proyecto.put("titulo", rs.getString("titulo"));
                        proyecto.put("institucion", rs.getString("institucion_proponente"));
                        proyecto.put("area_adscripcion", rs.getString("area_adscripcion"));
                        proyecto.put("convocatoria", rs.getString("nombre_convocatoria"));
                        proyecto.put("area_conocimiento", rs.getString("area_conocimiento"));
                        proyecto.put("sector", rs.getString("sector_impacto_proyecto"));
                        proyecto.put("tlr", rs.getString("nivel_tlr"));
                        proyecto.put("slr", rs.getString("nivel_slr"));
                        proyecto.put("resumen", rs.getString("resumen_ejecutivo"));
                        proyecto.put("antecedentes", rs.getString("antecedentes"));
                        proyecto.put("pertinencia", rs.getString("pertinencia"));
                        proyecto.put("municipio", rs.getString("Municipio"));
                        proyecto.put("preguntas", rs.getString("preguntas_investigacion"));
                        proyecto.put("obj_gral", rs.getString("objetivos_general"));
                        proyecto.put("obj_esp", rs.getString("objetivos_especificos"));
                        proyecto.put("metodologia", rs.getString("resumen_metodologia"));
                        proyecto.put("riesgos", rs.getString("factores_riesgo_mitigacion"));
                        proyecto.put("resultados", rs.getString("resultados_esperados"));
                        proyecto.put("imp_social", rs.getString("impacto_social"));
                        proyecto.put("imp_amb", rs.getString("impacto_ambiental"));
                        proyecto.put("imp_eco", rs.getString("impacto_economico"));
                        proyecto.put("imp_cient", rs.getString("impacto_cientificoTecnologico"));
                    } else {
                        mensajeError = "Proyecto con ID " + proyectoId + " no encontrado.";
                    }
                }
            }

            if (mensajeError == null) {
                // 2. RESPONSABLES (Corregido según Diagrama ER: 'email' en vez de 'correo_electronico')
                String sqlResp = "SELECT r.nombre_completo, r.correo_electronico, r.telefono, pr.tipo_responsable " +
                                 "FROM responsable r " +
                                 "JOIN proyecto_responsables pr ON r.id_responsable = pr.id_responsable " +
                                 "WHERE pr.id_proyecto = ?";
                try(PreparedStatement stmt = conn.prepareStatement(sqlResp)){
                    stmt.setInt(1, Integer.parseInt(proyectoId));
                    try(ResultSet rs = stmt.executeQuery()){
                        while(rs.next()){
                            String tipo = rs.getString("tipo_responsable"); // Ej: "Legal", "Técnico"
                            String nombre = rs.getString("nombre_completo");
                            String mail = rs.getString("correo_electronico"); // Nombre corregido según diagrama
                            String tel = rs.getString("telefono");
                            
                            if(tipo != null) {
                                String tipoL = tipo.toLowerCase();
                                if(tipoL.contains("legal")) {
                                    respLegal.put("nombre", nombre); respLegal.put("mail", mail); respLegal.put("tel", tel);
                                } else if (tipoL.contains("tecnico") || tipoL.contains("técnico")) {
                                    respTecnico.put("nombre", nombre); respTecnico.put("mail", mail); respTecnico.put("tel", tel);
                                } else if (tipoL.contains("admin")) {
                                    respAdmin.put("nombre", nombre); respAdmin.put("mail", mail); respAdmin.put("tel", tel);
                                }
                            }
                        }
                    }
                }

                // 3. CRONOGRAMA - Agrupado por semestre
                String sqlCron = "SELECT s.id_semestre, s.descripcion_semestre, s.meta_semestre, a.nombre_actividad, a.entregables " +
                                 "FROM Cronograma_Actividades ca " +
                                 "JOIN actividades a ON ca.id_actividad = a.id_actividad " +
                                 "JOIN semestres s ON ca.id_semestre = s.id_semestre " +
                                 "WHERE ca.id_proyecto = ? ORDER BY s.id_semestre, a.id_actividad";
                try(PreparedStatement stmt = conn.prepareStatement(sqlCron)){
                    stmt.setInt(1, Integer.parseInt(proyectoId));
                    try(ResultSet rs = stmt.executeQuery()){
                        while(rs.next()){
                            Map<String,Object> m = new HashMap<>();
                            m.put("id_semestre", rs.getInt("id_semestre"));
                            m.put("semestre", rs.getString("descripcion_semestre"));
                            m.put("meta", rs.getString("meta_semestre"));
                            m.put("actividad", rs.getString("nombre_actividad"));
                            m.put("entregables", rs.getString("entregables"));
                            cronograma.add(m);
                        }
                    }
                }
                
                // 4. PRESUPUESTO - Agrupado por partida con montos por semestre
                try {
                    String sqlPres = "SELECT p.id_partidas, p.nombre, p.justificacion, s.id_semestre, s.descripcion_semestre, sp.monto " +
                                     "FROM semestres_proyecto sp " +
                                     "JOIN partidas p ON sp.id_partidas = p.id_partidas " +
                                     "JOIN semestres s ON sp.id_semestre = s.id_semestre " +
                                     "WHERE sp.id_proyecto = ? " +
                                     "ORDER BY p.id_partidas, s.id_semestre";
                    try(PreparedStatement stmt = conn.prepareStatement(sqlPres)){
                        stmt.setInt(1, Integer.parseInt(proyectoId));
                        try(ResultSet rs = stmt.executeQuery()){
                            while(rs.next()){
                                Map<String,Object> m = new HashMap<>();
                                m.put("id_partida", rs.getInt("id_partidas"));
                                m.put("partida", rs.getString("nombre"));
                                m.put("justificacion", rs.getString("justificacion"));
                                m.put("id_semestre", rs.getInt("id_semestre"));
                                m.put("semestre", rs.getString("descripcion_semestre"));
                                m.put("monto", rs.getDouble("monto"));
                                presupuesto.add(m);
                            }
                        }
                    }
                } catch(Exception ePres) {
                    // Si falla presupuesto, no rompemos todo, solo lo logueamos
                    System.out.println("Error presupuesto: " + ePres.getMessage());
                    ePres.printStackTrace();
                }
                // --- AGREGAR ESTO DESPUÉS DE LA CONSULTA DE PRESUPUESTO ---
                // 5. OBTENER TODAS LAS CONVOCATORIAS PARA EL LISTADO
                if (mensajeError == null) {
                    String sqlTodasConv = "SELECT nombre_convocatoria FROM Convocatoria ORDER BY id_convocatoria ASC";
                    try(PreparedStatement stmt = conn.prepareStatement(sqlTodasConv);
                        ResultSet rs = stmt.executeQuery()){
                        while(rs.next()){
                            listaConvocatorias.add(rs.getString("nombre_convocatoria"));
                        }
                    }
                }
            }
            
        } catch (Exception e) {
            mensajeError = "Error en el sistema (Base de Datos)";
            // Capturamos el error completo para mostrarlo en pantalla
            java.io.StringWriter sw = new java.io.StringWriter();
            e.printStackTrace(new java.io.PrintWriter(sw));
            errorTecnico = sw.toString();
        } finally {
            if(conn != null) try { conn.close(); } catch(Exception e) {}
        }
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Formato Proyecto</title>
    <style>
        body { background-color: #eee; font-family: 'Arial', sans-serif; font-size: 11pt; color: #000; margin: 0; padding: 20px; }
        .page { background: white; width: 210mm; min-height: 297mm; padding: 20mm; margin: 0 auto; box-shadow: 0 0 15px rgba(0,0,0,0.2); box-sizing: border-box; }
        
        /* Tablas estilo Word */
        table { width: 100%; border-collapse: collapse; margin-bottom: 10px; page-break-inside: avoid; }
        th, td { border: 1px solid black; padding: 4px 8px; vertical-align: middle; font-size: 10pt; }
        
        .header-title { font-weight: bold; margin-top: 15px; margin-bottom: 5px; font-size: 11pt; text-transform: uppercase; }
        .section-content { margin-bottom: 10px; text-align: justify; font-size: 10pt; white-space: pre-wrap; }
        .section-box { border: 1px solid black; padding: 5px; min-height: 20px; }
        
        .center-text { text-align: center; }
        .bold { font-weight: bold; }
        .right-text { text-align: right; }
        
        /* Botonera superior */
        .toolbar { text-align: center; padding: 10px; margin-bottom: 20px; background: #333; color: white; position: sticky; top: 0; z-index: 100; border-radius: 5px; }
        .btn { background: #3b82f6; color: white; border: none; padding: 8px 15px; cursor: pointer; border-radius: 3px; font-weight: bold; text-decoration: none; font-size: 14px; }
        .btn:hover { background: #2563eb; }

        @media print {
            body { background: none; padding: 0; margin: 0; }
            .toolbar { display: none; }
            .page { width: 100%; margin: 0; padding: 0; box-shadow: none; }
            .page-break { page-break-before: always; }
        }
    </style>
</head>
<body>

    <% if (mensajeError != null) { %>
        <div style="background: white; padding: 20px; max-width: 800px; margin: 20px auto; border-left: 5px solid red;">
            <h2 style="color: red; margin-top: 0;">⚠️ Error al generar documento</h2>
            <p><strong>Mensaje:</strong> <%= mensajeError %></p>
            <% if (errorTecnico.length() > 0) { %>
                <details>
                    <summary style="cursor: pointer; color: blue;">Ver detalle técnico (para el programador)</summary>
                    <pre style="background: #f0f0f0; padding: 10px; overflow: auto; font-size: 10px;"><%= errorTecnico %></pre>
                </details>
            <% } %>
            <br>
            <a href="javascript:history.back()" class="btn" style="background: #666;">Regresar</a>
        </div>
    <% } else { %>

    <div class="toolbar">
        <button onclick="window.print()" class="btn">🖨️ Imprimir / Guardar PDF</button>
        <span style="margin: 0 10px;">|</span>
        <a href="infoProyecto.jsp?id=<%= proyectoId %>" class="btn" style="background: #666;">Volver al Proyecto</a>
    </div>

    <div class="page">
        
        <div style="text-align: center; font-weight: bold; font-size: 14pt; margin-bottom: 20px;">
            <%= escapeXml(proyecto.get("titulo")) %>
        </div>

        <div class="header-title">I) Institución proponente</div>
        <div class="section-content section-box"><%= escapeXml(proyecto.get("institucion")) %></div>

        <div class="header-title">II) Área de adscripción</div>
        <div class="section-content section-box"><%= escapeXml(proyecto.get("area_adscripcion")) %></div>

        <div class="header-title">III) Datos de las personas responsables de la propuesta:</div>
        <table>
            <tr>
                <td rowspan="3" class="bold" style="width: 20%; background-color: #f9f9f9;">Legal</td>
                <td style="width: 20%;">Nombre</td>
                <td><%= escapeXml(respLegal.get("nombre")) %></td>
            </tr>
            <tr><td>Correo electrónico</td><td><%= escapeXml(respLegal.get("mail")) %></td></tr>
            <tr><td>Número telefónico</td><td><%= escapeXml(respLegal.get("tel")) %></td></tr>
            
            <tr>
                <td rowspan="3" class="bold" style="background-color: #f9f9f9;">Técnico</td>
                <td>Nombre</td>
                <td><%= escapeXml(respTecnico.get("nombre")) %></td>
            </tr>
            <tr><td>Correo electrónico</td><td><%= escapeXml(respTecnico.get("mail")) %></td></tr>
            <tr><td>Número telefónico</td><td><%= escapeXml(respTecnico.get("tel")) %></td></tr>

            <tr>
                <td rowspan="3" class="bold" style="background-color: #f9f9f9;">Administrativo</td>
                <td>Nombre</td>
                <td><%= escapeXml(respAdmin.get("nombre")) %></td>
            </tr>
            <tr><td>Correo electrónico</td><td><%= escapeXml(respAdmin.get("mail")) %></td></tr>
            <tr><td>Número telefónico</td><td><%= escapeXml(respAdmin.get("tel")) %></td></tr>
        </table>

        <div class="header-title">IV) Convocatoria</div>
        <table>
            <tr class="bold">
                <td>Convocatoria</td>
                <td style="width: 120px; text-align: center;"> </td>
            </tr>
            <% 
            // Si no hay convocatorias en la BD, mostramos un mensaje vacío o filas vacías
            if(listaConvocatorias.isEmpty()) { %>
                <tr><td colspan="2">No hay convocatorias registradas en el sistema.</td></tr>
            <% } else { 
                // Recorremos todas las convocatorias existentes
                for (String nombreConv : listaConvocatorias) { 
            %>
            <tr>
                <td><%= escapeXml(nombreConv) %></td>
                <td class="center-text" style="width: 50px;">
                    <%= marcar(proyecto.get("convocatoria"), nombreConv) %>
                </td>
            </tr>
            <%  } 
               } %>
        </table>

        <div class="header-title">V) Área de conocimiento</div>
        <% String area = (String)proyecto.get("area_conocimiento"); %>
        <table style="font-size: 9pt;">
            <tr><td>I - Físico-Matemáticas y Ciencias de la Tierra</td><td class="center-text" style="width: 30px;"><%= marcar(area, "fisicoMatematicas") %></td></tr>
            <tr><td>II - Biología y Química</td><td class="center-text"><%= marcar(area, "biologiaQuimica") %></td></tr>
            <tr><td>III - Medicina y Ciencias de la Salud</td><td class="center-text"><%= marcar(area, "medicinaCienciasSalud") %></td></tr>
            <tr><td>IV - Ciencias de la Conducta y la Educación</td><td class="center-text"><%= marcar(area, "cienciasConductaEducacion") %></td></tr>
            <tr><td>V - Humanidades</td><td class="center-text"><%= marcar(area, "humanidades") %></td></tr>
            <tr><td>VI - Ciencias Sociales</td><td class="center-text"><%= marcar(area, "cienciasSociales") %></td></tr>
            <tr><td>VII - Ciencias de Agricultura, Agropecuarias, Forestales y de Ecosistemas</td><td class="center-text"><%= marcar(area, "cienciasAgricultura") %></td></tr>
            <tr><td>VIII - Ingenierías y Desarrollo Tecnológico</td><td class="center-text"><%= marcar(area, "ingenieriasDesarrollo") %></td></tr>
            <tr><td>IX - Interdisciplinaria</td><td class="center-text"><%= marcar(area, "interdisciplinaria") %></td></tr>
        </table>
        
        <div class="header-title">VI) Sector de desarrollo:</div>
        <div class="section-content section-box"><%= escapeXml(proyecto.get("sector")) %></div>

        <div class="page-break"></div>

        <div class="header-title">VII) Nivel de maduración (TRL / SRL):</div>
        <% String tlr = (String)proyecto.get("tlr"); %>
        <table style="font-size: 9pt;">
            <tr class="bold"><td style="width: 90%">Niveles de Maduración Tecnológica</td><td>TRL</td></tr>
            <tr><td>TRL 1: Principios básicos observados.</td><td class="center-text"><%= marcar(tlr, "TRL1") %></td></tr>
            <tr><td>TRL 2: Concepto y aplicación formulada.</td><td class="center-text"><%= marcar(tlr, "TRL2") %></td></tr>
            <tr><td>TRL 3: Prueba de concepto.</td><td class="center-text"><%= marcar(tlr, "TRL3") %></td></tr>
            <tr><td>TRL 4: Validación laboratorio.</td><td class="center-text"><%= marcar(tlr, "TRL4") %></td></tr>
            <tr><td>TRL 5: Validación entorno relevante.</td><td class="center-text"><%= marcar(tlr, "TRL5") %></td></tr>
            <tr><td>TRL 6: Demostración tecnológica.</td><td class="center-text"><%= marcar(tlr, "TRL6") %></td></tr>
            <tr><td>TRL 7 - 9: Prototipos y Productos finales.</td><td class="center-text"><%= (marcar(tlr, "TRL7").equals("X") || marcar(tlr, "TRL8").equals("X") || marcar(tlr, "TRL9").equals("X")) ? "X" : "" %></td></tr>
        </table>
        
        <% String slr = (String)proyecto.get("slr"); %>
        <table style="font-size: 9pt;">
            <tr class="bold"><td style="width: 90%">SRL: Niveles de Maduración Social</td><td>SRL</td></tr>
            <tr><td>SRL 1: Identificación del problema.</td><td class="center-text"><%= marcar(slr, "SRL1") %></td></tr>
            <tr><td>SRL 2: Formulación de soluciones.</td><td class="center-text"><%= marcar(slr, "SRL2") %></td></tr>
            <tr><td>SRL 3: Pruebas en campo iniciales.</td><td class="center-text"><%= marcar(slr, "SRL3") %></td></tr>
            <tr><td>SRL 4: Solución probada en contexto real.</td><td class="center-text"><%= marcar(slr, "SRL4") %></td></tr>
            <tr><td>SRL 5: Solución validada por usuarios.</td><td class="center-text"><%= marcar(slr, "SRL5") %></td></tr>
            <tr><td>SRL 6: Solución adoptada parcialmente.</td><td class="center-text"><%= marcar(slr, "SRL6") %></td></tr>
            <tr><td>SRL 7: Solución adoptada completamente.</td><td class="center-text"><%= marcar(slr, "SRL7") %></td></tr>
        </table>

        <div class="header-title">VIII) Resumen ejecutivo:</div>
        <div class="section-content"><%= escapeXml(proyecto.get("resumen")) %></div>

        <div class="header-title">IX) Antecedentes:</div>
        <div class="section-content"><%= escapeXml(proyecto.get("antecedentes")) %></div>

        <div class="header-title">X) Pertinencia:</div>
        <div class="section-content"><%= escapeXml(proyecto.get("pertinencia")) %></div>

        <div class="header-title">XI) Área de desarrollo (Municipio):</div>
        <div class="section-content"><%= escapeXml(proyecto.get("municipio")) %></div>

        <div class="header-title">XII) Preguntas de investigación:</div>
        <div class="section-content"><%= escapeXml(proyecto.get("preguntas")) %></div>

        <div class="header-title">XIII) Objetivo general:</div>
        <div class="section-content"><%= escapeXml(proyecto.get("obj_gral")) %></div>
        
        <div class="header-title">XIV) Objetivos específicos:</div>
        <div class="section-content"><%= escapeXml(proyecto.get("obj_esp")) %></div>

        <div class="header-title">XV) Meta:</div>
        <div class="section-content"><%= escapeXml(proyecto.get("resultados")) %></div>

        <div class="page-break"></div>

        <div class="header-title">XVI) Metodología:</div>
        <div class="section-content"><%= escapeXml(proyecto.get("metodologia")) %></div>

        <div class="header-title">XVII) Cronograma de actividades:</div>
        <% if(cronograma.isEmpty()) { %>
            <p class="center-text">No hay actividades registradas.</p>
        <% } else { 
            // Agrupar actividades por semestre
            Map<Integer, List<Map<String,Object>>> actividadesPorSemestre = new LinkedHashMap<>();
            Map<Integer, String> descripcionesSemestre = new LinkedHashMap<>();
            Map<Integer, String> metasSemestre = new LinkedHashMap<>();
            
            for(Map<String,Object> c : cronograma) {
                Integer idSem = (Integer)c.get("id_semestre");
                if(!actividadesPorSemestre.containsKey(idSem)) {
                    actividadesPorSemestre.put(idSem, new ArrayList<>());
                    descripcionesSemestre.put(idSem, (String)c.get("semestre"));
                    metasSemestre.put(idSem, (String)c.get("meta"));
                }
                actividadesPorSemestre.get(idSem).add(c);
            }
            
            int numSemestre = 1;
            for(Map.Entry<Integer, List<Map<String,Object>>> entry : actividadesPorSemestre.entrySet()) {
                Integer idSem = entry.getKey();
                List<Map<String,Object>> actividades = entry.getValue();
        %>
        <table style="margin-bottom: 15px;">
            <tr class="bold" style="background-color: #e0e0e0;">
                <th colspan="2">SEMESTRE <%= numSemestre %>: <%= escapeXml(descripcionesSemestre.get(idSem)) %></th>
            </tr>
            <tr>
                <td class="bold" style="width: 20%;">Meta del Semestre:</td>
                <td><%= escapeXml(metasSemestre.get(idSem)) %></td>
            </tr>
            <tr class="bold" style="background-color: #f5f5f5;">
                <td>Actividad</td>
                <td>Entregables</td>
            </tr>
            <% for(Map<String,Object> act : actividades) { %>
            <tr>
                <td><%= escapeXml(act.get("actividad")) %></td>
                <td><%= escapeXml(act.get("entregables")) %></td>
            </tr>
            <% } %>
        </table>
        <%
                numSemestre++;
            }
        } %>

        <div class="header-title">XVIII) Riesgos y estrategias:</div>
        <div class="section-content"><%= escapeXml(proyecto.get("riesgos")) %></div>
        
        <div class="header-title">XXI/XXII) Impactos Esperados:</div>
        <table>
            <tr><td class="bold" style="width: 30%;">Social</td><td><%= escapeXml(proyecto.get("imp_social")) %></td></tr>
            <tr><td class="bold">Ambiental</td><td><%= escapeXml(proyecto.get("imp_amb")) %></td></tr>
            <tr><td class="bold">Económico</td><td><%= escapeXml(proyecto.get("imp_eco")) %></td></tr>
            <tr><td class="bold">Científico</td><td><%= escapeXml(proyecto.get("imp_cient")) %></td></tr>
        </table>

        <div class="page-break"></div>

        <div class="header-title">XXIV) Presupuesto financiero detallado:</div>
        <% 
           if(presupuesto.isEmpty()) { 
        %>
            <p class="center-text">Sin presupuesto detallado.</p>
        <% } else { 
            // Agrupar por partida para mostrar montos por semestre
            Map<Integer, Map<String,Object>> partidasMap = new LinkedHashMap<>();
            Set<Integer> semestresSet = new LinkedHashSet<>();
            Map<Integer, String> semestresNombres = new LinkedHashMap<>();
            
            for(Map<String,Object> p : presupuesto) {
                Integer idPartida = (Integer)p.get("id_partida");
                Integer idSemestre = (Integer)p.get("id_semestre");
                
                semestresSet.add(idSemestre);
                semestresNombres.put(idSemestre, (String)p.get("semestre"));
                
                if(!partidasMap.containsKey(idPartida)) {
                    Map<String,Object> partidaInfo = new HashMap<>();
                    partidaInfo.put("nombre", p.get("partida"));
                    partidaInfo.put("justificacion", p.get("justificacion"));
                    partidaInfo.put("montos", new HashMap<Integer, Double>());
                    partidasMap.put(idPartida, partidaInfo);
                }
                ((Map<Integer,Double>)partidasMap.get(idPartida).get("montos")).put(idSemestre, (Double)p.get("monto"));
            }
            
            List<Integer> semestresOrdenados = new ArrayList<>(semestresSet);
            Collections.sort(semestresOrdenados);
            int numSemestres = semestresOrdenados.size();
        %>
        <table>
            <tr class="bold">
                <th>Partida</th>
                <th>Justificación</th>
                <% for(Integer idSem : semestresOrdenados) { %>
                <th style="width: 100px;">Semestre <%= semestresOrdenados.indexOf(idSem) + 1 %></th>
                <% } %>
                <th style="width: 100px;">Total</th>
            </tr>
            <% 
               double[] totalesSemestre = new double[numSemestres];
               double granTotal = 0;
               
               for(Map.Entry<Integer, Map<String,Object>> entry : partidasMap.entrySet()) {
                   Map<String,Object> partidaInfo = entry.getValue();
                   Map<Integer,Double> montos = (Map<Integer,Double>)partidaInfo.get("montos");
                   double totalPartida = 0;
            %>
            <tr>
                <td><%= escapeXml(partidaInfo.get("nombre")) %></td>
                <td><%= escapeXml(partidaInfo.get("justificacion")) %></td>
                <% 
                   int idx = 0;
                   for(Integer idSem : semestresOrdenados) { 
                       Double monto = montos.get(idSem);
                       double m = (monto != null) ? monto : 0;
                       totalPartida += m;
                       totalesSemestre[idx] += m;
                %>
                <td class="right-text">$ <%= String.format("%,.2f", m) %></td>
                <% 
                       idx++;
                   } 
                   granTotal += totalPartida;
                %>
                <td class="right-text bold">$ <%= String.format("%,.2f", totalPartida) %></td>
            </tr>
            <% } %>
            <tr class="bold" style="background-color: #ddd;">
                <td colspan="2" class="right-text">SUBTOTAL POR SEMESTRE:</td>
                <% for(int i = 0; i < numSemestres; i++) { %>
                <td class="right-text">$ <%= String.format("%,.2f", totalesSemestre[i]) %></td>
                <% } %>
                <td class="right-text">$ <%= String.format("%,.2f", granTotal) %></td>
            </tr>
        </table>
        <% } %>

    </div>

    <% } %>
</body>
</html>