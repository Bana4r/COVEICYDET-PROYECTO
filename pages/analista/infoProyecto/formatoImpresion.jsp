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
    // --- CONFIGURACIÓN Y UTILIDADES ---
    private static final String DB_URL = "jdbc:postgresql://localhost:5432/proyectos";
    private static final String DB_USER = "dbusr25";
    private static final String DB_PASSWORD = "mxToro24000Chocolate";

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
        Connection conn = null;
        try {
            Class.forName("org.postgresql.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
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

                // 3. CRONOGRAMA
                String sqlCron = "SELECT s.descripcion_semestre, a.nombre_actividad FROM Cronograma_Actividades ca " +
                                 "JOIN actividades a ON ca.id_actividad = a.id_actividad " +
                                 "JOIN semestres s ON ca.id_semestre = s.id_semestre " +
                                 "WHERE ca.id_proyecto = ? ORDER BY s.id_semestre";
                try(PreparedStatement stmt = conn.prepareStatement(sqlCron)){
                    stmt.setInt(1, Integer.parseInt(proyectoId));
                    try(ResultSet rs = stmt.executeQuery()){
                        while(rs.next()){
                            Map<String,Object> m = new HashMap<>();
                            m.put("periodo", rs.getString("descripcion_semestre"));
                            m.put("actividad", rs.getString("nombre_actividad"));
                            cronograma.add(m);
                        }
                    }
                }
                
                // 4. PRESUPUESTO (Unión: semestres_proyecto -> partidas)
                // Nota: Según diagrama, 'monto' está en 'semestres_proyecto' y 'nombre_partida'/'justificacion' en 'partidas'
                try {
                    String sqlPres = "SELECT p.nombre_partida, sp.monto, p.justificacion " +
                                     "FROM semestres_proyecto sp " +
                                     "JOIN partidas p ON sp.id_partidas = p.id_partidas " +
                                     "WHERE sp.id_proyecto = ?";
                    try(PreparedStatement stmt = conn.prepareStatement(sqlPres)){
                        stmt.setInt(1, Integer.parseInt(proyectoId));
                        try(ResultSet rs = stmt.executeQuery()){
                            while(rs.next()){
                                Map<String,Object> m = new HashMap<>();
                                m.put("partida", rs.getString("nombre_partida"));
                                m.put("monto", rs.getDouble("monto"));
                                m.put("justificacion", rs.getString("justificacion"));
                                presupuesto.add(m);
                            }
                        }
                    }
                } catch(Exception ePres) {
                    // Si falla presupuesto, no rompemos todo, solo lo logueamos
                    System.out.println("Error presupuesto: " + ePres.getMessage());
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
                <td style="width: 120px; text-align: center;">Marque con "X"</td>
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
            <tr><td>Físico-Matemáticas y Ciencias de la Tierra</td><td class="center-text" style="width: 30px;"><%= marcar(area, "Físico-Matemáticas y Ciencias de la Tierra") %></td></tr>
            <tr><td>Biología y Química</td><td class="center-text"><%= marcar(area, "Biología y Química") %></td></tr>
            <tr><td>Medicina y Ciencias de la Salud</td><td class="center-text"><%= marcar(area, "Medicina y Ciencias de la Salud") %></td></tr>
            <tr><td>Humanidades</td><td class="center-text"><%= marcar(area, "Humanidades") %></td></tr>
            <tr><td>Ciencias Sociales</td><td class="center-text"><%= marcar(area, "Ciencias Sociales") %></td></tr>
            <tr><td>Ingenierías y Desarrollo Tecnológico</td><td class="center-text"><%= marcar(area, "Ingenierías y Desarrollo Tecnológico") %></td></tr>
            <tr><td>Interdisciplinaria</td><td class="center-text"><%= marcar(area, "Interdisciplinaria") %></td></tr>
        </table>
        
        <div class="header-title">VI) Sector de desarrollo:</div>
        <div class="section-content section-box"><%= escapeXml(proyecto.get("sector")) %></div>

        <div class="page-break"></div>

        <div class="header-title">VII) Nivel de maduración (TRL / SRL):</div>
        <% String tlr = (String)proyecto.get("tlr"); %>
        <table style="font-size: 9pt;">
            <tr class="bold"><td style="width: 90%">Niveles de Maduración Tecnológica</td><td>TRL</td></tr>
            <tr><td>TRL 1: Principios básicos observados.</td><td class="center-text"><%= marcar(tlr, "TRL 1") %></td></tr>
            <tr><td>TRL 2: Concepto y aplicación formulada.</td><td class="center-text"><%= marcar(tlr, "TRL 2") %></td></tr>
            <tr><td>TRL 3: Prueba de concepto.</td><td class="center-text"><%= marcar(tlr, "TRL 3") %></td></tr>
            <tr><td>TRL 4: Validación laboratorio.</td><td class="center-text"><%= marcar(tlr, "TRL 4") %></td></tr>
            <tr><td>TRL 5: Validación entorno relevante.</td><td class="center-text"><%= marcar(tlr, "TRL 5") %></td></tr>
            <tr><td>TRL 6: Demostración tecnológica.</td><td class="center-text"><%= marcar(tlr, "TRL 6") %></td></tr>
            <tr><td>TRL 7 - 9: Prototipos y Productos finales.</td><td class="center-text"><%= (marcar(tlr, "TRL 7").equals("X") || marcar(tlr, "TRL 8").equals("X") || marcar(tlr, "TRL 9").equals("X")) ? "X" : "" %></td></tr>
        </table>
        
        <% String slr = (String)proyecto.get("slr"); %>
        <table style="font-size: 9pt;">
            <tr class="bold"><td style="width: 90%">SRL: Niveles de Maduración Social</td><td>SRL</td></tr>
            <tr><td>SRL 1: Identificación del problema.</td><td class="center-text"><%= marcar(slr, "SRL 1") %></td></tr>
            <tr><td>SRL 2: Formulación de soluciones.</td><td class="center-text"><%= marcar(slr, "SRL 2") %></td></tr>
            <tr><td>SRL 3: Pruebas en campo iniciales.</td><td class="center-text"><%= marcar(slr, "SRL 3") %></td></tr>
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
        <table>
            <tr class="bold"><th>Periodo</th><th>Actividad</th></tr>
            <% if(cronograma.isEmpty()) { %>
                <tr><td colspan="2" class="center-text">No hay actividades registradas.</td></tr>
            <% } else { 
                for(Map<String,Object> c : cronograma) { %>
                <tr>
                    <td><%= escapeXml(c.get("periodo")) %></td>
                    <td><%= escapeXml(c.get("actividad")) %></td>
                </tr>
            <% } } %>
        </table>

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
        <table>
            <tr class="bold">
                <th>Partida</th>
                <th>Justificación</th>
                <th>Monto</th>
            </tr>
            <% 
               double total = 0;
               if(presupuesto.isEmpty()) { 
            %>
                <tr><td colspan="3" class="center-text">Sin presupuesto detallado.</td></tr>
            <% } else { 
                   for(Map<String,Object> p : presupuesto) { 
                       double m = (Double)p.get("monto");
                       total += m;
            %>
                <tr>
                    <td><%= escapeXml(p.get("partida")) %></td>
                    <td><%= escapeXml(p.get("justificacion")) %></td>
                    <td class="right-text">$ <%= String.format("%,.2f", m) %></td>
                </tr>
                <% } %>
                <tr class="bold" style="background-color: #ddd;">
                    <td colspan="2" class="right-text">TOTAL SOLICITADO:</td>
                    <td class="right-text">$ <%= String.format("%,.2f", total) %></td>
                </tr>
            <% } %>
        </table>

    </div>

    <% } %>
</body>
</html>