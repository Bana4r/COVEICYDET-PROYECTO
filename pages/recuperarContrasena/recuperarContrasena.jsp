<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%@ include file="../../WEB-INF/conexion.jsp" %>

<%
    String token = request.getParameter("t");
    boolean tokenValido = false;
    
    // Validar token contra BD antes de mostrar nada
    if (token != null && !token.isEmpty()) {
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT id_usuario FROM usuarios WHERE token_cambiocontrasena = ?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, token);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                tokenValido = true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if(rs != null) try{rs.close();}catch(Exception e){}
            if(ps != null) try{ps.close();}catch(Exception e){}
            if(conn != null) try{conn.close();}catch(Exception e){}
        }
    }

    if (!tokenValido) {
        response.sendRedirect(request.getContextPath() + "/?error=token_invalido_pass");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>COVEICYDET - Nueva Contraseña</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { background: linear-gradient(135deg, #f8f9fa 0%, #f1f3f4 100%) !important; min-height: 100vh; }
        .card-container { box-shadow: 0 15px 35px rgba(122, 23, 55, 0.1); border-radius: 16px; max-width: 500px; width: 100%; overflow: hidden; }
        .header-decoration { background: linear-gradient(90deg, #7A1737 0%, #A8253C 100%); padding: 1.5rem; }
        .submit-btn { background: linear-gradient(90deg, #7A1737 0%, #A8253C 100%); color: white; transition: all 0.3s; }
        .submit-btn:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(122, 23, 55, 0.3); }
    </style>
</head>
<body class="flex items-center justify-center p-4">

    <div class="card-container bg-white">
        <div class="header-decoration flex items-center justify-between">
            <div>
                <h1 class="text-white text-xl font-bold">Nueva Contraseña</h1>
                <p class="text-white/90 text-sm">Establece tu nueva clave de acceso</p>
            </div>
            <i class="fas fa-key text-white text-2xl opacity-80"></i>
        </div>

        <form action="procesar_cambio_password.jsp" method="POST" class="p-8" id="passForm">
            <input type="hidden" name="token" value="<%= token %>">

            <div class="mb-6 relative">
                <label class="block text-gray-700 text-sm font-bold mb-2">Nueva Contraseña</label>
                <input type="password" id="password" name="password" required class="w-full px-4 py-3 rounded-lg border focus:outline-none focus:border-[#A8253C]" placeholder="********">
            </div>

            <div class="mb-6 relative">
                <label class="block text-gray-700 text-sm font-bold mb-2">Confirmar Contraseña</label>
                <input type="password" id="confirmPassword" required class="w-full px-4 py-3 rounded-lg border focus:outline-none focus:border-[#A8253C]" placeholder="********">
                <p id="errorMsg" class="text-red-500 text-xs mt-1 hidden">Las contraseñas no coinciden</p>
            </div>

            <button type="submit" id="submitBtn" class="w-full py-3 rounded-xl font-bold submit-btn">
                <i class="fas fa-save mr-2"></i> Guardar Nueva Contraseña
            </button>
        </form>
    </div>

    <script>
        const form = document.getElementById('passForm');
        const p1 = document.getElementById('password');
        const p2 = document.getElementById('confirmPassword');
        const error = document.getElementById('errorMsg');

        form.addEventListener('submit', (e) => {
            if (p1.value !== p2.value) {
                e.preventDefault();
                error.classList.remove('hidden');
                p2.classList.add('border-red-500');
            } else {
                 if(p1.value.length < 6) {
                     e.preventDefault();
                     alert("La contraseña debe tener al menos 6 caracteres");
                 }
            }
        });
        
        p2.addEventListener('input', () => {
             if(p1.value === p2.value) {
                 error.classList.add('hidden');
                 p2.classList.remove('border-red-500');
                 p2.classList.add('border-green-500');
             }
        });
    </script>
</body>
</html>