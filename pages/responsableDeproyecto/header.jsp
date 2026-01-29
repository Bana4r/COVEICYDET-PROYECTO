<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
  // --- BLOQUE 1: OBTENCIÓN DE DATOS DE USUARIO ---
  // (Esto reemplaza al código de logout que tenías por error)
    
  String primerNombre = "";
  boolean hasProject = false;
    
  // Recuperar datos de la sesión
  String nombreCompleto = (String) session.getAttribute("nombre");
  Integer idUsuarioHeader = (Integer) session.getAttribute("id_usuario");
  String rolHeader = (String) session.getAttribute("rol");

  // 1. Calcular el primer nombre para el saludo
  if (nombreCompleto != null && !nombreCompleto.isEmpty()) {
    String[] partes = nombreCompleto.split(" ");
    if (partes.length > 0) {
      primerNombre = partes[0];
    }
  }

  // 2. Verificar si el usuario ya tiene un proyecto (para la variable hasProject)
  // Solo verificamos si hay usuario logueado
  if (idUsuarioHeader != null) {
    { // Bloque para evitar conflictos de variables
      Connection connHeader = null;
      String dbErrorHeader = "";
      try {
          Class.forName("org.postgresql.Driver");
          
          java.util.Properties props = new java.util.Properties();
          // Usamos getRealPath para leer el archivo físicamente, asegurando que los cambios se detecten al instante
          // Ajustamos la ruta para buscar en WEB-INF/classes/db.properties donde lo movimos
          String path = application.getRealPath("/WEB-INF/classes/db.properties");
          
          if (path != null && new java.io.File(path).exists()) {
              java.io.FileInputStream fis = new java.io.FileInputStream(path);
              props.load(fis);
              fis.close();
          } else {
              // Intento alternativo por si getRealPath falla
              java.io.InputStream is = this.getClass().getResourceAsStream("/db.properties");
              if (is != null) {
                  props.load(is);
              } else {
                  throw new Exception("No se encontró el archivo db.properties");
              }
          }

          connHeader = DriverManager.getConnection(
              props.getProperty("db.url"),
              props.getProperty("db.user"),
              props.getProperty("db.pass")
          );

      } catch (Exception e) {
          dbErrorHeader = "Error de conexión en header: " + e.getMessage();
          System.err.println(dbErrorHeader);
          e.printStackTrace();
      }

      if (connHeader != null) {
        try {
          // Obtener el último proyecto y datos de convocatoria en una sola consulta
          String sqlHeader = "SELECT p.estado_proyecto, p.convocatoria_id, " +
                             "(SELECT COUNT(*) FROM convocatoria WHERE estado = 2) as hay_activa, " +
                             "(SELECT COUNT(*) FROM convocatoria WHERE estado = 2 AND id_convocatoria = p.convocatoria_id) as es_misma_activa " +
                             "FROM proyectos p " +
                             "JOIN proyecto_usuarios pu ON p.id_proyecto = pu.id_proyecto " +
                             "WHERE pu.id_usuario = ? ORDER BY p.id_proyecto DESC LIMIT 1"; 
          PreparedStatement psHeader = connHeader.prepareStatement(sqlHeader);
          psHeader.setInt(1, idUsuarioHeader);
          ResultSet rsHeader = psHeader.executeQuery();
          
          if (rsHeader.next()) {
            String estado = rsHeader.getString("estado_proyecto");
            int hayActiva = rsHeader.getInt("hay_activa");
            int esMismaActiva = rsHeader.getInt("es_misma_activa");
            
            if (estado != null) estado = estado.trim();
            
            if ("7".equals(estado)) {
                // Cancelado (7) -> Puede registrar nuevo
                hasProject = false;
            } else if (!"5".equals(estado)) {
                // Proyecto en curso (1,2,3,4,6) -> No puede registrar
                hasProject = true;
            } else {
                // Finalizado (5)
                if (hayActiva == 0) {
                    // No hay convocatorias activas -> No puede registrar (esperar nueva)
                    hasProject = true;
                } else if (esMismaActiva > 0) {
                    // La convocatoria activa es la MISMA del proyecto -> No puede registrar (ya cumplió)
                    hasProject = true;
                } else {
                    // Hay convocatoria activa y es DIFERENTE -> Puede registrar
                    hasProject = false;
                }
            }
          } else {
            // No tiene proyectos previos -> Puede registrar
            hasProject = false;
          }
                
          rsHeader.close();
          psHeader.close();
        } catch (Exception e) {
          System.out.println("Error en header verificando proyecto: " + e.getMessage());
          // Por seguridad en caso de error
          hasProject = false; 
        } finally {
          if (connHeader != null) {
            try { connHeader.close(); } catch (SQLException ex) {}
          }
        }
      }
    }
  }
