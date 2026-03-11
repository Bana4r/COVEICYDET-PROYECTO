<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%@ include file="../../../WEB-INF/conexion.jsp" %>

<%
    // Verificar si el evaluador ya está autenticado
    String rol = (String) session.getAttribute("rol");
    Boolean autenticado = (Boolean) session.getAttribute("autenticado");
    Integer idUsuario = (Integer) session.getAttribute("id_usuario");

    // Auto-login por cookie
    if ((autenticado == null || !autenticado) && idUsuario == null) {
        Cookie[] cookies = request.getCookies();
        String tokenEncontrado = null;
        if (cookies != null) {
            for (Cookie c : cookies) {
                if ("auth_token".equals(c.getName())) {
                    tokenEncontrado = c.getValue();
                    break;
                }
            }
        }

        if (tokenEncontrado != null && conn != null) {
            try {
                String sql = "SELECT u.id_usuario, u.nombre, u.primer_apellido, u.segundo_apellido, u.estado, t.tipo_usuario " +
                             "FROM usuarios u JOIN tipo_usuario t ON u.tipousuario = t.id_tipo_usuario " +
                             "WHERE u.token_sesion = ? AND t.tipo_usuario = 'evaluador'";

                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, tokenEncontrado);
                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    int estadoUsuario = rs.getInt("estado");
                    if (estadoUsuario == 2) {
                        session.setAttribute("autenticado", true);
                        session.setAttribute("id_usuario", rs.getInt("id_usuario"));
                        session.setAttribute("nombre", rs.getString("nombre") + " " + rs.getString("primer_apellido") + " " + rs.getString("segundo_apellido"));
                        session.setAttribute("rol", "evaluador");
                        response.sendRedirect(request.getContextPath() + "/pages/evaluador/index.jsp");
                        return;
                    }
                }
                rs.close();
                ps.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    // Si ya está autenticado como evaluador, redirigir
    if (autenticado != null && autenticado && "evaluador".equals(rol)) {
        response.sendRedirect(request.getContextPath() + "/pages/evaluador/index.jsp");
        return;
    }

    // Obtener error de la URL o de la sesión (compatibilidad)
    String errorLogin = request.getParameter("error");
    if (errorLogin == null) {
        errorLogin = (String) session.getAttribute("error_login");
        if (errorLogin != null) {
            session.removeAttribute("error_login");
        }
    }

    String msg = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>COVEICYDET - Login Evaluador</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://www.google.com/recaptcha/api.js?hl=es" async defer></script>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');
        
        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #f8f9fa 0%, #f1f3f4 100%);
            min-height: 100vh;
        }
        
        .login-card {
            box-shadow: 0 15px 35px rgba(122, 23, 55, 0.1), 0 5px 15px rgba(0, 0, 0, 0.07);
            border-radius: 16px;
            overflow: hidden;
            transition: transform 0.3s ease;
            max-width: 480px;
            width: 100%;
        }
        
        .login-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 40px rgba(122, 23, 55, 0.15);
        }
        
        .header-bg {
            background: linear-gradient(135deg, #7A1737 0%, #A8253C 100%);
        }
        
        .floating-label {
            position: relative;
            margin-bottom: 1.5rem;
        }
        
        .floating-input {
            border: 1.5px solid #e2e8f0;
            border-radius: 10px;
            padding: 1.1rem 0.85rem 0.6rem 2.5rem;
            width: 100%;
            transition: all 0.3s;
            font-size: 1rem;
        }
        
        .floating-input:focus {
            outline: none;
            border-color: #7A1737;
            box-shadow: 0 0 0 3px rgba(122, 23, 55, 0.15);
        }
        
        .floating-input:focus ~ .floating-label-text,
        .floating-input:not(:placeholder-shown) ~ .floating-label-text {
            top: 0.4rem;
            left: 0.85rem;
            font-size: 0.8rem;
            font-weight: 600;
            color: #7A1737;
            background-color: #ffffff;
            padding: 0 0.25rem;
        }
        
        .floating-label-text {
            position: absolute;
            top: 1.1rem;
            left: 2.5rem;
            color: #64748b;
            transition: all 0.2s;
            pointer-events: none;
        }
        
        .input-icon {
            position: absolute;
            left: 0.85rem;
            top: 50%;
            transform: translateY(-50%);
            color: #94a3b8;
        }
        
        .floating-input:focus + .input-icon {
            color: #7A1737;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #7A1737 0%, #A8253C 100%);
            transition: all 0.3s ease;
        }
        
        .btn-primary:hover:not(:disabled) {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(122, 23, 55, 0.3);
        }
        
        .btn-primary:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }
        
        .password-toggle {
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            color: #94a3b8;
            cursor: pointer;
            z-index: 10;
        }
        
        .password-toggle:hover {
            color: #7A1737;
        }
        
        .link-primary {
            color: #7A1737;
            transition: color 0.2s;
        }
        
        .link-primary:hover {
            color: #A8253C;
        }
    </style>
