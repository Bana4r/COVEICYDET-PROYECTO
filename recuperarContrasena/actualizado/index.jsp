<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Verificar si viene de un cambio exitoso
    String passwordMsg = (String) session.getAttribute("password_msg");
    boolean cambioExitoso = "password_actualizado".equals(passwordMsg);
    
    // Limpiar el mensaje de la sesión
    if (passwordMsg != null) {
        session.removeAttribute("password_msg");
    }
    
    // Si no viene de un cambio válido, redirigir al inicio
    if (!cambioExitoso) {
        response.sendRedirect(request.getContextPath() + "/");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Contraseña Actualizada - COVEICYDET</title>
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
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .icon-success {
            animation: bounceIn 0.8s ease-out 0.3s both;
        }
        @keyframes bounceIn {
            0% { transform: scale(0); }
            50% { transform: scale(1.2); }
            100% { transform: scale(1); }
        }
        .btn-login {
            background: linear-gradient(135deg, #7A1737 0%, #5a1028 100%);
            transition: all 0.3s ease;
        }
        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 30px rgba(122, 23, 55, 0.4);
        }
    </style>
</head>
<body class="flex items-center justify-center p-4">
    <div class="success-card bg-white rounded-2xl shadow-2xl p-8 md:p-12 max-w-lg w-full text-center">
        
        <!-- Icono de éxito -->
        <div class="icon-success mb-6">
            <div class="mx-auto w-24 h-24 bg-green-100 rounded-full flex items-center justify-center">
                <i class="fas fa-lock text-5xl text-green-500"></i>
            </div>
        </div>
        
        <!-- Título -->
        <h1 class="text-2xl md:text-3xl font-bold text-gray-800 mb-4">
            ¡Contraseña Actualizada!
        </h1>
        
        <!-- Mensaje -->
        <p class="text-gray-600 mb-8 leading-relaxed">
            Su contraseña ha sido actualizada exitosamente. 
            Ahora puede iniciar sesión con su nueva contraseña.
        </p>
        
        
        <!-- Botón de iniciar sesión -->
        <a href="/proyectos/" 
           class="btn-login inline-flex items-center justify-center gap-3 w-full py-4 px-6 text-white font-semibold rounded-xl text-lg">
            <i class="fas fa-sign-in-alt"></i>
            Iniciar Sesión
        </a>
        
        <!-- Footer -->
        <div class="mt-8 pt-6 border-t border-gray-200">
            <p class="text-sm text-gray-400">
                <i class="fas fa-shield-alt mr-1"></i>
                COVEICYDET - Sistema de Gestión de Proyectos
            </p>
        </div>
    </div>
    
    <script>
        if (window.history.replaceState) {
            window.history.replaceState(null, null, '/proyectos/recuperarContrasena/actualizado/');
        }
    </script>
</body>
</html>
