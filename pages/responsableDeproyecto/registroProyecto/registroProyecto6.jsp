<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<% if (!"responsable".equals(String.valueOf(session.getAttribute("rol")))) { String n=request.getRequestURI()+(request.getQueryString()!=null?("?"+request.getQueryString()):""); response.sendRedirect(request.getContextPath()+"/pages/login/login.jsp?next="+java.net.URLEncoder.encode(n,"UTF-8")); return;
} %>

<%@ include file="/WEB-INF/seguridadProyecto.jsp" %>

<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <title>Estudiantes - COVEICYDET</title>
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
        
        .file-input {
            border: 1px solid #d1d5db;
            border-radius: 0.375rem;
            padding: 0.5rem;
            width: 100%;
            font-size: 0.875rem;
        }
        
        .file-input:focus {
            outline: none;
            border-color: #7A1737;
            box-shadow: 0 0 0 2px rgba(122, 23, 55, 0.2);
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
                        <i class="fas fa-user-graduate mr-3"></i>OPCIONAL. Estudiantes Participantes 6/10
                    </h1>
                    <p class="text-white/90 mt-2 flex items-center">
                        <i class="fas fa-info-circle mr-2"></i>Ingrese la información de los estudiantes participantes (En caso de no contar con estudiantes, guarde en borrador y continúe)
                    </p>
                </div>

                <form id="formEstudiantes" class="p-8 space-y-8">
                    <div class="legend-box">
                        <div class="legend-title">Estudiantes Participantes</div>
                        <div class="legend-text"> Cada estudiante debe contar con información completa sobre su nivel académico, institución, programa educativo,
                            tiempo de permanencia en el proyecto, actividades específicas y adjuntar la carta de intención de colaboración.
                        </div>
                    </div>

                    <section class="space-y-6">
                        <h4 class="text-sm font-semibold uppercase tracking-wide text-slate-500 flex items-center">
                            <i class="fas fa-user-graduate mr-2 text-[#7A1737]"></i>ESTUDIANTES
                        </h4>

                        <div class="table-section">
                            <div class="section-header">
                                <h5 class="table-title">Estudiante 1</h5>
                            </div>
                            <table class="participant-table">
                                <tbody>
                                    <tr>
                                        <td style="width: 200px; background-color: #f8fafc; font-weight: 500;">Nombre completo</td>
                                        <td><input type="text" name="est-nombre-1" class="floating-input" placeholder="Nombre completo"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Nivel académico</td>
                                        <td>
                                            <select name="est-nivel-1" class="floating-input">
                                                <option value="">Seleccione</option>
                                                <option value="Licenciatura">Licenciatura</option>
                                                <option value="Maestría">Maestría</option>
                                                <option value="Doctorado">Doctorado</option>
                                            </select>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Institución</td>
                                        <td><input type="text" name="est-institucion-1" class="floating-input" placeholder="Institución"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Programa Educativo</td>
                                        <td><input type="text" name="est-programa-1" class="floating-input" placeholder="Programa Educativo"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Sexo</td>
                                        <td>
                                            <select name="est-sexo-1" class="floating-input">
                                                <option value="">Seleccione</option>
                                                <option value="Hombre">Hombre</option>
                                                <option value="Mujer">Mujer</option>
                                            </select>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Tiempo de permanencia (maximo 6 meses)</td>
                                        <td><input type="number" name="est-tiempo-1" class="floating-input" placeholder="Meses" min="1" max="6" oninput="if(this.value>6)this.value=6;"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Actividades a realizar</td>
                                        <td><input type="text" name="est-actividades-realizar-1" class="floating-input" placeholder="Actividades a realizar"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">
                                            <i class="fas fa-file-pdf text-[#7A1737] mr-2"></i>Adjunte carta de intención de colaboración 
                                        </td>
                                        <td>
                                            <input type="hidden" id="est_comprobante_1_path" name="est_comprobante_1_path">
                                            
                                            <div id="est_comprobante_1_uploader">
                                                <input type="file" id="est_comprobante_1" name="est_comprobante_1" accept=".pdf" 
                                                       class="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100" 
                                                       title="Adjunte comprobante">
                                            </div>

                                            <div id="est_comprobante_1_previewer" class="hidden items-center space-x-2 mt-1">
                                                <span id="est_comprobante_1_status" class="text-sm text-green-600 truncate" style="max-width: 150px;"></span>
                                                <button type="button" id="est_comprobante_1_view_btn" title="Visualizar Archivo" class="p-1 h-7 w-7 rounded bg-blue-600 text-white hover:bg-blue-700 text-xs">
                                                    <i class="fas fa-eye"></i>
                                                </button>
                                                <button type="button" id="est_comprobante_1_delete_btn" title="Eliminar Archivo" class="p-1 h-7 w-7 rounded bg-red-600 text-white hover:bg-red-700 text-xs">
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
                                <h5 class="table-title">Estudiante 2</h5>
                            </div>
                            <table class="participant-table">
                                <tbody>
                                    <tr>
                                        <td style="width: 200px; background-color: #f8fafc; font-weight: 500;">Nombre completo</td>
                                        <td><input type="text" name="est-nombre-2" class="floating-input" placeholder="Nombre completo"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Nivel académico</td>
                                        <td>
                                            <select name="est-nivel-2" class="floating-input">
                                                <option value="">Seleccione</option>
                                                <option value="Licenciatura">Licenciatura</option>
                                                <option value="Maestría">Maestría</option>
                                                <option value="Doctorado">Doctorado</option>
                                            </select>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Institución</td>
                                        <td><input type="text" name="est-institucion-2" class="floating-input" placeholder="Institución"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Programa Educativo</td>
                                        <td><input type="text" name="est-programa-2" class="floating-input" placeholder="Programa Educativo"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Sexo</td>
                                        <td>
                                            <select name="est-sexo-2" class="floating-input">
                                                <option value="">Seleccione</option>
                                                <option value="Hombre">Hombre</option>
                                                <option value="Mujer">Mujer</option>
                                            </select>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Tiempo de permanencia (meses)</td>
                                        <td><input type="number" name="est-tiempo-2" class="floating-input" placeholder="Meses" min="1" max="6" oninput="if(this.value>6)this.value=6;"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Actividades a realizar</td>
                                        <td><input type="text" name="est-actividades-realizar-2" class="floating-input" placeholder="Actividades a realizar"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">
                                            <i class="fas fa-file-pdf text-[#7A1737] mr-2"></i>Adjunte carta de intención de colaboración 
                                        </td>
                                        <td>
                                            <input type="hidden" id="est_comprobante_2_path" name="est_comprobante_2_path">
                                            
                                            <div id="est_comprobante_2_uploader">
                                                <input type="file" id="est_comprobante_2" name="est_comprobante_2" accept=".pdf" 
                                                       class="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100" 
                                                       title="Adjunte comprobante">
                                            </div>

                                            <div id="est_comprobante_2_previewer" class="hidden items-center space-x-2 mt-1">
                                                <span id="est_comprobante_2_status" class="text-sm text-green-600 truncate" style="max-width: 150px;"></span>
                                                <button type="button" id="est_comprobante_2_view_btn" title="Visualizar Archivo" class="p-1 h-7 w-7 rounded bg-blue-600 text-white hover:bg-blue-700 text-xs">
                                                    <i class="fas fa-eye"></i>
                                                </button>
                                                <button type="button" id="est_comprobante_2_delete_btn" title="Eliminar Archivo" class="p-1 h-7 w-7 rounded bg-red-600 text-white hover:bg-red-700 text-xs">
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
                                <h5 class="table-title">Estudiante 3</h5>
                            </div>
                            <table class="participant-table">
                                <tbody>
                                    <tr>
                                        <td style="width: 200px; background-color: #f8fafc; font-weight: 500;">Nombre completo</td>
                                        <td><input type="text" name="est-nombre-3" class="floating-input" placeholder="Nombre completo"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Nivel académico</td>
                                        <td>
                                            <select name="est-nivel-3" class="floating-input">
                                                <option value="">Seleccione</option>
                                                <option value="Licenciatura">Licenciatura</option>
                                                <option value="Maestría">Maestría</option>
                                                <option value="Doctorado">Doctorado</option>
                                            </select>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Institución</td>
                                        <td><input type="text" name="est-institucion-3" class="floating-input" placeholder="Institución"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Programa Educativo</td>
                                        <td><input type="text" name="est-programa-3" class="floating-input" placeholder="Programa Educativo"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Sexo</td>
                                        <td>
                                            <select name="est-sexo-3" class="floating-input">
                                                <option value="">Seleccione</option>
                                                <option value="Hombre">Hombre</option>
                                                <option value="Mujer">Mujer</option>
                                            </select>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Tiempo de permanencia (meses)</td>
                                        <td><input type="number" name="est-tiempo-3" class="floating-input" placeholder="Meses" min="1" max="6" oninput="if(this.value>6)this.value=6;"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Actividades a realizar</td>
                                        <td><input type="text" name="est-actividades-realizar-3" class="floating-input" placeholder="Actividades a realizar"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">
                                            <i class="fas fa-file-pdf text-[#7A1737] mr-2"></i>Adjunte carta de intención de colaboración 
                                        </td>
                                        <td>
                                            <input type="hidden" id="est_comprobante_3_path" name="est_comprobante_3_path">
                                            
                                            <div id="est_comprobante_3_uploader">
                                                <input type="file" id="est_comprobante_3" name="est_comprobante_3" accept=".pdf" 
                                                       class="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100" 
                                                       title="Adjunte comprobante">
                                            </div>

                                            <div id="est_comprobante_3_previewer" class="hidden items-center space-x-2 mt-1">
                                                <span id="est_comprobante_3_status" class="text-sm text-green-600 truncate" style="max-width: 150px;"></span>
                                                <button type="button" id="est_comprobante_3_view_btn" title="Visualizar Archivo" class="p-1 h-7 w-7 rounded bg-blue-600 text-white hover:bg-blue-700 text-xs">
                                                    <i class="fas fa-eye"></i>
                                                </button>
                                                <button type="button" id="est_comprobante_3_delete_btn" title="Eliminar Archivo" class="p-1 h-7 w-7 rounded bg-red-600 text-white hover:bg-red-700 text-xs">
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
                                <h5 class="table-title">Estudiante 4</h5>
                            </div>
                            <table class="participant-table">
                                <tbody>
                                    <tr>
                                        <td style="width: 200px; background-color: #f8fafc; font-weight: 500;">Nombre completo</td>
                                        <td><input type="text" name="est-nombre-4" class="floating-input" placeholder="Nombre completo"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Nivel académico</td>
                                        <td>
                                            <select name="est-nivel-4" class="floating-input">
                                                <option value="">Seleccione</option>
                                                <option value="Licenciatura">Licenciatura</option>
                                                <option value="Maestría">Maestría</option>
                                                <option value="Doctorado">Doctorado</option>
                                            </select>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Institución</td>
                                        <td><input type="text" name="est-institucion-4" class="floating-input" placeholder="Institución"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Programa Educativo</td>
                                        <td><input type="text" name="est-programa-4" class="floating-input" placeholder="Programa Educativo"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Sexo</td>
                                        <td>
                                            <select name="est-sexo-4" class="floating-input">
                                                <option value="">Seleccione</option>
                                                <option value="Hombre">Hombre</option>
                                                <option value="Mujer">Mujer</option>
                                            </select>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Tiempo de permanencia (meses)</td>
                                        <td><input type="number" name="est-tiempo-4" class="floating-input" placeholder="Meses" min="1" max="6" oninput="if(this.value>6)this.value=6;"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Actividades a realizar</td>
                                        <td><input type="text" name="est-actividades-realizar-4" class="floating-input" placeholder="Actividades a realizar"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">
                                            <i class="fas fa-file-pdf text-[#7A1737] mr-2"></i>Adjunte carta de intención de colaboración 
                                        </td>
                                        <td>
                                            <input type="hidden" id="est_comprobante_4_path" name="est_comprobante_4_path">
                                            
                                            <div id="est_comprobante_4_uploader">
                                                <input type="file" id="est_comprobante_4" name="est_comprobante_4" accept=".pdf" 
                                                       class="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100" 
                                                       title="Adjunte comprobante">
                                            </div>

                                            <div id="est_comprobante_4_previewer" class="hidden items-center space-x-2 mt-1">
                                                <span id="est_comprobante_4_status" class="text-sm text-green-600 truncate" style="max-width: 150px;"></span>
                                                <button type="button" id="est_comprobante_4_view_btn" title="Visualizar Archivo" class="p-1 h-7 w-7 rounded bg-blue-600 text-white hover:bg-blue-700 text-xs">
                                                    <i class="fas fa-eye"></i>
                                                </button>
                                                <button type="button" id="est_comprobante_4_delete_btn" title="Eliminar Archivo" class="p-1 h-7 w-7 rounded bg-red-600 text-white hover:bg-red-700 text-xs">
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
                                <h5 class="table-title">Estudiante 5</h5>
                            </div>
                            <table class="participant-table">
                                <tbody>
                                    <tr>
                                        <td style="width: 200px; background-color: #f8fafc; font-weight: 500;">Nombre completo</td>
                                        <td><input type="text" name="est-nombre-5" class="floating-input" placeholder="Nombre completo"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Nivel académico</td>
                                        <td>
                                            <select name="est-nivel-5" class="floating-input">
                                                <option value="">Seleccione</option>
                                                <option value="Licenciatura">Licenciatura</option>
                                                <option value="Maestría">Maestría</option>
                                                <option value="Doctorado">Doctorado</option>
                                            </select>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Institución</td>
                                        <td><input type="text" name="est-institucion-5" class="floating-input" placeholder="Institución"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Programa Educativo</td>
                                        <td><input type="text" name="est-programa-5" class="floating-input" placeholder="Programa Educativo"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Sexo</td>
                                        <td>
                                            <select name="est-sexo-5" class="floating-input">
                                                <option value="">Seleccione</option>
                                                <option value="Hombre">Hombre</option>
                                                <option value="Mujer">Mujer</option>
                                            </select>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Tiempo de permanencia (meses)</td>
                                        <td><input type="number" name="est-tiempo-5" class="floating-input" placeholder="Meses" min="1" max="6" oninput="if(this.value>6)this.value=6;"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">Actividades a realizar</td>
                                        <td><input type="text" name="est-actividades-realizar-5" class="floating-input" placeholder="Actividades a realizar"></td>
                                    </tr>
                                    <tr>
                                        <td style="background-color: #f8fafc; font-weight: 500;">
                                            <i class="fas fa-file-pdf text-[#7A1737] mr-2"></i>Adjunte carta de intención de colaboración 
                                        </td>
                                        <td>
                                            <input type="hidden" id="est_comprobante_5_path" name="est_comprobante_5_path">
                                            
                                            <div id="est_comprobante_5_uploader">
                                                <input type="file" id="est_comprobante_5" name="est_comprobante_5" accept=".pdf" 
                                                       class="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100" 
                                                       title="Adjunte comprobante">
                                            </div>

                                            <div id="est_comprobante_5_previewer" class="hidden items-center space-x-2 mt-1">
                                                <span id="est_comprobante_5_status" class="text-sm text-green-600 truncate" style="max-width: 150px;"></span>
                                                <button type="button" id="est_comprobante_5_view_btn" title="Visualizar Archivo" class="p-1 h-7 w-7 rounded bg-blue-600 text-white hover:bg-blue-700 text-xs">
                                                    <i class="fas fa-eye"></i>
                                                </button>
                                                <button type="button" id="est_comprobante_5_delete_btn" title="Eliminar Archivo" class="p-1 h-7 w-7 rounded bg-red-600 text-white hover:bg-red-700 text-xs">
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
                        <button type="button" onclick="guardarBorrador('formEstudiantes', 'pagina6', this)"
                                class="bg-gray-500 hover:bg-gray-600 text-white font-medium py-2 px-6 rounded-lg transition duration-200 flex items-center justify-center">
                            <i class="fas fa-save mr-2"></i>Guardar borrador
                        </button>
                        <div class="flex gap-4">
                            <button type="button"
                                    class="bg-gray-600 hover:bg-gray-700 text-white font-medium py-2 px-6 rounded-lg transition duration-200 flex items-center justify-center"
                                    onclick="location.href='/proyectos/pages/responsableDeproyecto/registroProyecto/registroProyecto5.jsp'">
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
        // Función para guardar datos del formulario en localStorage
        function guardarBorrador(formId, pageKey, targetBtn) {
            const form = document.getElementById(formId);
            console.log('[estudiantes] Iniciando guardado de borrador...');
            
            // 1. Crear el objeto contenedor
            const jsonData = {
                estudiantes: {}
            };

            // 2. Recorrer los 5 estudiantes para llenar el JSON
            for (let i = 1; i <= 5; i++) {
                // Obtenemos los valores del formulario
                jsonData.estudiantes['estudiante' + i + '_nombre'] = form.querySelector('[name="est-nombre-' + i + '"]')?.value || '';
                jsonData.estudiantes['estudiante' + i + '_sexo'] = form.querySelector('[name="est-sexo-' + i + '"]')?.value || '';
                jsonData.estudiantes['estudiante' + i + '_nivel'] = form.querySelector('[name="est-nivel-' + i + '"]')?.value || '';
                jsonData.estudiantes['estudiante' + i + '_tiempo'] = form.querySelector('[name="est-tiempo-' + i + '"]')?.value || '';
                jsonData.estudiantes['estudiante' + i + '_institucion'] = form.querySelector('[name="est-institucion-' + i + '"]')?.value || '';
                jsonData.estudiantes['estudiante' + i + '_programa'] = form.querySelector('[name="est-programa-' + i + '"]')?.value || '';
                jsonData.estudiantes['estudiante' + i + '_actividades'] = form.querySelector('[name="est-actividades-realizar-' + i + '"]')?.value || '';
                
                // Guardar la ruta del archivo (input hidden)
                jsonData.estudiantes['estudiante' + i + '_comprobante'] = document.getElementById('est_comprobante_' + i + '_path')?.value || '';
            }

            try {
                // 3. Guardar en LocalStorage
                localStorage.setItem('proyecto_borrador_' + pageKey, JSON.stringify(jsonData));
                console.log('[estudiantes] ✅ Borrador guardado exitosamente');
                
                // Verificación
                const verify = localStorage.getItem('proyecto_borrador_' + pageKey);
                if (verify) {
                    console.log('[estudiantes] ✅ Verificación exitosa');
                } else {
                    console.error('[estudiantes] ❌ Error: No se pudo verificar el guardado');
                }
            } catch (e) {
                console.error('[estudiantes] ❌ Error al guardar borrador:', e);
                mostrarMensaje('Error al guardar el borrador', 'error', targetBtn);
                return;
            }
            
            mostrarMensaje('Borrador guardado exitosamente', 'success', targetBtn);
        }

        // Función para cargar borrador
        function cargarBorrador(formId, pageKey) {
            console.log('[estudiantes] Intentando cargar borrador...');
            const savedData = localStorage.getItem('proyecto_borrador_' + pageKey);
            
            if (!savedData) {
                console.log('[estudiantes] No hay borrador guardado');
                return;
            }
            
            try {
                const data = JSON.parse(savedData);
                const form = document.getElementById(formId);
                if (!form) return;
                
                const p6 = data.estudiantes; // Objeto con los datos
                if (!p6) return;

                // Función auxiliar para cargar un estudiante específico
                const loadEstudiante = (num) => {
                    // Usamos concatenación (+) para evitar conflictos con JSP
                    if (p6['estudiante' + num + '_nombre']) form.querySelector('[name="est-nombre-' + num + '"]').value = p6['estudiante' + num + '_nombre'];
                    if (p6['estudiante' + num + '_sexo']) form.querySelector('[name="est-sexo-' + num + '"]').value = p6['estudiante' + num + '_sexo'];
                    if (p6['estudiante' + num + '_nivel']) form.querySelector('[name="est-nivel-' + num + '"]').value = p6['estudiante' + num + '_nivel'];
                    if (p6['estudiante' + num + '_tiempo']) form.querySelector('[name="est-tiempo-' + num + '"]').value = p6['estudiante' + num + '_tiempo'];
                    if (p6['estudiante' + num + '_institucion']) form.querySelector('[name="est-institucion-' + num + '"]').value = p6['estudiante' + num + '_institucion'];
                    if (p6['estudiante' + num + '_programa']) form.querySelector('[name="est-programa-' + num + '"]').value = p6['estudiante' + num + '_programa'];
                    if (p6['estudiante' + num + '_actividades']) form.querySelector('[name="est-actividades-realizar-' + num + '"]').value = p6['estudiante' + num + '_actividades'];

                    // CARGA DE ARCHIVO
                    const filePath = p6['estudiante' + num + '_comprobante'];
                    if (filePath) {
                        const hiddenInput = document.getElementById('est_comprobante_' + num + '_path');
                        if (hiddenInput) {
                            hiddenInput.value = filePath;
                            toggleFilePreview('est_comprobante_' + num, true, filePath, filePath.split('/').pop());
                        }
                    }
                };

                // Ciclo para cargar los 5 estudiantes
                for(let i = 1; i <= 5; i++) {
                    loadEstudiante(i);
                }
                
                console.log('[estudiantes] ✅ Borrador cargado exitosamente');
            } catch (error) {
                console.error('[estudiantes] ❌ Error al cargar borrador:', error);
            }
        }

        // --- FUNCIONES DE GESTIÓN DE ARCHIVOS (Igual que antes) ---

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
                    // 1. Asignar ruta al input oculto
                    hiddenPathInput.value = result.webUrl;
                    
                    // 2. Actualizar visualmente
                    toggleFilePreview(baseId, true, result.webUrl, result.originalName);
                    statusElement.className = 'text-sm text-green-600';
        
                    // 3. --- AUTO-GUARDADO ---
                    // Guardar inmediatamente en localStorage (pagina6)
                    guardarBorrador('formEstudiantes', 'pagina6', null);
                    console.log('Archivo subido y borrador actualizado automáticamente.');
                    // ------------------------
        
                    // 4. Disparar evento
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
                    
                    // 2. Actualizar visualmente
                    toggleFilePreview(baseId, false);
                    mostrarMensaje(result.message || 'Archivo eliminado', 'success');
                    
                    // 3. --- AUTO-GUARDADO ---
                    // Actualizar borrador para "olvidar" el archivo
                    guardarBorrador('formEstudiantes', 'pagina6', null);
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
            cargarBorrador('formEstudiantes', 'pagina6');
            
            // 2. Configurar botones de navegación
            const KEY = 'proyecto_borrador_pagina6_saved';
            const form = document.getElementById('formEstudiantes');
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
                    window.location.href = '/proyectos/pages/responsableDeproyecto/registroProyecto/registroProyecto7.jsp';
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
                const baseId = 'est_comprobante_' + i;
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
