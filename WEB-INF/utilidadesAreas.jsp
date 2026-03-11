<%@ page import="java.util.*" %>
<%!
    // ============================================
    // MAPEO DE ÁREAS DE CONOCIMIENTO
    // ============================================
    // Evaluador usa clasificación SECIHTI (9 áreas)
    // Proyectos usa clasificación CONACYT (9 áreas)
    // Ahora ambos usan la misma clasificación, por lo que el mapeo es 1:1

    // Mapeo: Área de Evaluador (SECIHTI) → Áreas de Proyecto (CONACYT)
    private static final Map<String, List<String>> MAPEO_AREAS = new HashMap<>();

    // Mapeo de texto legible a clave técnica
    private static final Map<String, String> AREA_TEXTO_A_CLAVE = new HashMap<>();

    static {
        // Ahora es mapeo directo (1:1) ya que ambos usan la misma clasificación
        MAPEO_AREAS.put("fisicoMatematicas", Arrays.asList("fisicoMatematicas"));
        MAPEO_AREAS.put("biologiaQuimica", Arrays.asList("biologiaQuimica"));
        MAPEO_AREAS.put("medicinaCienciasSalud", Arrays.asList("medicinaCienciasSalud"));
        MAPEO_AREAS.put("cienciasConductaEducacion", Arrays.asList("cienciasConductaEducacion"));
        MAPEO_AREAS.put("humanidades", Arrays.asList("humanidades"));
        MAPEO_AREAS.put("cienciasSociales", Arrays.asList("cienciasSociales"));
        MAPEO_AREAS.put("cienciasAgricultura", Arrays.asList("cienciasAgricultura"));
        MAPEO_AREAS.put("ingenieriasDesarrollo", Arrays.asList("ingenieriasDesarrollo"));
        MAPEO_AREAS.put("interdisciplinaria", Arrays.asList("interdisciplinaria"));
        
        // Inicializar mapeo de texto legible a clave técnica
        // Áreas CONACYT (proyectos)
        AREA_TEXTO_A_CLAVE.put("i - físico-matemáticas y ciencias de la tierra", "fisicoMatematicas");
        AREA_TEXTO_A_CLAVE.put("ii - biología y química", "biologiaQuimica");
        AREA_TEXTO_A_CLAVE.put("iii - medicina y ciencias de la salud", "medicinaCienciasSalud");
        AREA_TEXTO_A_CLAVE.put("iv - ciencias de la conducta y la educación", "cienciasConductaEducacion");
        AREA_TEXTO_A_CLAVE.put("v - humanidades", "humanidades");
        AREA_TEXTO_A_CLAVE.put("vi - ciencias sociales", "cienciasSociales");
        AREA_TEXTO_A_CLAVE.put("vii - ciencias de agricultura, agropecuarias, forestales y de ecosistemas", "cienciasAgricultura");
        AREA_TEXTO_A_CLAVE.put("viii - ingenierías y desarrollo tecnológico", "ingenieriasDesarrollo");
        AREA_TEXTO_A_CLAVE.put("ix - interdisciplinaria", "interdisciplinaria");
        // También aceptar sin números romanos
        AREA_TEXTO_A_CLAVE.put("físico-matemáticas y ciencias de la tierra", "fisicoMatematicas");
        AREA_TEXTO_A_CLAVE.put("biología y química", "biologiaQuimica");
        AREA_TEXTO_A_CLAVE.put("medicina y ciencias de la salud", "medicinaCienciasSalud");
        AREA_TEXTO_A_CLAVE.put("ciencias de la conducta y la educación", "cienciasConductaEducacion");
        AREA_TEXTO_A_CLAVE.put("ciencias sociales", "cienciasSociales");
        AREA_TEXTO_A_CLAVE.put("ciencias de agricultura, agropecuarias, forestales y de ecosistemas", "cienciasAgricultura");
        AREA_TEXTO_A_CLAVE.put("ingenierías y desarrollo tecnológico", "ingenieriasDesarrollo");
        // Áreas SECIHTI (evaluadores)
        AREA_TEXTO_A_CLAVE.put("ciencias naturales", "naturales");
        AREA_TEXTO_A_CLAVE.put("ingeniería y tecnología", "ingenieria");
        AREA_TEXTO_A_CLAVE.put("ciencias médicas y de la salud", "medicas");
        AREA_TEXTO_A_CLAVE.put("ciencias agrícolas", "agricolas");
        AREA_TEXTO_A_CLAVE.put("interdisciplinaria / multidisciplinaria", "interdisciplinaria");
    }
    
    /**
     * Normaliza un área: convierte texto legible a clave técnica
     */
    private String normalizarArea(String area) {
        if (area == null) return null;
        
        String areaTrim = area.trim();
        
        // Primero verificar si es una clave técnica (respetando camelCase)
        if (MAPEO_AREAS.containsKey(areaTrim)) {
            return areaTrim;
        }
        
        // Verificar si es un valor de área de proyecto (clave técnica en los valores)
        for (List<String> valores : MAPEO_AREAS.values()) {
            if (valores.contains(areaTrim)) {
                return areaTrim;
            }
        }
        
        // Si no es clave técnica, normalizar a minúsculas para buscar en mapeo de texto
        String areaLower = areaTrim.toLowerCase();
        
        // Buscar en el mapeo de texto a clave
        return AREA_TEXTO_A_CLAVE.getOrDefault(areaLower, areaTrim);
    }

    /**
     * Verifica si un área de evaluador es compatible con un área de proyecto
     * @param areaEvaluador Área del evaluador (clasificación SECIHTI)
     * @param areaProyecto Área del proyecto (clasificación CONACYT)
     * @return true si son compatibles, false en caso contrario
     */
    public boolean esAreaCompatible(String areaEvaluador, String areaProyecto) {
        if (areaEvaluador == null || areaProyecto == null) return false;

        // Normalizar áreas
        areaEvaluador = normalizarArea(areaEvaluador);
        areaProyecto = normalizarArea(areaProyecto);

        List<String> areasCompatibles = MAPEO_AREAS.get(areaEvaluador);
        if (areasCompatibles == null) return false;

        return areasCompatibles.contains(areaProyecto);
    }
    
    /**
     * Obtiene todas las áreas de proyecto compatibles con un evaluador
     * @param areaEvaluador Área del evaluador (clasificación SECIHTI)
     * @return Lista de áreas de proyecto compatibles
     */
    public List<String> obtenerAreasProyectoCompatibles(String areaEvaluador) {
        if (areaEvaluador == null) return new ArrayList<>();
        return new ArrayList<>(MAPEO_AREAS.getOrDefault(areaEvaluador.toLowerCase().trim(), new ArrayList<>()));
    }
    
    // ============================================
    // MAPEO INVERSO
    // ============================================
    // Mapeo: Área de Proyecto (CONACYT) → Área de Evaluador (SECIHTI)
    private static final Map<String, String> MAPEO_INVERSO = new HashMap<>();
    
    static {
        MAPEO_INVERSO.put("fisicoMatematicas", "naturales");
        MAPEO_INVERSO.put("biologiaQuimica", "naturales");
        MAPEO_INVERSO.put("ingenieriasDesarrollo", "ingenieria");
        MAPEO_INVERSO.put("medicinaCienciasSalud", "medicas");
        MAPEO_INVERSO.put("cienciasAgricultura", "agricolas");
        MAPEO_INVERSO.put("cienciasSociales", "sociales");
        MAPEO_INVERSO.put("cienciasConductaEducacion", "sociales");
        MAPEO_INVERSO.put("humanidades", "humanidades");
        MAPEO_INVERSO.put("interdisciplinaria", "interdisciplinaria");
    }
    
    /**
     * Obtiene el área de evaluador equivalente desde un área de proyecto
     * @param areaProyecto Área del proyecto (clasificación CONACYT)
     * @return Área de evaluador equivalente o null si no hay equivalencia
     */
    public String obtenerAreaEvaluadorDesdeProyecto(String areaProyecto) {
        if (areaProyecto == null) return null;
        return MAPEO_INVERSO.get(areaProyecto.toLowerCase().trim());
    }
    
    /**
     * Obtiene el área de proyecto equivalente desde un área de evaluador
     * (devuelve la primera área compatible encontrada)
     * @param areaEvaluador Área del evaluador (clasificación SECIHTI)
     * @return Primera área de proyecto equivalente o null
     */
    public String obtenerAreaProyectoDesdeEvaluador(String areaEvaluador) {
        if (areaEvaluador == null) return null;
        List<String> compatibles = MAPEO_AREAS.get(areaEvaluador.toLowerCase().trim());
        if (compatibles == null || compatibles.isEmpty()) return null;
        return compatibles.get(0);
    }
    
    /**
     * Obtiene la descripción legible de un área de evaluador
     */
    public String obtenerDescripcionAreaEvaluador(String area) {
        if (area == null) return "Área no especificada";

        Map<String, String> descripciones = new HashMap<>();
        descripciones.put("fisicoMatematicas", "I - Físico-Matemáticas y Ciencias de la Tierra");
        descripciones.put("biologiaQuimica", "II - Biología y Química");
        descripciones.put("medicinaCienciasSalud", "III - Medicina y Ciencias de la Salud");
        descripciones.put("cienciasConductaEducacion", "IV - Ciencias de la Conducta y la Educación");
        descripciones.put("humanidades", "V - Humanidades");
        descripciones.put("cienciasSociales", "VI - Ciencias Sociales");
        descripciones.put("cienciasAgricultura", "VII - Ciencias de Agricultura, Agropecuarias, Forestales y de Ecosistemas");
        descripciones.put("ingenieriasDesarrollo", "VIII - Ingenierías y Desarrollo Tecnológico");
        descripciones.put("interdisciplinaria", "IX - Interdisciplinaria");

        return descripciones.getOrDefault(area.toLowerCase().trim(), area);
    }
    
    /**
     * Obtiene la descripción legible de un área de proyecto
     */
    public String obtenerDescripcionAreaProyecto(String area) {
        if (area == null) return "Área no especificada";

        String areaTrim = area.trim();
        String areaLower = areaTrim.toLowerCase();

        Map<String, String> descripciones = new HashMap<>();
        descripciones.put("fisicoMatematicas", "I - Físico-Matemáticas y Ciencias de la Tierra");
        descripciones.put("biologiaQuimica", "II - Biología y Química");
        descripciones.put("medicinaCienciasSalud", "III - Medicina y Ciencias de la Salud");
        descripciones.put("cienciasConductaEducacion", "IV - Ciencias de la Conducta y la Educación");
        descripciones.put("humanidades", "V - Humanidades");
        descripciones.put("cienciasSociales", "VI - Ciencias Sociales");
        descripciones.put("cienciasAgricultura", "VII - Ciencias de Agricultura, Agropecuarias, Forestales y de Ecosistemas");
        descripciones.put("ingenieriasDesarrollo", "VIII - Ingenierías y Desarrollo Tecnológico");
        descripciones.put("interdisciplinaria", "IX - Interdisciplinaria");

        // Buscar por clave técnica (case-insensitive)
        for (Map.Entry<String, String> entry : descripciones.entrySet()) {
            if (entry.getKey().equalsIgnoreCase(areaTrim)) {
                return entry.getValue();
            }
        }

        // Si ya es una descripción legible, retornarla tal cual
        for (String desc : descripciones.values()) {
            if (desc.equalsIgnoreCase(areaTrim)) {
                return desc;
            }
        }

        // No se encontró coincidencia, retornar el valor original
        return areaTrim;
    }
%>
