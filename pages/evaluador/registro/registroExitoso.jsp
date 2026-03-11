<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Verificar si viene de un registro exitoso de evaluador o de activación
    String registroMsg = request.getParameter("registrado");
    String mailError = request.getParameter("mail_error");
    String activacionMsg = (String) session.getAttribute("activacion_msg");

    boolean registroExitoso = "1".equals(registroMsg);
    boolean activacionExitosa = "cuenta_activada".equals(activacionMsg);
    boolean correoFallido = "1".equals(mailError);

    // Limpiar los mensajes de la sesión
    if (activacionMsg != null) {
        session.removeAttribute("activacion_msg");
    }

    // Si no viene de un registro o activación, redirigir al login de evaluadores
    if (!registroExitoso && !activacionExitosa) {
        response.sendRedirect("index.jsp");
        return;
    }

    // Determinar el título y mensaje según el origen
    String titulo = activacionExitosa ? "¡Cuenta Activada!" : "¡Registro Exitoso!";
    String subtitulo = activacionExitosa ?
        "Su cuenta de evaluador ha sido activada correctamente." :
        "El evaluador ha sido registrado correctamente en el";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registro Exitoso - Evaluador COVEICYDET</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');
        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
            min-height: 100vh;
        }
        .success-card {
            animation: fadeInUp 0.6s ease-out;
        }
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        .icon-success {
            animation: bounceIn 0.8s ease-out 0.3s both;
        }
        @keyframes bounceIn {
            0% { transform: scale(0); }
            50% { transform: scale(1.2); }
            100% { transform: scale(1); }
        }
        .icon-mail {
            animation: pulse 2s ease-in-out infinite;
        }
        @keyframes pulse {
            0%, 100% { transform: scale(1); opacity: 1; }
            50% { transform: scale(1.1); opacity: 0.8; }
        }
        .btn-primary {
            background: linear-gradient(135deg, #7A1737 0%, #5a1028 100%);
            transition: all 0.3s ease;
        }
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 30px rgba(122, 23, 55, 0.4);
        }
        .step-card {
            transition: all 0.3s ease;
        }
        .step-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 40px rgba(0, 0, 0, 0.2);
        }
    </style>
</head>
<body class="flex items-center justify-center p-4">
    <div class="success-card bg-white rounded-2xl shadow-2xl p-8 md:p-12 max-w-2xl w-full text-center">

        <!-- Icono de éxito -->
        <div class="icon-success mb-6">
            <div class="mx-auto w-24 h-24 bg-green-100 rounded-full flex items-center justify-center">
                <i class="fas fa-check-circle text-5xl text-green-500"></i>
            </div>
        </div>

        <!-- Título -->
        <h1 class="text-2xl md:text-3xl font-bold text-gray-800 mb-4">
            <%= titulo %>
        </h1>

        <!-- Mensaje principal -->
        <p class="text-gray-600 mb-6 leading-relaxed">
            <%= subtitulo %>
            <% if (!activacionExitosa) { %>
            <span class="font-semibold text-[#7A1737]">Sistema de Registro de Proyectos COVEICYDET</span>.
            <% } %>
        </p>

        <% if (correoFallido && !activacionExitosa) { %>
        <!-- Advertencia de correo fallido -->
        <div class="bg-yellow-50 border border-yellow-200 rounded-xl p-4 mb-6 text-left">
            <div class="flex items-start gap-3">
                <i class="fas fa-exclamation-triangle text-yellow-600 text-xl mt-0.5"></i>
                <div>
                    <p class="font-semibold text-yellow-800 mb-1">No se pudo enviar el correo de activación</p>
                    <p class="text-sm text-yellow-700">
                        Su registro fue exitoso, pero hubo un problema al enviar el correo de activación.
                        Por favor, contacte al administrador para activar su cuenta o intente nuevamente más tarde.
                    </p>
                </div>
            </div>
        </div>
        <% } %>

        <% if (!activacionExitosa && !correoFallido) { %>
        <!-- Icono de correo -->
        <div class="icon-mail mb-4">
            <div class="mx-auto w-16 h-16 bg-[#7A1737]/10 rounded-full flex items-center justify-center">
                <i class="fas fa-envelope text-3xl text-[#7A1737]"></i>
            </div>
        </div>

        <!-- Instrucciones -->
        <div class="bg-gradient-to-r from-[#7A1737]/5 to-[#B28854]/5 rounded-xl p-6 mb-8 border border-[#B28854]/20">
            <p class="text-gray-700 font-medium mb-4">
                <i class="fas fa-info-circle text-[#B28854] mr-2"></i>
                Revise su correo electrónico
            </p>
            <p class="text-gray-600 text-sm leading-relaxed">
                Se ha enviado un enlace de validación a la dirección de correo registrada.
                Debe hacer clic en el enlace para validar su correo electrónico y proceder con la
                <span class="font-semibold text-[#7A1737]">validación y cotejo de documentos</span>.
            </p>
        </div>
        <% } %>

        <% if (!activacionExitosa) { %>
        <!-- Pasos a seguir -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-8">
            <div class="step-card bg-gray-50 rounded-xl p-4 border border-gray-200">
                <div class="w-10 h-10 bg-[#7A1737] text-white rounded-full flex items-center justify-center mx-auto mb-3 font-bold">
                    1
                </div>
                <p class="text-sm text-gray-600 font-medium">Revise su bandeja de entrada</p>
            </div>
            <div class="step-card bg-gray-50 rounded-xl p-4 border border-gray-200">
                <div class="w-10 h-10 bg-[#B28854] text-white rounded-full flex items-center justify-center mx-auto mb-3 font-bold">
                    2
                </div>
                <p class="text-sm text-gray-600 font-medium">Validar correo electrónico</p>
            </div>
            <div class="step-card bg-gray-50 rounded-xl p-4 border border-gray-200">
                <div class="w-10 h-10 bg-[#7A1737] text-white rounded-full flex items-center justify-center mx-auto mb-3 font-bold">
                    3
                </div>
                <p class="text-sm text-gray-600 font-medium">Cotejo de documentos</p>
            </div>
        </div>
        <% } %>

        <!-- Botón -->
        <a href="<%= activacionExitosa ? request.getContextPath() + "/" : request.getContextPath() + "/pages/evaluador/login/login.jsp" %>"
           class="btn-primary inline-flex items-center justify-center gap-3 w-full py-4 px-6 text-white font-semibold rounded-xl text-lg">
            <i class="fas fa-<%= activacionExitosa ? "sign-in-alt" : "arrow-left" %>"></i>
            <%= activacionExitosa ? "Iniciar Sesión" : "Volver al Login" %>
        </a>

        <!-- Logo o footer -->
        <div class="mt-8 pt-6 border-t border-gray-200">
            <p class="text-sm text-gray-400">
                <i class="fas fa-shield-alt mr-1"></i>
                COVEICYDET - Sistema de Gestión de Proyectos
            </p>
        </div>
    </div>

    <script>
        // Mantener la URL limpia
        if (window.history.replaceState) {
            window.history.replaceState(null, null, '<%= request.getContextPath() %>/pages/evaluador/registro/registroExitoso.jsp');
        }
    </script>
</body>
</html>
