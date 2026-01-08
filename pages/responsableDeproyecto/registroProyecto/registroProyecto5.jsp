<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<% if (!"responsable".equals(String.valueOf(session.getAttribute("rol")))) { String n=request.getRequestURI()+(request.getQueryString()!=null?("?"+request.getQueryString()):""); response.sendRedirect(request.getContextPath()+"/pages/login/login.jsp?next="+java.net.URLEncoder.encode(n,"UTF-8")); return;
} %>

<%@ include file="/WEB-INF/seguridadProyecto.jsp" %>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <title>Organizaciones Participantes - COVEICYDET</title>
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
        
        .participant-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 2rem;
            background: white;
            border-radius: 0.75rem;
            overflow: hidden;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }
        
        .participant-table th {
            background-color: #7A1737;
            color: white;
            padding: 1rem;
            text-align: left;
            font-weight: 600;
            font-size: 0.875rem;
        }
        
        .participant-table td {
            padding: 1rem;
            border-bottom: 1px solid #e5e7eb;
        }
        
        .table-section {
            background: white;
            border-radius: 0.75rem;
            padding: 1.5rem;
            margin-bottom: 2rem;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }
        
        .section-header {
            display: flex;
            align-items: center;
            margin-bottom: 1.5rem;
            padding-bottom: 0.75rem;
            border-bottom: 2px solid #B28854;
        }
        
        .notification {
            position: fixed;
            top: 1rem;
            right: 1rem;
            padding: 1rem;
            border-radius: 0.5rem;
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
            z-index: 1000;
            display: flex;
            align-items: center;
            max-width: 400px;
            transform: translateX(150%);
            transition: transform 0.3s ease-out;
            background-color: #fee2e2;
            border: 1px solid #ef4444;
            color: #991b1b;
        }
        
        .notification.show {
            transform: translateX(0);
        }
        
        .notification-icon {
            margin-right: 0.75rem;
            font-size: 1.25rem;
        }
        
        .table-title {
            color: #7A1737;
            font-weight: 600;
            margin: 0;
        }
        
        .legend-box {
            background-color: #f8fafc;
            border-left: 4px solid #7A1737;
            padding: 1rem;
            margin-bottom: 1.5rem;
            border-radius: 0.375rem;
        }
        
        .legend-title {
            font-weight: 600;
            color: #7A1737;
            margin-bottom: 0.5rem;
        }
        
        .legend-text {
            color: #4b5563;
            font-size: 0.875rem;
        }
    </style>
