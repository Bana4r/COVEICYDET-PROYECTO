<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.regex.*" %>
<% 
if (!"responsable".equals(String.valueOf(session.getAttribute("rol")))) { 
    String n=request.getRequestURI()+(request.getQueryString()!=null?("?"+request.getQueryString()):""); 
    response.sendRedirect(request.getContextPath()+"/pages/login/login.jsp?next="+java.net.URLEncoder.encode(n,"UTF-8")); 
    return; 
} 
%>

<%@ include file="/WEB-INF/conexion.jsp" %>

<%!
    // ==========================================
    // CLASE ROBUSTA PARA PARSEO DE JSON (SIN LIBRERÍAS EXTERNAS)
    // ==========================================
    public static class RobustJsonParser {
        private String json;
        private int pos;

        public Object parse(String input) throws Exception {
            if (input == null || input.trim().isEmpty()) return new HashMap<String, Object>();
            this.json = input;
            this.pos = 0;
            skipSpace();
            return parseVal();
        }

        private Object parseVal() throws Exception {
            if (pos >= json.length()) return null;
            char c = peek();
            if (c == '{') return parseObj();
            if (c == '[') return parseArr();
            if (c == '"') return parseStr();
            if (c == 't') { match("true"); return true; }
            if (c == 'f') { match("false"); return false; }
            if (c == 'n') { match("null"); return null; }
            if (Character.isDigit(c) || c == '-') return parseNum();
            throw new Exception("Carácter inesperado en posición " + pos + ": " + c);
        }

        private Map<String, Object> parseObj() throws Exception {
            Map<String, Object> map = new HashMap<String, Object>();
            consume('{');
            skipSpace();
            if (peek() == '}') { consume('}'); return map; }
            while (true) {
                String key = parseStr();
                skipSpace();
                consume(':');
                skipSpace();
                map.put(key, parseVal());
                skipSpace();
                if (peek() == '}') { consume('}'); break; }
                consume(',');
                skipSpace();
            }
            return map;
        }

        private List<Object> parseArr() throws Exception {
            List<Object> list = new ArrayList<Object>();
            consume('[');
            skipSpace();
            if (peek() == ']') { consume(']'); return list; }
            while (true) {
                list.add(parseVal());
                skipSpace();
                if (peek() == ']') { consume(']'); break; }
                consume(',');
                skipSpace();
            }
            return list;
        }

        private String parseStr() throws Exception {
            consume('"');
            StringBuilder sb = new StringBuilder();
            while (pos < json.length()) {
                char c = json.charAt(pos++);
                if (c == '"') return sb.toString();
                if (c == '\\') {
                    if (pos >= json.length()) break;
                    char esc = json.charAt(pos++);
                    if (esc == 'n') sb.append('\n');
                    else if (esc == 'r') sb.append('\r');
                    else if (esc == 't') sb.append('\t');
                    else if (esc == 'b') sb.append('\b');
                    else if (esc == 'f') sb.append('\f');
                    else if (esc == '"') sb.append('\"');
                    else if (esc == '\\') sb.append('\\');
                    else if (esc == '/') sb.append('/');
                    else if (esc == 'u') {
                        if (pos + 4 <= json.length()) {
                            try {
                                sb.append((char) Integer.parseInt(json.substring(pos, pos + 4), 16));
                                pos += 4;
                            } catch (NumberFormatException e) { sb.append("\\u"); }
                        } else { sb.append("\\u"); }
                    } else sb.append(esc);
                } else {
                    sb.append(c);
                }
            }
            return sb.toString();
        }

        private Number parseNum() throws Exception {
            int start = pos;
            if (pos < json.length() && json.charAt(pos) == '-') pos++;
            while (pos < json.length() && Character.isDigit(json.charAt(pos))) pos++;
            if (pos < json.length() && json.charAt(pos) == '.') {
                pos++;
                while (pos < json.length() && Character.isDigit(json.charAt(pos))) pos++;
            }
            String s = json.substring(start, pos);
            if (s.contains(".")) return Double.parseDouble(s);
            try { return Long.parseLong(s); } catch (NumberFormatException e) { return 0; }
        }

        private void skipSpace() {
            while (pos < json.length() && Character.isWhitespace(json.charAt(pos))) pos++;
        }
        private char peek() { return pos < json.length() ? json.charAt(pos) : 0; }
        private void consume(char c) throws Exception { if (peek() != c) throw new Exception("Esperaba " + c); pos++; }
        private void match(String s) throws Exception { for (char c : s.toCharArray()) consume(c); }
    }
    
    // Helpers seguros para extraer datos del mapa
    private String getStr(Map<String, Object> map, String key) {
        if (map == null || !map.containsKey(key)) return "";
        Object val = map.get(key);
        return val == null ? "" : String.valueOf(val).trim();
    }
    
    private Map<String, Object> getMap(Map<String, Object> parent, String key) {
        if (parent == null || !parent.containsKey(key)) return new HashMap<>();
        Object val = parent.get(key);
        if (val instanceof Map) return (Map<String, Object>) val;
        return new HashMap<>();
    }
    
    private List<Object> getList(Map<String, Object> parent, String key) {
        if (parent == null || !parent.containsKey(key)) return new ArrayList<>();
        Object val = parent.get(key);
        if (val instanceof List) return (List<Object>) val;
        return new ArrayList<>();
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <title>Procesando Proyecto - COVEICYDET</title>
</head>
<body class="bg-slate-100 min-h-screen antialiased font-sans">
    <div class="max-w-4xl mx-auto px-4 py-10">
        <div class="bg-white p-8 rounded-xl shadow-sm border border-slate-200">

<%
    // Obtener datos del usuario de la sesión
    Integer userId = (Integer) session.getAttribute("id_usuario");
    String nombreUsuario = (String) session.getAttribute("nombre");
    
    String mensaje = "";
    String tipoMensaje = "info";
    boolean exito = false;
    int proyectoId = 0;
    
    try {
        request.setCharacterEncoding("UTF-8");

        // Validar sesión
        if (userId == null || nombreUsuario == null) {
            throw new Exception("Sesión inválida. Por favor, inicie sesión nuevamente.");
        }
        
        // Obtener JSON consolidado
        String datosCompletosStr = request.getParameter("datosProyecto");
        
        if (datosCompletosStr == null || datosCompletosStr.trim().isEmpty()) {
            throw new Exception("No se recibieron datos del proyecto");
        }
        
        // ============================================================
        // PARSEO ROBUSTO DEL JSON COMPLETO
        // ============================================================
        RobustJsonParser parser = new RobustJsonParser();
        Map<String, Object> root = (Map<String, Object>) parser.parse(datosCompletosStr);
        
        // Extraer secciones principales como Mapas
        Map<String, Object> pagina1 = getMap(root, "pagina1");
        Map<String, Object> pagina2 = getMap(root, "pagina2");
        Map<String, Object> pagina3 = getMap(root, "pagina3");
        Map<String, Object> pagina4 = getMap(root, "pagina4");
        Map<String, Object> pagina5 = getMap(root, "pagina5");
        Map<String, Object> pagina6 = getMap(root, "pagina6");
        Map<String, Object> pagina7 = getMap(root, "pagina7");
        Map<String, Object> pagina8 = getMap(root, "pagina8");
        Map<String, Object> pagina9 = getMap(root, "pagina9");
        Map<String, Object> pagina10 = getMap(root, "pagina10");

        // Sub-estructuras específicas
        Map<String, Object> proyectoData = getMap(pagina1, "proyecto");
        List<Object> responsablesList = getList(pagina1, "responsables");
        
        Map<String, Object> p2Proyecto = getMap(pagina2, "proyecto");
        Map<String, Object> p3Proyecto = getMap(pagina3, "proyecto");
        Map<String, Object> p4Participantes = getMap(pagina4, "participante");
        Map<String, Object> p5Organizaciones = getMap(pagina5, "organizacion_social");
        Map<String, Object> p6Estudiantes = getMap(pagina6, "estudiantes");
        
        // En pagina 8, "partida" contiene un array "partidas"
        Map<String, Object> p8PartidaObj = getMap(pagina8, "partida");
        List<Object> p8PartidasList = getList(p8PartidaObj, "partidas");
        
        // List<Object> p8PartidasList = getList(p8PartidaObj, "partidas"); // Ya obtenido arriba

        // Verificar conexión
        if (conn == null) {
            throw new SQLException("No se pudo establecer conexión con la base de datos.");
        }

        try {
            conn.setAutoCommit(false);
            
            try {
                // ============================================================
                // 1. INSERTAR PROYECTO PRINCIPAL (Páginas 1, 2, 3, 9, 10)
                // ============================================================
                String sqlProyecto = "INSERT INTO proyectos (" +
                    "titulo, institucion_proponente, area_adscripcion, municipio, convocatoria_id, " +
                    "sector_impacto_proyecto, nivel_slr, nivel_tlr, doc_probatorio, area_conocimiento, " +
                    "resumen_ejecutivo, antecedentes, pertinencia, preguntas_investigacion, " +
                    "objetivos_general, objetivos_especificos, factores_riesgo_mitigacion, " +
                    "resumen_metodologia, resultados_esperados, " +
                    "impacto_social, impacto_ambiental, impacto_economico, impacto_cientificoTecnologico, " +
                    "doc_extenso, estado_proyecto" +
                    ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) " +
                    "RETURNING id_proyecto";
                
                try (PreparedStatement stmt = conn.prepareStatement(sqlProyecto)) {
                    // Página 1
                    stmt.setString(1, getStr(proyectoData, "titulo"));
                    stmt.setString(2, getStr(proyectoData, "institucion_proponente"));
                    stmt.setString(3, getStr(proyectoData, "area_adscripcion"));
                    stmt.setString(4, getStr(proyectoData, "municipio"));
                    
                    String convId = getStr(proyectoData, "convocatoria_id");
                    if (!convId.isEmpty() && !convId.equals("null")) stmt.setInt(5, Integer.parseInt(convId));
                    else stmt.setNull(5, java.sql.Types.INTEGER);
                    
                    stmt.setString(6, getStr(proyectoData, "sector_impacto_proyecto"));
                    stmt.setString(7, getStr(proyectoData, "nivel_slr"));
                    stmt.setString(8, getStr(proyectoData, "nivel_tlr"));
                    stmt.setString(9, getStr(proyectoData, "doc_probatorio"));
                    stmt.setString(10, getStr(proyectoData, "area_conocimiento"));
                    
                    // Página 2
                    stmt.setString(11, getStr(p2Proyecto, "resumen_ejecutivo"));
                    stmt.setString(12, getStr(p2Proyecto, "antecedentes"));
                    stmt.setString(13, getStr(p2Proyecto, "pertinencia"));
                    stmt.setString(14, getStr(p2Proyecto, "preguntas_investigacion"));
                    stmt.setString(15, getStr(p2Proyecto, "objetivos_general"));
                    stmt.setString(16, getStr(p2Proyecto, "objetivos_especificos"));
                    
                    // Página 3
                    stmt.setString(17, getStr(p3Proyecto, "factores_riesgo_mitigacion"));
                    stmt.setString(18, getStr(p3Proyecto, "resumen_metodologia"));
                    stmt.setString(19, getStr(p3Proyecto, "resultados_esperados"));
                    stmt.setString(20, getStr(p3Proyecto, "impacto_social"));
                    stmt.setString(21, getStr(p3Proyecto, "impacto_ambiental"));
                    stmt.setString(22, getStr(p3Proyecto, "impacto_economico"));
                    stmt.setString(23, getStr(p3Proyecto, "impacto_cientificoTecnologico"));
                    
                    // Página 10 (doc_extenso viene de pagina10 o pagina9)
                    String docExtenso = getStr(pagina10, "doc_extenso");
                    if(docExtenso.isEmpty()) docExtenso = getStr(pagina9, "doc_extenso");
                    stmt.setString(24, docExtenso);

                    // Estado del proyecto: "Enviado" (valor 2 según la tabla de estados)
                    stmt.setString(25, "2");

                    ResultSet rs = stmt.executeQuery();
                    if (rs.next()) {
                        proyectoId = rs.getInt("id_proyecto");
                    }
                }
                
                if (proyectoId == 0) throw new Exception("No se pudo insertar el proyecto (ID no retornado).");

                // ============================================================
                // 2. INSERTAR RESPONSABLES
                // ============================================================
                for (Object item : responsablesList) {
                    Map<String, Object> respMap = (Map<String, Object>) item;
                    String nombre = getStr(respMap, "nombre_completo");
                    
                    if (!nombre.isEmpty()) {
                        String sqlResp = "INSERT INTO responsable (nombre_completo, correo_electronico, telefono, ine, carta_aval) VALUES (?, ?, ?, ?, ?) RETURNING id_responsable";
                        try (PreparedStatement stmt = conn.prepareStatement(sqlResp)) {
                            stmt.setString(1, nombre);
                            stmt.setString(2, getStr(respMap, "correo_electronico"));
                            stmt.setString(3, getStr(respMap, "telefono"));
                            
                            String ine = getStr(respMap, "ine");
                            if (!ine.isEmpty()) stmt.setString(4, ine);
                            else stmt.setNull(4, java.sql.Types.VARCHAR);
                            
                            String aval = getStr(respMap, "carta_aval");
                            if (!aval.isEmpty()) stmt.setString(5, aval);
                            else stmt.setNull(5, java.sql.Types.VARCHAR);
                            
                            ResultSet rs = stmt.executeQuery();
                            if (rs.next()) {
                                int idResp = rs.getInt("id_responsable");
                                String sqlRel = "INSERT INTO proyecto_responsables (id_proyecto, id_responsable, tipo_responsable) VALUES (?, ?, ?)";
                                try (PreparedStatement s2 = conn.prepareStatement(sqlRel)) {
                                    s2.setInt(1, proyectoId);
                                    s2.setInt(2, idResp);
                                    s2.setString(3, getStr(respMap, "tipo_responsable"));
                                    s2.executeUpdate();
                                }
                            }
                        }
                    }
                }

                // ============================================================
                // 3. INSERTAR GRUPO DE TRABAJO (Página 4)
                // ============================================================
                for (int i = 1; i <= 5; i++) {
                    String nombre = getStr(p4Participantes, "participante" + i + "_nombre");
                    if (!nombre.isEmpty()) {
                        String sqlPart = "INSERT INTO participante (nombre_completo, institucion_adscripcion, grado_academico, area_conocimiento, disciplina, actividades_realizar, doc_comprobante_adscripcion, sexo) VALUES (?, ?, ?, ?, ?, ?, ?, ?) RETURNING id_gt_participante";
                        try (PreparedStatement stmt = conn.prepareStatement(sqlPart)) {
                            stmt.setString(1, nombre);
                            stmt.setString(2, getStr(p4Participantes, "participante" + i + "_institucion"));
                            stmt.setString(3, getStr(p4Participantes, "participante" + i + "_grado"));
                            stmt.setString(4, getStr(p4Participantes, "participante" + i + "_area"));
                            stmt.setString(5, getStr(p4Participantes, "participante" + i + "_disciplina"));
                            stmt.setString(6, getStr(p4Participantes, "participante" + i + "_actividades"));
                            stmt.setString(7, getStr(p4Participantes, "participante" + i + "_comprobante"));
                            stmt.setString(8, getStr(p4Participantes, "participante" + i + "_sexo"));
                            
                            ResultSet rs = stmt.executeQuery();
                            if (rs.next()) {
                                int idPart = rs.getInt("id_gt_participante");
                                try (PreparedStatement s2 = conn.prepareStatement("INSERT INTO gruposDetrabajo (id_proyecto, id_gt_participante) VALUES (?, ?)")) {
                                    s2.setInt(1, proyectoId);
                                    s2.setInt(2, idPart);
                                    s2.executeUpdate();
                                }
                            }
                        }
                    }
                }

                // ============================================================
                // 4. INSERTAR ORGANIZACIONES (Página 5)
                // ============================================================
                for (int i = 1; i <= 5; i++) {
                    String nombre = getStr(p5Organizaciones, "organizacion" + i + "_nombre");
                    if (!nombre.isEmpty()) {
                        String sqlOrg = "INSERT INTO organizacion_social (nombre_razon_social, responsable, domicilio, telefono, correo_electronico, doc_comprobante_adscripcion, desc_actividad) VALUES (?, ?, ?, ?, ?, ?, ?) RETURNING org_social_id";
                        try (PreparedStatement stmt = conn.prepareStatement(sqlOrg)) {
                            stmt.setString(1, nombre);
                            stmt.setString(2, getStr(p5Organizaciones, "organizacion" + i + "_responsable"));
                            stmt.setString(3, getStr(p5Organizaciones, "organizacion" + i + "_domicilio"));
                            stmt.setString(4, getStr(p5Organizaciones, "organizacion" + i + "_telefono"));
                            stmt.setString(5, getStr(p5Organizaciones, "organizacion" + i + "_email"));
                            stmt.setString(6, getStr(p5Organizaciones, "organizacion" + i + "_comprobante"));
                            stmt.setString(7, getStr(p5Organizaciones, "organizacion" + i + "_actividad"));
                            
                            ResultSet rs = stmt.executeQuery();
                            if (rs.next()) {
                                int idOrg = rs.getInt("org_social_id");
                                try (PreparedStatement s2 = conn.prepareStatement("INSERT INTO proyecto_organizaciones (id_proyecto, org_social_id) VALUES (?, ?)")) {
                                    s2.setInt(1, proyectoId);
                                    s2.setInt(2, idOrg);
                                    s2.executeUpdate();
                                }
                            }
                        }
                    }
                }

                // ============================================================
                // 5. INSERTAR ESTUDIANTES (Página 6)
                // ============================================================
                for (int i = 1; i <= 5; i++) {
                    String nombre = getStr(p6Estudiantes, "estudiante" + i + "_nombre");
                    if (!nombre.isEmpty()) {
                        String sqlEst = "INSERT INTO estudiantes (nombre_completo, sexo, nivel_academico, tiempo_permanencia, institucion, programa_educativo, actividades_principales, carta_colaboracion) VALUES (?, ?, ?, ?, ?, ?, ?, ?) RETURNING id_estudiante";
                        try (PreparedStatement stmt = conn.prepareStatement(sqlEst)) {
                            stmt.setString(1, nombre);
                            stmt.setString(2, getStr(p6Estudiantes, "estudiante" + i + "_sexo"));
                            stmt.setString(3, getStr(p6Estudiantes, "estudiante" + i + "_nivel"));
                            stmt.setString(4, getStr(p6Estudiantes, "estudiante" + i + "_tiempo"));
                            stmt.setString(5, getStr(p6Estudiantes, "estudiante" + i + "_institucion"));
                            stmt.setString(6, getStr(p6Estudiantes, "estudiante" + i + "_programa"));
                            stmt.setString(7, getStr(p6Estudiantes, "estudiante" + i + "_actividades"));
                            stmt.setString(8, getStr(p6Estudiantes, "estudiante" + i + "_comprobante"));
                            
                            ResultSet rs = stmt.executeQuery();
                            if (rs.next()) {
                                int idEst = rs.getInt("id_estudiante");
                                try (PreparedStatement s2 = conn.prepareStatement("INSERT INTO estudiantes_participantes (id_proyecto, id_estudiante) VALUES (?, ?)")) {
                                    s2.setInt(1, proyectoId);
                                    s2.setInt(2, idEst);
                                    s2.executeUpdate();
                                }
                            }
                        }
                    }
                }

                // ============================================================
                // 6. INSERTAR CALENDARIO (Página 7)
                // ============================================================
                List<Object> semestresList = getList(pagina7, "semestres");
                Map<Integer, Integer> semestreIds = new HashMap<>();
                int semCounter = 1;
                
                for (Object semObj : semestresList) {
                    Map<String, Object> semMap = (Map<String, Object>) semObj;
                    String desc = getStr(semMap, "descripcion_semestre");
                    String meta = getStr(semMap, "meta_semestre");
                    if (desc.isEmpty()) desc = "Semestre " + semCounter;
                    
                    // Insertar o buscar Semestre
                    int idSemestre = -1;
                    String sqlSem = "INSERT INTO semestres (descripcion_semestre, meta_semestre) VALUES (?, ?) RETURNING id_semestre";
                    try (PreparedStatement stmt = conn.prepareStatement(sqlSem)) {
                        stmt.setString(1, desc);
                        stmt.setString(2, meta);
                        ResultSet rs = stmt.executeQuery();
                        if (rs.next()) idSemestre = rs.getInt("id_semestre");
                    }
                    
                    if (idSemestre != -1) {
                        semestreIds.put(semCounter, idSemestre);
                        // Actividades del semestre
                        List<Object> actividades = getList(semMap, "actividades");
                        for (Object actObj : actividades) {
                            Map<String, Object> actMap = (Map<String, Object>) actObj;
                            String nombreAct = getStr(actMap, "nombre");
                            // Entregables viene como lista de strings, lo convertimos a string simple o JSON string
                            List<Object> entList = getList(actMap, "entregables");
                            String entStr = entList.toString(); 

                            if (!nombreAct.isEmpty()) {
                                String sqlAct = "INSERT INTO actividades (nombre_actividad, entregables) VALUES (?, ?) RETURNING id_actividad";
                                try (PreparedStatement stmtAct = conn.prepareStatement(sqlAct)) {
                                    stmtAct.setString(1, nombreAct);
                                    stmtAct.setString(2, entStr);
                                    ResultSet rsAct = stmtAct.executeQuery();
                                    if (rsAct.next()) {
                                        int idAct = rsAct.getInt("id_actividad");
                                        try (PreparedStatement sCrono = conn.prepareStatement("INSERT INTO cronograma_actividades (id_proyecto, id_actividad, id_semestre) VALUES (?, ?, ?)")) {
                                            sCrono.setInt(1, proyectoId);
                                            sCrono.setInt(2, idAct);
                                            sCrono.setInt(3, idSemestre);
                                            sCrono.executeUpdate();
                                        }
                                    }
                                }
                            }
                        }
                    }
                    semCounter++;
                }

                // ============================================================
                // 7. INSERTAR PRESUPUESTO (Página 8)
                // ============================================================
                for (Object parObj : p8PartidasList) {
                    Map<String, Object> partida = (Map<String, Object>) parObj;
                    String nombre = getStr(partida, "nombre");
                    String justif = getStr(partida, "justificacion");
                    Map<String, Object> montos = getMap(partida, "montos");
                    
                    double m1 = 0, m2 = 0;
                    try { m1 = Double.parseDouble(getStr(montos, "semestre1").replaceAll("[^0-9.]", "")); } catch(Exception e){}
                    try { m2 = Double.parseDouble(getStr(montos, "semestre2").replaceAll("[^0-9.]", "")); } catch(Exception e){}
                    
                    if (!nombre.isEmpty() && (!justif.isEmpty() || m1 > 0 || m2 > 0)) {
                        String sqlPar = "INSERT INTO partidas (nombre, justificacion) VALUES (?, ?) RETURNING id_partidas";
                        try (PreparedStatement stmt = conn.prepareStatement(sqlPar)) {
                            stmt.setString(1, nombre);
                            stmt.setString(2, justif.isEmpty() ? "Sin justificación" : justif);
                            ResultSet rs = stmt.executeQuery();
                            if (rs.next()) {
                                int idPartida = rs.getInt("id_partidas");
                                // Relacionar montos
                                if (semestreIds.containsKey(1) && m1 > 0) {
                                    try(PreparedStatement s2 = conn.prepareStatement("INSERT INTO semestres_proyecto (id_semestre, id_proyecto, id_partidas, monto) VALUES (?, ?, ?, ?)")){
                                        s2.setInt(1, semestreIds.get(1)); s2.setInt(2, proyectoId); s2.setInt(3, idPartida); s2.setDouble(4, m1); s2.executeUpdate();
                                    }
                                }
                                if (semestreIds.containsKey(2) && m2 > 0) {
                                    try(PreparedStatement s2 = conn.prepareStatement("INSERT INTO semestres_proyecto (id_semestre, id_proyecto, id_partidas, monto) VALUES (?, ?, ?, ?)")){
                                        s2.setInt(1, semestreIds.get(2)); s2.setInt(2, proyectoId); s2.setInt(3, idPartida); s2.setDouble(4, m2); s2.executeUpdate();
                                    }
                                }
                            }
                        }
                    }
                }

                // ============================================================
                // 8. RELACIONAR USUARIO Y FINALIZAR
                // ============================================================
                try (PreparedStatement stmt = conn.prepareStatement("INSERT INTO proyecto_usuarios (id_proyecto, id_usuario) VALUES (?, ?)")) {
                    stmt.setInt(1, proyectoId);
                    stmt.setInt(2, userId);
                    stmt.executeUpdate();
                }
                
                conn.commit();
                exito = true;
                mensaje = "Proyecto registrado exitosamente con ID: " + proyectoId;
                tipoMensaje = "success";
                
            } catch (Exception e) {
                if (conn != null) conn.rollback();
                throw e;
            }
        } finally {
             // Opcional: devolver autocommit a true o cerrar si es necesario
             if (conn != null) { 
                 try { conn.setAutoCommit(true); conn.close(); } catch(Exception e){} 
             }
        }

        
    } catch (SQLException e) {
        mensaje = "Error de base de datos: " + e.getMessage();
        tipoMensaje = "error";
        e.printStackTrace();
    } catch (Exception e) {
        mensaje = "Error al procesar el proyecto: " + e.getMessage();
        tipoMensaje = "error";
        e.printStackTrace();
    }
