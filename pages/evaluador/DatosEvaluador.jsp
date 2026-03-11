<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%@ include file="../../WEB-INF/conexion.jsp" %>

<%
    // Verificar si el usuario está autenticado
    Boolean autenticado = (Boolean) session.getAttribute("autenticado");
    String rol = (String) session.getAttribute("rol");
    Integer idUsuario = (Integer) session.getAttribute("id_usuario");
    String nombre = (String) session.getAttribute("nombre");
    String email = (String) session.getAttribute("email");

    // Si no está autenticado, redirigir al login
    if (autenticado == null || !autenticado) {
        response.sendRedirect(request.getContextPath() + "/pages/evaluador/login/login.jsp");
        return;
    }

    // Verificar que el rol sea evaluador
    if (!"evaluador".equals(rol)) {
        session.invalidate();
        response.sendRedirect(request.getContextPath() + "/pages/login/login.jsp?error=rol_invalido");
        return;
    }

    // Verificar si los datos del evaluador ya fueron cargados
    boolean datosCompletados = false;
    String nombreDB = "";
    String doctoradoDB = "";
    String institucionDB = "";
    String areaDB = "";
    String rutaGrado = "";
    String rutaINE = "";
    String rutaAdscripcion = "";
    String rutaCVU = "";

    if (idUsuario != null && conn != null) {
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT nombre_completo, doctorado, institucion, area_conocimiento, ruta_grado, ruta_ine, ruta_adscripcion, ruta_cvu " +
                         "FROM evaluadores WHERE id_usuario = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, idUsuario);
            rs = ps.executeQuery();

            if (rs.next()) {
                nombreDB = rs.getString("nombre_completo");
                doctoradoDB = rs.getString("doctorado");
                institucionDB = rs.getString("institucion");
                areaDB = rs.getString("area_conocimiento");
                rutaGrado = rs.getString("ruta_grado");
                rutaINE = rs.getString("ruta_ine");
                rutaAdscripcion = rs.getString("ruta_adscripcion");
                rutaCVU = rs.getString("ruta_cvu");

                // Si tiene nombre y al menos un archivo, consideramos datos completados
                if (nombreDB != null && !nombreDB.isEmpty() && rutaGrado != null && !rutaGrado.isEmpty()) {
                    datosCompletados = true;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (ps != null) try { ps.close(); } catch (Exception e) {}
        }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>COVEICYDET - Registro de Evaluador</title>
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
                        info: '#3B82F6',
                        oro: '#b07f2f',
                        oroClaro: '#efd7b1'
                    },
                    fontFamily: {
                        'sans': ['Inter', 'system-ui', '-apple-system', 'sans-serif'],
                    },
                    boxShadow: {
                        'soft': '0 4px 20px rgba(0, 0, 0, 0.05)',
                        'card': '0 8px 30px rgba(0, 0, 0, 0.08)',
                        'floating': '0 15px 50px rgba(0, 0, 0, 0.12)',
                        'gold': '0 4px 14px 0 rgba(178, 136, 84, 0.2)'
                    },
                    animation: {
                        'fade-in': 'fadeIn 0.5s ease-in',
                        'slide-up': 'slideUp 0.3s ease-out'
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
        
        .gradient-bg-gold {
            background: linear-gradient(135deg, #B28854 0%, #d4a574 100%);
        }
        
        .gradient-text {
            background: linear-gradient(135deg, #7A1737 0%, #B28854 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        
        .input-field {
            border: 1px solid #e5e7eb;
            border-radius: 12px;
            padding: 0.85rem 1rem;
            width: 100%;
            transition: all 0.3s;
            font-size: 0.95rem;
            background-color: white;
        }
        
        .input-field:focus {
            border-color: #B28854;
            box-shadow: 0 0 0 4px rgba(178, 136, 84, 0.1);
            outline: none;
        }
        
        .file-upload-btn {
            background: white;
            border: 1px solid #B28854;
            color: #7A1737;
            padding: 0.85rem 1.5rem;
            border-radius: 12px;
            font-weight: 500;
            font-size: 0.95rem;
            transition: all 0.3s;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            width: 100%;
        }
        
        .file-upload-btn:hover {
            background: #B28854;
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(178, 136, 84, 0.2);
        }
        
        .file-upload-btn i {
            color: #B28854;
            transition: all 0.3s;
        }
        
        .file-upload-btn:hover i {
            color: white;
        }
        
        .file-card {
            background: white;
            border: 1px solid #e5e7eb;
            border-radius: 12px;
            padding: 0.75rem 1rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.02);
            transition: all 0.2s;
        }
        
        .file-card:hover {
            border-color: #B28854;
            box-shadow: 0 4px 12px rgba(178, 136, 84, 0.1);
        }
        
        .file-card.has-file {
            border-color: #B28854;
            background: #f8f1e8;
        }
        
        .btn-primary {
            background: linear-gradient(145deg, #7A1737, #A8253C);
            color: white;
            padding: 0.85rem 2rem;
            border-radius: 12px;
            font-weight: 600;
            font-size: 1rem;
            transition: all 0.3s;
            border: none;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 0.75rem;
            box-shadow: 0 4px 12px rgba(122, 23, 55, 0.2);
        }
        
        .btn-primary:hover:not(:disabled) {
            background: linear-gradient(145deg, #A8253C, #7A1737);
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(122, 23, 55, 0.3);
        }
        
        .btn-primary:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }
        
        .btn-secondary {
            background: white;
            color: #4b5563;
            padding: 0.85rem 2rem;
            border-radius: 12px;
            font-weight: 600;
            font-size: 1rem;
            transition: all 0.3s;
            border: 1px solid #e5e7eb;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 0.75rem;
        }
        
        .btn-secondary:hover {
            background: #f9fafb;
            border-color: #B28854;
            color: #7A1737;
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
        }
        
        .badge-requerido {
            background: #fef3c7;
            color: #B28854;
            font-size: 0.7rem;
            padding: 0.25rem 0.75rem;
            border-radius: 9999px;
            margin-left: 0.75rem;
            font-weight: 600;
            letter-spacing: 0.3px;
        }
        
        .badge-pdf {
            background: #f1f5f9;
            color: #475569;
            font-size: 0.65rem;
            padding: 0.2rem 0.6rem;
            border-radius: 9999px;
            display: inline-flex;
            align-items: center;
            gap: 0.25rem;
        }
        
        .badge-pdf i {
            color: #B28854;
            font-size: 0.6rem;
        }
        
        .badge-documento {
            background: #faf7f2;
            color: #B28854;
            font-size: 0.7rem;
            padding: 0.25rem 0.75rem;
            border-radius: 9999px;
            border: 1px solid #e5d5c0;
        }
        
        .select-area {
            appearance: none;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 20 20'%3E%3Cpath stroke='%23B28854' stroke-linecap='round' stroke-linejoin='round' stroke-width='1.5' d='M6 8l4 4 4-4'/%3E%3C/svg%3E");
            background-position: right 1rem center;
            background-repeat: no-repeat;
            background-size: 1.5em 1.5em;
            padding-right: 3rem;
        }
        
        .section-title {
            font-size: 1.1rem;
            font-weight: 600;
            color: #1f2937;
            display: flex;
            align-items: center;
            gap: 0.75rem;
            margin-bottom: 1.5rem;
            padding-bottom: 0.75rem;
            border-bottom: 2px solid #f1e4d6;
        }
        
        .section-title i {
            color: #B28854;
            font-size: 1.2rem;
        }
        
        .preview-card {
            background: linear-gradient(145deg, #faf7f2, #f5efe6);
            border-radius: 16px;
            padding: 1.5rem;
            border: 1px solid #e5d5c0;
        }
        
        .preview-item {
            display: flex;
            flex-direction: column;
            gap: 0.25rem;
        }
        
        .preview-label {
            font-size: 0.7rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: #B28854;
            font-weight: 600;
        }
        
        .preview-value {
            font-size: 0.95rem;
            color: #1f2937;
            font-weight: 500;
        }
        
        .campo-group {
            position: relative;
            margin-bottom: 1.5rem;
        }
        
        .campo-label {
            display: flex;
            align-items: center;
            margin-bottom: 0.5rem;
            font-weight: 500;
            color: #374151;
            font-size: 0.9rem;
        }
        
        .campo-label i {
            color: #B28854;
            margin-right: 0.5rem;
            width: 1.2rem;
            font-size: 1rem;
        }
        
        .aviso-privacidad {
            background: linear-gradient(145deg, #faf7f2, #f5efe6);
            border: 1px solid #e5d5c0;
            border-radius: 16px;
            padding: 1.5rem;
            margin: 2rem 0 1.5rem 0;
        }
        
        .declaracion-texto {
            font-size: 0.95rem;
            line-height: 1.6;
            color: #374151;
            padding-left: 1rem;
            border-left: 3px solid #B28854;
        }
        
        .checkbox-custom {
            width: 1.2rem;
            height: 1.2rem;
            border: 2px solid #d1d5db;
            border-radius: 4px;
            cursor: pointer;
            transition: all 0.2s;
            appearance: none;
            -webkit-appearance: none;
        }
        
        .checkbox-custom:checked {
            background-color: #B28854;
            border-color: #B28854;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='white'%3E%3Cpath d='M20 6L9 17l-5-5' stroke='white' stroke-width='2' fill='none'/%3E%3C/svg%3E");
            background-size: 0.8rem;
            background-position: center;
            background-repeat: no-repeat;
        }
        
        .link-aviso {
            color: #7A1737;
            text-decoration: underline;
            text-decoration-color: #B28854;
            text-underline-offset: 4px;
            font-weight: 500;
            transition: all 0.2s;
        }
        
        .link-aviso:hover {
            color: #B28854;
            text-decoration-color: #7A1737;
        }
        
        .hidden-file-input {
            display: none;
        }
    </style>
</head>
<body class="bg-gradient-to-br from-[#fcf9f5] via-white to-[#faf5ee] min-h-screen font-sans text-gray-800">

    <!-- Header -->
    <header class="gradient-bg text-white shadow-lg">
        <div class="container mx-auto px-6 py-4">
            <div class="flex items-center justify-between">
                <div class="flex items-center space-x-4">
                    <div class="bg-white/20 p-3 rounded-xl">
                        <i class="fas fa-user-check text-2xl"></i>
                    </div>
                    <div>
                        <h1 class="text-2xl font-bold tracking-tight">
                            <%= datosCompletados ? "Perfil del Evaluador" : "Registro de Evaluador" %>
                        </h1>
                        <p class="text-white/90 text-sm">COVEICYDET • Sistema de Evaluación de Proyectos</p>
                    </div>
                </div>

                <div class="flex items-center space-x-3">
                    <% if (datosCompletados) { %>
                    <div class="bg-green-500/30 px-4 py-2 rounded-lg text-sm backdrop-blur-sm">
                        <i class="fas fa-check-circle mr-2"></i>
                        Datos completados
                    </div>
                    <% } else { %>
                    <div class="bg-yellow-500/30 px-4 py-2 rounded-lg text-sm backdrop-blur-sm">
                        <i class="fas fa-exclamation-triangle mr-2"></i>
                        Pendiente
                    </div>
                    <% } %>
                    <a href="<%= request.getContextPath() %>/pages/evaluador/login/logout.jsp"
                       class="bg-white/20 hover:bg-white/30 px-4 py-2 rounded-lg text-sm transition-all backdrop-blur-sm">
                        <i class="fas fa-sign-out-alt mr-2"></i>
                        Cerrar Sesión
                    </a>
                </div>
            </div>
        </div>

        <!-- Barra decorativa dorada -->
        <div class="h-1 w-full bg-gradient-to-r from-[#B28854] via-[#d4a574] to-[#B28854]"></div>
    </header>

    <!-- Main Content -->
    <main class="container mx-auto px-4 py-6">

        <% if (datosCompletados) { %>
        <!-- Vista: Datos ya completados -->
        <div class="glass-card rounded-2xl p-8 mb-6 animate-slide-up">
            <div class="text-center mb-8">
                <div class="mx-auto w-20 h-20 bg-green-100 rounded-full flex items-center justify-center mb-4">
                    <i class="fas fa-check-circle text-4xl text-green-600"></i>
                </div>
                <h2 class="text-2xl font-bold text-gray-800 mb-2">¡Registro Completado!</h2>
                <p class="text-gray-600">Sus datos han sido guardados exitosamente</p>
            </div>

            <!-- Resumen de datos -->
            <div class="bg-gradient-to-r from-[#7A1737]/5 to-[#B28854]/5 rounded-xl p-6 border border-[#B28854]/20">
                <h3 class="text-lg font-bold text-gray-800 mb-4 flex items-center gap-2">
                    <i class="fas fa-clipboard-list text-[#B28854]"></i>
                    Resumen de información registrada
                </h3>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div class="bg-white rounded-lg p-4 border border-gray-200">
                        <p class="text-xs text-gray-500 uppercase font-semibold">Nombre completo</p>
                        <p class="text-gray-800 font-medium"><%= nombreDB %></p>
                    </div>
                    <div class="bg-white rounded-lg p-4 border border-gray-200">
                        <p class="text-xs text-gray-500 uppercase font-semibold">Doctorado en</p>
                        <p class="text-gray-800 font-medium"><%= doctoradoDB %></p>
                    </div>
                    <div class="bg-white rounded-lg p-4 border border-gray-200">
                        <p class="text-xs text-gray-500 uppercase font-semibold">INE</p>
                        <p class="text-gray-800 font-medium"><%= rutaINE != null && !rutaINE.isEmpty() ? "PDF cargado" : "No cargado" %></p>
                    </div>
                    <div class="bg-white rounded-lg p-4 border border-gray-200">
                        <p class="text-xs text-gray-500 uppercase font-semibold">Institución</p>
                        <p class="text-gray-800 font-medium"><%= institucionDB %></p>
                    </div>
                    <div class="bg-white rounded-lg p-4 border border-gray-200">
                        <p class="text-xs text-gray-500 uppercase font-semibold">Área de conocimiento</p>
                        <p class="text-gray-800 font-medium"><%= areaDB %></p>
                    </div>
                    <div class="bg-white rounded-lg p-4 border border-gray-200">
                        <p class="text-xs text-gray-500 uppercase font-semibold">Estado</p>
                        <p class="text-green-600 font-medium"><i class="fas fa-check-circle mr-1"></i> Documentos cargados</p>
                    </div>
                </div>
            </div>

            <!-- Mensaje de validación -->
            <div class="bg-blue-50 border border-blue-200 rounded-xl p-4 mt-6">
                <div class="flex items-start gap-3">
                    <i class="fas fa-info-circle text-blue-600 mt-1"></i>
                    <div>
                        <p class="text-sm text-gray-700">
                            <strong>Nota:</strong> Su información está siendo revisada por el COVEICYDET.
                            Una vez validada, podrá acceder a los proyectos asignados para evaluación.
                        </p>
                    </div>
                </div>
            </div>

            <!-- Botones -->
            <div class="flex flex-col sm:flex-row gap-3 mt-6">
                <a href="<%= request.getContextPath() %>/pages/evaluador/proyectos/ProyectosAsignadosEvaluador.jsp"
                   class="btn-primary justify-center">
                    <i class="fas fa-folder-open"></i>
                    Ver Proyectos Asignados
                </a>
                <button onclick="window.print()" class="btn-secondary justify-center">
                    <i class="fas fa-print"></i>
                    Imprimir comprobante
                </button>
            </div>
        </div>
        <% } else { %>
        <!-- Vista: Formulario para completar datos -->
        <div class="glass-card rounded-2xl p-6 mb-5">
            <div class="flex items-center justify-between mb-6">
                <div class="flex items-center">
                    <div class="bg-[#B28854]/10 p-3 rounded-xl mr-4">
                        <i class="fas fa-id-card text-[#B28854] text-xl"></i>
                    </div>
                    <div>
                        <h2 class="text-xl font-bold text-gray-800">Datos del Evaluador</h2>
                        <p class="text-sm text-gray-500">Complete toda la información solicitada para el registro oficial</p>
                    </div>
                </div>
            </div>
            
            <form id="formEvaluador" class="space-y-6" action="<%= request.getContextPath() %>/pages/evaluador/procesar_datos.jsp" method="POST">
                <!-- Campos ocultos para almacenar las rutas de los archivos -->
                <input type="hidden" id="rutaGrado" name="rutaGrado" value="">
                <input type="hidden" id="rutaINE" name="rutaINE" value="">
                <input type="hidden" id="rutaAdscripcion" name="rutaAdscripcion" value="">
                <input type="hidden" id="rutaCVU" name="rutaCVU" value="">
                
                <!-- Campo 1: Nombre completo -->
                <div class="campo-group">
                    <div class="campo-label">
                        <i class="fas fa-user"></i>
                        <span>Nombre completo</span>
                        <span class="badge-requerido">Requerido</span>
                    </div>
                    <div class="relative">
                        <input type="text"
                               class="input-field"
                               name="nombreCompleto"
                               placeholder="Ingrese nombre completo del evaluador"
                               id="nombreCompleto"
                               oninput="actualizarPreview()"
                               required>
                    </div>
                </div>

                <!-- Campo 2: Doctorado en (con subida de PDF) -->
                <div class="campo-group">
                    <div class="campo-label">
                        <i class="fas fa-graduation-cap"></i>
                        <span>Doctorado en</span>
                        <span class="badge-requerido">Requerido</span>
                        <span class="badge-pdf ml-2"><i class="fas fa-file-pdf"></i> Subir PDF</span>
                    </div>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <input type="text"
                               class="input-field"
                               name="doctorado"
                               placeholder="Ej. Ciencias Biológicas, Física, etc."
                               id="doctorado"
                               oninput="actualizarPreview()"
                               required>
                        <div>
                            <!-- Input oculto para el archivo -->
                            <input type="file" id="gradoFile" accept=".pdf" class="hidden-file-input" onchange="uploadFile('grado', this)">
                            <button type="button" onclick="document.getElementById('gradoFile').click()"
                                    class="file-upload-btn">
                                <i class="fas fa-cloud-upload-alt"></i>
                                Subir documento probatorio de grado
                            </button>
                            <div id="gradoStatus" class="mt-2 text-xs text-gray-500 flex items-center">
                                <i class="far fa-circle mr-1 text-gray-400"></i>
                                Ningún archivo seleccionado
                            </div>
                            <!-- Información del archivo -->
                            <div id="gradoFileInfo" class="file-card mt-2 hidden">
                                <div class="flex items-center">
                                    <i class="fas fa-file-pdf text-[#B28854] mr-2"></i>
                                    <span class="text-sm" id="gradoFileName"></span>
                                </div>
                                <button type="button" onclick="deleteFile('grado')" class="text-gray-400 hover:text-red-500">
                                    <i class="fas fa-times"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Campo 3: INE (solo subir pdf) -->
                <div class="campo-group">
                    <div class="campo-label">
                        <i class="fas fa-id-card"></i>
                        <span>INE / Identificación oficial</span>
                        <span class="badge-requerido">Requerido</span>
                        <span class="badge-pdf ml-2"><i class="fas fa-file-pdf"></i> Subir PDF</span>
                    </div>
                    <div>
                        <!-- Input oculto para el archivo -->
                        <input type="file" id="ineFile" accept=".pdf" class="hidden-file-input" onchange="uploadFile('ine', this)">
                        <button type="button" onclick="document.getElementById('ineFile').click()"
                                class="file-upload-btn">
                            <i class="fas fa-cloud-upload-alt"></i>
                            Subir INE (PDF)
                        </button>
                        <div id="ineStatus" class="mt-2 text-xs text-gray-500 flex items-center">
                            <i class="far fa-circle mr-1 text-gray-400"></i>
                            Ningún archivo seleccionado
                        </div>
                        <!-- Información del archivo -->
                        <div id="ineFileInfo" class="file-card mt-2 hidden">
                            <div class="flex items-center">
                                <i class="fas fa-file-pdf text-[#B28854] mr-2"></i>
                                <span class="text-sm" id="ineFileName"></span>
                            </div>
                            <button type="button" onclick="deleteFile('ine')" class="text-gray-400 hover:text-red-500">
                                <i class="fas fa-times"></i>
                            </button>
                        </div>
                    </div>
                </div>
                
                <!-- Campo 4: Institución de adscripción (con subida de PDF) -->
                <div class="campo-group">
                    <div class="campo-label">
                        <i class="fas fa-building"></i>
                        <span>Institución de adscripción</span>
                        <span class="badge-requerido">Requerido</span>
                        <span class="badge-pdf ml-2"><i class="fas fa-file-pdf"></i> Subir PDF</span>
                    </div>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <input type="text"
                               class="input-field"
                               name="institucion"
                               placeholder="Ej. ITSX, UV, etc."
                               id="institucion"
                               oninput="actualizarPreview()"
                               required>
                        <div>
                            <!-- Input oculto para el archivo -->
                            <input type="file" id="adscripcionFile" accept=".pdf" class="hidden-file-input" onchange="uploadFile('adscripcion', this)">
                            <button type="button" onclick="document.getElementById('adscripcionFile').click()"
                                    class="file-upload-btn">
                                <i class="fas fa-cloud-upload-alt"></i>
                                Subir documento probatorio de adscripción
                            </button>
                            <div id="adscripcionStatus" class="mt-2 text-xs text-gray-500 flex items-center">
                                <i class="far fa-circle mr-1 text-gray-400"></i>
                                Ningún archivo seleccionado
                            </div>
                            <!-- Información del archivo -->
                            <div id="adscripcionFileInfo" class="file-card mt-2 hidden">
                                <div class="flex items-center">
                                    <i class="fas fa-file-pdf text-[#B28854] mr-2"></i>
                                    <span class="text-sm" id="adscripcionFileName"></span>
                                </div>
                                <button type="button" onclick="deleteFile('adscripcion')" class="text-gray-400 hover:text-red-500">
                                    <i class="fas fa-times"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Campo 5: Área del conocimiento -->
                <div class="campo-group">
                    <div class="campo-label">
                        <i class="fas fa-brain"></i>
                        <span>Área del conocimiento</span>
                        <span class="badge-requerido">Requerido</span>
                        <span class="badge-documento ml-2">SECIHTI</span>
                    </div>
                    <select class="input-field select-area" name="areaConocimiento" id="areaConocimiento" onchange="actualizarPreview()" required>
                        <option value="" disabled selected>Seleccione un área según clasificación SECIHTI</option>
                        <option value="fisicoMatematicas">I - Físico-Matemáticas y Ciencias de la Tierra</option>
                        <option value="biologiaQuimica">II - Biología y Química</option>
                        <option value="medicinaCienciasSalud">III - Medicina y Ciencias de la Salud</option>
                        <option value="cienciasConductaEducacion">IV - Ciencias de la Conducta y la Educación</option>
                        <option value="humanidades">V - Humanidades</option>
                        <option value="cienciasSociales">VI - Ciencias Sociales</option>
                        <option value="cienciasAgricultura">VII - Ciencias de Agricultura, Agropecuarias, Forestales y de Ecosistemas</option>
                        <option value="ingenieriasDesarrollo">VIII - Ingenierías y Desarrollo Tecnológico</option>
                        <option value="interdisciplinaria">IX - Interdisciplinaria</option>
                    </select>
                </div>

                <!-- Campo 6: CVU SECIHTI -->
                <div class="campo-group">
                    <div class="campo-label">
                        <i class="fas fa-file-alt"></i>
                        <span>CVU SECIHTI</span>
                        <span class="badge-requerido">Requerido</span>
                        <span class="badge-pdf ml-2"><i class="fas fa-file-pdf"></i> PDF</span>
                    </div>
                    <div>
                        <input type="file" id="cvuFile" accept=".pdf" class="hidden-file-input" onchange="uploadFile('cvu', this)">
                        <button type="button" onclick="document.getElementById('cvuFile').click()"
                                class="file-upload-btn">
                            <i class="fas fa-cloud-upload-alt"></i>
                            Subir CVU SECIHTI (PDF)
                        </button>

                        <div id="cvuStatus" class="mt-2 text-xs text-gray-500 flex items-center">
                            <i class="far fa-circle mr-1 text-gray-400"></i>
                            Ningún archivo seleccionado
                        </div>
                        <div id="cvuFileInfo" class="file-card mt-2 hidden">
                            <div class="flex items-center">
                                <i class="fas fa-file-pdf text-[#B28854] mr-2"></i>
                                <span class="text-sm" id="cvuFileName"></span>
                            </div>
                            <button type="button" onclick="deleteFile('cvu')" class="text-gray-400 hover:text-red-500">
                                <i class="fas fa-times"></i>
                            </button>
                        </div>
                    </div>
                </div>
                
                <!-- Aviso de Privacidad y Declaración -->
                <div class="aviso-privacidad">
                    <div class="flex items-start gap-3">
                        <div class="pt-1">
                            <input type="checkbox" id="aceptoAviso" class="checkbox-custom" onchange="actualizarEstadoBoton(); actualizarStatusDocumentos();">
                        </div>
                        <div class="flex-1">
                            <div class="declaracion-texto">
                                Declaro que la información proporcionada es verídica y autorizo su verificación por parte de COVEICYDET.
                            </div>
                            
                            <!-- Enlace para descargar aviso de privacidad -->
                            <div class="mt-4 flex items-center justify-between">
                                <a href="#" onclick="descargarAvisoPrivacidad(event)" class="link-aviso text-sm flex items-center gap-2">
                                    <i class="fas fa-file-pdf text-[#B28854]"></i>
                                    Descargar Aviso de Privacidad (PDF)
                                    <i class="fas fa-download text-xs ml-1"></i>
                                </a>
                                
                                <span class="text-xs text-gray-500">
                                    <i class="fas fa-info-circle mr-1"></i>
                                    Lea el aviso antes de aceptar
                                </span>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Botones de acción -->
                <div class="flex flex-col sm:flex-row justify-end gap-3 pt-4">
                    <button type="button" onclick="limpiarFormulario()" class="btn-secondary">
                        <i class="fas fa-eraser"></i>
                        Limpiar formulario
                    </button>
                    <button type="button" onclick="guardarEvaluador()" id="btnGuardar" class="btn-primary opacity-50 cursor-not-allowed" disabled>
                        <i class="fas fa-save"></i>
                        Guardar registro
                    </button>
                </div>
            </form>
        </div>
        
        <!-- Resumen del registro -->
        <div class="glass-card rounded-2xl p-6">
            <div class="section-title">
                <i class="fas fa-clipboard-list"></i>
                <span>Resumen del registro</span>
            </div>
            
            <div class="preview-card">
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    <div class="preview-item">
                        <span class="preview-label">Nombre completo</span>
                        <span class="preview-value" id="previewNombre">—</span>
                    </div>
                    <div class="preview-item">
                        <span class="preview-label">Doctorado en</span>
                        <span class="preview-value" id="previewDoctorado">—</span>
                    </div>
                    <div class="preview-item">
                        <span class="preview-label">INE</span>
                        <span class="preview-value" id="previewINE">PDF no cargado</span>
                    </div>
                    <div class="preview-item">
                        <span class="preview-label">Institución</span>
                        <span class="preview-value" id="previewInstitucion">—</span>
                    </div>
                    <div class="preview-item">
                        <span class="preview-label">Área del conocimiento</span>
                        <span class="preview-value" id="previewArea">—</span>
                    </div>
                    <div class="preview-item">
                        <span class="preview-label">CVU SECIHTI</span>
                        <span class="preview-value" id="previewCVU">—</span>
                    </div>
                </div>
                
                <!-- Documentos adjuntos -->
                <div class="mt-4 pt-4 border-t border-[#e5d5c0]">
                    <div class="grid grid-cols-2 md:grid-cols-5 gap-2 text-xs">
                        <div class="flex items-center" id="previewGrado">
                            <i class="far fa-circle mr-1 text-gray-400"></i>
                            <span>Grado</span>
                        </div>
                        <div class="flex items-center" id="previewINEStatus">
                            <i class="far fa-circle mr-1 text-gray-400"></i>
                            <span>INE</span>
                        </div>
                        <div class="flex items-center" id="previewAdscripcion">
                            <i class="far fa-circle mr-1 text-gray-400"></i>
                            <span>Adscripción</span>
                        </div>
                        <div class="flex items-center" id="previewCVUStatus">
                            <i class="far fa-circle mr-1 text-gray-400"></i>
                            <span>CVU</span>
                        </div>
                        <div class="flex items-center" id="previewAceptacion">
                            <i class="far fa-circle mr-1 text-gray-400"></i>
                            <span>Aceptación</span>
                        </div>
                    </div>
                </div>
                
                <div class="mt-4 flex items-center text-xs text-[#B28854]">
                    <i class="fas fa-check-circle mr-1"></i>
                    Todos los documentos serán verificados por COVEICYDET
                </div>
            </div>
        </div>
        <% } %>
    </main>

    <!-- Toast Container -->
    <div id="toastContainer" class="fixed bottom-6 right-6 z-40 space-y-3"></div>

    <script>
        const STORAGE_KEY = 'evaluador_registro_data';
        
        // Variables para almacenar las rutas de los archivos
        let archivosSubidos = {
            grado: { webUrl: '', originalName: '' },
            ine: { webUrl: '', originalName: '' },
            adscripcion: { webUrl: '', originalName: '' },
            cvu: { webUrl: '', originalName: '' }
        };
        
        // Cargar datos guardados en localStorage al iniciar
        function cargarDatosGuardados() {
            try {
                const guardado = localStorage.getItem(STORAGE_KEY);
                if (guardado) {
                    const datos = JSON.parse(guardado);
                    
                    // Mapeo de tipos a IDs de campos ocultos
                    const idsMap = {
                        'grado': 'rutaGrado',
                        'ine': 'rutaINE',
                        'adscripcion': 'rutaAdscripcion',
                        'cvu': 'rutaCVU'
                    };
                    
                    // Restaurar archivos
                    if (datos.archivos) {
                        archivosSubidos = datos.archivos;
                        
                        // Actualizar campos ocultos
                        for (const tipo in archivosSubidos) {
                            const campoId = idsMap[tipo];
                            if (campoId) {
                                document.getElementById(campoId).value = archivosSubidos[tipo].webUrl || '';
                            }
                        }
                        
                        // Actualizar UI de archivos
                        if (archivosSubidos.grado.webUrl) {
                            actualizarUIArchivo('grado', archivosSubidos.grado.originalName, true);
                        }
                        if (archivosSubidos.ine.webUrl) {
                            actualizarUIArchivo('ine', archivosSubidos.ine.originalName, true);
                        }
                        if (archivosSubidos.adscripcion.webUrl) {
                            actualizarUIArchivo('adscripcion', archivosSubidos.adscripcion.originalName, true);
                        }
                        if (archivosSubidos.cvu.webUrl) {
                            actualizarUIArchivo('cvu', archivosSubidos.cvu.originalName, true);
                        }
                    }
                    
                    // Restaurar campos de texto
                    if (datos.campos) {
                        if (datos.campos.nombreCompleto) {
                            document.getElementById('nombreCompleto').value = datos.campos.nombreCompleto;
                        }
                        if (datos.campos.doctorado) {
                            document.getElementById('doctorado').value = datos.campos.doctorado;
                        }
                        if (datos.campos.institucion) {
                            document.getElementById('institucion').value = datos.campos.institucion;
                        }
                        if (datos.campos.areaConocimiento) {
                            document.getElementById('areaConocimiento').value = datos.campos.areaConocimiento;
                        }
                    }
                    
                    console.log('>>> [CACHE] Datos restaurados:', datos);
                }
            } catch (e) {
                console.error('>>> [CACHE] Error cargando datos:', e);
            }
        }
        
        // Guardar datos en localStorage
        function guardarDatosEnCache() {
            try {
                const datos = {
                    archivos: archivosSubidos,
                    campos: {
                        nombreCompleto: document.getElementById('nombreCompleto').value,
                        doctorado: document.getElementById('doctorado').value,
                        institucion: document.getElementById('institucion').value,
                        areaConocimiento: document.getElementById('areaConocimiento').value
                    }
                };
                localStorage.setItem(STORAGE_KEY, JSON.stringify(datos));
                console.log('>>> [CACHE] Datos guardados');
            } catch (e) {
                console.error('>>> [CACHE] Error guardando datos:', e);
            }
        }
        
        // Limpiar cache (después de guardar exitosamente)
        function limpiarCache() {
            localStorage.removeItem(STORAGE_KEY);
            console.log('>>> [CACHE] Cache limpiado');
        }

        // Subir archivo usando AJAX + Base64 (como en registroProyecto.jsp)
        function uploadFile(tipo, input) {
            if (input.files && input.files[0]) {
                const file = input.files[0];

                console.log('>>> [UPLOAD] Archivo seleccionado:', file.name, 'Tipo:', file.type, 'Tamaño:', file.size);

                // Validar que sea PDF
                if (file.type !== 'application/pdf') {
                    mostrarToast('Solo se permiten archivos PDF', 'error');
                    input.value = '';
                    return;
                }

                // Validar tamaño (10 MB máximo)
                if (file.size > 10 * 1024 * 1024) {
                    mostrarToast('El archivo no debe exceder 10 MB', 'error');
                    input.value = '';
                    return;
                }

                // Mostrar mensaje de carga
                mostrarToast('Subiendo archivo...', 'info');

                // Leer archivo como Base64
                const reader = new FileReader();
                reader.onload = function(e) {
                    const base64Data = e.target.result;
                    
                    console.log('>>> [UPLOAD] Base64 length:', base64Data.length);

                    // Mapeo de tipos a IDs de campos ocultos
                    const idsMap = {
                        'grado': 'rutaGrado',
                        'ine': 'rutaINE',
                        'adscripcion': 'rutaAdscripcion',
                        'cvu': 'rutaCVU'
                    };

                    // Enviar al servidor usando URL-encoded (no multipart)
                    const params = new URLSearchParams();
                    params.append('fileData', base64Data);
                    params.append('fileName', file.name);
                    params.append('tipoArchivo', tipo);
                    
                    console.log('>>> [UPLOAD] Enviando params:', {
                        fileName: file.name,
                        tipoArchivo: tipo,
                        base64Length: base64Data.length
                    });

                    fetch('<%= request.getContextPath() %>/pages/evaluador/upload.jsp', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded'
                        },
                        body: params
                    })
                    .then(response => {
                        console.log('>>> [UPLOAD] Response status:', response.status);
                        return response.json();
                    })
                    .then(data => {
                        console.log('>>> [UPLOAD] Response data:', data);
                        if (data.success) {
                            // Guardar ruta del archivo
                            archivosSubidos[tipo].webUrl = data.webUrl;
                            archivosSubidos[tipo].originalName = data.originalName;

                            // Actualizar campo oculto con la ruta (usando mapeo correcto)
                            const campoId = idsMap[tipo];
                            if (campoId) {
                                document.getElementById(campoId).value = data.webUrl;
                            }

                            // Actualizar UI
                            actualizarUIArchivo(tipo, file.name);
                            mostrarToast('Archivo subido exitosamente', 'success');
                        } else {
                            mostrarToast('Error al subir: ' + data.message, 'error');
                            input.value = '';
                        }
                    })
                    .catch(error => {
                        console.error('>>> [UPLOAD] Error:', error);
                        mostrarToast('Error de conexión: ' + error, 'error');
                        input.value = '';
                    });
                };
                reader.onerror = function(error) {
                    console.error('>>> [UPLOAD] Error leyendo archivo:', error);
                    mostrarToast('Error al leer el archivo', 'error');
                };
                reader.readAsDataURL(file);
            }
        }

        // Actualizar UI después de subir archivo
        function actualizarUIArchivo(tipo, fileName, skipCache = false) {
            const fileInfo = document.getElementById(tipo + 'FileInfo');
            const fileNameSpan = document.getElementById(tipo + 'FileName');
            const statusDiv = document.getElementById(tipo + 'Status');

            if (fileInfo && fileNameSpan && statusDiv) {
                fileNameSpan.textContent = fileName;
                fileInfo.classList.remove('hidden');
                statusDiv.innerHTML = '<i class="fas fa-check-circle text-[#B28854] mr-1"></i><span class="text-[#B28854]">Archivo cargado</span>';
            }

            actualizarPreview();
            actualizarStatusDocumentos();
            actualizarEstadoBoton();
            
            if (!skipCache) {
                guardarDatosEnCache();
            }
        }

        // Eliminar archivo
        function deleteFile(tipo) {
            const webUrl = archivosSubidos[tipo].webUrl;
            if (!webUrl) return;

            if (!confirm('¿Está seguro de eliminar este archivo?')) return;

            // Mapeo de tipos a IDs de campos ocultos
            const idsMap = {
                'grado': 'rutaGrado',
                'ine': 'rutaINE',
                'adscripcion': 'rutaAdscripcion',
                'cvu': 'rutaCVU'
            };

            // Enviar solicitud de eliminación
            const params = new URLSearchParams();
            params.append('fileUrl', webUrl);

            fetch('<%= request.getContextPath() %>/pages/evaluador/deleteFile.jsp', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: params
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    // Limpiar datos
                    archivosSubidos[tipo].webUrl = '';
                    archivosSubidos[tipo].originalName = '';
                    
                    // Limpiar campo oculto (usando mapeo correcto)
                    const campoId = idsMap[tipo];
                    if (campoId) {
                        document.getElementById(campoId).value = '';
                    }

                    // Resetear input file
                    document.getElementById(tipo + 'File').value = '';

                    // Actualizar UI
                    const fileInfo = document.getElementById(tipo + 'FileInfo');
                    const statusDiv = document.getElementById(tipo + 'Status');

                    if (fileInfo) fileInfo.classList.add('hidden');
                    if (statusDiv) statusDiv.innerHTML = '<i class="far fa-circle mr-1 text-gray-400"></i>Ningún archivo seleccionado';

                    actualizarPreview();
                    actualizarStatusDocumentos();
                    actualizarEstadoBoton();
                    mostrarToast('Archivo eliminado', 'success');
                } else {
                    mostrarToast('Error al eliminar: ' + data.message, 'error');
                }
            })
            .catch(error => {
                console.error('>>> [DELETE] Error:', error);
                mostrarToast('Error de conexión: ' + error, 'error');
            });
        }
        
        // Actualizar estado del botón de guardar
        function actualizarEstadoBoton() {
            const btnGuardar = document.getElementById('btnGuardar');
            if (!btnGuardar) return; // Si no existe el botón (vista de completado), salir
            
            const acepto = document.getElementById('aceptoAviso');
            if (!acepto) return; // Si no existe el checkbox, salir
            
            const aceptoChecked = acepto.checked;

            if (aceptoChecked) {
                btnGuardar.disabled = false;
                btnGuardar.classList.remove('opacity-50', 'cursor-not-allowed');
            } else {
                btnGuardar.disabled = true;
                btnGuardar.classList.add('opacity-50', 'cursor-not-allowed');
            }

            actualizarStatusDocumentos();
        }

        // Actualizar status de documentos en preview
        function actualizarStatusDocumentos() {
            // Grado
            const previewGrado = document.getElementById('previewGrado');
            if (previewGrado) {
                if (archivosSubidos.grado.webUrl) {
                    previewGrado.innerHTML = '<i class="fas fa-check-circle text-[#B28854] mr-1"></i><span class="text-[#B28854]">Grado</span>';
                } else {
                    previewGrado.innerHTML = '<i class="far fa-circle mr-1 text-gray-400"></i><span class="text-gray-400">Grado</span>';
                }
            }

            // INE
            const previewINE = document.getElementById('previewINEStatus');
            if (previewINE) {
                if (archivosSubidos.ine.webUrl) {
                    previewINE.innerHTML = '<i class="fas fa-check-circle text-[#B28854] mr-1"></i><span class="text-[#B28854]">INE</span>';
                } else {
                    previewINE.innerHTML = '<i class="far fa-circle mr-1 text-gray-400"></i><span class="text-gray-400">INE</span>';
                }
            }

            // Adscripción
            const previewAdscripcion = document.getElementById('previewAdscripcion');
            if (previewAdscripcion) {
                if (archivosSubidos.adscripcion.webUrl) {
                    previewAdscripcion.innerHTML = '<i class="fas fa-check-circle text-[#B28854] mr-1"></i><span class="text-[#B28854]">Adscripción</span>';
                } else {
                    previewAdscripcion.innerHTML = '<i class="far fa-circle mr-1 text-gray-400"></i><span class="text-gray-400">Adscripción</span>';
                }
            }

            // CVU
            const previewCVUStatus = document.getElementById('previewCVUStatus');
            if (previewCVUStatus) {
                if (archivosSubidos.cvu.webUrl) {
                    previewCVUStatus.innerHTML = '<i class="fas fa-check-circle text-[#B28854] mr-1"></i><span class="text-[#B28854]">CVU</span>';
                } else {
                    previewCVUStatus.innerHTML = '<i class="far fa-circle mr-1 text-gray-400"></i><span class="text-gray-400">CVU</span>';
                }
            }

            // Aceptación
            const previewAceptacion = document.getElementById('previewAceptacion');
            if (previewAceptacion) {
                const aceptoCheckbox = document.getElementById('aceptoAviso');
                if (aceptoCheckbox && aceptoCheckbox.checked) {
                    previewAceptacion.innerHTML = '<i class="fas fa-check-circle text-[#B28854] mr-1"></i><span class="text-[#B28854]">Aceptación</span>';
                } else {
                    previewAceptacion.innerHTML = '<i class="far fa-circle mr-1 text-gray-400"></i><span class="text-gray-400">Aceptación</span>';
                }
            }
        }
        
        // Actualizar vista previa
        function actualizarPreview() {
            document.getElementById('previewNombre').textContent = document.getElementById('nombreCompleto').value || '—';
            document.getElementById('previewDoctorado').textContent = document.getElementById('doctorado').value || '—';
            document.getElementById('previewInstitucion').textContent = document.getElementById('institucion').value || '—';

            // Actualizar estado del INE (PDF)
            const previewINE = document.getElementById('previewINE');
            if (previewINE) {
                previewINE.textContent = archivosSubidos.ine.webUrl ? 'PDF cargado' : 'PDF no cargado';
            }

            const areaSelect = document.getElementById('areaConocimiento');
            const areaText = areaSelect.options[areaSelect.selectedIndex]?.text || '—';
            document.getElementById('previewArea').textContent = areaText !== 'Seleccione un área según clasificación SECIHTI' ? areaText : '—';

            document.getElementById('previewCVU').textContent = archivosSubidos.cvu.webUrl ? 'PDF cargado' : '—';
        }
        
        // Función para descargar aviso de privacidad
        function descargarAvisoPrivacidad(event) {
            event.preventDefault();
            
            // Simular descarga de PDF
            mostrarToast('Iniciando descarga del Aviso de Privacidad...', 'info');
            
            setTimeout(() => {
                mostrarToast('Aviso de Privacidad descargado', 'success');
            }, 1500);
        }
        
        // Validar formulario
        function validarFormulario() {
            if (!document.getElementById('nombreCompleto').value.trim()) {
                mostrarToast('El campo Nombre completo es requerido', 'warning');
                return false;
            }

            if (!document.getElementById('doctorado').value.trim()) {
                mostrarToast('El campo Doctorado en es requerido', 'warning');
                return false;
            }

            if (!document.getElementById('institucion').value.trim()) {
                mostrarToast('El campo Institución de adscripción es requerido', 'warning');
                return false;
            }

            const area = document.getElementById('areaConocimiento').value;
            if (!area) {
                mostrarToast('Debe seleccionar un área del conocimiento', 'warning');
                return false;
            }

            // Validar que los archivos estén subidos
            if (!archivosSubidos.grado.webUrl) {
                mostrarToast('Debe subir el documento probatorio de grado', 'warning');
                return false;
            }

            if (!archivosSubidos.ine.webUrl) {
                mostrarToast('Debe subir el archivo PDF del INE', 'warning');
                return false;
            }

            if (!archivosSubidos.adscripcion.webUrl) {
                mostrarToast('Debe subir el documento probatorio de adscripción', 'warning');
                return false;
            }

            if (!archivosSubidos.cvu.webUrl) {
                mostrarToast('Debe subir el archivo CVU SECIHTI', 'warning');
                return false;
            }

            if (!document.getElementById('aceptoAviso').checked) {
                mostrarToast('Debe aceptar la declaración', 'warning');
                return false;
            }

            return true;
        }

        // Guardar evaluador
        function guardarEvaluador() {
            if (!validarFormulario()) {
                return;
            }

            // Mostrar mensaje de carga
            mostrarToast('Guardando datos...', 'info');

            // Deshabilitar botón
            const btn = document.getElementById('btnGuardar');
            btn.disabled = true;
            btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Guardando...';

            // Marcar para limpiar cache después de guardar
            sessionStorage.setItem('limpiar_cache_evaluador', 'true');

            // Enviar formulario
            document.getElementById('formEvaluador').submit();
        }

        // Limpiar formulario
        function limpiarFormulario() {
            if (confirm('¿Está seguro de que desea limpiar todos los campos?')) {
                document.getElementById('formEvaluador').reset();

                // Mapeo de tipos a IDs de campos ocultos
                const idsMap = {
                    'grado': 'rutaGrado',
                    'ine': 'rutaINE',
                    'adscripcion': 'rutaAdscripcion',
                    'cvu': 'rutaCVU'
                };

                // Limpiar campos ocultos de rutas
                for (const tipo in idsMap) {
                    document.getElementById(idsMap[tipo]).value = '';
                }

                // Resetear archivos subidos
                archivosSubidos.grado.webUrl = '';
                archivosSubidos.grado.originalName = '';
                archivosSubidos.ine.webUrl = '';
                archivosSubidos.ine.originalName = '';
                archivosSubidos.adscripcion.webUrl = '';
                archivosSubidos.adscripcion.originalName = '';
                archivosSubidos.cvu.webUrl = '';
                archivosSubidos.cvu.originalName = '';

                // Limpiar inputs file
                document.getElementById('gradoFile').value = '';
                document.getElementById('ineFile').value = '';
                document.getElementById('adscripcionFile').value = '';
                document.getElementById('cvuFile').value = '';

                // Ocultar información de archivos
                document.getElementById('gradoFileInfo').classList.add('hidden');
                document.getElementById('ineFileInfo').classList.add('hidden');
                document.getElementById('adscripcionFileInfo').classList.add('hidden');
                document.getElementById('cvuFileInfo').classList.add('hidden');

                // Resetear status
                document.getElementById('gradoStatus').innerHTML = '<i class="far fa-circle mr-1 text-gray-400"></i>Ningún archivo seleccionado';
                document.getElementById('ineStatus').innerHTML = '<i class="far fa-circle mr-1 text-gray-400"></i>Ningún archivo seleccionado';
                document.getElementById('adscripcionStatus').innerHTML = '<i class="far fa-circle mr-1 text-gray-400"></i>Ningún archivo seleccionado';
                document.getElementById('cvuStatus').innerHTML = '<i class="far fa-circle mr-1 text-gray-400"></i>Ningún archivo seleccionado';

                // Resetear checkbox
                document.getElementById('aceptoAviso').checked = false;

                // Limpiar cache
                limpiarCache();

                actualizarPreview();
                actualizarStatusDocumentos();
                actualizarEstadoBoton();
                mostrarToast('Formulario limpiado', 'info');
            }
        }
        
        // Mostrar toast
        function mostrarToast(mensaje, tipo = 'info') {
            const container = document.getElementById('toastContainer');
            const toast = document.createElement('div');
            
            const config = {
                success: { bg: 'bg-gradient-to-r from-[#B28854] to-[#d4a574]', icon: 'check-circle' },
                error: { bg: 'bg-gradient-to-r from-red-500 to-red-600', icon: 'exclamation-circle' },
                info: { bg: 'bg-gradient-to-r from-blue-500 to-blue-600', icon: 'info-circle' },
                warning: { bg: 'bg-gradient-to-r from-yellow-500 to-yellow-600', icon: 'exclamation-triangle' }
            };
            
            toast.className = `${config[tipo].bg} text-white px-5 py-4 rounded-xl shadow-floating flex items-center text-sm animate-fade-in`;
            toast.innerHTML = `<i class="fas fa-${config[tipo].icon} mr-3 text-lg"></i><span>${mensaje}</span>`;
            
            container.appendChild(toast);
            setTimeout(() => toast.remove(), 3000);
        }
        
        // Inicializar
        document.addEventListener('DOMContentLoaded', function() {
            // Verificar si hay que limpiar cache (después de guardar exitosamente)
            if (sessionStorage.getItem('limpiar_cache_evaluador') === 'true') {
                limpiarCache();
                sessionStorage.removeItem('limpiar_cache_evaluador');
            }
            
            // Cargar datos guardados en localStorage
            cargarDatosGuardados();
            
            // Inicializar status
            actualizarStatusDocumentos();
            actualizarEstadoBoton();

            // Agregar listeners para guardar automáticamente al escribir
            const campos = ['nombreCompleto', 'doctorado', 'ine', 'institucion', 'areaConocimiento'];
            campos.forEach(function(id) {
                const el = document.getElementById(id);
                if (el) {
                    el.addEventListener('input', guardarDatosEnCache);
                    el.addEventListener('change', guardarDatosEnCache);
                }
            });

            // Mostrar mensaje de éxito si viene de la sesión
            <% String datosGuardados = (String) session.getAttribute("datos_guardados");
               String errorDatos = (String) session.getAttribute("error_datos");
               if ("true".equals(datosGuardados)) { %>
            mostrarToast('Datos guardados exitosamente. Su registro está completo.', 'success');
            <% session.removeAttribute("datos_guardados"); } %>

            <% if (errorDatos != null && !errorDatos.isEmpty()) { %>
            mostrarToast('<%= errorDatos.replace("'", "\\'") %>', 'error');
            <% session.removeAttribute("error_datos"); } %>
        });
    </script>
</body>
</html>