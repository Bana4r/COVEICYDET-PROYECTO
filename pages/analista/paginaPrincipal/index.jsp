<% if (!"analista".equals(String.valueOf(session.getAttribute("rol")))) { String n=request.getRequestURI()+(request.getQueryString()!=null?("?"+request.getQueryString()):""); response.sendRedirect(request.getContextPath()+"/pages/login/login.jsp?next="+java.net.URLEncoder.encode(n,"UTF-8")); return; } %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    // Variables para las estadísticas (analista ve todos los proyectos del sistema)
    int proyectosActivos = 0;
    int proyectosCompletados = 0;
    int proyectosEnProgreso = 0;
    int proyectosEnBorrador = 0;
    
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        // Configuración de la conexión a PostgreSQL
        String url = "jdbc:postgresql://localhost:5432/proyectos";
        String username = "dbusr25";
        String password = "mxToro24000Chocolate";
        
        Class.forName("org.postgresql.Driver");
        conn = DriverManager.getConnection(url, username, password);
        
        // Consulta para todos los proyectos del sistema (sin filtro de usuario)
        String sql = "SELECT estado_proyecto, COUNT(*) as total FROM proyectos GROUP BY estado_proyecto";
        ps = conn.prepareStatement(sql);
        rs = ps.executeQuery();
            
        while (rs.next()) {
            String estado = rs.getString("estado_proyecto");
            int total = rs.getInt("total");
            
            if ("enviado".equals(estado) || "aprobado".equals(estado)) {
                proyectosActivos += total;
            } else if ("completado".equals(estado) || "finalizado".equals(estado)) {
                proyectosCompletados += total;
            } else if ("en_revision".equals(estado) || "en_desarrollo".equals(estado)) {
                proyectosEnProgreso += total;
            } else if ("borrador".equals(estado)) {
                proyectosEnBorrador += total;
            }
        }
            
    } catch (Exception e) {
        e.printStackTrace();
        // En caso de error, mantener los valores en 0
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (ps != null) try { ps.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
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
  </style>
</head>
<body class="min-h-screen flex flex-col">
  <%@ include file="../header.jsp" %>
  
  <!-- Hero Section -->
  <section class="hero-pattern text-white py-16">
    <div class="container mx-auto px-4 text-center">
      <h1 class="text-4xl md:text-5xl font-bold mb-6">Panel de Analista - COVEICYDET</h1>
      <p class="text-xl md:text-2xl mb-8 max-w-3xl mx-auto">Sistema de Análisis y Gestión de Proyectos de Investigación</p>
      <div class="bg-white/20 backdrop-blur-sm rounded-lg p-6 inline-block">
        <p class="text-lg">Analiza y supervisa todos los proyectos del sistema</p>
      </div>
    </div>
  </section>

  <!-- Contenido principal -->
  <main class="flex-grow py-12">
    <div class="container mx-auto px-4">
      <!-- Acciones principales -->
      <div class="bg-white rounded-xl shadow-lg p-8 mb-12">
        <h2 class="text-2xl font-bold mb-6 text-gray-800">Acciones Rápidas</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <a href="/proyectos/pages/analista/proyectos/" class="bg-gradient-to-r from-[#7A1737] to-[#A8253C] text-white p-6 rounded-lg shadow-md hover:shadow-lg transition duration-300 flex items-center">
            <svg class="w-8 h-8 mr-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
            </svg>
            <div>
              <h3 class="text-xl font-semibold">Ver Todos los Proyectos</h3>
              <p>Consultar todos los proyectos del sistema</p>
            </div>
          </a>
          
          <a href="/proyectos/pages/analista/usuarios/" class="bg-gradient-to-r from-[#B28854] to-[#7A1737] text-white p-6 rounded-lg shadow-md hover:shadow-lg transition duration-300 flex items-center">
            <svg class="w-8 h-8 mr-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.25 2.25 0 11-4.5 0 2.25 2.25 0 014.5 0z"></path>
            </svg>
            <div>
              <h3 class="text-xl font-semibold">Ver Usuarios</h3>
              <p>Directorio de responsables de proyecto</p>
            </div>
          </a>
        </div>
      </div>
      
      <!-- Estadísticas rápidas -->
      <!--<div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-12 max-w-4xl mx-auto">
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
        </div>-->
        
        
      </div>

      <!-- Gestión de notificaciones
      <div class="bg-white rounded-xl shadow-lg p-8 mb-12">
        <div class="flex justify-between items-center mb-6">
          <h2 class="text-2xl font-bold text-gray-800">Gestión de Notificaciones</h2>
          <button onclick="openNotificationModal()" 
                  class="bg-gradient-to-r from-[#7A1737] to-[#A8253C] hover:from-[#A8253C] hover:to-[#7A1737] text-white px-6 py-3 rounded-lg font-semibold transition duration-300 flex items-center shadow-lg">
            <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
            </svg>
            Publicar Notificación
          </button>
        </div> -->
        
        <!-- Lista de notificaciones existentes (placeholder)
        <div class="space-y-4">
          <div class="bg-gray-50 border-l-4 border-gray-400 text-gray-700 p-4 rounded-r-lg" role="alert">
            <p class="font-medium text-gray-500">No hay notificaciones publicadas</p>
            <p class="text-sm text-gray-400 mt-1">Las notificaciones que publiques aparecerán aquí para todos los usuarios del sistema.</p>
          </div>
        </div>
      </div>-->



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
  
  <!-- Modal para publicar notificación -->
  <div id="notificationModal" class="hidden fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
    <div class="relative top-20 mx-auto p-5 border w-11/12 max-w-md shadow-lg rounded-md bg-white">
      <!-- Encabezado del modal -->
      <div class="flex items-center justify-between pb-3 border-b border-gray-200">
        <h3 class="text-lg font-bold text-gray-900">Publicar Nueva Notificación</h3>
        <button onclick="closeNotificationModal()" class="text-gray-400 hover:text-gray-600">
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
          </svg>
        </button>
      </div>
      
      <!-- Contenido del modal -->
      <div class="mt-4">
        <form id="notificationForm">
          <!-- Tipo de notificación -->
          <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-2">Tipo de Notificación</label>
            <select id="notificationType" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#7A1737] focus:border-transparent">
              <option value="informativa">📢 Informativa</option>
              <option value="atencion">⚠️ Atención</option>
              <option value="urgente">🚨 Urgente</option>
            </select>
          </div>
          
          <!-- Mensaje -->
          <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-2">Mensaje</label>
            <textarea id="notificationMessage" 
                      placeholder="Escribe aquí el mensaje de la notificación..."
                      class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#7A1737] focus:border-transparent"
                      rows="4"></textarea>
          </div>
          
          <!-- Vista previa -->
          <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-2">Vista Previa</label>
            <div id="notificationPreview" class="p-3 rounded-r-lg border-l-4 bg-blue-50 border-blue-500 text-blue-700">
              <p class="font-bold">📢 Información</p>
              <p class="text-sm">El mensaje aparecerá aquí...</p>
            </div>
          </div>
          
          <!-- Botones -->
          <div class="flex justify-end space-x-3 pt-4">
            <button type="button" onclick="closeNotificationModal()" 
                    class="px-4 py-2 bg-gray-300 text-gray-700 rounded-md hover:bg-gray-400 transition duration-200">
              Cancelar
            </button>
            <button type="button" onclick="publishNotification()" 
                    class="px-4 py-2 bg-gradient-to-r from-[#7A1737] to-[#A8253C] text-white rounded-md hover:from-[#A8253C] hover:to-[#7A1737] transition duration-200">
              Publicar
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>

  <%@ include file="/footer.jsp" %>
  
  <script>
    // Funciones para el modal de notificaciones
    function openNotificationModal() {
      document.getElementById('notificationModal').classList.remove('hidden');
      updatePreview(); // Actualizar vista previa al abrir
    }
    
    function closeNotificationModal() {
      document.getElementById('notificationModal').classList.add('hidden');
      // Limpiar formulario
      document.getElementById('notificationForm').reset();
      document.getElementById('notificationType').value = 'informativa';
      updatePreview();
    }
    
    function updatePreview() {
      const type = document.getElementById('notificationType').value;
      const message = document.getElementById('notificationMessage').value || 'El mensaje aparecerá aquí...';
      const preview = document.getElementById('notificationPreview');
      
      // Configurar estilos según el tipo
      const types = {
        informativa: {
          classes: 'bg-blue-50 border-blue-500 text-blue-700',
          icon: '📢',
          title: 'Información'
        },
        atencion: {
          classes: 'bg-yellow-50 border-yellow-500 text-yellow-700',
          icon: '⚠️',
          title: 'Atención'
        },
        urgente: {
          classes: 'bg-red-50 border-red-500 text-red-700',
          icon: '🚨',
          title: 'Urgente'
        }
      };
      
      const config = types[type];
      preview.className = `p-3 rounded-r-lg border-l-4 ${config.classes}`;
      preview.innerHTML = `
        <p class="font-bold">${config.icon} ${config.title}</p>
        <p class="text-sm">${message}</p>
      `;
    }
    
    function publishNotification() {
      const type = document.getElementById('notificationType').value;
      const message = document.getElementById('notificationMessage').value.trim();
      
      if (!message) {
        alert('Por favor, ingresa un mensaje para la notificación.');
        return;
      }
      
      // Simulación de publicación (sin funcionalidad real)
      alert(`Notificación ${type.toUpperCase()} publicada:\n\n"${message}"\n\n(Esta es solo una simulación - funcionalidad pendiente)`);
      closeNotificationModal();
    }
    
    // Actualizar vista previa en tiempo real
    document.addEventListener('DOMContentLoaded', function() {
      const typeSelect = document.getElementById('notificationType');
      const messageTextarea = document.getElementById('notificationMessage');
      
      if (typeSelect) typeSelect.addEventListener('change', updatePreview);
      if (messageTextarea) messageTextarea.addEventListener('input', updatePreview);
    });
    
    // Cerrar modal al hacer click fuera
    document.getElementById('notificationModal').addEventListener('click', function(event) {
      if (event.target === this) {
        closeNotificationModal();
      }
    });
  </script>
</body>
</html>
