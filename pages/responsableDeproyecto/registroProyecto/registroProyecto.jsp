<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.regex.*" %>

<% if (!"responsable".equals(String.valueOf(session.getAttribute("rol")))) { String n=request.getRequestURI()+(request.getQueryString()!=null?("?"+request.getQueryString()):""); response.sendRedirect(request.getContextPath()+"/pages/login/login.jsp?next="+java.net.URLEncoder.encode(n,"UTF-8")); return; } %>
<%!
    private static final String DB_URL = "jdbc:postgresql://localhost:5432/proyectos";
    private static final String DB_USER = "dbusr25";
    private static final String DB_PASSWORD = "mxToro24000Chocolate";

    private static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
    }
%>

<%
    //--- BLOQUEO DE SEGURIDAD ---//
    Integer idUsuarioSeguridad = (Integer) session.getAttribute("id_usuario");

    if (idUsuarioSeguridad != null) {
        boolean yaTieneProyecto = false;

        try (Connection conn = getConnection();
            PreparedStatement ps = conn.prepareStatement("SELECT 1 FROM proyecto_usuarios WHERE id_usuario = ? LIMIT 1")) {

                ps.setInt(1, idUsuarioSeguridad);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        yaTieneProyecto = true;
                    }
                }
                } catch (Exception e) {
                    e.printStackTrace();
                }
                if (yaTieneProyecto) {
                    response.sendRedirect(request.getContextPath() + "/pages/responsableDeproyecto/paginaPrincipal/index.jsp");
                    return;
                }
        }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registro de Proyecto - COVEICYDET</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');
        
        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
        }
        
        .form-container {
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
        }
        
        .floating-input {
            border: 1px solid #cbd5e0;
            border-radius: 0.5rem;
            padding: 0.75rem;
            width: 100%;
            transition: all 0.2s;
        }
        
        .floating-input:focus {
            outline: none;
            border-color: #7A1737;
            box-shadow: 0 0 0 3px rgba(122, 23, 55, 0.2);
        }
        
        .table-input {
            border: 1px solid #d1d5db;
            border-radius: 0.375rem;
            padding: 0.5rem;
            width: 100%;
            font-size: 0.875rem;
        }
        
        .table-input:focus {
            outline: none;
            border-color: #7A1737;
            box-shadow: 0 0 0 2px rgba(122, 23, 55, 0.2);
        }
    </style>