%>
<header class="bg-gradient-to-r from-[#7A1737] to-[#9A4560] text-white shadow-lg">
  <div class="container mx-auto px-6 py-4">
    <!-- Primera fila: Título y usuario -->
    <div class="flex justify-between items-center mb-3">
      <div class="flex items-center gap-4">
        <div class="w-2 h-10 bg-[#B28854] rounded-full"></div>
        <div>
          <h1 class="text-2xl font-bold">Registro de Proyectos COVEICYDET</h1>
          <% if (!primerNombre.isEmpty()) { %>
            <p class="text-sm text-gray-200 mt-1 flex items-center gap-1">
              <span class="w-2 h-2 bg-green-400 rounded-full"></span>
              Hola, <span class="font-semibold text-white"><%= primerNombre %></span>
            </p>
          <% } %>
        </div>
      </div>
      
      <div class="flex items-center gap-4">
        <div class="text-right">
          <div class="text-lg text-gray-200 font-semibold">Sesión activa</div>
          <div class="text-xl font-bold text-white">Usuario</div>
        </div>
        <a href="<%= request.getContextPath() %>/pages/login/logout.jsp" 
          class="bg-[#B28854] hover:bg-[#A87844] text-white px-4 py-2 rounded-lg font-semibold transition-all duration-300 flex items-center gap-2 shadow-md hover:shadow-lg">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path>
          </svg>
          Cerrar Sesión
        </a>
      </div>
    </div>

    <!-- Segunda fila: Navegación -->
    <nav class="bg-white/10 backdrop-blur-sm rounded-xl p-3 border border-white/20">
      <div class="flex items-center justify-center gap-8">
        <a class="flex items-center gap-2 px-4 py-2 rounded-lg hover:bg-white/20 transition-all duration-300 font-medium text-lg" 
           href="/proyectos/pages/responsableDeproyecto/paginaPrincipal/">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"></path>
          </svg>
          Inicio
        </a>
        
        <div class="w-1 h-6 bg-white/30 rounded-full"></div>
        
        <% if (hasProject) { %>
            <a class="flex items-center gap-2 px-4 py-2 rounded-lg font-medium text-lg 
                      opacity-50 cursor-not-allowed"
               href="#" 
               onclick="alert('Ya tienes un proyecto registrado. No puedes registrar uno nuevo.'); return false;">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                 <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
              </svg>
              Registro de Proyecto
            </a>
        <% } else { %>
            <a class="flex items-center gap-2 px-4 py-2 rounded-lg hover:bg-white/20 transition-all duration-300 font-medium text-lg" 
               href="/proyectos/pages/responsableDeproyecto/registroProyecto/registroProyecto.jsp">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                 <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
              </svg>
              Registro de Proyecto
            </a>
        <% } %>
        
        <div class="w-1 h-6 bg-white/30 rounded-full"></div>
        
        <a class="flex items-center gap-2 px-4 py-2 rounded-lg hover:bg-white/20 transition-all duration-300 font-medium text-lg" 
           href="/proyectos/pages/responsableDeproyecto/proyectos/">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
          </svg>
          Consultar Proyectos
        </a>
      </div>
    </nav>

    <!-- Línea decorativa inferior -->
    <div class="mt-3 h-1 bg-gradient-to-r from-transparent via-[#B28854] to-transparent rounded-full"></div>
  </div>
</header>