%>

            <div class="text-center">
                <% if ("success".equals(tipoMensaje)) { %>
                    <div class="mx-auto flex items-center justify-center h-16 w-16 rounded-full bg-green-100 mb-4">
                        <svg class="h-8 w-8 text-green-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                        </svg>
                    </div>
                    <h1 class="text-3xl font-bold text-gray-900 mb-2">¡Proyecto Registrado!</h1>
                    <p class="text-lg text-gray-600 mb-2"><%= mensaje %></p>
                    <p class="text-sm text-gray-500 mb-6">Tu proyecto ha sido enviado correctamente y está en revisión.</p>
                <% } else { %>
                    <div class="mx-auto flex items-center justify-center h-16 w-16 rounded-full bg-red-100 mb-4">
                        <svg class="h-8 w-8 text-red-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                        </svg>
                    </div>
                    <h1 class="text-3xl font-bold text-gray-900 mb-2">Error al Procesar</h1>
                    <p class="text-lg text-red-600 mb-6"><%= mensaje %></p>
                <% } %>
                
                <div class="flex justify-center space-x-4 mt-8">
                    <% if (exito) { %>
                        <a href="<%= request.getContextPath() %>/pages/responsableDeproyecto/proyectos/index.jsp" 
                           class="inline-flex items-center px-6 py-3 border border-transparent text-base font-medium rounded-md text-white bg-[#7A1737] hover:bg-[#5c0f2a] transition duration-200">
                            <i class="fas fa-list mr-2"></i>Ver Mis Proyectos
                        </a>
                        <a href="<%= request.getContextPath() %>/pages/responsableDeproyecto/registroProyecto/registroProyecto.jsp" 
                           class="inline-flex items-center px-6 py-3 border border-gray-300 text-base font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 transition duration-200">
                            <i class="fas fa-plus mr-2"></i>Nuevo Proyecto
                        </a>
                    <% } else { %>
                        <button onclick="history.back()" 
                                class="inline-flex items-center px-6 py-3 border border-gray-300 text-base font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 transition duration-200">
                            <i class="fas fa-arrow-left mr-2"></i>Volver
                        </button>
                        <a href="<%= request.getContextPath() %>/pages/responsableDeproyecto/registroProyecto/registroProyecto.jsp" 
                           class="inline-flex items-center px-6 py-3 border border-transparent text-base font-medium rounded-md text-white bg-[#7A1737] hover:bg-[#5c0f2a] transition duration-200">
                            <i class="fas fa-redo mr-2"></i>Intentar de Nuevo
                        </a>
                    <% } %>
                </div>
                
                <% if (exito) { %>
                <script>
                    // Limpiar localStorage después del envío exitoso
                    for (let i = 1; i <= 10; i++) {
                        localStorage.removeItem('proyecto_borrador_pagina' + i);
                        localStorage.removeItem('proyecto_borrador_pagina' + i + '_saved');
                    }
                    console.log('✅ LocalStorage limpiado después del envío exitoso');
                </script>
                <% } %>
            </div>
        </div>
    </div>
</body>
</html>
