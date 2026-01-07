<% if (!"responsable".equals(String.valueOf(session.getAttribute("rol")))) { String n=request.getRequestURI()+(request.getQueryString()!=null?("?"+request.getQueryString()):""); response.sendRedirect(request.getContextPath()+"/pages/login/login.jsp?next="+java.net.URLEncoder.encode(n,"UTF-8")); return; } %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    // CORRECCIÓN 1: Usar el nombre correcto de la variable de sesión
    Integer userId = (Integer) session.getAttribute("id_usuario");
    
    // Variables para las estadísticas
    int proyectosActivos = 0;
    int proyectosCompletados = 0;
    int proyectosEnProgreso = 0;
    
    if (userId != null) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            // Configuración de la conexión
            String url = "jdbc:postgresql://localhost:5432/proyectos";
            String username = "dbusr25";
            String password = "mxToro24000Chocolate";
            
            Class.forName("org.postgresql.Driver");
            conn = DriverManager.getConnection(url, username, password);
            
            // CORRECCIÓN 2: Usar INNER JOIN para vincular proyectos con el usuario correctamente
            String sql = "SELECT p.estado_proyecto, COUNT(*) as total " +
                         "FROM proyectos p " +
                         "INNER JOIN proyecto_usuarios pu ON p.id_proyecto = pu.id_proyecto " +
                         "WHERE pu.id_usuario = ? " +
                         "GROUP BY p.estado_proyecto";
                         
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                String estado = rs.getString("estado_proyecto");
                if (estado == null) continue;
                
                int total = rs.getInt("total");
                String estadoMin = estado.toLowerCase();
                
                // CORRECCIÓN 3: Mapeo completo de estados basado en proyectos.jsp
                switch (estadoMin) {
                    // ACTIVO: Trámites en curso, validaciones, evaluaciones
                    case "enviado":
                    case "validado":
                    case "en_evaluacion_externa":
                    case "en_evaluacion_interna":
                    case "aprobado":
                    case "convenio":
                    case "facturacion":
                    case "ministracion":
                    case "seguimiento":
                    case "reporte_semestral":
                    case "auditoria":
                    case "comite_tecnico":
                        proyectosActivos += total;
                        break;
                        
                    // COMPLETADO: Finalizados o cerrados
                    case "finalizado":
                    case "acta_conclusion":
                    case "entregado": // Por si acaso
                        proyectosCompletados += total;
                        break;
                        
                    // EN PROGRESO: Etapas tempranas o correcciones
                    case "borrador":
                    case "en_revision":
                    case "recalendarizacion":
                    case "rechazado": // Podrías querer contarlo aparte
                        proyectosEnProgreso += total;
                        break;
                        
                    default:
                        // Por defecto a progreso si es desconocido
                        proyectosEnProgreso += total;
                        break;
                }
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (ps != null) try { ps.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <script src="https://cdn.tailwindcss.com"></script>
  <title>COVEICYDET - Página Principal</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');
    
    body {
      font-family: 'Inter', sans-serif;
      background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
    }
    
    .hero-pattern {
      background-color: #7A1737;
      background-image: radial-gradient(#B28854 0.5px, transparent 0.5px), radial-gradient(#B28854 0.5px, #7A1737 0.5px);
      background-size: 20px 20px;
      background-position: 0 0, 10px 10px;
    }
    
    .card-hover {
      transition: all 0.3s ease;
    }
    
    .card-hover:hover {
      transform: translateY(-5px);
      box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
    }

    .download-btn {
        background: linear-gradient(135deg, #7A1737 0%, #B28854 100%);
        transition: all 0.3s ease;
    }
  </style>
</head>
<body class="min-h-screen flex flex-col">
  <%@ include file="../header.jsp" %>
  
  <!-- Hero Section -->
  <section class="hero-pattern text-white py-16">
    <div class="container mx-auto px-4 text-center">
      <h1 class="text-4xl md:text-5xl font-bold mb-6">Bienvenido a COVEICYDET</h1>
      <p class="text-xl md:text-2xl mb-8 max-w-3xl mx-auto">Sistema de Registro y Gestión de Proyectos de Investigación</p>
    </div>
  </section>

  <!-- Acciones principales -->
  <div class="bg-white rounded-xl shadow-lg p-8 mb-12">
    <h2 class="text-2xl font-bold mb-6 text-gray-800">Acciones Rápidas</h2>
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
      <a href="/proyectos/pages/responsableDeproyecto/registroProyecto/registroProyecto.jsp" class="bg-gradient-to-r from-[#B28854] to-[#7A1737] text-white p-6 rounded-lg shadow-md hover:shadow-lg transition duration-300 flex items-center">
        <svg class="w-8 h-8 mr-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
        </svg>
        <div>
          <h3 id="tituloNuevoProyecto" class="text-xl font-semibold">Nuevo Proyecto</h3>
          <p id="descNuevoProyecto">Registrar un nuevo proyecto de investigación</p>
        </div>
      </a>
      
      <a href="/proyectos/pages/responsableDeproyecto/proyectos/" class="bg-gradient-to-r from-[#7A1737] to-[#A8253C] text-white p-6 rounded-lg shadow-md hover:shadow-lg transition duration-300 flex items-center">
        <svg class="w-8 h-8 mr-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
        </svg>
        <div>
          <h3 class="text-xl font-semibold">Ver Proyectos</h3>
          <p>Consultar todos tus proyectos registrados</p>
        </div>
      </a>

      <a href="/proyectos/plantillas/EjemploDocCOVEICYDET.docx" download
         class="download-btn text-white font-bold py-5 px-10 rounded-xl inline-flex items-center justify-center text-lg transition-all duration-300 md:col-span-2 mx-auto">
          <i class="fas fa-download mr-3 text-xl"></i>
          <span>Descargar Plantilla Oficial</span>
      </a>
    </div>
  </div>

  

  <!-- Contenido principal -->
  <main class="flex-grow py-12">
    <div class="container mx-auto px-4">
      <!-- Estadísticas rápidas -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-12 max-w-4xl mx-auto">
        <div class="bg-white rounded-xl p-6 shadow-lg text-center card-hover">
          <div class="bg-blue-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
            <svg class="w-8 h-8 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v10a2 2 0 002 2h8a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"></path>
            </svg>
          </div>
          <h3 class="text-xl font-semibold mb-2">Proyectos Activos</h3>
          <p class="text-3xl font-bold text-gray-800"><%= proyectosActivos %></p>
          <p class="text-sm text-gray-500 mt-1">Enviados/Aprobados</p>
        </div>
        
        <div class="bg-white rounded-xl p-6 shadow-lg text-center card-hover">
          <div class="bg-green-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
            <svg class="w-8 h-8 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
            </svg>
          </div>
          <h3 class="text-xl font-semibold mb-2">Completados</h3>
          <p class="text-3xl font-bold text-gray-800"><%= proyectosCompletados %></p>
          <p class="text-sm text-gray-500 mt-1">Finalizados</p>
        </div>
        
        <div class="bg-white rounded-xl p-6 shadow-lg text-center card-hover">
          <div class="bg-purple-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
            <svg class="w-8 h-8 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
            </svg>
          </div>
          <h3 class="text-xl font-semibold mb-2">En Progreso</h3>
          <p class="text-3xl font-bold text-gray-800"><%= proyectosEnProgreso %></p>
          <p class="text-sm text-gray-500 mt-1">En revisión/desarrollo</p>
        </div>
        
        
      </div>

      <!-- Notificaciones importantes -->
      <div class="bg-white rounded-xl shadow-lg p-8 mb-12">
        <h2 class="text-2xl font-bold mb-6 text-gray-800">Notificaciones</h2>
        <div class="space-y-4">


          <% if (proyectosEnProgreso > 0) { %>
          <!-- Proyectos en progreso -->
          <div class="bg-blue-100 border-l-4 border-blue-500 text-blue-700 p-4 rounded-r-lg" role="alert">
            <p class="font-bold">Información</p>
            <p><%= proyectosEnProgreso == 1 ? "Tienes 1 proyecto en" : "Tienes " + proyectosEnProgreso + " proyectos en" %> proceso de revisión.</p>
          </div>
          <% } %>

          <!-- Notificación general sobre convocatoria -->
          <div class="bg-green-100 border-l-4 border-green-500 text-green-700 p-4 rounded-r-lg" role="alert">
            <p class="font-bold">Convocatoria Abierta</p>
            <p>La convocatoria 2025 está abierta hasta el 31 de Diciembre de 2024.</p>
          </div>
        </div>
      </div>

      

      <!-- Información adicional -->
      <div class="bg-gradient-to-r from-[#EDD1AA] to-[#f8fafc] rounded-xl shadow-lg p-8">
        <h2 class="text-2xl font-bold mb-6 text-gray-800">Información Importante</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
          <div>
            <h3 class="text-xl font-semibold mb-4 text-[#7A1737]">Próximos Eventos</h3>
            <ul class="space-y-3">
              <li class="flex items-start">
                <span class="bg-[#B28854] text-white rounded-full w-6 h-6 flex items-center justify-center mr-3 mt-1">•</span>
                <span>Reunión de avances - 25 de Noviembre</span>
              </li>
              <li class="flex items-start">
                <span class="bg-[#B28854] text-white rounded-full w-6 h-6 flex items-center justify-center mr-3 mt-1">•</span>
                <span>Taller de metodología - 30 de Noviembre</span>
              </li>
              <li class="flex items-start">
                <span class="bg-[#B28854] text-white rounded-full w-6 h-6 flex items-center justify-center mr-3 mt-1">•</span>
                <span>Entrega de reportes - 15 de Diciembre</span>
              </li>
            </ul>
          </div>
          
          <div>
            <h3 class="text-xl font-semibold mb-4 text-[#7A1737]">Noticias Recientes</h3>
            <ul class="space-y-3">
              <li class="flex items-start">
                <span class="bg-[#A8253C] text-white rounded-full w-6 h-6 flex items-center justify-center mr-3 mt-1">•</span>
                <span>Nueva convocatoria 2025 abierta</span>
              </li>
              <li class="flex items-start">
                <span class="bg-[#A8253C] text-white rounded-full w-6 h-6 flex items-center justify-center mr-3 mt-1">•</span>
                <span>Actualización del sistema de registro</span>
              </li>
              <li class="flex items-start">
                <span class="bg-[#A8253C] text-white rounded-full w-6 h-6 flex items-center justify-center mr-3 mt-1">•</span>
                <span>Capacitación para nuevos usuarios</span>
              </li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  </main>
  
  <%@ include file="/footer.jsp" %>

  <script>
    document.addEventListener('DOMContentLoaded', function() {
      // Verificar si existen borradores en localStorage
      const draftKeys = [
        'proyecto_borrador_pagina1',
        'proyecto_borrador_pagina2',
        'proyecto_borrador_pagina3',
        'proyecto_borrador_pagina4',
        'proyecto_borrador_pagina5',
        'proyecto_borrador_pagina6',
        'proyecto_borrador_pagina7',
        'proyecto_borrador_pagina8',
        'proyecto_borrador_pagina9'
      ];

      let hasDraft = false;
      for (const key of draftKeys) {
        if (localStorage.getItem(key)) {
          hasDraft = true;
          break;
        }
      }

      if (hasDraft) {
        const btnTitle = document.getElementById('tituloNuevoProyecto');
        const btnDesc = document.getElementById('descNuevoProyecto');
        
        if (btnTitle) btnTitle.textContent = 'Tienes un proyecto pendiente en enviar';
        if (btnDesc) btnDesc.textContent = 'Continuar con el registro de tu proyecto';
      }
    });
  </script>
</body>
</html>