</head>
<body class="flex items-center justify-center p-4">
    <div class="login-card bg-white">
        <!-- Header -->
        <div class="header-bg p-6 text-white text-center">
            <div class="mx-auto w-16 h-16 bg-white/20 rounded-full flex items-center justify-center mb-3">
                <i class="fas fa-user-tie text-2xl"></i>
            </div>
            <h1 class="text-2xl font-bold">Login Evaluador</h1>
            <p class="text-white/90 text-sm mt-1">Sistema COVEICYDET</p>
        </div>

        <!-- Error message -->
        <% if (errorLogin != null && !errorLogin.isEmpty()) { %>
            <div class="bg-red-50 border-l-4 border-red-500 p-4 mx-6 mt-4">
                <p class="text-red-700 text-sm"><i class="fas fa-exclamation-circle mr-2"></i><%= errorLogin %></p>
            </div>
        <% } %>

        <!-- Form -->
        <form action="procesar_login.jsp" method="post" class="p-6" id="loginForm">
            <!-- Email -->
            <div class="floating-label">
                <input type="email" id="email" name="email" required placeholder=" "
                    class="floating-input" autocomplete="email">
                <label for="email" class="floating-label-text">Correo Electrónico</label>
                <i class="fas fa-envelope input-icon"></i>
            </div>

            <!-- Password -->
            <div class="floating-label">
                <input type="password" id="password" name="password" required placeholder=" "
                    class="floating-input" autocomplete="current-password">
                <label for="password" class="floating-label-text">Contraseña</label>
                <i class="fas fa-lock input-icon"></i>
                <button type="button" class="password-toggle" id="togglePassword">
                    <i class="fas fa-eye"></i>
                </button>
            </div>

            <!-- Remember me -->
            <div class="flex items-center justify-between text-sm mb-4">
                <div class="flex items-center">
                    <input type="checkbox" id="remember-me" name="remember-me" 
                        class="w-4 h-4 text-[#7A1737] border-gray-300 rounded focus:ring-[#7A1737]">
                    <label for="remember-me" class="ml-2 text-gray-700">Recordar sesión</label>
                </div>
                <a href="<%= request.getContextPath() %>/pages/recuperarContrasena/" 
                   class="link-primary font-medium">¿Olvidaste tu contraseña?</a>
            </div>

            <!-- reCAPTCHA -->
            <div class="flex justify-center mb-4">
                <div class="g-recaptcha" data-sitekey="6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI"
                     data-callback="onCaptchaSuccess"></div>
            </div>

            <!-- Submit button -->
            <button type="submit" class="w-full py-3 px-4 rounded-xl text-white font-semibold btn-primary"
                    id="submitBtn" disabled>
                <i class="fas fa-lock mr-2"></i> Verifica seguridad para continuar
            </button>

            <!-- Register link -->
            <div class="text-center text-sm text-gray-600 mt-6 pt-4 border-t">
                ¿No tienes una cuenta?
                <a href="<%= request.getContextPath() %>/pages/evaluador/registro/" 
                   class="link-primary font-semibold ml-1">
                    Registrarse como evaluador
                </a>
            </div>
        </form>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script>
        // Mostrar mensajes de notificación
        const msg = "<%= (msg != null && !msg.isEmpty()) ? msg : "" %>";
        
        if (msg === "cuenta_activada") {
            Swal.fire({
                title: '¡Cuenta Activada!',
                text: 'Su cuenta ha sido activada. Ahora puede iniciar sesión.',
                icon: 'success',
                confirmButtonColor: '#7A1737'
            });
        } else if (msg === "registro_exitoso") {
            Swal.fire({
                title: '¡Registro Exitoso!',
                text: 'Revise su correo electrónico para activar su cuenta.',
                icon: 'info',
                confirmButtonColor: '#7A1737'
            });
        }

        // Toggle password visibility
        document.getElementById('togglePassword').addEventListener('click', function() {
            const password = document.getElementById('password');
            const icon = this.querySelector('i');
            if (password.type === 'password') {
                password.type = 'text';
                icon.classList.replace('fa-eye', 'fa-eye-slash');
            } else {
                password.type = 'password';
                icon.classList.replace('fa-eye-slash', 'fa-eye');
            }
        });

        // reCAPTCHA callbacks
        let captchaVerified = false;
        
        window.onCaptchaSuccess = function(response) {
            captchaVerified = true;
            const btn = document.getElementById('submitBtn');
            btn.disabled = false;
            btn.innerHTML = '<i class="fas fa-sign-in-alt mr-2"></i> Iniciar Sesión';
        };

        // Form submit
        document.getElementById('loginForm').addEventListener('submit', function(e) {
            if (!captchaVerified) {
                e.preventDefault();
                Swal.fire({
                    title: 'Verificación requerida',
                    text: 'Por favor complete el reCAPTCHA',
                    icon: 'warning',
                    confirmButtonColor: '#7A1737'
                });
            }
        });
    </script>
</body>
</html>