</head>
<%@ include file="../header.jsp" %>
<%@ include file="Navegador.jsp" %>
<body class="min-h-screen flex flex-col">
    <!-- Contenido principal -->
    <main class="flex-grow py-8">
        <div class="container mx-auto px-4">
            <div class="form-container bg-white rounded-xl overflow-hidden border border-slate-200">
                <!-- Encabezado del formulario -->
                <div class="bg-[#B28854] p-6">
                    <h1 class="text-2xl font-bold text-white flex items-center">
                        <i class="fas fa-file-alt mr-3"></i>Datos generales 1/10
                    </h1>
                    <p class="text-white/90 mt-2 flex items-center">
                        <i class="fas fa-info-circle mr-2"></i>Complete cada sección (todos los campos son necesarios)
                    </p>
                </div>

                <!-- Formulario -->
                <form id="formPagina1" class="p-8 space-y-8">
                    <!-- titulo proyecto -->
                    <div>
                        <label for="titulo" class="block text-sm font-medium text-gray-700 mb-2 flex items-center">
                            <i class="fas fa-heading text-[#7A1737] mr-2"></i>Título del Proyecto
                            <span class="ml-2 text-gray-500 cursor-help" title="Ingrese el título completo del proyecto que desea registrar">
                                <i class="fas fa-question-circle"></i>
                            </span>
                        </label>
                        <input type="text" id="titulo" name="titulo" required 
                               class="floating-input" placeholder="Ejemplo: Desarrollo de una aplicación móvil para la gestión de recursos educativos">
                    </div>

                    <!-- Institución proponente -->
                    <div>
                        <label for="institucion" class="block text-sm font-medium text-gray-700 mb-2 flex items-center">
                            <i class="fas fa-university text-[#7A1737] mr-2"></i>Institución Proponente
                        </label>
                        <div class="relative" id="institucion-wrapper">
                            <input type="text" id="institucion_search" class="floating-input pr-10" placeholder="Buscar institución..." autocomplete="off">
                            <input type="hidden" id="institucion" name="institucion" required>
                            <div class="absolute inset-y-0 right-0 flex items-center px-3 pointer-events-none text-gray-500">
                                <i class="fas fa-chevron-down text-xs"></i>
                            </div>
                            <div id="institucion_dropdown" class="hidden absolute z-20 w-full bg-white border border-gray-300 mt-1 max-h-60 overflow-y-auto rounded-md shadow-lg">
                                <%
                                    try (Connection conn = getConnection();
                                        Statement stmt = conn.createStatement();
                                        ResultSet rs = stmt.executeQuery("SELECT institucion FROM instituciones ORDER BY institucion ASC")) {
                                        while (rs.next()) {
                                            String inst = rs.getString("institucion");
                                            String safeInst = inst != null ? inst.replace("\"", "&quot;") : "";
                                %>
                                            <div class="institucion-option px-4 py-2 hover:bg-gray-100 cursor-pointer text-sm text-gray-700" 
                                                 data-value="<%= safeInst %>">
                                                <%= inst %>
                                            </div>
                                <%
                                        }
                                    } catch (Exception e) {
                                        e.printStackTrace();
                                    }
                                %>
                                <div id="institucion_no_results" class="hidden px-4 py-2 text-sm text-gray-500">No se encontraron resultados</div>
                            </div>
                        </div>
                        <p class="mt-2 text-xs text-blue-600 flex items-center font-medium bg-blue-50 p-2 rounded border border-blue-100">
                            <i class="fas fa-info-circle mr-2"></i>
                            En caso de no encontrar la institución, comuníquese al correo: 
                            <a href="mailto:marquez@coveicydet.gob.mx" class="ml-1 underline hover:text-blue-800">
                                marquez@coveicydet.gob.mx
                            </a>
                        </p>
                                     
                    </div>

                    <!-- Área de adscripción -->
                    <div>
                        <label for="area" class="block text-sm font-medium text-gray-700 mb-2 flex items-center">
                            <i class="fas fa-network-wired text-[#7A1737] mr-2"></i>Área de Adscripción
                        </label>
                        <input type="text" id="area" name="area" required 
                               class="floating-input" placeholder="Ejemplo: Ingenieria en Sistemas Computacionales">
                    </div>

                    <!-- Municipio -->
                    <div>
                        <label for="municipio" class="block text-sm font-medium text-gray-700 mb-2 flex items-center">
                            <i class="fas fa-city text-[#7A1737] mr-2"></i>Municipio
                        </label>
                        <select id="municipio" name="municipio" required class="floating-input">
                            <option value="">Seleccione un municipio</option>
                            <%@ include file="listaMunicipios/index.jsp" %>
                        </select>
                    </div>

                    <!-- Responsables -->
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-4 flex items-center">
                            <i class="fas fa-users-cog text-[#7A1737] mr-2"></i>Responsable de la Propuesta
                        </label>
                        <div class="bg-gray-50 p-4 rounded-lg border border-gray-200">
                            <table class="min-w-full divide-y divide-gray-200">
                                <thead>
                                    <tr class="bg-gray-100">
                                        <th class="px-4 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">
                                            <i class="fas fa-user-tie mr-1"></i>Tipo
                                        </th>
                                        <th class="px-4 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">
                                            <i class="fas fa-signature mr-1"></i>Nombre
                                        </th>
                                        <th class="px-4 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">
                                            <i class="fas fa-envelope mr-1"></i>Correo
                                        </th>
                                        <th class="px-4 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">
                                            <i class="fas fa-phone mr-1"></i>Teléfono
                                        </th>
                                        <th class="px-4 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">
                                            <i class="fas fa-id-card mr-1"></i>Documento
                                        </th>
                                    </tr>
                                </thead>
                                <tbody class="bg-white divide-y divide-gray-200">
                                    <!-- Representante Técnico (PRIMERO) -->
                                    <tr>
                                        <td class="px-4 py-3 whitespace-nowrap text-sm font-medium text-gray-900">
                                            <i class="fas fa-user-cog text-gray-600 mr-2"></i>Representante Técnico
                                        </td>
                                        <td class="px-4 py-3"><input type="text" name="nombreTecnico" class="table-input" required></td>
                                        <td class="px-4 py-3"><input type="email" name="correoTecnico" class="table-input" required></td>
                                        <td class="px-4 py-3"><input type="tel" name="telefonoTecnico" class="table-input" required></td>
                                        <td class="px-4 py-3">
                                            <input type="hidden" id="ineTecnico_path" name="ineTecnico_path">
                                            <div id="ineTecnico_uploader">
                                                    <input type="file" name="ineTecnico" id="ineTecnico" accept=".pdf" 
                                                    class="block w-full text-xs text-gray-500 file:mr-2 file:py-1 file:px-3 file:rounded file:border-0 file:text-xs file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100" 
                                                    title="Adjunte INE del Representante Técnico (PDF)">
                                                    <p class="text-xs text-gray-500 mt-1">Adjunte INE del Representante Técnico (PDF)</p>
                                            </div>
                                            <div id="ineTecnico_previewer" class="hidden items-center space-x-2 mt-1">
                                                <span id="ineTecnico_status" class="text-sm text-green-600 truncate" style="max-width: 150px;"></span>
                                                <button type="button" id="ineTecnico_view_btn" title="Visualizar Archivo"
                                                    class="p-1 h-7 w-7 rounded bg-blue-600 text-white hover:bg-blue-700 text-xs">
                                                    <i class="fas fa-eye"></i>
                                                </button>
                                                <button type="button" id="ineTecnico_delete_btn" title="Eliminar Archivo"
                                                    class="p-1 h-7 w-7 rounded bg-red-600 text-white hover:bg-red-700 text-xs">
                                                    <i class="fas fa-trash"></i>
                                                </button>
                                            </div>
                                    </td>
                                    </tr>
                                    <!-- Representante Legal (SEGUNDO) -->
                                    <tr>
                                        <td class="px-4 py-3 whitespace-nowrap text-sm font-medium text-gray-900">
                                            <i class="fas fa-user-tie text-gray-600 mr-2"></i>Representante Legal
                                        </td>
                                        <td class="px-4 py-3"><input type="text" name="nombreLegal" class="table-input" required></td>
                                        <td class="px-4 py-3"><input type="email" name="correoLegal" class="table-input" required></td>
                                        <td class="px-4 py-3"><input type="tel" name="telefonoLegal" class="table-input" required></td>
                                        <td class="px-4 py-3">
                                        <input type="hidden" id="cartaAvalLegal_path" name="cartaAvalLegal_path">
                                        <div id="cartaAvalLegal_uploader">
                                            <input type="file" name="cartaAvalLegal" id="cartaAvalLegal" accept=".pdf" 
                                                class="block w-full text-xs text-gray-500 file:mr-2 file:py-1 file:px-3 file:rounded file:border-0 file:text-xs file:font-semibold file:bg-green-50 file:text-green-700 hover:file:bg-green-100" 
                                                title="Adjunte Carta Aval del Representante Legal (PDF)">
                                            <p class="text-xs text-gray-500 mt-1">Adjunte Carta Aval del Representante Legal (PDF)</p>
                                        </div>
                                        <div id="cartaAvalLegal_previewer" class="hidden items-center space-x-2 mt-1">
                                            <span id="cartaAvalLegal_status" class="text-sm text-green-600 truncate" style="max-width: 150px;"></span>
                                            <button type="button" id="cartaAvalLegal_view_btn" title="Visualizar Archivo"
                                                class="p-1 h-7 w-7 rounded bg-blue-600 text-white hover:bg-blue-700 text-xs">
                                                <i class="fas fa-eye"></i>
                                            </button>
                                            <button type="button" id="cartaAvalLegal_delete_btn" title="Eliminar Archivo"
                                                class="p-1 h-7 w-7 rounded bg-red-600 text-white hover:bg-red-700 text-xs">
                                                <i class="fas fa-trash"></i>
                                            </button>
                                        </div>
                                    </td>
                                    </tr>
                                    <!-- Representante Administrativo -->
                                    <tr>
                                        <td class="px-4 py-3 whitespace-nowrap text-sm font-medium text-gray-900">
                                            <i class="fas fa-user-shield text-gray-600 mr-2"></i>Representante Administrativo
                                        </td>
                                        <td class="px-4 py-3"><input type="text" name="nombreAdministrativo" class="table-input" required></td>
                                        <td class="px-4 py-3"><input type="email" name="correoAdministrativo" class="table-input" required></td>
                                        <td class="px-4 py-3"><input type="tel" name="telefonoAdministrativo" class="table-input" required></td>
                                        <td class="px-4 py-3">-</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <!-- Convocatoria -->
                    <div>
                        <label for="convocatoria" class="block text-sm font-medium text-gray-700 mb-2 flex items-center">
                            <i class="fas fa-bullhorn text-[#7A1737] mr-2"></i>Convocatoria
                        </label>
                        <select id="convocatoria" name="convocatoria" required class="floating-input">
                            <option value="">Seleccione una convocatoria</option>
                            <%
                                try (Connection conn = getConnection();
                                     Statement stmt = conn.createStatement();
                                     ResultSet rs = stmt.executeQuery("SELECT id_convocatoria, nombre_convocatoria FROM convocatoria ORDER BY nombre_convocatoria")) {
                                    while(rs.next()) {
                            %>
                                        <option value="<%= rs.getInt("id_convocatoria") %>"><%= rs.getString("nombre_convocatoria") %></option>
                            <%
                                    }
                                } catch(Exception e) {
                                    e.printStackTrace();
                                }
                            %>
                        </select>
                    </div>

                    <!-- Área de conocimiento -->
                    <div>
                        <label for="areaConocimiento" class="block text-sm font-medium text-gray-700 mb-2 flex items-center">
                            <i class="fas fa-book-open text-[#7A1737] mr-2"></i>Área de Conocimiento
                        </label>
                        <select id="areaConocimiento" name="areaConocimiento" required class="floating-input">
                            <option value="">Seleccione una opción</option>
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

                    <!-- Sector de desarrollo -->
                    <div>
                        <label for="sectorDesarrollo" class="block text-sm font-medium text-gray-700 mb-2 flex items-center">
                            <i class="fas fa-industry text-[#7A1737] mr-2"></i>Sector al que impacta el proyecto
                        </label>
                        <input type="text" id="sectorDesarrollo" name="sectorDesarrollo" required 
                            class="floating-input" placeholder="Ejemplo: Agrícola, Tecnología, Salud, etc.">
                    </div>

                    <!-- Nivel de Maduración -->
                    <div class="mt-6">
                        <label class="block text-sm font-medium text-gray-700 mb-4">Nivel de Maduración (tecnológico y/o social)</label>
                        <p class="text-sm text-gray-600 mb-4">Marque el nivel de maduración tecnológico y/o social en el que se encuentra su proyecto. Puede seleccionar uno de cada categoría.</p>
                        
                        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                            <!-- TRL - Niveles de Maduración Tecnológica -->
                            <div class="bg-blue-50 p-6 rounded-lg border border-blue-100">
                                <h4 class="text-lg font-semibold text-blue-800 mb-4">Niveles de Maduración Tecnológica</h4>
                                <div class="space-y-3">
                                    <div class="flex items-start space-x-3">
                                        <input type="radio" id="trl1" name="nivelTRL" value="TRL1" class="mt-1 text-blue-600 focus:ring-blue-500">
                                        <label for="trl1" class="text-sm">
                                            <span class="font-semibold">TRL 1:</span> Principios básicos observados y reportados. Investigación básica.
                                        </label>
                                    </div>
                                    <div class="flex items-start space-x-3">
                                        <input type="radio" id="trl2" name="nivelTRL" value="TRL2" class="mt-1 text-blue-600 focus:ring-blue-500">
                                        <label for="trl2" class="text-sm">
                                            <span class="font-semibold">TRL 2:</span> Concepto y aplicación formulada.
                                        </label>
                                    </div>
                                    <div class="flex items-start space-x-3">
                                        <input type="radio" id="trl3" name="nivelTRL" value="TRL3" class="mt-1 text-blue-600 focus:ring-blue-500">
                                        <label for="trl3" class="text-sm">
                                            <span class="font-semibold">TRL 3:</span> Prueba de concepto.
                                        </label>
                                    </div>
                                    <div class="flex items-start space-x-3">
                                        <input type="radio" id="trl4" name="nivelTRL" value="TRL4" class="mt-1 text-blue-600 focus:ring-blue-500">
                                        <label for="trl4" class="text-sm">
                                            <span class="font-semibold">TRL 4:</span> Validación de componentes a nivel laboratorio/campo.
                                        </label>
                                    </div>
                                    <div class="flex items-start space-x-3">
                                        <input type="radio" id="trl5" name="nivelTRL" value="TRL5" class="mt-1 text-blue-600 focus:ring-blue-500">
                                        <label for="trl5" class="text-sm">
                                            <span class="font-semibold">TRL 5:</span> Validación de componentes en un entorno relevante.
                                        </label>
                                    </div>
                                    <div class="flex items-start space-x-3">
                                        <input type="radio" id="trl6" name="nivelTRL" value="TRL6" class="mt-1 text-blue-600 focus:ring-blue-500">
                                        <label for="trl6" class="text-sm">
                                            <span class="font-semibold">TRL 6:</span> Demostración tecnológica en un ambiente relevante.
                                        </label>
                                    </div>
                                    <div class="flex items-start space-x-3">
                                        <input type="radio" id="trl7" name="nivelTRL" value="TRL7" class="mt-1 text-blue-600 focus:ring-blue-500">
                                        <label for="trl7" class="text-sm">
                                            <span class="font-semibold">TRL 7:</span> Demostración de prototipo a nivel sistema en un ambiente operativo real.
                                        </label>
                                    </div>
                                    <div class="flex items-start space-x-3">
                                        <input type="radio" id="trl8" name="nivelTRL" value="TRL8" class="mt-1 text-blue-600 focus:ring-blue-500">
                                        <label for="trl8" class="text-sm">
                                            <span class="font-semibold">TRL 8:</span> Desarrollo de producto completo y evaluado.
                                        </label>
                                    </div>
                                    <div class="flex items-start space-x-3">
                                        <input type="radio" id="trl9" name="nivelTRL" value="TRL9" class="mt-1 text-blue-600 focus:ring-blue-500">
                                        <label for="trl9" class="text-sm">
                                            <span class="font-semibold">TRL 9:</span> Producto terminado con éxito en el entorno real.
                                        </label>
                                    </div>
                                </div>
                            </div>

                            <!-- SRL - Niveles de Maduración Social -->
                            <div class="bg-green-50 p-6 rounded-lg border border-green-100">
                                <h4 class="text-lg font-semibold text-green-800 mb-4">SRL: Niveles de Maduración Social</h4>
                                <div class="space-y-3">
                                    <div class="flex items-start space-x-3">
                                        <input type="radio" id="srl1" name="nivelSRL" value="SRL1" class="mt-1 text-green-600 focus:ring-green-500">
                                        <label for="srl1" class="text-sm">
                                            <span class="font-semibold">SRL 1:</span> Identificación del problema y su impacto social.
                                        </label>
                                    </div>
                                    <div class="flex items-start space-x-3">
                                        <input type="radio" id="srl2" name="nivelSRL" value="SRL2" class="mt-1 text-green-600 focus:ring-green-500">
                                        <label for="srl2" class="text-sm">
                                            <span class="font-semibold">SRL 2:</span> Formulación del problema, propuesta de soluciones e impacto potencial.
                                        </label>
                                    </div>
                                    <div class="flex items-start space-x-3">
                                        <input type="radio" id="srl3" name="nivelSRL" value="SRL3" class="mt-1 text-green-600 focus:ring-green-500">
                                        <label for="srl3" class="text-sm">
                                            <span class="font-semibold">SRL 3:</span> Inicio de pruebas en campo con el grupo de interés.
                                        </label>
                                    </div>
                                    <div class="flex items-start space-x-3">
                                        <input type="radio" id="srl4" name="nivelSRL" value="SRL4" class="mt-1 text-green-600 focus:ring-green-500">
                                        <label for="srl4" class="text-sm">
                                            <span class="font-semibold">SRL 4:</span> Problema validado mediante prueba piloto en entorno relevante.
                                        </label>
                                    </div>
                                    <div class="flex items-start space-x-3">
                                        <input type="radio" id="srl5" name="nivelSRL" value="SRL5" class="mt-1 text-green-600 focus:ring-green-500">
                                        <label for="srl5" class="text-sm">
                                            <span class="font-semibold">SRL 5:</span> Solución validada por el grupo de interés relevante en el área.
                                        </label>
                                    </div>
                                    <div class="flex items-start space-x-3">
                                        <input type="radio" id="srl6" name="nivelSRL" value="SRL6" class="mt-1 text-green-600 focus:ring-green-500">
                                        <label for="srl6" class="text-sm">
                                            <span class="font-semibold">SRL 6:</span> Adopción de la solución.
                                        </label>
                                    </div>
                                    <div class="flex items-start space-x-3">
                                        <input type="radio" id="srl7" name="nivelSRL" value="SRL7" class="mt-1 text-green-600 focus:ring-green-500">
                                        <label for="srl7" class="text-sm">
                                            <span class="font-semibold">SRL 7:</span> Impacto social.
                                        </label>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Botón para resetear TLR y SLR -->
                        <!--
                        <div class="mt-4 flex justify-end">
                            <button type="button" onclick="resetearNivelesMaduracion()" 
                                    class="bg-orange-500 hover:bg-orange-600 text-white font-medium py-2 px-4 rounded-lg transition duration-200 flex items-center">
                                <i class="fas fa-undo mr-2"></i>Resetear Niveles de Maduración
                            </button>
                        </div>
                        -->

                        <!-- Documento probatorio -->
                        <div class="mt-6">
                            <label class="block text-sm font-medium text-gray-700 mb-2">Adjunte el documento que acredite los niveles de maduración</label>

                            <input type="hidden" id="cartaAvalMaduracion_path" name="cartaAvalMaduracion_path">

                            <div id="cartaAvalMaduracion_uploader">
                                <input type="file" id="cartaAvalMaduracion" name="cartaAvalMaduracion" accept=".pdf" 
                                    class="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100"
                                    title="Adjunte el documento que acredite los niveles de maduración (PDF)">
                                <p class="text-xs text-gray-500 mt-1">Adjunte el documento que acredite los niveles de maduración (PDF)</p>
                            </div>

                            <div id="cartaAvalMaduracion_previewer" class="hidden items-center space-x-2 mt-2">
                                <span id="cartaAvalMaduracion_status" class="text-sm text-green-600"></span>
                                <button type="button" id="cartaAvalMaduracion_view_btn" title="Visualizar Archivo"
                                    class="py-1 px-3 rounded bg-blue-600 text-white hover:bg-blue-700 text-sm">
                                    <i class="fas fa-eye mr-2"></i>Visualizar
                                </button>
                                <button type="button" id="cartaAvalMaduracion_delete_btn" title="Eliminar Archivo"
                                    class="py-1 px-3 rounded bg-red-600 text-white hover:bg-red-700 text-sm">
                                    <i class="fas fa-trash mr-2"></i>Eliminar
                                </button>
                            </div>
                        </div>
                    </div>

                    <!-- Botones de acción -->
                    <div class="flex justify-end mt-8 pt-6 border-t border-gray-200">
                        <div class="flex space-x-4">
                            <button type="button" onclick="guardarBorrador('formPagina1', 'pagina1', this)" class="bg-gray-500 hover:bg-gray-600 text-white font-medium py-2 px-6 rounded-lg">
                                Guardar Borrador
                            </button>
                        <button type="button"
                                    class="bg-[#7A1737] hover:bg-[#5c0f2a] text-white font-medium py-2 px-6 rounded-lg transition duration-200 flex items-center justify-center"
                                    onclick="location.href='/proyectos/pages/responsableDeproyecto/registroProyecto/registroProyecto2.jsp'">
                                Siguiente <i class="fas fa-arrow-right ml-2"></i>
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </main>
<%@ include file="/footer.jsp" %>
    <script>
        // Función para resetear los niveles de maduración TLR y SLR
        function resetearNivelesMaduracion() {
            // Desmarcar todos los radio buttons de TRL
            const trlRadios = document.querySelectorAll('input[name="nivelTRL"]');
            trlRadios.forEach(radio => radio.checked = false);
            
            // Desmarcar todos los radio buttons de SRL
            const srlRadios = document.querySelectorAll('input[name="nivelSRL"]');
            srlRadios.forEach(radio => radio.checked = false);
            
            // Mostrar mensaje de confirmación
            mostrarMensaje('Niveles de maduración reseteados correctamente', 'success');
        }

        // Función para guardar datos del formulario en localStorage con estructura adecuada para BD
        function guardarBorrador(formId, pageKey, targetBtn) {
            const form = document.getElementById(formId);
            
            // Estructura JSON adecuada para la base de datos
            const jsonData = {
                proyecto: {
                    titulo: form.querySelector('[name="titulo"]')?.value || '',
                    institucion_proponente: form.querySelector('[name="institucion"]')?.value || '',
                    area_adscripcion: form.querySelector('[name="area"]')?.value || '',
                    municipio: form.querySelector('[name="municipio"]')?.value || '',
                    convocatoria_id: form.querySelector('[name="convocatoria"]')?.value || null,
                    sector_impacto_proyecto: form.querySelector('[name="sectorDesarrollo"]')?.value || '',
                    nivel_slr: form.querySelector('[name="nivelSRL"]:checked')?.value || null,
                    nivel_tlr: form.querySelector('[name="nivelTRL"]:checked')?.value || null,
                    doc_probatorio: document.getElementById('cartaAvalMaduracion_path')?.value || null,
                    area_conocimiento: form.querySelector('[name="areaConocimiento"]')?.value || ''
                },
                responsables: [
                    {
                        nombre_completo: form.querySelector('[name="nombreTecnico"]')?.value || '',
                        correo_electronico: form.querySelector('[name="correoTecnico"]')?.value || '',
                        telefono: form.querySelector('[name="telefonoTecnico"]')?.value || '',
                        tipo_responsable: 'tecnico',
                        ine: document.getElementById('ineTecnico_path')?.value || null,
                        carta_aval: null
                    },
                    {
                        nombre_completo: form.querySelector('[name="nombreLegal"]')?.value || '',
                        correo_electronico: form.querySelector('[name="correoLegal"]')?.value || '',
                        telefono: form.querySelector('[name="telefonoLegal"]')?.value || '',
                        tipo_responsable: 'legal',
                        ine: null,
                        carta_aval: document.getElementById('cartaAvalLegal_path')?.value || null
                    },
                    {
                        nombre_completo: form.querySelector('[name="nombreAdministrativo"]')?.value || '',
                        correo_electronico: form.querySelector('[name="correoAdministrativo"]')?.value || '',
                        telefono: form.querySelector('[name="telefonoAdministrativo"]')?.value || '',
                        tipo_responsable: 'administrativo',
                        ine: null,
                        carta_aval: null
                    }
                ]
            };
            
            localStorage.setItem('proyecto_borrador_' + pageKey, JSON.stringify(jsonData));
            // mostrar el mensaje encima del botón que disparó el guardado
            mostrarMensaje('Borrador guardado exitosamente', 'success', targetBtn);
        }

        function cargarBorrador(formId, pageKey) {
            const savedData = localStorage.getItem('proyecto_borrador_' + pageKey);
            if (savedData) {
                try {
                    const data = JSON.parse(savedData);
                    const form = document.getElementById(formId);
                    // Cargar datos del proyecto
                    if (data.proyecto) {
                        if (data.proyecto.titulo)
                            form.querySelector('[name="titulo"]').value = data.proyecto.titulo;
                        if (data.proyecto.institucion_proponente) {
                            form.querySelector('[name="institucion"]').value = data.proyecto.institucion_proponente;
                            const searchInput = document.getElementById('institucion_search');
                            if (searchInput) searchInput.value = data.proyecto.institucion_proponente;
                        }
                        if (data.proyecto.area_adscripcion)
                            form.querySelector('[name="area"]').value = data.proyecto.area_adscripcion;
                        if (data.proyecto.municipio)
                            form.querySelector('[name="municipio"]').value = data.proyecto.municipio;
                        if (data.proyecto.convocatoria_id)
                            form.querySelector('[name="convocatoria"]').value = data.proyecto.convocatoria_id;
                        if (data.proyecto.sector_impacto_proyecto)
                            form.querySelector('[name="sectorDesarrollo"]').value = data.proyecto.sector_impacto_proyecto;
                        if (data.proyecto.area_conocimiento)
                            form.querySelector('[name="areaConocimiento"]').value = data.proyecto.area_conocimiento;
                        // Cargar niveles de maduración
                        if (data.proyecto.nivel_tlr) {
                            const trlRadio = form.querySelector('[name="nivelTRL"][value="' + data.proyecto.nivel_tlr + '"]');
                            if (trlRadio) trlRadio.checked = true;
                        }
                        if (data.proyecto.nivel_slr) {
                            const srlRadio = form.querySelector('[name="nivelSRL"][value="' + data.proyecto.nivel_slr + '"]');
                            if (srlRadio) srlRadio.checked = true;
                        }
                        // --- AÑADIDO: Cargar archivo de maduración ---
                        if (data.proyecto.doc_probatorio) {
                            document.getElementById('cartaAvalMaduracion_path').value = data.proyecto.doc_probatorio;
                            toggleFilePreview('cartaAvalMaduracion', true, data.proyecto.doc_probatorio, data.proyecto.doc_probatorio.split('/').pop());
                        }
                    }
                    // Cargar datos de responsables
                    if (data.responsables && Array.isArray(data.responsables)) {
                        data.responsables.forEach(resp => {
                            if (resp.tipo_responsable === 'tecnico') {
                                if (resp.nombre_completo)
                                    form.querySelector('[name="nombreTecnico"]').value = resp.nombre_completo;
                                if (resp.correo_electronico)
                                    form.querySelector('[name="correoTecnico"]').value = resp.correo_electronico;
                                if (resp.telefono)
                                    form.querySelector('[name="telefonoTecnico"]').value = resp.telefono;
                                // --- AÑADIDO: Cargar INE Técnico ---
                                if(resp.ine) {
                                    document.getElementById('ineTecnico_path').value = resp.ine;
                                    toggleFilePreview('ineTecnico', true, resp.ine, resp.ine.split('/').pop());
                                }
                            } else if (resp.tipo_responsable === 'legal') {
                                if (resp.nombre_completo)
                                    form.querySelector('[name="nombreLegal"]').value = resp.nombre_completo;
                                if (resp.correo_electronico)
                                    form.querySelector('[name="correoLegal"]').value = resp.correo_electronico;
                                if (resp.telefono)
                                    form.querySelector('[name="telefonoLegal"]').value = resp.telefono;
                                // --- AÑADIDO: Cargar Carta Aval ---
                                if(resp.carta_aval) {
                                    document.getElementById('cartaAvalLegal_path').value = resp.carta_aval;
                                    toggleFilePreview('cartaAvalLegal', true, resp.carta_aval, resp.carta_aval.split('/').pop());
                                }
                            } else if (resp.tipo_responsable === 'administrativo') {
                                if (resp.nombre_completo)
                                    form.querySelector('[name="nombreAdministrativo"]').value = resp.nombre_completo;
                                if (resp.correo_electronico)
                                    form.querySelector('[name="correoAdministrativo"]').value = resp.correo_electronico;
                                if (resp.telefono)
                                    form.querySelector('[name="telefonoAdministrativo"]').value = resp.telefono;
                            }
                        });
                    }
                } catch (error) {
                    console.error('Error al cargar borrador:', error);
                }
            }
        }

        // Muestra un mensaje; si se proporciona `targetEl` posiciona el mensaje encima de ese elemento,
        // en caso contrario usa la esquina superior derecha.
        function mostrarMensaje(mensaje, tipo = 'info', targetEl = null) {
            const messageDiv = document.createElement('div');
            let baseClasses = 'p-4 rounded-md shadow-lg z-50 border ';

            if (tipo === 'success') {
                baseClasses += 'bg-green-100 text-green-800 border-green-200';
            } else if (tipo === 'error') {
                baseClasses += 'bg-red-100 text-red-800 border-red-200';
            } else {
                baseClasses += 'bg-blue-100 text-blue-800 border-blue-200';
            }

            messageDiv.className = baseClasses;
            messageDiv.textContent = mensaje;

            if (targetEl && targetEl.getBoundingClientRect) {
                // posicion absoluta sobre el elemento objetivo
                messageDiv.style.position = 'absolute';
                messageDiv.style.visibility = 'hidden';
                document.body.appendChild(messageDiv);

                // calcular posición después de render para conocer dimensiones
                const rect = targetEl.getBoundingClientRect();
                const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
                const scrollLeft = window.pageXOffset || document.documentElement.scrollLeft;

                const mw = messageDiv.offsetWidth;
                const mh = messageDiv.offsetHeight;

                let left = rect.left + scrollLeft + (rect.width - mw) / 2;
                let top = rect.top + scrollTop - mh - 8; // 8px de separación

                // si no cabe encima, poner debajo del botón
                if (top < (window.pageYOffset || document.documentElement.scrollTop)) {
                    top = rect.top + scrollTop + rect.height + 8;
                }

                // asegurar que no salga por la izquierda/derecha
                const maxLeft = (window.pageXOffset || document.documentElement.scrollLeft) + document.documentElement.clientWidth - mw - 8;
                if (left < 8) left = 8;
                if (left > maxLeft) left = maxLeft;

                messageDiv.style.left = left + 'px';
                messageDiv.style.top = top + 'px';
                messageDiv.style.visibility = 'visible';
            } else {
                // fallback: esquina superior derecha (fixed)
                messageDiv.style.position = 'fixed';
                messageDiv.style.top = '1rem';
                messageDiv.style.right = '1rem';
                document.body.appendChild(messageDiv);
            }

            setTimeout(() => {
                if (messageDiv && messageDiv.parentNode) messageDiv.parentNode.removeChild(messageDiv);
            }, 3000);
        }

        // Versión avanzada: bloquear "Siguiente" hasta que se pulse "Guardar Borrador".
        window.addEventListener('load', function() {
            // Cargar datos guardados (si existen)
            cargarBorrador('formPagina1', 'pagina1');

            const KEY = 'proyecto_borrador_pagina1_saved';
            const form = document.getElementById('formPagina1');

            // Buscar botones por atributos/texto (resiliente cuando no hay id)
            const buttons = Array.from(document.querySelectorAll('button'));
            const guardarBtn = buttons.find(b => (b.getAttribute('onclick')||'').includes('guardarBorrador') || /guardar borrador/i.test(b.textContent));
            const siguienteBtn = document.getElementById('btnSiguiente') || buttons.find(b => /siguiente/i.test(b.textContent));

            function setDisabled(btn, disabled){
                if(!btn) return;
                // No usar disabled real para que los eventos sigan funcionando
                btn.setAttribute('aria-disabled', disabled ? 'true' : 'false');
                btn.setAttribute('data-disabled', disabled ? 'true' : 'false');
                if(disabled) {
                    btn.classList.add('opacity-60', 'cursor-not-allowed');
                    btn.classList.remove('hover:bg-[#5c0f2a]');
                } else {
                    btn.classList.remove('opacity-60', 'cursor-not-allowed');
                    btn.classList.add('hover:bg-[#5c0f2a]');
                }
            }

            if(!guardarBtn || !siguienteBtn){
                console.warn('No se encontraron los botones "Guardar Borrador" o "Siguiente". Control de bloqueo no inicializado.');
                return;
            }

            // Estado inicial desde localStorage
            let saved = localStorage.getItem(KEY) === '1';
            setDisabled(siguienteBtn, !saved);

            // Cuando se pulsa guardar, marcar y habilitar siguiente
            guardarBtn.addEventListener('click', function(){
                // Marcar borrador como guardado
                localStorage.setItem(KEY, '1');
                saved = true;
                setDisabled(siguienteBtn, false);
                console.log('Borrador marcado como guardado -> Siguiente habilitado');
            });

            // Agregar evento al botón siguiente para manejar navegación y advertencias
            siguienteBtn.addEventListener('click', function(e){
                e.preventDefault();
                e.stopPropagation();
                
                // Verificar si está "deshabilitado" (visualmente)
                if(siguienteBtn.getAttribute('data-disabled') === 'true'){
                    mostrarMensaje('Debe guardar el borrador antes de continuar', 'error', siguienteBtn);
                    return false;
                }
                
                // --- NAVEGACIÓN REAL ---
                window.location.href = '/proyectos/pages/responsableDeproyecto/registroProyecto/registroProyecto2.jsp';
            });

            const ineInput = document.getElementById('ineTecnico');
            const inePath = document.getElementById('ineTecnico_path');
            const ineStatus = document.getElementById('ineTecnico_status');
            ineInput.addEventListener('change', () => handleFileUpload(ineInput, inePath, ineStatus));

            const avalInput = document.getElementById('cartaAvalLegal');
            const avalPath = document.getElementById('cartaAvalLegal_path');
            const avalStatus = document.getElementById('cartaAvalLegal_status');
            avalInput.addEventListener('change', () => handleFileUpload(avalInput, avalPath, avalStatus));

            const maduracionInput = document.getElementById('cartaAvalMaduracion');
            const maduracionPath = document.getElementById('cartaAvalMaduracion_path');
            const maduracionStatus = document.getElementById('cartaAvalMaduracion_status');
            maduracionInput.addEventListener('change', () => handleFileUpload(maduracionInput, maduracionPath, maduracionStatus));

            // Conectar botones de Visualizar
            document.getElementById('ineTecnico_view_btn').addEventListener('click', function() { 
                window.open(this.getAttribute('data-url'), '_blank'); 
            });
            document.getElementById('cartaAvalLegal_view_btn').addEventListener('click', function() { 
                window.open(this.getAttribute('data-url'), '_blank'); 
            });
            document.getElementById('cartaAvalMaduracion_view_btn').addEventListener('click', function() { 
                window.open(this.getAttribute('data-url'), '_blank'); 
            });

            // Conectar botones de Eliminar
            document.getElementById('ineTecnico_delete_btn').addEventListener('click', function() { 
                handleFileDelete('ineTecnico', document.getElementById('ineTecnico_path').value); 
            });
            document.getElementById('cartaAvalLegal_delete_btn').addEventListener('click', function() { 
                handleFileDelete('cartaAvalLegal', document.getElementById('cartaAvalLegal_path').value); 
            });
            document.getElementById('cartaAvalMaduracion_delete_btn').addEventListener('click', function() { 
                handleFileDelete('cartaAvalMaduracion', document.getElementById('cartaAvalMaduracion_path').value); 
            });

            // Si el formulario cambia después de guardar, volver a marcar como no guardado y bloquear
            if(form){
                const inputs = Array.from(form.querySelectorAll('input, textarea, select'));
                const onChange = function(){
                    if(saved){
                        saved = false;
                        localStorage.setItem(KEY, '0');
                        setDisabled(siguienteBtn, true);
                        console.log('Formulario modificado después de guardar: Siguiente bloqueado.');
                    }
                };
                inputs.forEach(el => el.addEventListener('input', onChange));
                inputs.forEach(el => el.addEventListener('change', onChange));
                // Advertir al usuario si intenta abandonar la página con cambios no guardados
                window.addEventListener('beforeunload', function(e) {
                    try {
                        if (!saved) {
                            // Mensaje personalizado no siempre se muestra por motivos de seguridad en navegadores modernos,
                            // pero setting returnValue provoca el diálogo de confirmación.
                            var confirmationMessage = 'Tiene cambios sin guardar. ¿Desea salir sin guardar?';
                            e.preventDefault();
                            e.returnValue = confirmationMessage;
                            return confirmationMessage;
                        }
                    } catch (err) {
                        // en caso de cualquier error, no bloquear la navegación
                        return undefined;
                    }
                });
            }
        });

        // Función corregida para manejar la subida de archivos
        async function handleFileUpload(fileInput, hiddenPathInput, statusElement) {
            const file = fileInput.files[0];
            const baseId = fileInput.id; 
            
            if (!file) return;

            // Validar que sea PDF
            if (file.type !== 'application/pdf' && !file.name.toLowerCase().endsWith('.pdf')) {
                alert('Solo se permiten archivos PDF.');
                fileInput.value = ''; // Limpiar input
                return;
            }

            // Validar tamaño (5MB = 5 * 1024 * 1024 bytes)
            const maxSize = 5 * 1024 * 1024;
            if (file.size > maxSize) {
                alert('El archivo no debe superar los 5 MB.');
                fileInput.value = ''; // Limpiar input
                return;
            }
        
            // --- Lógica de Base64 ---
            const reader = new FileReader();
            const fileReadPromise = new Promise((resolve, reject) => {
                reader.onload = () => resolve(reader.result);
                reader.onerror = (error) => reject(error);
            });
            reader.readAsDataURL(file);
        
            // Mostramos estado visual
            toggleFilePreview(baseId, true, '', 'Procesando...');
            statusElement.className = 'text-sm text-blue-600';
        
            try {
                // 1. Espera a que el archivo se lea como Base64
                const base64String = await fileReadPromise;
                statusElement.textContent = 'Subiendo...';
        
                // 2. Prepara los datos
                const bodyParams = new URLSearchParams();
                bodyParams.append('fileName', file.name);
                bodyParams.append('fileData', base64String);
        
                // 3. Envía la solicitud
                const response = await fetch('/proyectos/pages/responsableDeproyecto/registroProyecto/upload.jsp', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded'
                    },
                    body: bodyParams
                });
        
                // 4. Leer respuesta (SOLO UNA VEZ)
                const result = await response.json();
        
                if (response.ok && result.success) {
                    // Éxito: Guardar ruta
                    hiddenPathInput.value = result.webUrl;
                    
                    // Actualizar UI
                    toggleFilePreview(baseId, true, result.webUrl, result.originalName);
                    statusElement.className = 'text-sm text-green-600';
        
                    // --- AUTO-GUARDADO (LA CLAVE PARA QUE "RECUERDE") ---
                    guardarBorrador('formPagina1', 'pagina1', null);
                    console.log('Archivo subido y borrador actualizado automáticamente.');
                    // ----------------------------------------------------
        
                    hiddenPathInput.dispatchEvent(new Event('input'));
                } else {
                    throw new Error(result.message || 'Error al subir el archivo.');
                }
        
            } catch (error) {
                console.error('Error en carga:', error);
                toggleFilePreview(baseId, false);
                statusElement.textContent = `❌ Error: ${error.message}`;
                statusElement.className = 'text-sm text-red-600';
                fileInput.value = '';
                hiddenPathInput.value = '';
            }
        }

        // --- NUEVA FUNCIÓN ---
        // Ayudante para mostrar/ocultar los botones de carga/vista previa
        function toggleFilePreview(baseId, showPreview, fileUrl = '', statusText = '') {
            const uploader = document.getElementById(baseId + '_uploader');
            const previewer = document.getElementById(baseId + '_previewer');
            const status = document.getElementById(baseId + '_status');
            const viewBtn = document.getElementById(baseId + '_view_btn');

            if (showPreview) {
                if (uploader) uploader.classList.add('hidden');
                if (previewer) previewer.classList.remove('hidden');
                if (status) status.textContent = statusText;
                if (viewBtn) viewBtn.setAttribute('data-url', fileUrl);
            } else {
                if (uploader) uploader.classList.remove('hidden');
                if (previewer) previewer.classList.add('hidden');
                if (status) status.textContent = '';
                if (viewBtn) viewBtn.removeAttribute('data-url');
                
                // Limpiar el input de archivo por si acaso
                const fileInput = document.getElementById(baseId);
                if (fileInput) fileInput.value = '';
            }
        }

        // --- NUEVA FUNCIÓN ---
        // Maneja la eliminación del archivo
        async function handleFileDelete(baseId, fileUrl) {
            if (!fileUrl) {
                console.warn('No hay fileUrl para eliminar');
                toggleFilePreview(baseId, false);
                return;
            }

            if (!confirm('¿Está seguro de que desea eliminar este archivo? Esta acción no se puede deshacer.')) {
                return;
            }

            const status = document.getElementById(baseId + '_status');
            status.textContent = 'Eliminando...';
            status.className = 'text-sm text-red-600';

            try {
                const bodyParams = new URLSearchParams();
                bodyParams.append('fileUrl', fileUrl);

                const response = await fetch('/proyectos/pages/responsableDeproyecto/registroProyecto/deleteFile.jsp', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: bodyParams
                });

                const result = await response.json();

                if (response.ok && result.success) {
                    // Éxito: limpiar UI
                    document.getElementById(baseId + '_path').value = '';
                    toggleFilePreview(baseId, false);
                    mostrarMensaje(result.message || 'Archivo eliminado', 'success');

                    // --- AUTO-GUARDADO AL BORRAR ---
                    guardarBorrador('formPagina1', 'pagina1', null);
                    console.log('Archivo eliminado y borrador actualizado automáticamente.');
                    // -------------------------------

                    document.getElementById(baseId + '_path').dispatchEvent(new Event('input'));
                } else {
                    throw new Error(result.message || 'Error al eliminar el archivo.');
                }
            } catch (error) {
                console.error('Error en eliminación:', error);
                status.textContent = `Error: ${error.message}`;
                status.className = 'text-sm text-red-600';
            }
        }

        // Lógica para el buscador de instituciones
        document.addEventListener('DOMContentLoaded', function() {
            const wrapper = document.getElementById('institucion-wrapper');
            const searchInput = document.getElementById('institucion_search');
            const hiddenInput = document.getElementById('institucion');
            const dropdown = document.getElementById('institucion_dropdown');
            const options = document.querySelectorAll('.institucion-option');
            const noResults = document.getElementById('institucion_no_results');

            if (!wrapper || !searchInput || !dropdown) return;

            // Mostrar dropdown al enfocar
            searchInput.addEventListener('focus', () => {
                dropdown.classList.remove('hidden');
            });

            // Filtrar opciones
            searchInput.addEventListener('input', function() {
                const filter = this.value.toLowerCase();
                let hasResults = false;
                
                dropdown.classList.remove('hidden');

                options.forEach(option => {
                    const text = option.textContent.toLowerCase();
                    if (text.includes(filter)) {
                        option.classList.remove('hidden');
                        hasResults = true;
                    } else {
                        option.classList.add('hidden');
                    }
                });

                if (hasResults) {
                    noResults.classList.add('hidden');
                } else {
                    noResults.classList.remove('hidden');
                }
            });

            // Seleccionar opción
            options.forEach(option => {
                option.addEventListener('click', function() {
                    const value = this.getAttribute('data-value');
                    searchInput.value = this.textContent.trim(); // Mostrar nombre limpio
                    hiddenInput.value = value; // Guardar valor real
                    dropdown.classList.add('hidden');
                    
                    // Disparar evento change para validaciones si las hay
                    hiddenInput.dispatchEvent(new Event('change'));
                });
            });

            // Cerrar al hacer clic fuera
            document.addEventListener('click', function(e) {
                if (!wrapper.contains(e.target)) {
                    dropdown.classList.add('hidden');
                    
                    // Si el input está vacío, limpiar el hidden
                    if (searchInput.value.trim() === '') {
                        hiddenInput.value = '';
                        return;
                    }

                    // Verificar si el texto actual coincide exactamente con alguna opción (case insensitive)
                    const currentText = searchInput.value.trim().toLowerCase();
                    let match = false;
                    options.forEach(opt => {
                        if (opt.textContent.trim().toLowerCase() === currentText) {
                            match = true;
                            hiddenInput.value = opt.getAttribute('data-value');
                        }
                    });

                    // Si no hubo match exacto, revertir al valor guardado en hiddenInput
                    if (!match) {
                        if (hiddenInput.value) {
                            searchInput.value = hiddenInput.value;
                        } else {
                            searchInput.value = '';
                        }
                    }
                }
            });
        });

    </script>
</body>
</html>
