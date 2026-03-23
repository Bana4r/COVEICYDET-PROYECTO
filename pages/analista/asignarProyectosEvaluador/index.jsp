<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page buffer="none" %>
<%@ include file="/WEB-INF/utilidadesAreas.jsp" %>
<%
    // Configurar codificación UTF-8 para la respuesta
    response.setCharacterEncoding("UTF-8");
    request.setCharacterEncoding("UTF-8");
%>

<%
    try {
        String test = obtenerDescripcionAreaProyecto("ingenieriasDesarrollo");
        System.out.println("[DEBUG] Función OK: " + test);
    } catch (Exception e) {
        System.out.println("[DEBUG] Función ERROR: " + e.getMessage());
        e.printStackTrace();
    }
%>

<%!
    // Función auxiliar para formatear tiempo
    private String formatearHaceTiempo(Timestamp fecha) {
        if (fecha == null) return "";
        long diff = System.currentTimeMillis() - fecha.getTime();
        long minutos = diff / 60000;
        long horas = minutos / 60;
        long dias = horas / 24;

        if (minutos < 1) return "Ahora mismo";
        if (minutos < 60) return "Hace " + minutos + " min";
        if (horas < 24) return "Hace " + horas + " horas";
        return "Hace " + dias + " días";
    }
%>
<%
    // Verificar sesión del analista
    if (session.getAttribute("id_usuario") == null) {
        response.sendRedirect(request.getContextPath() + "/pages/login/login.jsp");
        return;
    }

    Integer idUsuarioAnalista = (Integer) session.getAttribute("id_usuario");
    String nombreAnalista = (String) session.getAttribute("nombre");

    // Variables para datos de la BD
    List<Map<String, Object>> proyectos = new ArrayList<>();
    List<Map<String, Object>> evaluadores = new ArrayList<>();
    List<Map<String, Object>> asignacionesRecientes = new ArrayList<>();
    
    int totalProyectos = 0;
    int totalEvaluadores = 0;
    int totalAsignaciones = 0;
    int proyectosPorAsignar = 0;

    try {
        %>
        <%@ include file="/WEB-INF/conexion.jsp" %>
        <%

        if (conn != null && !conn.isClosed()) {
            // Obtener estadísticas
            String countProyectos = "SELECT COUNT(*) FROM proyectos WHERE estado_proyecto = '3'";
            Statement stmtCount = conn.createStatement();
            ResultSet rsCount = stmtCount.executeQuery(countProyectos);
            if (rsCount.next()) totalProyectos = rsCount.getInt(1);
            rsCount.close();
            stmtCount.close();

            String countEvaluadores = "SELECT COUNT(*) FROM usuarios WHERE tipousuario = 3 AND estado = 2";
            stmtCount = conn.createStatement();
            rsCount = stmtCount.executeQuery(countEvaluadores);
            if (rsCount.next()) totalEvaluadores = rsCount.getInt(1);
            rsCount.close();
            stmtCount.close();

            String countAsignaciones = "SELECT COUNT(*) FROM evaluador_proyecto";
            stmtCount = conn.createStatement();
            rsCount = stmtCount.executeQuery(countAsignaciones);
            if (rsCount.next()) totalAsignaciones = rsCount.getInt(1);
            rsCount.close();
            stmtCount.close();

            // Proyectos APROBADOS (estado=3) sin asignar o con menos de 2 evaluadores
            String sqlProyectos = "SELECT p.id_proyecto, p.titulo, p.area_conocimiento, p.estado_proyecto, " +
                                 "p.fecha_creacion, " +
                                 "(SELECT COUNT(*) FROM evaluador_proyecto ep WHERE ep.id_proyecto = p.id_proyecto) as evaluadores_count " +
                                 "FROM proyectos p " +
                                 "WHERE p.estado_proyecto = '3' " +
                                 "ORDER BY p.fecha_creacion DESC " +
                                 "LIMIT 20";
            
            PreparedStatement pstmt = conn.prepareStatement(sqlProyectos);
            ResultSet rs = pstmt.executeQuery();
            
            SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
            
            while (rs.next()) {
                Map<String, Object> proyecto = new HashMap<>();
                proyecto.put("id_proyecto", rs.getInt("id_proyecto"));
                proyecto.put("titulo", rs.getString("titulo"));
                proyecto.put("area_conocimiento", rs.getString("area_conocimiento"));
                proyecto.put("estado_proyecto", rs.getString("estado_proyecto"));
                proyecto.put("fecha_creacion", rs.getTimestamp("fecha_creacion") != null ? sdf.format(rs.getTimestamp("fecha_creacion")) : "");
                proyecto.put("evaluadores_count", rs.getInt("evaluadores_count"));
                
                // Determinar si está disponible (menos de 2 evaluadores)
                boolean disponible = rs.getInt("evaluadores_count") < 2;
                proyecto.put("disponible", disponible);
                
                if (!disponible) {
                    proyectosPorAsignar++;
                }
                
                proyectos.add(proyecto);
            }
            rs.close();
            pstmt.close();

            // Contar proyectos APROBADOS (estado=3) por asignar (con 0 o 1 evaluador)
            String countPorAsignar = "SELECT COUNT(*) FROM proyectos p WHERE " +
                                    "p.estado_proyecto = '3' AND " +
                                    "(SELECT COUNT(*) FROM evaluador_proyecto ep WHERE ep.id_proyecto = p.id_proyecto) < 2";
            stmtCount = conn.createStatement();
            rsCount = stmtCount.executeQuery(countPorAsignar);
            if (rsCount.next()) proyectosPorAsignar = rsCount.getInt(1);
            rsCount.close();
            stmtCount.close();

            // Obtener evaluadores (usuarios tipo 3, estado 2 = activo)
            // Usar nombre_completo de evaluadores si existe, sino usar usuarios
            String sqlEvaluadores = "SELECT u.id_usuario, " +
                                   "COALESCE(NULLIF(e.nombre_completo, ''), u.nombre || ' ' || u.primer_apellido || ' ' || COALESCE(u.segundo_apellido, '')) as nombre_completo, " +
                                   "e.area_conocimiento, e.institucion, " +
                                   "u.correo_electronico, " +
                                   "(SELECT COUNT(*) FROM evaluador_proyecto ep WHERE ep.id_usuario = u.id_usuario) as proyectos_asignados " +
                                   "FROM usuarios u " +
                                   "LEFT JOIN evaluadores e ON u.id_usuario = e.id_usuario " +
                                   "WHERE u.tipousuario = 3 AND u.estado = 2 " +
                                   "ORDER BY nombre_completo " +
                                   "LIMIT 20";

            pstmt = conn.prepareStatement(sqlEvaluadores);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Map<String, Object> evaluador = new HashMap<>();
                evaluador.put("id_usuario", rs.getInt("id_usuario"));
                evaluador.put("nombre_completo", rs.getString("nombre_completo"));
                evaluador.put("area_conocimiento", rs.getString("area_conocimiento"));
                evaluador.put("institucion", rs.getString("institucion"));
                evaluador.put("correo_electronico", rs.getString("correo_electronico"));
                evaluador.put("proyectos_asignados", rs.getInt("proyectos_asignados"));

                // Determinar disponibilidad (menos de 3 proyectos asignados)
                boolean disponible = rs.getInt("proyectos_asignados") < 3;
                evaluador.put("disponible", disponible);

                evaluadores.add(evaluador);
            }
            rs.close();
            pstmt.close();

            // Obtener asignaciones recientes
            String sqlRecientes = "SELECT ep.id_asignacion, ep.id_proyecto, ep.id_usuario, ep.fecha_asignacion, " +
                                 "p.titulo, " +
                                 "COALESCE(NULLIF(e.nombre_completo, ''), u.nombre || ' ' || u.primer_apellido || ' ' || COALESCE(u.segundo_apellido, '')) as nombre_evaluador " +
                                 "FROM evaluador_proyecto ep " +
                                 "JOIN proyectos p ON ep.id_proyecto = p.id_proyecto " +
                                 "JOIN usuarios u ON ep.id_usuario = u.id_usuario " +
                                 "LEFT JOIN evaluadores e ON ep.id_usuario = e.id_usuario " +
                                 "ORDER BY ep.fecha_asignacion DESC " +
                                 "LIMIT 5";

            pstmt = conn.prepareStatement(sqlRecientes);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Map<String, Object> asignacion = new HashMap<>();
                asignacion.put("id_proyecto", rs.getInt("id_proyecto"));
                asignacion.put("titulo", rs.getString("titulo"));
                asignacion.put("nombre_evaluador", rs.getString("nombre_evaluador"));
                asignacion.put("fecha_asignacion", rs.getTimestamp("fecha_asignacion") != null ?
                    formatearHaceTiempo(rs.getTimestamp("fecha_asignacion")) : "");
                asignacionesRecientes.add(asignacion);
            }
            rs.close();
            pstmt.close();

            conn.close();
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>COVEICYDET - Asignación de Proyectos (Analista)</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        primary: '#7A1737',
                        secondary: '#B28854',
                        accent: '#A8253C',
                        success: '#10B981',
                        warning: '#F59E0B',
                        danger: '#EF4444',
                        info: '#3B82F6'
                    },
                    fontFamily: {
                        'sans': ['Inter', 'system-ui', '-apple-system', 'sans-serif'],
                    },
                    boxShadow: {
                        'soft': '0 4px 20px rgba(0, 0, 0, 0.05)',
                        'card': '0 8px 30px rgba(0, 0, 0, 0.08)',
                        'floating': '0 15px 50px rgba(0, 0, 0, 0.12)'
                    },
                    animation: {
                        'fade-in': 'fadeIn 0.5s ease-in',
                        'slide-up': 'slideUp 0.3s ease-out',
                        'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite'
                    },
                    keyframes: {
                        fadeIn: {
                            '0%': { opacity: '0' },
                            '100%': { opacity: '1' }
                        },
                        slideUp: {
                            '0%': { transform: 'translateY(20px)', opacity: '0' },
                            '100%': { transform: 'translateY(0)', opacity: '1' }
                        }
                    }
                }
            }
        }
    </script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        .glass-card {
            background: rgba(255, 255, 255, 0.98);
            backdrop-filter: blur(12px);
            border: 1px solid rgba(255, 255, 255, 0.3);
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.08);
        }

        .gradient-bg {
            background: linear-gradient(135deg, #7A1737 0%, #A8253C 100%);
        }

        .gradient-text {
            background: linear-gradient(135deg, #7A1737 0%, #B28854 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .project-card {
            transition: all 0.3s ease;
        }

        .project-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 20px 40px rgba(122, 23, 55, 0.15);
        }

        .evaluador-card {
            transition: all 0.3s ease;
        }

        .evaluador-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
        }

        .evaluador-card.selected {
            border: 2px solid #7A1737;
            background: linear-gradient(to bottom right, rgba(122, 23, 55, 0.05), rgba(168, 37, 60, 0.05));
        }

        .project-card.selected {
            border: 2px solid #10B981;
            background: linear-gradient(to bottom right, rgba(16, 185, 129, 0.05), rgba(5, 150, 105, 0.05));
        }

        .status-badge {
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .status-disponible { background-color: #D1FAE5; color: #065F46; }
        .status-asignado { background-color: #DBEAFE; color: #1E40AF; }
        .status-evaluado { background-color: #FEF3C7; color: #92400E; }
        .status-no-disponible { background-color: #F3F4F6; color: #6B7280; }

        .search-input {
            transition: all 0.3s ease;
        }

        .search-input:focus {
            box-shadow: 0 0 0 3px rgba(122, 23, 55, 0.2);
        }

        .proyecto-id {
            font-family: 'Courier New', monospace;
            letter-spacing: 1px;
        }

        .badge-area {
            background-color: #F3F4F6;
            color: #4B5563;
            font-size: 0.7rem;
            padding: 2px 8px;
            border-radius: 12px;
        }

        .tab-button.active {
            background-color: #7A1737;
            color: white;
        }

        /* Estilos para compatibilidad de áreas */
        .compatibilidad-indicator {
            display: inline-block;
            min-height: 16px;
        }

        .compatibilidad-indicator-proyecto {
            display: inline-block;
            min-height: 16px;
        }

        .evaluador-card.no-compatible {
            opacity: 0.5;
            pointer-events: none;
        }

        .evaluador-card.compatible {
            border-left: 3px solid #10B981;
        }

        .project-card.no-compatible {
            opacity: 0.5;
            pointer-events: none;
        }

        .project-card.compatible {
            border-left: 3px solid #10B981;
        }
    </style>
</head>
<body class="bg-gradient-to-br from-gray-50 via-white to-gray-100 min-h-screen font-sans text-gray-800">

    <%@ include file="/pages/analista/header.jsp" %>

    <!-- Main Content -->
    <main class="container mx-auto px-6 py-8">

        <!-- Estadísticas Rápidas -->
        <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
            <div class="glass-card rounded-xl p-5 border-l-4 border-primary">
                <div class="flex justify-between items-start">
                    <div>
                        <p class="text-sm text-gray-600">Total Proyectos</p>
                        <h3 class="text-3xl font-bold text-gray-800"><%= totalProyectos %></h3>
                    </div>
                    <div class="bg-primary/10 p-3 rounded-lg">
                        <i class="fas fa-folder-open text-primary text-xl"></i>
                    </div>
                </div>
            </div>

            <div class="glass-card rounded-xl p-5 border-l-4 border-green-500">
                <div class="flex justify-between items-start">
                    <div>
                        <p class="text-sm text-gray-600">Evaluadores</p>
                        <h3 class="text-3xl font-bold text-green-600"><%= totalEvaluadores %></h3>
                    </div>
                    <div class="bg-green-500/10 p-3 rounded-lg">
                        <i class="fas fa-users text-green-600 text-xl"></i>
                    </div>
                </div>
            </div>

            <div class="glass-card rounded-xl p-5 border-l-4 border-yellow-500">
                <div class="flex justify-between items-start">
                    <div>
                        <p class="text-sm text-gray-600">Asignaciones</p>
                        <h3 class="text-3xl font-bold text-yellow-600"><%= totalAsignaciones %></h3>
                    </div>
                    <div class="bg-yellow-500/10 p-3 rounded-lg">
                        <i class="fas fa-handshake text-yellow-600 text-xl"></i>
                    </div>
                </div>
                <p class="text-xs text-gray-500 mt-2"><%= totalEvaluadores > 0 ? String.format("%.1f", (double)totalAsignaciones/totalEvaluadores) : "0" %> proyectos por evaluador</p>
            </div>

            <div class="glass-card rounded-xl p-5 border-l-4 border-purple-500">
                <div class="flex justify-between items-start">
                    <div>
                        <p class="text-sm text-gray-600">Por asignar</p>
                        <h3 class="text-3xl font-bold text-purple-600"><%= proyectosPorAsignar %></h3>
                    </div>
                    <div class="bg-purple-500/10 p-3 rounded-lg">
                        <i class="fas fa-clock text-purple-600 text-xl"></i>
                    </div>
                </div>
            </div>
        </div>

        <!-- Formulario de Asignación -->
        <form id="formAsignacion" action="<%= request.getContextPath() %>/pages/analista/asignarProyectosEvaluador/procesarAsignacion.jsp" method="POST">
            <input type="hidden" name="accion" value="asignar">
            <input type="hidden" id="evaluador_id_hidden" name="evaluador_id" value="">
            <div id="proyectosSeleccionadosContainer"></div>

            <!-- Panel de Asignación - 2 Columnas -->
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">

                <!-- COLUMNA IZQUIERDA: LISTA DE PROYECTOS -->
                <div class="glass-card rounded-2xl overflow-hidden">
                    <div class="bg-gradient-to-r from-primary to-accent text-white p-5">
                        <div class="flex justify-between items-center">
                            <h2 class="text-xl font-bold flex items-center">
                                <i class="fas fa-project-diagram mr-3"></i>
                                Proyectos Disponibles
                            </h2>
                            <span class="bg-white/20 px-3 py-1 rounded-full text-sm"><%= proyectosPorAsignar %> sin asignar</span>
                        </div>
                    </div>

                    <div class="p-5 border-b border-gray-200">
                        <div class="relative">
                            <i class="fas fa-search absolute left-4 top-1/2 transform -translate-y-1/2 text-gray-400"></i>
                            <input type="text" id="buscadorProyectos"
                                   placeholder="Buscar proyectos por ID, título o área..."
                                   class="search-input pl-11 pr-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:border-primary focus:ring-2 focus:ring-primary/30 w-full">
                        </div>

                        <!-- Filtros de área para proyectos -->
                        <div class="flex flex-wrap gap-2 mt-4" id="filtrosAreaProyectos">
                            <button type="button" class="px-3 py-1.5 bg-primary text-white rounded-full text-xs font-medium transition-all filter-area-proyecto active" data-area="">
                                <i class="fas fa-th mr-1"></i>Todos
                            </button>
                            <button type="button" class="px-3 py-1.5 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-full text-xs font-medium transition-all filter-area-proyecto" data-area="fisicoMatematicas">
                                I - Físico-Matemáticas
                            </button>
                            <button type="button" class="px-3 py-1.5 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-full text-xs font-medium transition-all filter-area-proyecto" data-area="biologiaQuimica">
                                II - Biología y Química
                            </button>
                            <button type="button" class="px-3 py-1.5 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-full text-xs font-medium transition-all filter-area-proyecto" data-area="medicinaCienciasSalud">
                                III - Medicina y Salud
                            </button>
                            <button type="button" class="px-3 py-1.5 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-full text-xs font-medium transition-all filter-area-proyecto" data-area="cienciasConductaEducacion">
                                IV - Conducta y Educación
                            </button>
                            <button type="button" class="px-3 py-1.5 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-full text-xs font-medium transition-all filter-area-proyecto" data-area="humanidades">
                                V - Humanidades
                            </button>
                            <button type="button" class="px-3 py-1.5 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-full text-xs font-medium transition-all filter-area-proyecto" data-area="cienciasSociales">
                                VI - Ciencias Sociales
                            </button>
                            <button type="button" class="px-3 py-1.5 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-full text-xs font-medium transition-all filter-area-proyecto" data-area="cienciasAgricultura">
                                VII - Agricultura
                            </button>
                            <button type="button" class="px-3 py-1.5 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-full text-xs font-medium transition-all filter-area-proyecto" data-area="ingenieriasDesarrollo">
                                VIII - Ingenierías
                            </button>
                            <button type="button" class="px-3 py-1.5 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-full text-xs font-medium transition-all filter-area-proyecto" data-area="interdisciplinaria">
                                IX - Interdisciplinaria
                            </button>
                        </div>
                    </div>

                    <div class="overflow-y-auto max-h-[600px] p-4 space-y-3">
                        <% if (proyectos.isEmpty()) { %>
                            <div class="text-center py-8 text-gray-500">
                                <i class="fas fa-folder-open text-4xl mb-3 opacity-50"></i>
                                <p>No hay proyectos disponibles</p>
                            </div>
                        <% } else { 
                            for (Map<String, Object> proyecto : proyectos) {
                                int idProyecto = (Integer) proyecto.get("id_proyecto");
                                String titulo = (String) proyecto.get("titulo");
                                String area = (String) proyecto.get("area_conocimiento");
                                String estado = (String) proyecto.get("estado_proyecto");
                                String fecha = (String) proyecto.get("fecha_creacion");
                                int evaluadoresCount = (Integer) proyecto.get("evaluadores_count");
                                boolean disponible = (Boolean) proyecto.get("disponible");
                                
                                String statusClass = disponible ? "status-disponible" : "status-asignado";
                                String statusText = disponible ? "Disponible" : "Completo";
                                String clickableClass = disponible ? "cursor-pointer hover:border-primary transition-all" : "opacity-60 cursor-not-allowed";
                                String onclickAttr = disponible ? "onclick=\"seleccionarProyecto(this, '" + idProyecto + "')\"" : "";
                            %>
                            <div class="border border-gray-200 rounded-xl p-4 project-card <%= clickableClass %>" 
                                 data-area-proyecto="<%= area != null ? area : "" %>"
                                 <%= onclickAttr %>>
                                <div class="flex items-start gap-3">
                                    <div class="bg-gradient-to-br from-gray-700 to-gray-600 p-3 rounded-lg">
                                        <i class="fas fa-file-alt text-white"></i>
                                    </div>
                                    <div class="flex-1">
                                        <div class="flex items-center justify-between">
                                            <span class="font-mono text-xs bg-gray-100 px-2 py-1 rounded">PROY-<%= idProyecto %></span>
                                            <span class="status-badge <%= statusClass %> text-[0.6rem] px-2 py-0.5"><%= statusText %></span>
                                        </div>
                                        <h4 class="font-bold text-gray-800 text-sm mt-2 line-clamp-2"><%= titulo != null ? titulo : "Sin título" %></h4>
                                        <div class="flex items-center gap-2 mt-2">
                                            <% if (area != null && !area.isEmpty()) { %>
                                                <span class="badge-area area-badge-proyecto" title="<%= area %>"><%= obtenerDescripcionAreaProyecto(area) %></span>
                                            <% } %>
                                            <span class="compatibilidad-indicator-proyecto text-xs"></span>
                                            <span class="text-xs text-gray-500"><i class="far fa-calendar mr-1"></i> <%= fecha %></span>
                                            <% if (!disponible) { %>
                                                <span class="text-xs text-blue-600 font-medium">
                                                    <i class="fas fa-user-check mr-1"></i> <%= evaluadoresCount %> evaluador(es)
                                                </span>
                                            <% } %>
                                        </div>
                                        <% if (disponible) { %>
                                        <div class="mt-2">
                                            <label class="flex items-center gap-2 cursor-pointer">
                                                <input type="checkbox" name="proyecto_ids" value="<%= idProyecto %>"
                                                       class="proyecto-checkbox w-4 h-4 text-primary border-gray-300 rounded focus:ring-primary"
                                                       onchange="actualizarProyectosSeleccionados()">
                                                <span class="text-xs text-gray-600">Seleccionar para asignar</span>
                                            </label>
                                        </div>
                                        <% } %>
                                    </div>
                                </div>
                            </div>
                            <% } 
                        } %>
                    </div>

                    <div class="p-4 border-t border-gray-200 bg-gray-50">
                        <div class="flex justify-between text-sm">
                            <span class="text-gray-600">Mostrando <%= proyectos.size() %> proyectos</span>
                        </div>
                    </div>
                </div>

                <!-- COLUMNA DERECHA: LISTA DE EVALUADORES -->
                <div class="glass-card rounded-2xl overflow-hidden">
                    <div class="bg-gradient-to-r from-primary to-accent text-white p-5">
                        <div class="flex justify-between items-center">
                            <h2 class="text-xl font-bold flex items-center">
                                <i class="fas fa-users mr-3"></i>
                                Evaluadores Disponibles
                            </h2>
                            <span class="bg-white/20 px-3 py-1 rounded-full text-sm"><%= evaluadores.size() %> activos</span>
                        </div>
                    </div>

                    <div class="p-5 border-b border-gray-200">
                        <div class="relative">
                            <i class="fas fa-search absolute left-4 top-1/2 transform -translate-y-1/2 text-gray-400"></i>
                            <input type="text" id="buscadorEvaluadores"
                                   placeholder="Buscar evaluadores por nombre o ID..."
                                   class="search-input pl-11 pr-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:border-primary focus:ring-2 focus:ring-primary/30 w-full">
                        </div>

                        <!-- Filtros de área para evaluadores -->
                        <div class="flex flex-wrap gap-2 mt-4" id="filtrosAreaEvaluadores">
                            <button type="button" class="px-3 py-1.5 bg-primary text-white rounded-full text-xs font-medium transition-all filter-area-evaluador active" data-area="">
                                <i class="fas fa-th mr-1"></i>Todos
                            </button>
                            <button type="button" class="px-3 py-1.5 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-full text-xs font-medium transition-all filter-area-evaluador" data-area="fisicoMatematicas">
                                I - Físico-Matemáticas
                            </button>
                            <button type="button" class="px-3 py-1.5 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-full text-xs font-medium transition-all filter-area-evaluador" data-area="biologiaQuimica">
                                II - Biología y Química
                            </button>
                            <button type="button" class="px-3 py-1.5 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-full text-xs font-medium transition-all filter-area-evaluador" data-area="medicinaCienciasSalud">
                                III - Medicina y Salud
                            </button>
                            <button type="button" class="px-3 py-1.5 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-full text-xs font-medium transition-all filter-area-evaluador" data-area="cienciasConductaEducacion">
                                IV - Conducta y Educación
                            </button>
                            <button type="button" class="px-3 py-1.5 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-full text-xs font-medium transition-all filter-area-evaluador" data-area="humanidades">
                                V - Humanidades
                            </button>
                            <button type="button" class="px-3 py-1.5 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-full text-xs font-medium transition-all filter-area-evaluador" data-area="cienciasSociales">
                                VI - Ciencias Sociales
                            </button>
                            <button type="button" class="px-3 py-1.5 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-full text-xs font-medium transition-all filter-area-evaluador" data-area="cienciasAgricultura">
                                VII - Agricultura
                            </button>
                            <button type="button" class="px-3 py-1.5 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-full text-xs font-medium transition-all filter-area-evaluador" data-area="ingenieriasDesarrollo">
                                VIII - Ingenierías
                            </button>
                            <button type="button" class="px-3 py-1.5 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-full text-xs font-medium transition-all filter-area-evaluador" data-area="interdisciplinaria">
                                IX - Interdisciplinaria
                            </button>
                        </div>
                    </div>

                    <div class="overflow-y-auto max-h-[600px] p-4 space-y-3">
                        <% if (evaluadores.isEmpty()) { %>
                            <div class="text-center py-8 text-gray-500">
                                <i class="fas fa-users-slash text-4xl mb-3 opacity-50"></i>
                                <p>No hay evaluadores disponibles</p>
                            </div>
                        <% } else {
                            int index = 0;
                            for (Map<String, Object> evaluador : evaluadores) {
                                int idUsuario = (Integer) evaluador.get("id_usuario");
                                String nombreComp = (String) evaluador.get("nombre_completo");
                                String area = (String) evaluador.get("area_conocimiento");
                                String institucion = (String) evaluador.get("institucion");
                                int proyectosAsignados = (Integer) evaluador.get("proyectos_asignados");
                                boolean disponible = (Boolean) evaluador.get("disponible");

                                // Si no hay nombre_completo (evaluador no ha completado perfil), usar ID
                                String nombreParaMostrar = (nombreComp != null && !nombreComp.isEmpty()) ?
                                    nombreComp : "Evaluador ID: " + idUsuario;
                                    
                                String statusClass = disponible ? "bg-green-100 text-green-800" : "bg-yellow-100 text-yellow-800";
                                String statusText = disponible ? "Disponible" : "Ocupado";
                                String clickableClass = disponible ? "cursor-pointer hover:border-primary transition-all" : "opacity-60 cursor-not-allowed";
                                String selectedClass = index == 0 && disponible ? "selected" : "";
                            %>
                            <div class="border border-gray-200 rounded-xl p-4 evaluador-card <%= clickableClass %> <%= selectedClass %>"
                                 data-area-evaluador="<%= area != null ? area : "" %>"
                                 onclick="<%= disponible ? "seleccionarEvaluador(this, '" + idUsuario + "')" : "" %>">
                                <div class="flex items-start gap-3">
                                    <div class="bg-primary/10 p-3 rounded-full">
                                        <i class="fas fa-user-circle text-primary text-xl"></i>
                                    </div>
                                    <div class="flex-1">
                                        <div class="flex items-center justify-between">
                                            <h4 class="font-bold text-gray-800"><%= nombreParaMostrar %></h4>
                                            <span class="text-xs <%= statusClass %> px-2 py-0.5 rounded-full"><%= statusText %></span>
                                        </div>
                                        <p class="text-xs text-gray-600 mt-1">ID: <%= idUsuario %></p>
                                        <div class="flex flex-wrap gap-1 mt-2">
                                            <% if (area != null && !area.isEmpty()) { %>
                                                <span class="badge-area area-badge"><%= obtenerDescripcionAreaEvaluador(area) %></span>
                                            <% } %>
                                            <% if (institucion != null && !institucion.isEmpty()) { %>
                                                <span class="badge-area"><%= institucion %></span>
                                            <% } %>
                                        </div>
                                        <div class="flex items-center justify-between mt-2 text-xs">
                                            <span class="text-gray-500"><i class="fas fa-tasks mr-1"></i> <%= proyectosAsignados %> asignados</span>
                                            <span class="compatibilidad-indicator text-xs"></span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <% 
                                index++;
                            } 
                        } %>
                    </div>

                    <div class="p-4 border-t border-gray-200 bg-gray-50">
                        <div class="flex justify-between text-sm">
                            <span class="text-gray-600">Mostrando <%= evaluadores.size() %> evaluadores</span>
                        </div>
                    </div>
                </div>
            </div>
        </form>

        <!-- Panel de Asignación Rápida -->
        <div class="glass-card rounded-2xl p-6 mt-8">
            <div class="flex items-center justify-between mb-4">
                <h3 class="text-xl font-bold text-gray-800 flex items-center">
                    <i class="fas fa-hand-pointer mr-3 text-primary"></i>
                    Confirmar Asignación
                </h3>
                <div class="flex items-center gap-2 text-xs">
                    <span class="flex items-center gap-1">
                        <i class="fas fa-check-circle text-green-600"></i>
                        <span class="text-gray-600">Compatible</span>
                    </span>
                    <span class="flex items-center gap-1 ml-3">
                        <i class="fas fa-times-circle text-red-600"></i>
                        <span class="text-gray-600">No compatible</span>
                    </span>
                </div>
            </div>

            <div class="bg-blue-50 border border-blue-200 rounded-xl p-4 mb-4">
                <div class="flex items-start gap-3">
                    <i class="fas fa-info-circle text-blue-600 mt-0.5"></i>
                    <div class="text-sm text-gray-700">
                        <p class="font-semibold mb-1">Sistema de compatibilidad de áreas</p>
                        <p>
                            El sistema filtra automáticamente los evaluadores compatibles según el área del proyecto seleccionado.
                            Los evaluadores con área compatible se muestran con el indicador 
                            <span class="text-green-600 font-medium"><i class="fas fa-check-circle"></i> Compatible</span>.
                            Si seleccionas un evaluador no compatible, recibirás una advertencia.
                        </p>
                    </div>
                </div>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <div class="bg-gray-50 rounded-xl p-5 border border-gray-200">
                    <p class="text-sm text-gray-500 mb-1">Proyectos seleccionados</p>
                    <div id="proyectoSeleccionadoDisplay" class="min-h-[80px]">
                        <p class="text-gray-400 italic text-sm">Ningún proyecto seleccionado</p>
                    </div>
                </div>

                <div class="bg-gray-50 rounded-xl p-5 border border-gray-200">
                    <p class="text-sm text-gray-500 mb-1">Evaluador seleccionado</p>
                    <div id="evaluadorSeleccionadoDisplay" class="min-h-[80px]">
                        <p class="text-gray-400 italic text-sm">Ningún evaluador seleccionado</p>
                    </div>
                </div>

                <div class="bg-gray-50 rounded-xl p-5 border border-gray-200 flex flex-col justify-center">
                    <button type="button" id="btnAsignar" class="w-full bg-gradient-to-r from-primary to-accent text-white py-4 rounded-xl font-bold text-lg hover:shadow-lg transition-all disabled:opacity-50 disabled:cursor-not-allowed" disabled>
                        <i class="fas fa-link mr-2"></i> Asignar Proyectos
                    </button>
                    <p class="text-xs text-gray-500 text-center mt-2">Selecciona proyectos y evaluador</p>
                </div>
            </div>

            <!-- Asignaciones Recientes -->
            <% if (!asignacionesRecientes.isEmpty()) { %>
            <div class="mt-6 pt-4 border-t border-gray-200">
                <h4 class="font-semibold text-gray-700 mb-3 flex items-center">
                    <i class="fas fa-history mr-2 text-gray-400"></i>
                    Asignaciones recientes
                </h4>
                <div class="space-y-2">
                    <% for (Map<String, Object> asignacion : asignacionesRecientes) { %>
                    <div class="flex items-center justify-between text-sm bg-gray-50 p-3 rounded-lg">
                        <div class="flex items-center">
                            <span class="font-mono text-xs bg-gray-200 px-2 py-1 rounded mr-3">PROY-<%= asignacion.get("id_proyecto") %></span>
                            <span class="text-gray-800"><%= asignacion.get("titulo") %></span>
                        </div>
                        <div class="flex items-center">
                            <i class="fas fa-arrow-right text-gray-400 mx-3"></i>
                            <span class="font-medium"><%= asignacion.get("nombre_evaluador") %></span>
                            <span class="text-xs text-gray-500 ml-3"><%= asignacion.get("fecha_asignacion") %></span>
                        </div>
                    </div>
                    <% } %>
                </div>
            </div>
            <% } %>
        </div>
    </main>

    <!-- Toast Container -->
    <div id="toastContainer" class="fixed bottom-6 right-6 z-40 space-y-3"></div>

    <script>
        // ============================================
        // MAPEO DE ÁREAS (Evaluador SECIHTI → Proyecto CONACYT)
        // ============================================
        // Mapeo de áreas: Evaluador → Proyecto
        // Ahora ambos usan la misma clasificación SECIHTI (9 áreas), por lo que el mapeo es 1:1
        const MAPEO_AREAS = {
            'fisicoMatematicas': ['fisicoMatematicas'],
            'biologiaQuimica': ['biologiaQuimica'],
            'medicinaCienciasSalud': ['medicinaCienciasSalud'],
            'cienciasConductaEducacion': ['cienciasConductaEducacion'],
            'humanidades': ['humanidades'],
            'cienciasSociales': ['cienciasSociales'],
            'cienciasAgricultura': ['cienciasAgricultura'],
            'ingenieriasDesarrollo': ['ingenieriasDesarrollo'],
            'interdisciplinaria': ['interdisciplinaria']
        };

        // Mapeo inverso: de texto legible a clave técnica
        const AREA_TEXTO_A_CLAVE = {
            // Áreas CONACYT (proyectos)
            'i - físico-matemáticas y ciencias de la tierra': 'fisicoMatematicas',
            'ii - biología y química': 'biologiaQuimica',
            'iii - medicina y ciencias de la salud': 'medicinaCienciasSalud',
            'iv - ciencias de la conducta y la educación': 'cienciasConductaEducacion',
            'v - humanidades': 'humanidades',
            'vi - ciencias sociales': 'cienciasSociales',
            'vii - ciencias de agricultura, agropecuarias, forestales y de ecosistemas': 'cienciasAgricultura',
            'viii - ingenierías y desarrollo tecnológico': 'ingenieriasDesarrollo',
            'ix - interdisciplinaria': 'interdisciplinaria',
            // También aceptar sin números romanos
            'físico-matemáticas y ciencias de la tierra': 'fisicoMatematicas',
            'biología y química': 'biologiaQuimica',
            'medicina y ciencias de la salud': 'medicinaCienciasSalud',
            'ciencias de la conducta y la educación': 'cienciasConductaEducacion',
            'ciencias sociales': 'cienciasSociales',
            'ciencias de agricultura, agropecuarias, forestales y de ecosistemas': 'cienciasAgricultura',
            'ingenierías y desarrollo tecnológico': 'ingenieriasDesarrollo',
            // Áreas SECIHTI (evaluadores)
            'ciencias naturales': 'naturales',
            'ingeniería y tecnología': 'ingenieria',
            'ciencias médicas y de la salud': 'medicas',
            'ciencias agrícolas': 'agricolas',
            'interdisciplinaria / multidisciplinaria': 'interdisciplinaria'
        };

        // Normalizar área: convertir texto legible a clave técnica
        function normalizarArea(area) {
            if (!area) return null;
            
            const areaTrim = area.trim();
            
            // Primero verificar si es una clave técnica (respetando camelCase)
            if (MAPEO_AREAS[areaTrim]) {
                return areaTrim;
            }
            
            // Verificar si es un valor de área de proyecto (clave técnica en los valores)
            for (const clave in MAPEO_AREAS) {
                if (MAPEO_AREAS[clave].includes(areaTrim)) {
                    return areaTrim;
                }
            }
            
            // Si no es clave técnica, normalizar a minúsculas para buscar en mapeo de texto
            const areaLower = areaTrim.toLowerCase();
            
            // Buscar en el mapeo de texto a clave
            return AREA_TEXTO_A_CLAVE[areaLower] || areaTrim;
        }

        // Verificar si un área de evaluador es compatible con un área de proyecto
        function esAreaCompatible(areaEvaluador, areaProyecto) {
            if (!areaEvaluador || !areaProyecto) return false;

            // Normalizar áreas (quitar acentos, minúsculas, etc.)
            areaEvaluador = normalizarArea(areaEvaluador);
            areaProyecto = normalizarArea(areaProyecto);
            
            console.log('[esAreaCompatible] Evaluador:', areaEvaluador, '| Proyecto:', areaProyecto);

            const areasCompatibles = MAPEO_AREAS[areaEvaluador] || [];
            const compatible = areasCompatibles.includes(areaProyecto);
            
            console.log('[esAreaCompatible] Compatibles:', areasCompatibles, '| Resultado:', compatible);
            
            return compatible;
        }

        // Obtener áreas de proyecto compatibles con un evaluador
        function obtenerAreasCompatibles(areaEvaluador) {
            areaEvaluador = normalizarArea(areaEvaluador);
            return MAPEO_AREAS[areaEvaluador] || [];
        }

        // Actualizar indicadores de compatibilidad en evaluadores
        function actualizarCompatibilidadEvaluadores(areaProyecto) {
            areaProyecto = normalizarArea(areaProyecto);

            console.log('[Compatibilidad] Área proyecto:', areaProyecto);

            document.querySelectorAll('.evaluador-card').forEach(card => {
                const areaEvaluador = normalizarArea(card.getAttribute('data-area-evaluador'));
                const indicador = card.querySelector('.compatibilidad-indicator');

                if (!areaEvaluador || !indicador) return;

                const compatible = esAreaCompatible(areaEvaluador, areaProyecto);

                console.log('[Compatibilidad] Evaluador:', areaEvaluador, '→ Compatible:', compatible);

                if (areaProyecto && areaEvaluador) {
                    if (compatible) {
                        indicador.innerHTML = '<i class="fas fa-check-circle text-green-600 mr-1"></i> Compatible';
                        indicador.className = 'compatibilidad-indicator text-xs text-green-600 font-medium';
                        card.style.opacity = '1';
                        card.classList.remove('no-compatible');
                    } else {
                        indicador.innerHTML = '<i class="fas fa-times-circle text-red-600 mr-1"></i> No compatible';
                        indicador.className = 'compatibilidad-indicator text-xs text-red-600 font-medium';
                        card.style.opacity = '0.4';
                        card.classList.add('no-compatible');
                    }
                } else {
                    indicador.innerHTML = '';
                    card.style.opacity = '1';
                    card.classList.remove('no-compatible');
                }
            });
        }

        // Actualizar indicadores de compatibilidad en proyectos (cuando se selecciona evaluador)
        function actualizarCompatibilidadProyectos(areaEvaluador) {
            areaEvaluador = normalizarArea(areaEvaluador);

            console.log('[Compatibilidad] Área evaluador:', areaEvaluador);

            // Obtener áreas de proyecto compatibles con este evaluador
            const areasProyectosCompatibles = obtenerAreasCompatibles(areaEvaluador);
            console.log('[Compatibilidad] Áreas proyecto compatibles:', areasProyectosCompatibles);

            document.querySelectorAll('.project-card').forEach(card => {
                const areaProyecto = card.getAttribute('data-area-proyecto') || '';
                const indicador = card.querySelector('.compatibilidad-indicator-proyecto');

                if (!areaProyecto) return;

                const areaProyectoNormalizada = normalizarArea(areaProyecto);
                const compatible = areasProyectosCompatibles.includes(areaProyectoNormalizada);

                console.log('[Compatibilidad] Proyecto:', areaProyectoNormalizada, '→ Compatible:', compatible);

                if (areaEvaluador && areaProyecto) {
                    if (compatible) {
                        card.style.opacity = '1';
                        card.classList.remove('no-compatible');
                        if (indicador) {
                            indicador.innerHTML = '<i class="fas fa-check-circle text-green-600 mr-1"></i> Compatible';
                            indicador.className = 'compatibilidad-indicator-proyecto text-xs text-green-600 font-medium';
                        }
                    } else {
                        card.style.opacity = '0.4';
                        card.classList.add('no-compatible');
                        if (indicador) {
                            indicador.innerHTML = '<i class="fas fa-times-circle text-red-600 mr-1"></i> No compatible';
                            indicador.className = 'compatibilidad-indicator-proyecto text-xs text-red-600 font-medium';
                        }
                    }
                } else {
                    card.style.opacity = '1';
                    card.classList.remove('no-compatible');
                    if (indicador) {
                        indicador.innerHTML = '';
                    }
                }
            });
        }

        // Variables globales
        let evaluadorActual = null;
        let proyectosSeleccionados = [];
        let ultimoProyectoClickeado = null;
        let areaProyectoActual = null;

        // Función para seleccionar proyecto
        function seleccionarProyecto(element, idProyecto) {
            const checkbox = element.querySelector('.proyecto-checkbox');
            const estaSeleccionado = proyectosSeleccionados.includes(idProyecto);

            // Si ya está seleccionado, lo deseleccionamos
            if (estaSeleccionado) {
                element.classList.remove('selected', 'border-green-500', 'bg-green-50');

                if (checkbox) {
                    checkbox.checked = false;
                }

                // Remover de la lista
                proyectosSeleccionados = proyectosSeleccionados.filter(id => id !== idProyecto);

                mostrarToast('Proyecto deseleccionado', 'info');
            } else {
                // Añadir clase seleccionada
                element.classList.add('selected', 'border-green-500', 'bg-green-50');

                if (checkbox) {
                    checkbox.checked = true;
                }

                // Agregar a la lista de seleccionados
                proyectosSeleccionados.push(idProyecto);
                ultimoProyectoClickeado = { element, id: idProyecto };

                mostrarToast('Proyecto seleccionado', 'success');
            }

            // Obtener información del proyecto (usar el último seleccionado o el primero de la lista)
            let areaProyecto = '';
            let areaTexto = 'Área no especificada';
            let titulo = '';
            let id = '';
            
            if (proyectosSeleccionados.length > 0 && ultimoProyectoClickeado && !estaSeleccionado) {
                // Usar el proyecto que acabamos de seleccionar
                const lastElement = ultimoProyectoClickeado.element;
                titulo = lastElement.querySelector('h4').textContent;
                id = lastElement.querySelector('.font-mono').textContent;
                const areaBadge = lastElement.querySelector('.area-badge-proyecto');
                areaTexto = areaBadge ? areaBadge.textContent.trim() : 'Área no especificada';
                areaProyecto = lastElement.getAttribute('data-area-proyecto') || '';
            } else if (proyectosSeleccionados.length > 0) {
                // Usar el primer proyecto de la lista
                const firstSelectedCard = document.querySelector('.project-card.selected');
                if (firstSelectedCard) {
                    titulo = firstSelectedCard.querySelector('h4').textContent;
                    id = firstSelectedCard.querySelector('.font-mono').textContent;
                    const areaBadge = firstSelectedCard.querySelector('.area-badge-proyecto');
                    areaTexto = areaBadge ? areaBadge.textContent.trim() : 'Área no especificada';
                    areaProyecto = firstSelectedCard.getAttribute('data-area-proyecto') || '';
                }
            }

            // Si no hay proyectos seleccionados, resetear
            if (proyectosSeleccionados.length === 0) {
                areaProyectoActual = null;
                ultimoProyectoClickeado = null;
                // Resetear indicadores de compatibilidad
                resetearCompatibilidadEvaluadores();
            } else {
                // Guardar área del proyecto para compatibilidad
                areaProyectoActual = areaProyecto;

                // Actualizar indicadores de compatibilidad en evaluadores
                if (areaProyecto) {
                    actualizarCompatibilidadEvaluadores(areaProyecto);
                }
            }

            const proyectoActual = {
                id: id,
                titulo: titulo,
                area: areaTexto
            };

            // Actualizar display
            actualizarDisplaySeleccion(proyectoActual);

            // Actualizar hidden inputs del formulario
            actualizarProyectosSeleccionados();

            // Habilitar/deshabilitar botón de asignación
            verificarBotonAsignar();
        }

        // Resetear indicadores de compatibilidad en evaluadores
        function resetearCompatibilidadEvaluadores() {
            document.querySelectorAll('.evaluador-card').forEach(card => {
                const indicador = card.querySelector('.compatibilidad-indicator');
                if (indicador) {
                    indicador.innerHTML = '';
                }
                card.style.opacity = '1';
                card.classList.remove('no-compatible');
            });
        }

        // Función para seleccionar evaluador
        function seleccionarEvaluador(element, idEvaluador) {
            // Remover selección previa
            document.querySelectorAll('.evaluador-card').forEach(card => {
                card.classList.remove('selected');
            });

            // Añadir clase seleccionada
            element.classList.add('selected');

            // Obtener información del evaluador
            const h4Element = element.querySelector('h4');
            const idTextElement = element.querySelector('.text-gray-600');
            
            const nombre = h4Element ? h4Element.textContent.trim() : '';
            const id = idTextElement ? idTextElement.textContent.replace('ID: ', '').trim() : idEvaluador;
            const areaEvaluador = element.getAttribute('data-area-evaluador') || '';

            // Verificar compatibilidad con el proyecto seleccionado
            if (areaProyectoActual && areaEvaluador) {
                const compatible = esAreaCompatible(areaEvaluador, areaProyectoActual);
                if (!compatible) {
                    mostrarToast('⚠️ El evaluador NO es compatible con el área del proyecto', 'warning');
                }
            }

            evaluadorActual = {
                id: id,
                nombre: nombre,
                area: areaEvaluador
            };

            // Actualizar hidden input del formulario
            const hiddenEvaluador = document.getElementById('evaluador_id_hidden');
            if (hiddenEvaluador) {
                hiddenEvaluador.value = idEvaluador;
            }

            // Actualizar display
            actualizarDisplayEvaluador();

            // Actualizar compatibilidad de proyectos cuando se selecciona evaluador
            if (areaEvaluador) {
                actualizarCompatibilidadProyectos(areaEvaluador);
            } else {
                // Si no hay área, resetear proyectos
                resetearCompatibilidadProyectos();
            }

            // Habilitar/deshabilitar botón de asignación
            verificarBotonAsignar();
        }

        // Resetear indicadores de compatibilidad en proyectos
        function resetearCompatibilidadProyectos() {
            document.querySelectorAll('.project-card').forEach(card => {
                card.style.opacity = '1';
                card.classList.remove('no-compatible');
                const indicador = card.querySelector('.compatibilidad-indicator-proyecto');
                if (indicador) {
                    indicador.innerHTML = '';
                }
            });
        }

        // Función para actualizar proyectos seleccionados en el formulario
        function actualizarProyectosSeleccionados() {
            const container = document.getElementById('proyectosSeleccionadosContainer');
            container.innerHTML = '';
            
            proyectosSeleccionados.forEach(id => {
                const input = document.createElement('input');
                input.type = 'hidden';
                input.name = 'proyecto_ids';
                input.value = id;
                container.appendChild(input);
            });
        }

        // Función para actualizar display de proyectos
        function actualizarDisplaySeleccion(proyectoActual) {
            const proyectoDisplay = document.getElementById('proyectoSeleccionadoDisplay');

            if (proyectosSeleccionados.length > 0 && proyectoActual) {
                var html = '<div class="flex items-start">' +
                    '<div class="bg-green-100 p-2 rounded-lg mr-3">' +
                    '<i class="fas fa-project-diagram text-green-600"></i>' +
                    '</div>' +
                    '<div>' +
                    '<p class="font-mono text-xs text-gray-500">' + proyectoActual.id + '</p>' +
                    '<p class="font-medium text-gray-800 line-clamp-2">' + proyectoActual.titulo + '</p>' +
                    '<p class="text-xs text-gray-500 mt-1">' + proyectoActual.area + '</p>' +
                    '<p class="text-xs text-green-600 mt-1">' + proyectosSeleccionados.length + ' proyecto(s) seleccionado(s)</p>' +
                    '</div>' +
                    '</div>';
                proyectoDisplay.innerHTML = html;
            } else {
                proyectoDisplay.innerHTML = '<p class="text-gray-400 italic text-sm">Ningún proyecto seleccionado</p>';
            }
        }

        // Función para actualizar display de evaluador
        function actualizarDisplayEvaluador() {
            const evaluadorDisplay = document.getElementById('evaluadorSeleccionadoDisplay');

            if (evaluadorActual && evaluadorActual.nombre) {
                var html = '<div class="flex items-start">' +
                    '<div class="bg-primary/10 p-2 rounded-lg mr-3">' +
                    '<i class="fas fa-user-circle text-primary"></i>' +
                    '</div>' +
                    '<div>' +
                    '<p class="font-medium text-gray-800">' + evaluadorActual.nombre + '</p>' +
                    '<p class="text-xs text-gray-500">' + evaluadorActual.id + '</p>' +
                    '</div>' +
                    '</div>';
                evaluadorDisplay.innerHTML = html;
            } else {
                evaluadorDisplay.innerHTML = '<p class="text-gray-400 italic text-sm">Ningún evaluador seleccionado</p>';
            }
        }

        // Función para verificar si se puede asignar
        function verificarBotonAsignar() {
            const btnAsignar = document.getElementById('btnAsignar');
            const tieneProyectos = proyectosSeleccionados.length > 0;
            const tieneEvaluador = evaluadorActual !== null;

            // Verificar compatibilidad de áreas
            let esCompatible = true;
            let hayProyectosCompatibles = false;

            if (tieneProyectos && tieneEvaluador && areaProyectoActual && evaluadorActual?.area) {
                esCompatible = esAreaCompatible(evaluadorActual.area, areaProyectoActual);
            }

            // Si hay evaluador seleccionado, verificar si hay al menos un proyecto compatible seleccionado
            if (tieneEvaluador && evaluadorActual?.area) {
                const areasCompatibles = obtenerAreasCompatibles(evaluadorActual.area);
                // Verificar cada proyecto seleccionado
                for (const idProyecto of proyectosSeleccionados) {
                    const card = document.querySelector(`.project-card.selected`);
                    if (card) {
                        const areaProyecto = normalizarArea(card.getAttribute('data-area-proyecto'));
                        if (areasCompatibles.includes(areaProyecto)) {
                            hayProyectosCompatibles = true;
                            break;
                        }
                    }
                }
                // Si hay proyectos seleccionados pero ninguno es compatible
                if (tieneProyectos && !hayProyectosCompatibles && areasCompatibles.length > 0) {
                    esCompatible = false;
                }
            }

            if (tieneProyectos && tieneEvaluador && esCompatible) {
                btnAsignar.disabled = false;
                btnAsignar.innerHTML = '<i class="fas fa-link mr-2"></i> Asignar Proyectos';
            } else if (tieneProyectos && tieneEvaluador && !esCompatible) {
                btnAsignar.disabled = true;
                btnAsignar.innerHTML = '<i class="fas fa-exclamation-triangle mr-2"></i> Áreas No Compatibles';
            } else {
                btnAsignar.disabled = true;
                btnAsignar.innerHTML = '<i class="fas fa-link mr-2"></i> Asignar Proyectos';
            }
        }

        // Función para asignar proyecto
        document.getElementById('btnAsignar')?.addEventListener('click', function() {
            if (proyectosSeleccionados.length > 0 && evaluadorActual) {
                // Enviar formulario
                document.getElementById('formAsignacion').submit();
            }
        });

        // Función para mostrar toast
        function mostrarToast(mensaje, tipo = 'info') {
            const container = document.getElementById('toastContainer');
            const toast = document.createElement('div');

            const tipos = {
                success: 'bg-gradient-to-r from-green-500 to-green-600',
                error: 'bg-gradient-to-r from-red-500 to-red-600',
                info: 'bg-gradient-to-r from-blue-500 to-blue-600',
                warning: 'bg-gradient-to-r from-yellow-500 to-yellow-600'
            };

            toast.className = `${tipos[tipo]} text-white px-6 py-4 rounded-xl shadow-floating flex items-center animate-slide-up`;
            toast.innerHTML = `
                <i class="fas fa-${tipo == 'success' ? 'check-circle' : tipo == 'error' ? 'exclamation-circle' : tipo == 'warning' ? 'exclamation-triangle' : 'info-circle'} mr-3 text-lg"></i>
                <span class="font-medium">${mensaje}</span>
                <button onclick="this.parentElement.remove()" class="ml-4 hover:opacity-80">
                    <i class="fas fa-times"></i>
                </button>
            `;

            container.appendChild(toast);

            setTimeout(() => {
                if (toast.parentElement) {
                    toast.remove();
                }
            }, 5000);
        }

        // Mostrar mensajes de la sesión
        <% 
            String mensaje = (String) session.getAttribute("mensaje_asignacion");
            String tipoMensaje = (String) session.getAttribute("tipo_mensaje_asignacion");
            if (mensaje != null && !mensaje.isEmpty()) {
                String tipo = tipoMensaje != null ? tipoMensaje : "info";
        %>
        mostrarToast('<%= mensaje.replace("'", "\\'").replace("\n", " ") %>', '<%= tipo %>');
        <% 
                session.removeAttribute("mensaje_asignacion");
                session.removeAttribute("tipo_mensaje_asignacion");
            }
        %>

        // Inicializar
        document.addEventListener('DOMContentLoaded', function() {
            // Seleccionar primer evaluador disponible por defecto
            const primerEvaluador = document.querySelector('.evaluador-card:not(.opacity-60)');
            if (primerEvaluador) {
                const idEvaluador = primerEvaluador.querySelector('h4');
                // Obtener ID del evaluador del texto
                const idText = primerEvaluador.querySelector('.text-gray-600');
                if (idText) {
                    const idValor = idText.textContent.replace('ID: ', '').trim();
                    seleccionarEvaluador(primerEvaluador, idValor);
                }
            }

            // Agregar evento a los checkboxes para toggle de selección
            document.querySelectorAll('.proyecto-checkbox').forEach(checkbox => {
                checkbox.addEventListener('change', function(e) {
                    e.stopPropagation(); // Evitar que el click se propague a la tarjeta
                    const card = this.closest('.project-card');
                    const idProyecto = this.value;
                    if (card) {
                        seleccionarProyecto(card, idProyecto);
                    }
                });
            });

            // Agregar buscador de proyectos
            const buscadorProyectos = document.getElementById('buscadorProyectos');
            if (buscadorProyectos) {
                buscadorProyectos.addEventListener('input', function(e) {
                    const filtro = e.target.value.toLowerCase();
                    const areaFiltro = document.querySelector('.filter-area-proyecto.active')?.dataset?.area || '';
                    filtrarProyectos(filtro, areaFiltro);
                });
            }

            // Agregar filtros de área para proyectos
            document.querySelectorAll('.filter-area-proyecto').forEach(btn => {
                btn.addEventListener('click', function() {
                    // Remover clase active de todos
                    document.querySelectorAll('.filter-area-proyecto').forEach(b => {
                        b.classList.remove('active', 'bg-primary', 'text-white');
                        b.classList.add('bg-gray-100', 'text-gray-700');
                    });
                    // Activar este botón
                    this.classList.remove('bg-gray-100', 'text-gray-700');
                    this.classList.add('active', 'bg-primary', 'text-white');
                    
                    const areaFiltro = this.dataset.area;
                    const textoFiltro = document.getElementById('buscadorProyectos')?.value?.toLowerCase() || '';
                    filtrarProyectos(textoFiltro, areaFiltro);
                });
            });

            // Función para filtrar proyectos por texto y área
            function filtrarProyectos(texto, area) {
                document.querySelectorAll('.project-card').forEach(card => {
                    const textoCard = card.textContent.toLowerCase();
                    const areaCard = card.dataset.areaProyecto || '';
                    
                    const coincideTexto = !texto || textoCard.includes(texto);
                    const coincideArea = !area || areaCard === area;
                    
                    card.style.display = (coincideTexto && coincideArea) ? '' : 'none';
                });
            }

            // Agregar buscador de evaluadores
            const buscadorEvaluadores = document.getElementById('buscadorEvaluadores');
            if (buscadorEvaluadores) {
                buscadorEvaluadores.addEventListener('input', function(e) {
                    const filtro = e.target.value.toLowerCase();
                    const areaFiltro = document.querySelector('.filter-area-evaluador.active')?.dataset?.area || '';
                    filtrarEvaluadores(filtro, areaFiltro);
                });
            }

            // Agregar filtros de área para evaluadores
            document.querySelectorAll('.filter-area-evaluador').forEach(btn => {
                btn.addEventListener('click', function() {
                    // Remover clase active de todos
                    document.querySelectorAll('.filter-area-evaluador').forEach(b => {
                        b.classList.remove('active', 'bg-primary', 'text-white');
                        b.classList.add('bg-gray-100', 'text-gray-700');
                    });
                    // Activar este botón
                    this.classList.remove('bg-gray-100', 'text-gray-700');
                    this.classList.add('active', 'bg-primary', 'text-white');
                    
                    const areaFiltro = this.dataset.area;
                    const textoFiltro = document.getElementById('buscadorEvaluadores')?.value?.toLowerCase() || '';
                    filtrarEvaluadores(textoFiltro, areaFiltro);
                });
            });

            // Función para filtrar evaluadores por texto y área
            function filtrarEvaluadores(texto, area) {
                document.querySelectorAll('.evaluador-card').forEach(card => {
                    const textoCard = card.textContent.toLowerCase();
                    const areaCard = card.dataset.areaEvaluador || '';
                    
                    const coincideTexto = !texto || textoCard.includes(texto);
                    const coincideArea = !area || areaCard === area;
                    
                    card.style.display = (coincideTexto && coincideArea) ? '' : 'none';
                });
            }
        });
    </script>

    <%@ include file="/footer.jsp" %>
</body>
</html>
