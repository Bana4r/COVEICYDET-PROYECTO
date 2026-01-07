<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
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
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <title>Descargar Plantilla - COVEICYDET</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');
        
        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
        }
        
        .form-container {
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
        }
        
        .download-btn {
            background: linear-gradient(135deg, #7A1737 0%, #B28854 100%);
            transition: all 0.3s ease;
        }
        
        .download-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(122, 23, 55, 0.3);
        }
    </style>
</head>
<body class="min-h-screen flex flex-col">
    <%@ include file="../header.jsp" %>
    
    <!-- Contenido principal -->
    <%@ include file="Navegador.jsp" %>

    <main class="flex-grow py-8">
        <div class="container mx-auto px-4 max-w-4xl">
            <div class="form-container bg-white rounded-xl overflow-hidden border border-slate-200">
                <!-- Encabezado del formulario - SOLO COLOR #B28854 -->
                <div class="bg-[#B28854] p-6 text-white">
                    <div class="flex items-center space-x-4">
                        <div class="w-14 h-14 bg-white/20 rounded-full flex items-center justify-center">
                            <i class="fas fa-download text-2xl text-white"></i>
                        </div>
                        <div>
                            <h1 class="text-2xl font-bold">Descargar Plantilla del Documento Extenso 9/10</h1>
                            <p class="text-white/90 mt-1">Utiliza nuestra plantilla oficial para garantizar el formato correcto</p>
                        </div>
                    </div>
                </div>

                <!-- Formulario -->
                <form id="formPagina9" class="p-8 space-y-8">

                    <!-- Sección principal de descarga -->
                    <section class="space-y-8">
                        <!-- Información importante -->
                        <div class="bg-gradient-to-r from-yellow-50 to-amber-50 border-l-4 border-amber-400 p-6 rounded-lg">
                            <div class="flex items-start">
                                <i class="fas fa-lightbulb text-amber-500 text-2xl mr-4 mt-1"></i>
                                <div>
                                    <h3 class="font-semibold text-amber-800 text-lg mb-2">Recomendación Importante</h3>
                                    <p class="text-amber-700">
                                        Descarga y utiliza esta plantilla antes de comenzar a redactar tu documento extenso. 
                                        Esto garantizará que tu proyecto cumpla con todos los requisitos de formato establecidos por COVEICYDET.
                                    </p>
                                </div>
                            </div>
                        </div>

                        <!-- Botón de descarga principal -->
                        <div class="text-center py-8">
                            <a href="/proyectos/plantillas/EjemploDocCOVEICYDET.docx" download
                               class="download-btn text-white font-bold py-5 px-10 rounded-xl inline-flex items-center justify-center text-lg transition-all duration-300">
                                <i class="fas fa-download mr-3 text-xl"></i>
                                <span>Descargar Plantilla Oficial</span>
                            </a>
                        </div>

                        <!-- Instrucciones -->
                        <div class="bg-gray-50 p-6 rounded-lg border border-gray-200">
                            <h3 class="font-semibold text-gray-800 mb-4 flex items-center">
                                <i class="fas fa-list-ol text-[#7A1737] mr-2"></i>
                                Instrucciones de Uso
                            </h3>
                            <div class="grid grid-cols-1 md:grid-cols-2 md:grid-rows-3 md:grid-flow-col gap-4">
                                <div class="flex items-start">
                                    <div class="w-8 h-8 bg-[#7A1737] text-white rounded-full flex items-center justify-center mr-3 flex-shrink-0">
                                        <span class="font-bold text-sm">1</span>
                                    </div>
                                    <div>
                                        <p class="font-medium text-gray-800">Descarga la plantilla</p>
                                        <p class="text-sm text-gray-600">Haz clic en el botón de descarga superior</p>
                                    </div>
                                </div>
                                <div class="flex items-start">
                                    <div class="w-8 h-8 bg-[#7A1737] text-white rounded-full flex items-center justify-center mr-3 flex-shrink-0">
                                        <span class="font-bold text-sm">2</span>
                                    </div>
                                    <div>
                                        <p class="font-medium text-gray-800">Abre el documento</p>
                                        <p class="text-sm text-gray-600">En Microsoft Word o LibreOffice Writer</p>
                                    </div>
                                </div>
                                <div class="flex items-start">
                                    <div class="w-8 h-8 bg-[#7A1737] text-white rounded-full flex items-center justify-center mr-3 flex-shrink-0">
                                        <span class="font-bold text-sm">3</span>
                                    </div>
                                    <div>
                                        <p class="font-medium text-gray-800">Completa cada sección</p>
                                        <p class="text-sm text-gray-600">Sigue las instrucciones incluidas</p>
                                    </div>
                                </div>
                                <div class="flex items-start">
                                    <div class="w-8 h-8 bg-[#B28854] text-white rounded-full flex items-center justify-center mr-3 flex-shrink-0">
                                        <span class="font-bold text-sm">4</span>
                                    </div>
                                    <div>
                                        <p class="font-medium text-gray-800">Imprime el documento</p>
                                        <p class="text-sm text-gray-600">Para proceder al siguiente paso</p>
                                    </div>
                                </div>
                                <div class="flex items-start">
                                    <div class="w-8 h-8 bg-[#B28854] text-white rounded-full flex items-center justify-center mr-3 flex-shrink-0">
                                        <span class="font-bold text-sm">5</span>
                                    </div>
                                    <div>
                                        <p class="font-medium text-gray-800">Firma el documento</p>
                                        <p class="text-sm text-gray-600">El documento debe contener la firma autografa del representante tecnico (no se aceptan firmas digitales ni imágenes superpuestas)</p>
                                    </div>
                                </div>
                                <div class="flex items-start">
                                    <div class="w-8 h-8 bg-[#B28854] text-white rounded-full flex items-center justify-center mr-3 flex-shrink-0">
                                        <span class="font-bold text-sm">6</span>
                                    </div>
                                    <div>
                                        <p class="font-medium text-gray-800">Escanea el documento en formato pdf</p>
                                        <p class="text-sm text-gray-600">Para proceder a subir su documento</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </section>

                    <!-- Navegación -->
                    <div class="flex flex-col-reverse gap-4 pt-8 border-t border-gray-200 sm:flex-row sm:justify-between">
                        <div class="flex gap-4">
                            <button type="button"
                                    class="bg-gray-600 hover:bg-gray-700 text-white font-medium py-3 px-8 rounded-lg transition duration-200 flex items-center justify-center transform hover:scale-105"
                                    onclick="location.href='registroProyecto8.jsp'">
                                <i class="fas fa-arrow-left mr-2"></i>Anterior
                            </button>
                            <button type="button" onclick="guardarBorrador()"
                                    class="bg-gray-500 hover:bg-gray-600 text-white font-medium py-3 px-8 rounded-lg transition duration-200 flex items-center justify-center transform hover:scale-105">
                                <i class="fas fa-save mr-2"></i>Guardar Borrador
                            </button>
                        </div>
                        <button type="button" 
                                class="bg-gradient-to-r from-green-600 to-emerald-600 hover:from-green-700 hover:to-emerald-700 text-white font-medium py-3 px-8 rounded-lg transition duration-200 flex items-center justify-center transform hover:scale-105"
                                onclick="location.href='registroProyecto10.jsp'">
                            Siguiente
                            <i class="fas fa-arrow-right ml-2"></i>
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </main>
    
    <%@ include file="/footer.jsp" %>
    
    <script>
        // Función para guardar borrador
        function guardarBorrador() {
            const jsonData = {
                pagina9: {
                    plantilla_descargada: true,
                    fecha_descarga: new Date().toISOString()
                }
            };
            
            localStorage.setItem('proyecto_borrador_pagina9', JSON.stringify(jsonData));
            
            // Mostrar mensaje de éxito
            const messageDiv = document.createElement('div');
            messageDiv.className = 'fixed top-4 right-4 bg-green-100 border border-green-400 text-green-700 px-6 py-4 rounded-lg shadow-lg z-50';
            messageDiv.innerHTML = `
                <div class="flex items-center">
                    <i class="fas fa-check-circle mr-3 text-green-500 text-xl"></i>
                    <div>
                        <p class="font-semibold">Borrador guardado</p>
                        <p class="text-sm">Progreso de la plantilla guardado correctamente</p>
                    </div>
                </div>
            `;
            document.body.appendChild(messageDiv);
            
            setTimeout(() => {
                if (messageDiv && messageDiv.parentNode) {
                    messageDiv.parentNode.removeChild(messageDiv);
                }
            }, 3000);
        }

        // Efecto de descarga
        document.addEventListener('DOMContentLoaded', function() {
            const downloadBtn = document.querySelector('.download-btn');
            
            // Efecto de descarga
            if (downloadBtn) {
                downloadBtn.addEventListener('click', function() {
                    this.innerHTML = '<i class="fas fa-spinner fa-spin mr-3 text-xl"></i><span>Descargando...</span>';
                    this.classList.add('opacity-75');
                    
                    setTimeout(() => {
                        guardarBorrador();
                    }, 1500);
                });
            }
        });
    </script>
</body>
</html>
