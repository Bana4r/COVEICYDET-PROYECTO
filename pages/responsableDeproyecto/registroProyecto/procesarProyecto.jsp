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

<%!
    // Configuración de la base de datos
    private static final String DB_URL = "jdbc:postgresql://localhost:5432/proyectos";
    private static final String DB_USER = "dbusr25";
    private static final String DB_PASSWORD = "mxToro24000Chocolate";
    
    // Función para extraer valor de JSON usando regex (sin librerías externas)
    public String extraerValor(String json, String clave) {
        if (json == null || clave == null) return "";
        
        String patron = "\"" + clave + "\"\\s*:\\s*\"([^\"]*)\"|\"" + clave + "\"\\s*:\\s*([^,}\\]]+)";
        Pattern pattern = Pattern.compile(patron);
        Matcher matcher = pattern.matcher(json);
        
        if (matcher.find()) {
            String valor = matcher.group(1);
            if (valor == null) valor = matcher.group(2);
            if (valor != null) {
                valor = valor.trim();
                if (valor.equals("null") || valor.equals("undefined") || valor.equals("NaN")) return "";
                return valor;
            }
        }
        return "";
    }
    
    // Función para encontrar cierre balanceado de llaves/corchetes
    private int encontrarCierreBalanceado(String s, int inicio, char abre, char cierra) {
        int profundidad = 0;
        boolean enString = false;
        boolean escape = false;
        for (int i = inicio; i < s.length(); i++) {
            char ch = s.charAt(i);
            if (enString) {
                if (escape) {
                    escape = false;
                } else if (ch == '\\') {
                    escape = true;
                } else if (ch == '"') {
                    enString = false;
                }
                continue;
            }
            if (ch == '"') {
                enString = true;
                continue;
            }
            if (ch == abre) profundidad++;
            else if (ch == cierra) {
                profundidad--;
                if (profundidad == 0) return i;
            }
        }
        return -1;
    }

    // Extraer objeto JSON por clave
    private String extraerObjetoPorClave(String json, String clave) {
        if (json == null) return "{}";
        String buscado = "\"" + clave + "\"";
        int idx = json.indexOf(buscado);
        if (idx < 0) return "{}";
        int ll = json.indexOf('{', idx);
        if (ll < 0) return "{}";
        int rr = encontrarCierreBalanceado(json, ll, '{', '}');
        if (rr < 0) return "{}";
        return json.substring(ll, rr + 1);
    }
    
    // Extraer array JSON por clave
    private String extraerArrayPorClave(String json, String clave) {
        if (json == null) return "[]";
        String buscado = "\"" + clave + "\"";
        int idx = json.indexOf(buscado);
        if (idx < 0) return "[]";
        int lb = json.indexOf('[', idx);
        if (lb < 0) return "[]";
        int rb = encontrarCierreBalanceado(json, lb, '[', ']');
        if (rb < 0) return "[]";
        return json.substring(lb, rb + 1);
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
        
        // Obtener JSON consolidado de todas las páginas
        String datosCompletos = request.getParameter("datosProyecto");
        
        if (datosCompletos == null || datosCompletos.trim().isEmpty()) {
            throw new Exception("No se recibieron datos del proyecto");
        }
        
        // Extraer cada página del JSON
        String pagina1Json = extraerObjetoPorClave(datosCompletos, "pagina1");
        String pagina2Json = extraerObjetoPorClave(datosCompletos, "pagina2");
        String pagina3Json = extraerObjetoPorClave(datosCompletos, "pagina3");
        String pagina4Json = extraerObjetoPorClave(datosCompletos, "pagina4");
        String pagina5Json = extraerObjetoPorClave(datosCompletos, "pagina5");
        String pagina6Json = extraerObjetoPorClave(datosCompletos, "pagina6");
        String pagina7Json = extraerObjetoPorClave(datosCompletos, "pagina7");
        String pagina8Json = extraerObjetoPorClave(datosCompletos, "pagina8");
        String pagina9Json = extraerObjetoPorClave(datosCompletos, "pagina9");
        
        // Página 1 tiene estructura especial: {proyecto: {...}, responsables: [...]}
        String proyectoJson = extraerObjetoPorClave(pagina1Json, "proyecto");
        String responsablesArray = extraerArrayPorClave(pagina1Json, "responsables");
        
        // Extraer objetos - páginas 2 y 3 usan 'proyecto' porque van a la misma tabla
        String pagina2Data = extraerObjetoPorClave(pagina2Json, "proyecto");
        String pagina3Data = extraerObjetoPorClave(pagina3Json, "proyecto");
        String pagina4Data = extraerObjetoPorClave(pagina4Json, "participante");
        String pagina5Data = extraerObjetoPorClave(pagina5Json, "organizacion_social");
        String pagina6Data = extraerObjetoPorClave(pagina6Json, "estudiantes");
        String pagina7Data = extraerObjetoPorClave(pagina7Json, "cronograma");

        // pagina 8 tiene estructura especial
        String pagina8Data = extraerObjetoPorClave(pagina8Json, "partida");
        String pagina8Array = extraerArrayPorClave(pagina8Data, "partidas");

        String pagina9Data = extraerObjetoPorClave(pagina9Json, "pagina9");
        
        // Conectar a la base de datos
        Class.forName("org.postgresql.Driver");
        
        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
            conn.setAutoCommit(false);
            
            try {
                // ============================================================
                // 1. INSERTAR PROYECTO PRINCIPAL (Páginas 1, 2, 3, 9)
                // ============================================================
                String sqlProyecto = "INSERT INTO proyectos (" +
                    "titulo, institucion_proponente, area_adscripcion, municipio, convocatoria_id, " +
                    "sector_impacto_proyecto, nivel_slr, nivel_tlr, doc_probatorio, area_conocimiento, " +
                    "resumen_ejecutivo, antecedentes, pertinencia, preguntas_investigacion, " +
                    "objetivos_general, objetivos_especificos, factores_riesgo_mitigacion, " +
                    "resumen_metodologia, resultados_esperados, " +
                    "impacto_social, impacto_ambiental, impacto_economico, impacto_cientificoTecnologico, " +
                    "doc_extenso" +
                    ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) " +
                    "RETURNING id_proyecto";
                
                try (PreparedStatement stmt = conn.prepareStatement(sqlProyecto)) {
                    // Página 1 - Datos generales (del objeto "proyecto")
                    stmt.setString(1, extraerValor(proyectoJson, "titulo"));
                    stmt.setString(2, extraerValor(proyectoJson, "institucion_proponente"));
                    stmt.setString(3, extraerValor(proyectoJson, "area_adscripcion"));
                    stmt.setString(4, extraerValor(proyectoJson, "municipio"));
                    
                    // Convocatoria ID
                    String convocatoriaIdStr = extraerValor(proyectoJson, "convocatoria_id");
                    if (convocatoriaIdStr != null && !convocatoriaIdStr.isEmpty()) {
                        stmt.setInt(5, Integer.parseInt(convocatoriaIdStr));
                    } else {
                        stmt.setNull(5, java.sql.Types.INTEGER);
                    }
                    
                    stmt.setString(6, extraerValor(proyectoJson, "sector_impacto_proyecto"));
                    stmt.setString(7, extraerValor(proyectoJson, "nivel_slr"));
                    stmt.setString(8, extraerValor(proyectoJson, "nivel_tlr"));
                    stmt.setString(9, extraerValor(proyectoJson, "doc_probatorio"));
                    stmt.setString(10, extraerValor(proyectoJson, "area_conocimiento"));
                    
                    // Página 2 - Justificación y objetivos
                    stmt.setString(11, extraerValor(pagina2Data, "resumen_ejecutivo"));
                    stmt.setString(12, extraerValor(pagina2Data, "antecedentes"));
                    stmt.setString(13, extraerValor(pagina2Data, "pertinencia"));
                    stmt.setString(14, extraerValor(pagina2Data, "preguntas_investigacion"));
                    stmt.setString(15, extraerValor(pagina2Data, "objetivos_general"));
                    stmt.setString(16, extraerValor(pagina2Data, "objetivos_especificos"));
                    
                    // Página 3 - Planeación y evaluación
                    stmt.setString(17, extraerValor(pagina3Data, "factores_riesgo_mitigacion"));
                    stmt.setString(18, extraerValor(pagina3Data, "resumen_metodologia"));
                    stmt.setString(19, extraerValor(pagina3Data, "resultados_esperados"));
                    stmt.setString(20, extraerValor(pagina3Data, "impacto_social"));
                    stmt.setString(21, extraerValor(pagina3Data, "impacto_ambiental"));
                    stmt.setString(22, extraerValor(pagina3Data, "impacto_economico"));
                    stmt.setString(23, extraerValor(pagina3Data, "impacto_cientificoTecnologico"));
                    
                    // Página 9 - Documento extenso
                    stmt.setString(24, extraerValor(pagina9Data, "doc_extenso"));
                    
                    ResultSet rs = stmt.executeQuery();
                    if (rs.next()) {
                        proyectoId = rs.getInt("id_proyecto");
                    }
                }
                
                if (proyectoId == 0) {
                    throw new Exception("No se pudo insertar el proyecto");
                }
                
                // ============================================================
                // 2. INSERTAR RESPONSABLES (Página 1 - array)
                // ============================================================
                // Extraer cada objeto del array responsables
                List<String> responsablesObjetos = new ArrayList<>();
                int pos = 0;
                while (pos < responsablesArray.length()) {
                    int objStart = responsablesArray.indexOf('{', pos);
                    if (objStart < 0) break;
                    int objEnd = encontrarCierreBalanceado(responsablesArray, objStart, '{', '}');
                    if (objEnd < 0) break;
                    String obj = responsablesArray.substring(objStart, objEnd + 1);
                    responsablesObjetos.add(obj);
                    pos = objEnd + 1;
                }
                
                // Insertar cada responsable
                for (String respJson : responsablesObjetos) {
                    String nombreCompleto = extraerValor(respJson, "nombre_completo");
                    if (!nombreCompleto.isEmpty()) {
                        String sqlResp = "INSERT INTO responsable (nombre_completo, correo_electronico, telefono, ine, carta_aval) " +
                                        "VALUES (?, ?, ?, ?, ?) RETURNING id_responsable";
                        try (PreparedStatement stmt = conn.prepareStatement(sqlResp)) {
                            stmt.setString(1, nombreCompleto);
                            stmt.setString(2, extraerValor(respJson, "correo_electronico"));
                            stmt.setString(3, extraerValor(respJson, "telefono"));
                            
                            // INE y Carta Aval (pueden ser null según el tipo de responsable)
                            String ine = extraerValor(respJson, "ine");
                            String cartaAval = extraerValor(respJson, "carta_aval");
                            
                            if (ine != null && !ine.isEmpty()) {
                                stmt.setString(4, ine);
                            } else {
                                stmt.setNull(4, java.sql.Types.VARCHAR);
                            }
                            
                            if (cartaAval != null && !cartaAval.isEmpty()) {
                                stmt.setString(5, cartaAval);
                            } else {
                                stmt.setNull(5, java.sql.Types.VARCHAR);
                            }
                            
                            ResultSet rs = stmt.executeQuery();
                            if (rs.next()) {
                                int idResp = rs.getInt("id_responsable");
                                
                                // Relacionar con proyecto
                                String tipoResp = extraerValor(respJson, "tipo_responsable");
                                String sqlProyResp = "INSERT INTO proyecto_responsables (id_proyecto, id_responsable, tipo_responsable) VALUES (?, ?, ?)";
                                try (PreparedStatement stmt2 = conn.prepareStatement(sqlProyResp)) {
                                    stmt2.setInt(1, proyectoId);
                                    stmt2.setInt(2, idResp);
                                    stmt2.setString(3, tipoResp);
                                    stmt2.executeUpdate();
                                }
                            }
                        }
                    }
                }
                
                // ============================================================
                // 3. INSERTAR GRUPO DE TRABAJO (Página 4) - participante1-5
                // ============================================================
                for (int i = 1; i <= 5; i++) {
                    String nombre = extraerValor(pagina4Data, "participante" + i + "_nombre");
                    
                    if (!nombre.isEmpty()) {
                        String sqlParticipante = "INSERT INTO participante (" +
                            "nombre_completo, institucion_adscripcion, grado_academico, " +
                            "area_conocimiento, disciplina, actividades_realizar, doc_comprobante_adscripcion, sexo" + // AGREGADO sexo
                            ") VALUES (?, ?, ?, ?, ?, ?, ?, ?) RETURNING id_gt_participante"; // AGREGADO un parámetro más

                        try (PreparedStatement stmt = conn.prepareStatement(sqlParticipante)) {
                            stmt.setString(1, nombre);
                            stmt.setString(2, extraerValor(pagina4Data, "participante" + i + "_institucion"));
                            stmt.setString(3, extraerValor(pagina4Data, "participante" + i + "_grado"));
                            stmt.setString(4, extraerValor(pagina4Data, "participante" + i + "_area"));
                            stmt.setString(5, extraerValor(pagina4Data, "participante" + i + "_disciplina"));
                            stmt.setString(6, extraerValor(pagina4Data, "participante" + i + "_actividades"));
                            stmt.setString(7, extraerValor(pagina4Data, "participante" + i + "_comprobante"));
                            stmt.setString(8, extraerValor(pagina4Data, "participante" + i + "_sexo")); // NUEVO: campo sexo

                            ResultSet rs = stmt.executeQuery();
                            if (rs.next()) {
                                int idParticipante = rs.getInt("id_gt_participante");
                                // Relacionar con proyecto
                                String sqlGrupo = "INSERT INTO gruposDetrabajo (id_proyecto, id_gt_participante) VALUES (?, ?)";
                                try (PreparedStatement stmt2 = conn.prepareStatement(sqlGrupo)) {
                                    stmt2.setInt(1, proyectoId);
                                    stmt2.setInt(2, idParticipante);
                                    stmt2.executeUpdate();
                                }
                            }
                        }
                    }
                }
                
                // ============================================================
                // 4. INSERTAR ORGANIZACIONES (Página 5) - organizacion1-5
                // ============================================================
                for (int i = 1; i <= 5; i++) {
                    String nombre = extraerValor(pagina5Data, "organizacion" + i + "_nombre");
                    System.out.println("DEBUG: Org " + i + " Nombre = '" + nombre + "'"); // <--- AÑADE ESTO

                    if (!nombre.isEmpty()) {
                        String sqlOrg = "INSERT INTO organizacion_social (" +
                            "nombre_razon_social, responsable, domicilio, telefono, " +
                            "correo_electronico, doc_comprobante_adscripcion, desc_actividad" +
                            ") VALUES (?, ?, ?, ?, ?, ?, ?) RETURNING org_social_id";
                        
                        try (PreparedStatement stmt = conn.prepareStatement(sqlOrg)) {
                            stmt.setString(1, nombre);
                            stmt.setString(2, extraerValor(pagina5Data, "organizacion" + i + "_responsable"));
                            stmt.setString(3, extraerValor(pagina5Data, "organizacion" + i + "_domicilio"));
                            stmt.setString(4, extraerValor(pagina5Data, "organizacion" + i + "_telefono"));
                            stmt.setString(5, extraerValor(pagina5Data, "organizacion" + i + "_email"));
                            stmt.setString(6, extraerValor(pagina5Data, "organizacion" + i + "_comprobante"));
                            stmt.setString(7, extraerValor(pagina5Data, "organizacion" + i + "_actividad"));
                            
                            ResultSet rs = stmt.executeQuery();
                            if (rs.next()) {
                                int idOrg = rs.getInt("org_social_id");
                                
                                // Relacionar con proyecto
                                String sqlProyOrg = "INSERT INTO proyecto_organizaciones (id_proyecto, org_social_id) VALUES (?, ?)";
                                try (PreparedStatement stmt2 = conn.prepareStatement(sqlProyOrg)) {
                                    stmt2.setInt(1, proyectoId);
                                    stmt2.setInt(2, idOrg);
                                    stmt2.executeUpdate();
                                }
                            }
                        }
                    }
                }
                
                // ============================================================
                // 5. INSERTAR ESTUDIANTES (Página 6) - estudiante1-5
                // ============================================================
                for (int i = 1; i <= 5; i++) {
                    String nombre = extraerValor(pagina6Data, "estudiante" + i + "_nombre");
                    
                    if (!nombre.isEmpty()) {
                        String sqlEst = "INSERT INTO estudiantes (" +
                            "nombre_completo, sexo, nivel_academico, tiempo_permanencia, " +
                            "institucion, programa_educativo, actividades_principales, carta_colaboracion" +
                            ") VALUES (?, ?, ?, ?, ?, ?, ?, ?) RETURNING id_estudiante";
                        
                        try (PreparedStatement stmt = conn.prepareStatement(sqlEst)) {
                            stmt.setString(1, nombre);
                            stmt.setString(2, extraerValor(pagina6Data, "estudiante" + i + "_sexo"));
                            stmt.setString(3, extraerValor(pagina6Data, "estudiante" + i + "_nivel"));
                            stmt.setString(4, extraerValor(pagina6Data, "estudiante" + i + "_tiempo"));
                            stmt.setString(5, extraerValor(pagina6Data, "estudiante" + i + "_institucion"));
                            stmt.setString(6, extraerValor(pagina6Data, "estudiante" + i + "_programa"));
                            stmt.setString(7, extraerValor(pagina6Data, "estudiante" + i + "_actividades"));
                            stmt.setString(8, extraerValor(pagina6Data, "estudiante" + i + "_comprobante"));
                            
                            ResultSet rs = stmt.executeQuery();
                            if (rs.next()) {
                                int idEstudiante = rs.getInt("id_estudiante");
                                
                                // Relacionar con proyecto
                                String sqlEstProy = "INSERT INTO estudiantes_participantes (id_proyecto, id_estudiante) VALUES (?, ?)";
                                try (PreparedStatement stmt2 = conn.prepareStatement(sqlEstProy)) {
                                    stmt2.setInt(1, proyectoId);
                                    stmt2.setInt(2, idEstudiante);
                                    stmt2.executeUpdate();
                                }
                            }
                        }
                    }
                }
                
                // ============================================================
                // 6. INSERTAR CALENDARIO DE ACTIVIDADES (Página 7)
                // ============================================================
                // Extraer el array de "semestres" del objeto "pagina7"
                String semestresArray = extraerArrayPorClave(pagina7Data, "semestres");
                Map<Integer, Integer> semestreIds = new HashMap<>();
                int semestreCounter = 1; // Contador para saber si es Semestre 1, 2, etc.

                if (semestresArray != null && semestresArray.length() > 2) {
                    // Loop para extraer cada objeto {} del array [] de semestres
                    int posSemestre = 0;
                    while (posSemestre < semestresArray.length()) {
                        int objSemStart = semestresArray.indexOf('{', posSemestre);
                        if (objSemStart < 0) break;
                        int objSemEnd = encontrarCierreBalanceado(semestresArray, objSemStart, '{', '}');
                        if (objSemEnd < 0) break;
                        
                        String semestreJson = semestresArray.substring(objSemStart, objSemEnd + 1);
                        posSemestre = objSemEnd + 1;

                        // Extraer datos del semestre (descripción y meta)
                        String descSemestre = extraerValor(semestreJson, "descripcion_semestre");
                        String metaSemestre = extraerValor(semestreJson, "meta_semestre");

                        // Insertar el semestre en la BD con los datos reales del formulario
                        String sqlSem = "INSERT INTO semestres (descripcion_semestre, meta_semestre) " +
                                       "VALUES (?, ?) " +
                                       "RETURNING id_semestre";
                        
                        Integer idSemestre = null;
                        try (PreparedStatement stmtSem = conn.prepareStatement(sqlSem)) {
                            stmtSem.setString(1, descSemestre.isEmpty() ? "Semestre " + semestreCounter : descSemestre);
                            stmtSem.setString(2, metaSemestre.isEmpty() ? "Meta semestre " + semestreCounter : metaSemestre);
                            
                            ResultSet rsSem = stmtSem.executeQuery();
                            if (rsSem.next()) {
                                idSemestre = rsSem.getInt("id_semestre");
                                semestreIds.put(semestreCounter, idSemestre);
                            }
                        }

                        if (idSemestre == null) {
                            // Si falla la inserción (ej. conflicto), intentar buscarlo
                            String sqlBuscar = "SELECT id_semestre FROM semestres WHERE descripcion_semestre = ?";
                            try (PreparedStatement stmtBuscar = conn.prepareStatement(sqlBuscar)) {
                                stmtBuscar.setString(1, descSemestre.isEmpty() ? "Semestre " + semestreCounter : descSemestre);
                                ResultSet rsBuscar = stmtBuscar.executeQuery();
                                if (rsBuscar.next()) {
                                    idSemestre = rsBuscar.getInt("id_semestre");
                                    semestreIds.put(semestreCounter, idSemestre);
                                }
                            }
                        }
                        
                        // Si tenemos un ID de semestre, procesamos sus actividades
                        if (idSemestre != null) {
                            String actividadesArray = extraerArrayPorClave(semestreJson, "actividades");
                            
                            if (actividadesArray != null && actividadesArray.length() > 2) {
                                // Loop para extraer cada objeto {} del array [] de actividades
                                int posActividad = 0;
                                while (posActividad < actividadesArray.length()) {
                                    int objActStart = actividadesArray.indexOf('{', posActividad);
                                    if (objActStart < 0) break;
                                    int objActEnd = encontrarCierreBalanceado(actividadesArray, objActStart, '{', '}');
                                    if (objActEnd < 0) break;

                                    String actividadJson = actividadesArray.substring(objActStart, objActEnd + 1);
                                    posActividad = objActEnd + 1;

                                    // Extraer el nombre de la actividad
                                    String nombreAct = extraerValor(actividadJson, "nombre");
                                    String entregablesLista = extraerArrayPorClave(actividadJson, "entregables");
                                    
                                    // NOTA: El código actual solo inserta el "nombre" en la columna "entregables".
                                    // La lista de entregables del JSON (ej: ["libros", "tesis"]) se ignora.
                                    // Esto coincide con el comportamiento anterior, pero ahora lee la estructura anidada.

                                    if (nombreAct != null && !nombreAct.isEmpty()) {
                                        // Insertar actividad
                                        String sqlAct = "INSERT INTO actividades (nombre_actividad, entregables) VALUES (?, ?) RETURNING id_actividad";
                                        try (PreparedStatement stmtAct = conn.prepareStatement(sqlAct)) {
                                            stmtAct.setString(1, nombreAct); // El nombre va en la columna 1
                                            stmtAct.setString(2, entregablesLista); // La lista JSON va en la columna 2
                                            ResultSet rsAct = stmtAct.executeQuery();
                                            
                                            if (rsAct.next()) {
                                                int idActividad = rsAct.getInt("id_actividad");
                                                // Relacionar con cronograma
                                                String sqlCrono = "INSERT INTO cronograma_actividades (id_proyecto, id_actividad, id_semestre) VALUES (?, ?, ?)";
                                                try (PreparedStatement stmtCrono = conn.prepareStatement(sqlCrono)) {
                                                    stmtCrono.setInt(1, proyectoId);
                                                    stmtCrono.setInt(2, idActividad);
                                                    stmtCrono.setInt(3, idSemestre);
                                                    stmtCrono.executeUpdate();
                                                }
                                            }
                                        }
                                    }
                                } // Fin loop actividades
                            }
                        }
                        semestreCounter++;
                    } // Fin loop semestres
                }
                
                // ============================================================
                // 7. INSERTAR PRESUPUESTO (Página 8) - (LÓGICA MODIFICADA)
                // ============================================================
                // 'pagina8Data' ahora contiene el ARRAY de partidas [{}, {}, ...]
                int posPartida = 0;
                while (posPartida < pagina8Array.length()) {
                    int objStart = pagina8Array.indexOf('{', posPartida);
                    if (objStart < 0) break;
                    int objEnd = encontrarCierreBalanceado(pagina8Array, objStart, '{', '}');
                    if (objEnd < 0) break;

                    String partidaJson = pagina8Array.substring(objStart, objEnd + 1);
                    posPartida = objEnd + 1;

                    // Extraer datos del JSON de la partida
                    String nombre = extraerValor(partidaJson, "nombre");
                    String justificacion = extraerValor(partidaJson, "justificacion");
                    String montosJson = extraerObjetoPorClave(partidaJson, "montos");

                    double monto_s1 = 0;
                    double monto_s2 = 0;
                    try {
                        String s1 = extraerValor(montosJson, "semestre1");
                        // Usamos la misma limpieza de $ y comas que tenía el código anterior
                        if (!s1.isEmpty())
                            monto_s1 = Double.parseDouble(s1.replace(",", "").replace("$", "").trim());
                        String s2 = extraerValor(montosJson, "semestre2");
                        // Usamos la misma limpieza de $ y comas que tenía el código anterior
                        if (!s2.isEmpty())
                            monto_s2 = Double.parseDouble(s2.replace(",", "").replace("$", "").trim());
                    } catch (Exception e) {
                        // Ignorar errores de conversión (Esto está bien, no es un error de BD)
                    }

                    // Solo insertar si hay nombre Y (justificación o montos)
                    if (!nombre.isEmpty() && (!justificacion.isEmpty() || monto_s1 > 0 || monto_s2 > 0)) {
                        // Insertar partida
                        String sqlPartida = "INSERT INTO partidas (nombre, justificacion) VALUES (?, ?) RETURNING id_partidas";
                        try (PreparedStatement stmt = conn.prepareStatement(sqlPartida)) {
                            stmt.setString(1, nombre);
                            stmt.setString(2, justificacion.isEmpty() ? "Sin justificación" : justificacion);

                            ResultSet rs = stmt.executeQuery();
                            if (rs.next()) {
                                int idPartida = rs.getInt("id_partidas");
                                // Insertar montos para cada semestre
                                for (int sem = 1; sem <= 2; sem++) {
                                    Integer idSemestre = semestreIds.get(sem);
                                    if (idSemestre == null)
                                        continue;
                                    double monto = (sem == 1) ? monto_s1 : monto_s2;
                                    if (monto > 0) {
                                        String sqlSemProj = "INSERT INTO semestres_proyecto (id_semestre, id_proyecto, id_partidas, monto) VALUES (?, ?, ?, ?)";
                                        try (PreparedStatement stmt2 = conn.prepareStatement(sqlSemProj)) {
                                            stmt2.setInt(1, idSemestre);
                                            stmt2.setInt(2, proyectoId);
                                            stmt2.setInt(3, idPartida);
                                            stmt2.setDouble(4, monto);
                                            stmt2.executeUpdate();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // ============================================================
                // 8. RELACIONAR USUARIO CON PROYECTO
                // ============================================================
                String sqlUsuarioProyecto = "INSERT INTO proyecto_usuarios (id_proyecto, id_usuario) VALUES (?, ?)";
                try (PreparedStatement stmt = conn.prepareStatement(sqlUsuarioProyecto)) {
                    stmt.setInt(1, proyectoId);
                    stmt.setInt(2, userId);
                    stmt.executeUpdate();
                }
                
                // Commit de la transacción
                conn.commit();
                exito = true;
                mensaje = "Proyecto registrado exitosamente con ID: " + proyectoId;
                tipoMensaje = "success";
                
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        }
        
    } catch (ClassNotFoundException e) {
        mensaje = "Error: Driver de PostgreSQL no encontrado";
        tipoMensaje = "error";
        e.printStackTrace();
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
                        <a href="<%= request.getContextPath() %>/pages/responsableDeproyecto/proyectos/proyectos.jsp" 
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