</head>
<body class="min-h-screen flex flex-col">
    <%@ include file="../header.jsp" %>
    <%@ include file="Navegador.jsp" %>
    
    <main class="flex-grow py-8">
        <div class="container mx-auto px-4">
            <div class="form-container bg-white rounded-xl overflow-hidden border border-slate-200">
                <div class="bg-[#B28854] p-6">
                    <h1 class="text-2xl font-bold text-white flex items-center">
                        <i class="fas fa-building mr-3"></i>Organizaciones Participantes 5/10
                    </h1>
                    <p class="text-white/90 mt-2 flex items-center">
                        <i class="fas fa-info-circle mr-2"></i>Complete la información de las organizaciones participantes (Min 1 - Max 5).
                    </p>
                </div>

                <form id="formOrganizaciones" class="p-8 space-y-8">
                    <div class="legend-box">
                        <div class="legend-title">Organizaciones Participantes</div>
                        <div class="legend-text">
                            En esta sección deberá registrar la información de las 5 organizaciones que participarán en el proyecto.
                            Cada organización debe contar con información completa sobre su razón social, responsable, datos de contacto 
                            y la descripción de las actividades que realizarán en el proyecto.
                        </div>
                    </div>

                    <section class="space-y-6">
                        <h4 class="text-sm font-semibold uppercase tracking-wide text-slate-500 flex items-center">
                            <i class="fas fa-building mr-2 text-[#7A1737]"></i>ORGANIZACIONES PARTICIPANTES
                        </h4>

                        <div class="table-section">
                            <div class="section-header">
                                <h5 class="table-title">Organización 1</h5>
                            </div>
                            <table class="participant-table">
                                <tbody>
                                    <tr>
                                        <td style="width: 200px; background-color: #f8fafc; font-weight: 500;">Nombre o razón social</td>
                                        <td><input type="text" name="org-nombre-1" class="floating-input" placeholder="Nombre o razón social"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Responsable</td>
                                        <td><input type="text" name="org-responsable-1" class="floating-input" placeholder="Responsable"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Domicilio</td>
                                        <td><input type="text" name="org-domicilio-1" class="floating-input" placeholder="Domicilio"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Teléfono</td>
                                        <td><input type="text" name="org-telefono-1" class="floating-input" placeholder="Teléfono"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Descripción de la actividad</td>
                                        <td><input type="text" name="org-actividad-1" class="floating-input" placeholder="Descripción de la actividad"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Correo electrónico</td>
                                        <td><input type="email" name="org-email-1" class="floating-input" placeholder="Correo electrónico"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">
                                            <i class="fas fa-file-pdf text-[#7A1737] mr-2"></i>Comprobante de adscripción
                                        </td>
                                        <td>
                                            <input type="hidden" id="org_comprobante_1_path" name="org_comprobante_1_path">
                                            
                                            <div id="org_comprobante_1_uploader">
                                                <input type="file" id="org_comprobante_1" name="org_comprobante_1" accept=".pdf" 
                                                       class="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100" 
                                                       title="Adjunte comprobante de adscripción">
                                            </div>

                                            <div id="org_comprobante_1_previewer" class="hidden items-center space-x-2 mt-1">
                                                <span id="org_comprobante_1_status" class="text-sm text-green-600 truncate" style="max-width: 150px;"></span>
                                                <button type="button" id="org_comprobante_1_view_btn" title="Visualizar Archivo" class="p-1 h-7 w-7 rounded bg-blue-600 text-white hover:bg-blue-700 text-xs">
                                                    <i class="fas fa-eye"></i>
                                                </button>
                                                <button type="button" id="org_comprobante_1_delete_btn" title="Eliminar Archivo" class="p-1 h-7 w-7 rounded bg-red-600 text-white hover:bg-red-700 text-xs">
                                                    <i class="fas fa-trash"></i>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>

                        <div class="table-section">
                            <div class="section-header">
                                <h5 class="table-title">Organización 2</h5>
                            </div>
                            <table class="participant-table">
                                <tbody>
                                    <tr>
                                        <td style="width: 200px; background-color: #f8fafc; font-weight: 500;">Nombre o razón social</td>
                                        <td><input type="text" name="org-nombre-2" class="floating-input" placeholder="Nombre o razón social"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Responsable</td>
                                        <td><input type="text" name="org-responsable-2" class="floating-input" placeholder="Responsable"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Domicilio</td>
                                        <td><input type="text" name="org-domicilio-2" class="floating-input" placeholder="Domicilio"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Teléfono</td>
                                        <td><input type="text" name="org-telefono-2" class="floating-input" placeholder="Teléfono"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Descripción de la actividad</td>
                                        <td><input type="text" name="org-actividad-2" class="floating-input" placeholder="Descripción de la actividad"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Correo electrónico</td>
                                        <td><input type="email" name="org-email-2" class="floating-input" placeholder="Correo electrónico"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">
                                            <i class="fas fa-file-pdf text-[#7A1737] mr-2"></i>Comprobante de adscripción
                                        </td>
                                        <td>
                                            <input type="hidden" id="org_comprobante_2_path" name="org_comprobante_2_path">
                                            
                                            <div id="org_comprobante_2_uploader">
                                                <input type="file" id="org_comprobante_2" name="org_comprobante_2" accept=".pdf" 
                                                       class="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100" 
                                                       title="Adjunte comprobante de adscripción">
                                            </div>

                                            <div id="org_comprobante_2_previewer" class="hidden items-center space-x-2 mt-1">
                                                <span id="org_comprobante_2_status" class="text-sm text-green-600 truncate" style="max-width: 150px;"></span>
                                                <button type="button" id="org_comprobante_2_view_btn" title="Visualizar Archivo" class="p-1 h-7 w-7 rounded bg-blue-600 text-white hover:bg-blue-700 text-xs">
                                                    <i class="fas fa-eye"></i>
                                                </button>
                                                <button type="button" id="org_comprobante_2_delete_btn" title="Eliminar Archivo" class="p-1 h-7 w-7 rounded bg-red-600 text-white hover:bg-red-700 text-xs">
                                                    <i class="fas fa-trash"></i>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>

                        <div class="table-section">
                            <div class="section-header">
                                <h5 class="table-title">Organización 3</h5>
                            </div>
                            <table class="participant-table">
                                <tbody>
                                    <tr>
                                        <td style="width: 200px; background-color: #f8fafc; font-weight: 500;">Nombre o razón social</td>
                                        <td><input type="text" name="org-nombre-3" class="floating-input" placeholder="Nombre o razón social"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Responsable</td>
                                        <td><input type="text" name="org-responsable-3" class="floating-input" placeholder="Responsable"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Domicilio</td>
                                        <td><input type="text" name="org-domicilio-3" class="floating-input" placeholder="Domicilio"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Teléfono</td>
                                        <td><input type="text" name="org-telefono-3" class="floating-input" placeholder="Teléfono"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Descripción de la actividad</td>
                                        <td><input type="text" name="org-actividad-3" class="floating-input" placeholder="Descripción de la actividad"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Correo electrónico</td>
                                        <td><input type="email" name="org-email-3" class="floating-input" placeholder="Correo electrónico"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">
                                            <i class="fas fa-file-pdf text-[#7A1737] mr-2"></i>Comprobante de adscripción
                                        </td>
                                        <td>
                                            <input type="hidden" id="org_comprobante_3_path" name="org_comprobante_3_path">
                                            
                                            <div id="org_comprobante_3_uploader">
                                                <input type="file" id="org_comprobante_3" name="org_comprobante_3" accept=".pdf" 
                                                       class="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100" 
                                                       title="Adjunte comprobante de adscripción">
                                            </div>

                                            <div id="org_comprobante_3_previewer" class="hidden items-center space-x-2 mt-1">
                                                <span id="org_comprobante_3_status" class="text-sm text-green-600 truncate" style="max-width: 150px;"></span>
                                                <button type="button" id="org_comprobante_3_view_btn" title="Visualizar Archivo" class="p-1 h-7 w-7 rounded bg-blue-600 text-white hover:bg-blue-700 text-xs">
                                                    <i class="fas fa-eye"></i>
                                                </button>
                                                <button type="button" id="org_comprobante_3_delete_btn" title="Eliminar Archivo" class="p-1 h-7 w-7 rounded bg-red-600 text-white hover:bg-red-700 text-xs">
                                                    <i class="fas fa-trash"></i>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>

                        <div class="table-section">
                            <div class="section-header">
                                <h5 class="table-title">Organización 4</h5>
                            </div>
                            <table class="participant-table">
                                <tbody>
                                    <tr>
                                        <td style="width: 200px; background-color: #f8fafc; font-weight: 500;">Nombre o razón social</td>
                                        <td><input type="text" name="org-nombre-4" class="floating-input" placeholder="Nombre o razón social"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Responsable</td>
                                        <td><input type="text" name="org-responsable-4" class="floating-input" placeholder="Responsable"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Domicilio</td>
                                        <td><input type="text" name="org-domicilio-4" class="floating-input" placeholder="Domicilio"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Teléfono</td>
                                        <td><input type="text" name="org-telefono-4" class="floating-input" placeholder="Teléfono"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Descripción de la actividad</td>
                                        <td><input type="text" name="org-actividad-4" class="floating-input" placeholder="Descripción de la actividad"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Correo electrónico</td>
                                        <td><input type="email" name="org-email-4" class="floating-input" placeholder="Correo electrónico"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">
                                            <i class="fas fa-file-pdf text-[#7A1737] mr-2"></i>Comprobante de adscripción
                                        </td>
                                        <td>
                                            <input type="hidden" id="org_comprobante_4_path" name="org_comprobante_4_path">
                                            
                                            <div id="org_comprobante_4_uploader">
                                                <input type="file" id="org_comprobante_4" name="org_comprobante_4" accept=".pdf" 
                                                       class="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100" 
                                                       title="Adjunte comprobante de adscripción">
                                            </div>

                                            <div id="org_comprobante_4_previewer" class="hidden items-center space-x-2 mt-1">
                                                <span id="org_comprobante_4_status" class="text-sm text-green-600 truncate" style="max-width: 150px;"></span>
                                                <button type="button" id="org_comprobante_4_view_btn" title="Visualizar Archivo" class="p-1 h-7 w-7 rounded bg-blue-600 text-white hover:bg-blue-700 text-xs">
                                                    <i class="fas fa-eye"></i>
                                                </button>
                                                <button type="button" id="org_comprobante_4_delete_btn" title="Eliminar Archivo" class="p-1 h-7 w-7 rounded bg-red-600 text-white hover:bg-red-700 text-xs">
                                                    <i class="fas fa-trash"></i>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>

                        <div class="table-section">
                            <div class="section-header">
                                <h5 class="table-title">Organización 5</h5>
                            </div>
                            <table class="participant-table">
                                <tbody>
                                    <tr>
                                        <td style="width: 200px; background-color: #f8fafc; font-weight: 500;">Nombre o razón social</td>
                                        <td><input type="text" name="org-nombre-5" class="floating-input" placeholder="Nombre o razón social"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Responsable</td>
                                        <td><input type="text" name="org-responsable-5" class="floating-input" placeholder="Responsable"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Domicilio</td>
                                        <td><input type="text" name="org-domicilio-5" class="floating-input" placeholder="Domicilio"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Teléfono</td>
                                        <td><input type="text" name="org-telefono-5" class="floating-input" placeholder="Teléfono"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Descripción de la actividad</td>
                                        <td><input type="text" name="org-actividad-5" class="floating-input" placeholder="Descripción de la actividad"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Correo electrónico</td>
                                        <td><input type="email" name="org-email-5" class="floating-input" placeholder="Correo electrónico"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">
                                            <i class="fas fa-file-pdf text-[#7A1737] mr-2"></i>Comprobante de adscripción
                                        </td>
                                        <td>
                                            <input type="hidden" id="org_comprobante_5_path" name="org_comprobante_5_path">
                                            
                                            <div id="org_comprobante_5_uploader">
                                                <input type="file" id="org_comprobante_5" name="org_comprobante_5" accept=".pdf" 
                                                       class="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100" 
                                                       title="Adjunte comprobante de adscripción">
                                            </div>

                                            <div id="org_comprobante_5_previewer" class="hidden items-center space-x-2 mt-1">
                                                <span id="org_comprobante_5_status" class="text-sm text-green-600 truncate" style="max-width: 150px;"></span>
                                                <button type="button" id="org_comprobante_5_view_btn" title="Visualizar Archivo" class="p-1 h-7 w-7 rounded bg-blue-600 text-white hover:bg-blue-700 text-xs">
                                                    <i class="fas fa-eye"></i>
                                                </button>
                                                <button type="button" id="org_comprobante_5_delete_btn" title="Eliminar Archivo" class="p-1 h-7 w-7 rounded bg-red-600 text-white hover:bg-red-700 text-xs">
                                                    <i class="fas fa-trash"></i>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </section>

                    <div class="flex flex-col-reverse gap-4 pt-8 border-t border-gray-200 sm:flex-row sm:justify-end">
                        <button type="button" onclick="guardarBorrador('formOrganizaciones', 'pagina5', this)"
                                class="bg-gray-500 hover:bg-gray-600 text-white font-medium py-2 px-6 rounded-lg transition duration-200 flex items-center justify-center">
                            <i class="fas fa-save mr-2"></i>Guardar borrador
                        </button>
                        <div class="flex gap-4">
                            <button type="button"
                                    class="bg-gray-600 hover:bg-gray-700 text-white font-medium py-2 px-6 rounded-lg transition duration-200 flex items-center justify-center"
                                    onclick="location.href='/proyectos/pages/responsableDeproyecto/registroProyecto/registroProyecto4.jsp'">
                                <i class="fas fa-arrow-left mr-2"></i>Anterior
                            </button>
                            <button type="button" id="btnSiguiente"
                                    class="bg-[#7A1737] hover:bg-[#5c0f2a] text-white font-medium py-2 px-6 rounded-lg transition duration-200 flex items-center justify-center">
                                Siguiente <i class="fas fa-arrow-right ml-2"></i>
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </main>
    <%@ include file="/footer.jsp" %>
    
    <div id="notification" class="notification">
        <i class="notification-icon fas fa-exclamation-circle"></i>
        <span class="notification-message"></span>
    </div>
    
    <script>
        // Función para guardar datos del formulario en localStorage con estructura adecuada para BD
        function guardarBorrador(formId, pageKey, targetBtn) {
            const form = document.getElementById(formId);
            console.log('[organizaciones] Iniciando guardado de borrador...');
            
            // Estructura JSON PLANA - cada organización como campo individual (sin arrays ni loops)
            const jsonData = {
                organizacion_social: {
                    // Organización 1
                    organizacion1_nombre: form.querySelector('[name="org-nombre-1"]')?.value || '',
                    organizacion1_responsable: form.querySelector('[name="org-responsable-1"]')?.value || '',
                    organizacion1_domicilio: form.querySelector('[name="org-domicilio-1"]')?.value || '',
                    organizacion1_telefono: form.querySelector('[name="org-telefono-1"]')?.value || '',
                    organizacion1_actividad: form.querySelector('[name="org-actividad-1"]')?.value || '',
                    organizacion1_email: form.querySelector('[name="org-email-1"]')?.value || '',
                    // AQUI GUARDAMOS LA URL DEL ARCHIVO, NO EL NOMBRE SIMPLE
                    organizacion1_comprobante: document.getElementById('org_comprobante_1_path')?.value || '',
                    
                    // Organización 2
                    organizacion2_nombre: form.querySelector('[name="org-nombre-2"]')?.value || '',
                    organizacion2_responsable: form.querySelector('[name="org-responsable-2"]')?.value || '',
                    organizacion2_domicilio: form.querySelector('[name="org-domicilio-2"]')?.value || '',
                    organizacion2_telefono: form.querySelector('[name="org-telefono-2"]')?.value || '',
                    organizacion2_actividad: form.querySelector('[name="org-actividad-2"]')?.value || '',
                    organizacion2_email: form.querySelector('[name="org-email-2"]')?.value || '',
                    organizacion2_comprobante: document.getElementById('org_comprobante_2_path')?.value || '',
                    
                    // Organización 3
                    organizacion3_nombre: form.querySelector('[name="org-nombre-3"]')?.value || '',
                    organizacion3_responsable: form.querySelector('[name="org-responsable-3"]')?.value || '',
                    organizacion3_domicilio: form.querySelector('[name="org-domicilio-3"]')?.value || '',
                    organizacion3_telefono: form.querySelector('[name="org-telefono-3"]')?.value || '',
                    organizacion3_actividad: form.querySelector('[name="org-actividad-3"]')?.value || '',
                    organizacion3_email: form.querySelector('[name="org-email-3"]')?.value || '',
                    organizacion3_comprobante: document.getElementById('org_comprobante_3_path')?.value || '',
                    
                    // Organización 4
                    organizacion4_nombre: form.querySelector('[name="org-nombre-4"]')?.value || '',
                    organizacion4_responsable: form.querySelector('[name="org-responsable-4"]')?.value || '',
                    organizacion4_domicilio: form.querySelector('[name="org-domicilio-4"]')?.value || '',
                    organizacion4_telefono: form.querySelector('[name="org-telefono-4"]')?.value || '',
                    organizacion4_actividad: form.querySelector('[name="org-actividad-4"]')?.value || '',
                    organizacion4_email: form.querySelector('[name="org-email-4"]')?.value || '',
                    organizacion4_comprobante: document.getElementById('org_comprobante_4_path')?.value || '',
                    
                    // Organización 5
                    organizacion5_nombre: form.querySelector('[name="org-nombre-5"]')?.value || '',
                    organizacion5_responsable: form.querySelector('[name="org-responsable-5"]')?.value || '',
                    organizacion5_domicilio: form.querySelector('[name="org-domicilio-5"]')?.value || '',
                    organizacion5_telefono: form.querySelector('[name="org-telefono-5"]')?.value || '',
                    organizacion5_actividad: form.querySelector('[name="org-actividad-5"]')?.value || '',
                    organizacion5_email: form.querySelector('[name="org-email-5"]')?.value || '',
                    organizacion5_comprobante: document.getElementById('org_comprobante_5_path')?.value || ''
                }
            };
            try {
                localStorage.setItem('proyecto_borrador_' + pageKey, JSON.stringify(jsonData));
                console.log('[organizaciones] ✅ Borrador guardado exitosamente');
                const verify = localStorage.getItem('proyecto_borrador_' + pageKey);
                if (verify) {
                    console.log('[organizaciones] ✅ Verificación exitosa');
                } else {
                    console.error('[organizaciones] ❌ Error de verificación');
                }
            } catch (e) {
                console.error('[organizaciones] ❌ Error al guardar borrador:', e);
                mostrarMensaje('Error al guardar el borrador', 'error', targetBtn);
                return;
            }
            
            mostrarMensaje('Borrador guardado exitosamente', 'success', targetBtn);
        }

        // Función para cargar borrador
        function cargarBorrador(formId, pageKey) {
            console.log('[organizaciones] Intentando cargar borrador...');
            const savedData = localStorage.getItem('proyecto_borrador_' + pageKey);
            
            if (!savedData) {
                console.log('[organizaciones] No hay borrador guardado');
                return;
            }
            
            try {
                const data = JSON.parse(savedData);
                const form = document.getElementById(formId);
                if (!form) return;
                
                const p5 = data?.organizacion_social;
                if (!p5) return;
                
                // Helper para cargar campos y archivos
                // Helper para cargar campos y archivos corregido
            const loadOrg = (num) => {
                if (p5['organizacion' + num + '_nombre']) form.querySelector('[name="org-nombre-' + num + '"]').value = p5['organizacion' + num + '_nombre'];
                if (p5['organizacion' + num + '_responsable']) form.querySelector('[name="org-responsable-' + num + '"]').value = p5['organizacion' + num + '_responsable'];
                if (p5['organizacion' + num + '_domicilio']) form.querySelector('[name="org-domicilio-' + num + '"]').value = p5['organizacion' + num + '_domicilio'];
                if (p5['organizacion' + num + '_telefono']) form.querySelector('[name="org-telefono-' + num + '"]').value = p5['organizacion' + num + '_telefono'];
                if (p5['organizacion' + num + '_actividad']) form.querySelector('[name="org-actividad-' + num + '"]').value = p5['organizacion' + num + '_actividad'];
                if (p5['organizacion' + num + '_email']) form.querySelector('[name="org-email-' + num + '"]').value = p5['organizacion' + num + '_email'];

                // CARGA DE ARCHIVO
                const filePath = p5['organizacion' + num + '_comprobante'];
                if (filePath) {
                    const hiddenInput = document.getElementById('org_comprobante_' + num + '_path');
                    if (hiddenInput) {
                        hiddenInput.value = filePath;
                        // Mostrar la previsualización
                        toggleFilePreview('org_comprobante_' + num, true, filePath, filePath.split('/').pop());
                    }
                }
            };

                // Cargar las 5 organizaciones
            for(let i=1; i<=5; i++) {
                loadOrg(i);
            }
                
                console.log('[organizaciones] ✅ Borrador cargado exitosamente');
            } catch (error) {
                console.error('[organizaciones] ❌ Error al cargar borrador:', error);
            }
        }

        // --- FUNCIONES DE GESTIÓN DE ARCHIVOS (COPIADAS DE registroProyecto.jsp) ---

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
        
            // Previsualización y lectura
            const reader = new FileReader();
            const fileReadPromise = new Promise((resolve, reject) => {
                reader.onload = () => resolve(reader.result);
                reader.onerror = (error) => reject(error);
            });
            reader.readAsDataURL(file);
        
            toggleFilePreview(baseId, true, '', 'Procesando...');
            statusElement.className = 'text-sm text-blue-600';
        
            try {
                const base64String = await fileReadPromise;
                statusElement.textContent = 'Subiendo...';
        
                const bodyParams = new URLSearchParams();
                bodyParams.append('fileName', file.name);
                bodyParams.append('fileData', base64String);
        
                const response = await fetch('/proyectos/pages/responsableDeproyecto/registroProyecto/upload.jsp', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: bodyParams
                });
        
                const result = await response.json();
        
                if (response.ok && result.success) {
                    // 1. Asignar ruta
                    hiddenPathInput.value = result.webUrl;
                    
                    // 2. Actualizar UI
                    toggleFilePreview(baseId, true, result.webUrl, result.originalName);
                    statusElement.className = 'text-sm text-green-600';
        
                    // 3. --- AUTO-GUARDADO ---
                    // Guardamos inmediatamente en localStorage
                    guardarBorrador('formOrganizaciones', 'pagina5', null);
                    console.log('Archivo subido y borrador actualizado automáticamente.');
                    // ------------------------
        
                    // 4. Notificar cambio
                    hiddenPathInput.dispatchEvent(new Event('input'));
                } else {
                    throw new Error(result.message || 'Error al subir el archivo.');
                }
            } catch (error) {
                console.error('Error en carga (Base64):', error);
                toggleFilePreview(baseId, false);
                statusElement.textContent = `❌ Error al subir: ${error.message}`;
                statusElement.className = 'text-sm text-red-600';
                fileInput.value = '';
                hiddenPathInput.value = '';
            }
        }

        async function handleFileDelete(baseId, fileUrl) {
            if (!fileUrl) {
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
                    // 1. Limpiar valor
                    document.getElementById(baseId + '_path').value = '';

                    // 2. Actualizar UI
                    toggleFilePreview(baseId, false);
                    mostrarMensaje(result.message || 'Archivo eliminado', 'success');

                    // 3. --- AUTO-GUARDADO ---
                    // Actualizamos el borrador para que "olvide" el archivo
                    guardarBorrador('formOrganizaciones', 'pagina5', null);
                    console.log('Archivo eliminado y borrador actualizado automáticamente.');
                    // ------------------------

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
                const fileInput = document.getElementById(baseId);
                if (fileInput) fileInput.value = '';
            }
        }

        // Mostrar mensaje temporal
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
                messageDiv.style.position = 'absolute';
                messageDiv.style.visibility = 'hidden';
                document.body.appendChild(messageDiv);
                
                const rect = targetEl.getBoundingClientRect();
                const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
                const scrollLeft = window.pageXOffset || document.documentElement.scrollLeft;
                const mw = messageDiv.offsetWidth;
                const mh = messageDiv.offsetHeight;
                
                let left = rect.left + scrollLeft + (rect.width - mw) / 2;
                let top = rect.top + scrollTop - mh - 8;
                if (top < (window.pageYOffset || document.documentElement.scrollTop)) {
                    top = rect.top + scrollTop + rect.height + 8;
                }
                const maxLeft = (window.pageXOffset || document.documentElement.scrollLeft) + document.documentElement.clientWidth - mw - 8;
                if (left < 8) left = 8;
                if (left > maxLeft) left = maxLeft;
                
                messageDiv.style.left = left + 'px';
                messageDiv.style.top = top + 'px';
                messageDiv.style.visibility = 'visible';
            } else {
                messageDiv.style.position = 'fixed';
                messageDiv.style.top = '1rem';
                messageDiv.style.right = '1rem';
                document.body.appendChild(messageDiv);
            }
            setTimeout(() => {
                if (messageDiv && messageDiv.parentNode) messageDiv.parentNode.removeChild(messageDiv);
            }, 3000);
        }

        // Inicialización y Eventos
        window.addEventListener('load', function() {
            // 1. Cargar datos
            cargarBorrador('formOrganizaciones', 'pagina5');
            
            // 2. Configurar botones de navegación
            const KEY = 'proyecto_borrador_pagina5_saved';
            const form = document.getElementById('formOrganizaciones');
            const buttons = Array.from(document.querySelectorAll('button'));
            const guardarBtn = buttons.find(b => (b.getAttribute('onclick')||'').includes('guardarBorrador') || /guardar borrador/i.test(b.textContent));
            const siguienteBtn = document.getElementById('btnSiguiente');
            
            function setDisabled(btn, disabled){
                if(!btn) return;
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
                console.warn('Botones de navegación faltantes');
            } else {
                let saved = localStorage.getItem(KEY) === '1';
                setDisabled(siguienteBtn, !saved);
                
                guardarBtn.addEventListener('click', function(){
                    localStorage.setItem(KEY,'1');
                    saved = true;
                    setDisabled(siguienteBtn, false);
                });
                
                siguienteBtn.addEventListener('click', function(e){
                    e.preventDefault();
                    e.stopPropagation();
                    if(siguienteBtn.getAttribute('data-disabled') === 'true'){
                        mostrarMensaje('Debe guardar el borrador antes de continuar', 'error', siguienteBtn);
                        return false;
                    }
                    window.location.href = '/proyectos/pages/responsableDeproyecto/registroProyecto/registroProyecto6.jsp';
                });

                // Control de cambios sin guardar
                if(form){
                    const inputs = Array.from(form.querySelectorAll('input, textarea, select'));
                    const onChange = function(){
                        if(saved){
                            saved = false;
                            localStorage.setItem(KEY,'0');
                            setDisabled(siguienteBtn, true);
                            console.log('Formulario modificado: Siguiente bloqueado.');
                        }
                    };
                    inputs.forEach(el => el.addEventListener('input', onChange));
                    inputs.forEach(el => el.addEventListener('change', onChange));
                    
                    window.addEventListener('beforeunload', function(e){
                        try{
                            if(!saved){
                                var msg = 'Tiene cambios sin guardar.';
                                e.preventDefault(); 
                                e.returnValue = msg; 
                                return msg;
                            }
                        }catch(err){ return undefined; }
                    });
                }
            }

            // 3. ASIGNAR LISTENERS A LOS 5 CAMPOS DE ARCHIVO DINÁMICAMENTE
            for (let i = 1; i <= 5; i++) {
                const baseId = 'org_comprobante_' + i;
                const fileInput = document.getElementById(baseId);
                const hiddenPath = document.getElementById(baseId + '_path');
                const statusSpan = document.getElementById(baseId + '_status');
                const viewBtn = document.getElementById(baseId + '_view_btn');
                const deleteBtn = document.getElementById(baseId + '_delete_btn');

                if (fileInput && hiddenPath && statusSpan) {
                    // Evento Subida
                    fileInput.addEventListener('change', () => handleFileUpload(fileInput, hiddenPath, statusSpan));
                    
                    // Evento Ver
                    if (viewBtn) {
                        viewBtn.addEventListener('click', function() { 
                            const url = this.getAttribute('data-url');
                            if(url) window.open(url, '_blank'); 
                        });
                    }
                    
                    // Evento Borrar
                    if (deleteBtn) {
                        deleteBtn.addEventListener('click', function() { 
                            handleFileDelete(baseId, hiddenPath.value); 
                        });
                    }
                }
            }
        });
    </script>
</body>
</html>
