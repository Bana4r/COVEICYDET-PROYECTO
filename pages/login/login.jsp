<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String rolActual = (String) session.getAttribute("rol");
    Boolean autenticado = (Boolean) session.getAttribute("autenticado");

    // LÓGICA DE AUTO-LOGIN POR COOKIE
    if ((autenticado == null || !autenticado)) {
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

        if (tokenEncontrado != null) {
            // Validar Token contra la BD
            try {
                Class.forName("org.postgresql.Driver");
                Connection conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/proyectos", "dbusr25", "mxToro24000Chocolate");
                
                String sql = "SELECT u.id_usuario, u.nombre, u.primer_apellido, u.segundo_apellido, u.estado, t.tipo_usuario " +
                             "FROM usuarios u JOIN tipo_usuario t ON u.tipousuario = t.id_tipo_usuario " +
                             "WHERE u.token_sesion = ?";
                
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, tokenEncontrado);
                ResultSet rs = ps.executeQuery();
                
                if (rs.next()) {
                    int estadoUsuario = rs.getInt("estado");

                    if (estadoUsuario == 2) {
                
                        session.setAttribute("autenticado", true);
                        session.setAttribute("id_usuario", rs.getInt("id_usuario"));
                        session.setAttribute("nombre", rs.getString("nombre") + " " + rs.getString("primer_apellido") + " " + rs.getString("segundo_apellido"));
                        session.setAttribute("rol", rs.getString("tipo_usuario"));
                    
                        // Actualizamos las variables locales para que el siguiente bloque if redirija
                        autenticado = true;
                        rolActual = rs.getString("tipo_usuario");
                    }else{
                        Cookie killCookie = new Cookie("auth_token", "");
                        killCookie.setMaxAge(0);
                        killCookie.setPath("/");
                        response.addCookie(killCookie);
                    }
                }
                conn.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    // REDIRECCIÓN SI YA ESTÁ AUTENTICADO
    if (autenticado != null && autenticado && rolActual != null) {
        String redirectUrl = "";
        switch (rolActual) {
            case "responsable": redirectUrl = request.getContextPath() + "/pages/responsableDeproyecto/paginaPrincipal/main.jsp"; break;
            case "analista": redirectUrl = request.getContextPath() + "/pages/analista/paginaPrincipal/main.jsp"; break;
            case "evaluador": redirectUrl = request.getContextPath() + "/pages/evaluador/main.jsp"; break;
            default: redirectUrl = request.getContextPath() + "/index.jsp"; break;
        }
        response.sendRedirect(redirectUrl);
        return;
    }

    String errorLogin = (String) session.getAttribute("error_login");
    if (errorLogin != null) {
        session.removeAttribute("error_login");
    }
    
    String nextUrl = request.getParameter("next");

    String msg = request.getParameter("msg");
    
    String rememberedEmail = "";
    boolean hasRememberedEmail = false;
    Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (Cookie cookie : cookies) {
            if (cookie.getName().equals("remembered_email")) {
                rememberedEmail = cookie.getValue();
                hasRememberedEmail = !rememberedEmail.isEmpty();
                break;
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>COVEICYDET - Iniciar Sesión</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- reCAPTCHA v2 -->
    <script src="https://www.google.com/recaptcha/api.js" async defer></script>
    <style>
        body {
            background: linear-gradient(135deg, #f8f9fa 0%, #f1f3f4 100%) !important;
            min-height: 100vh;
        }
        
        /* CONTENEDOR MÁS ANCHO - MODIFICADO */
        .login-container {
            box-shadow: 0 15px 35px rgba(122, 23, 55, 0.1), 0 5px 15px rgba(0, 0, 0, 0.07);
            border-radius: 16px;
            overflow: hidden;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            width: 100%;
            max-width: 550px; /* Aumentado de 480px a 550px */
        }
        
        .login-container:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 40px rgba(122, 23, 55, 0.15), 0 8px 20px rgba(0, 0, 0, 0.1);
        }
        
        /* CAMPOS DE FORMULARIO MÁS ANCHOS */
        .floating-label {
            position: relative;
            margin-bottom: 1.5rem;
        }
        
        .floating-input {
            border: 1.5px solid #e2e8f0;
            border-radius: 10px;
            padding: 1.1rem 0.85rem 0.6rem;
            width: 100%;
            transition: all 0.3s;
            font-size: 1rem;
            background-color: #ffffff;
        }
        
        .floating-input:focus {
            outline: none;
            border-color: #A8253C;
            box-shadow: 0 0 0 3px rgba(168, 37, 60, 0.15);
            background-color: #fff;
        }
        
        .floating-label-text {
            position: absolute;
            top: 1.1rem;
            left: 0.85rem;
            color: #64748b;
            transition: all 0.2s;
            pointer-events: none;
            font-size: 1rem;
            background-color: transparent;
            padding: 0 0.25rem;
        }
        
        .floating-input:focus ~ .floating-label-text,
        .floating-input:not(:placeholder-shown) ~ .floating-label-text {
            top: 0.4rem;
            left: 0.85rem;
            font-size: 0.8rem;
            font-weight: 600;
            color: #A8253C;
            background-color: #ffffff;
            z-index: 5;
        }
        
        .form-icon {
            position: absolute;
            right: 14px;
            top: 50%;
            transform: translateY(-50%);
            color: #94a3b8;
            pointer-events: none;
        }
        
        .floating-input:focus + .form-icon {
            color: #A8253C;
        }
        
        /* CAPTCHA MÁS ANCHO */
        .captcha-wrapper {
            margin: 1.5rem 0 1.5rem 0;
            display: flex;
            justify-content: center;
        }
        
        .g-recaptcha {
            transform: scale(1.05); /* Ligeramente más grande */
            transform-origin: center;
        }
        
        @media (max-width: 768px) {
            .g-recaptcha {
                transform: scale(0.95);
            }
        }
        
        /* Animación para advertencia */
        @keyframes pulseWarning {
            0% { box-shadow: 0 0 0 0 rgba(239, 68, 68, 0.7); }
            70% { box-shadow: 0 0 0 10px rgba(239, 68, 68, 0); }
            100% { box-shadow: 0 0 0 0 rgba(239, 68, 68, 0); }
        }
        
        .captcha-error {
            animation: pulseWarning 2s infinite;
        }
        
        /* Botón de submit más ancho */
        .submit-btn {
            background: linear-gradient(90deg, #7A1737 0%, #A8253C 100%);
            position: relative;
            overflow: hidden;
            transition: all 0.4s;
            font-weight: 600;
            letter-spacing: 0.5px;
            padding: 1rem 2rem;
        }
        
        .submit-btn:hover:not(:disabled) {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(122, 23, 55, 0.3);
        }
        
        .submit-btn:active:not(:disabled) {
            transform: translateY(0);
        }
        
        .submit-btn:disabled {
            background: linear-gradient(90deg, #9ca3af 0%, #6b7280 100%);
            cursor: not-allowed;
            transform: none;
        }
        
        .submit-btn:disabled:hover {
            transform: none;
            box-shadow: none;
        }
        
        .submit-btn::after {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            transition: left 0.7s;
        }
        
        .submit-btn:hover:not(:disabled)::after {
            left: 100%;
        }
        
        /* Header más ancho */
        .header-decoration {
            background: linear-gradient(90deg, #7A1737 0%, #A8253C 100%);
            position: relative;
            overflow: hidden;
            padding: 1.75rem 2rem;
        }
        
        .header-decoration::after {
            content: '';
            position: absolute;
            top: 0;
            right: 0;
            width: 100px;
            height: 100%;
            background: linear-gradient(90deg, transparent 0%, #B28854 100%);
            opacity: 0.7;
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
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
            transition: all 0.2s;
        }
        
        .password-toggle:hover {
            color: #A8253C;
            background-color: rgba(168, 37, 60, 0.05);
        }
        
        /* Mensaje de error */
        .captcha-error-message {
            font-size: 0.9rem; /* Un poco más grande */
            color: #ef4444;
            text-align: center;
            margin-top: 0.5rem;
            display: none;
            padding: 0 1rem;
        }
        
        .captcha-error-message.show {
            display: block;
        }
        
        /* Contenedor principal más ancho */
        .main-container {
            width: 100%;
            max-width: 1200px;
            margin: 0 auto;
        }
        
        /* Ajuste de padding para formulario más ancho */
        .form-padding {
            padding: 2.5rem 2.5rem; /* Más padding horizontal */
        }
        
        /* Opciones con más espacio */
        .form-options {
            padding: 0 0.5rem;
        }
    </style>
</head>
<body class="min-h-screen antialiased font-sans flex flex-col">

    <%@ include file="/../header.jsp" %>

    <!-- Contenedor principal MÁS ANCHO -->
    <div class="flex-1 flex items-center justify-center px-4 py-8">
        <div class="w-full max-w-2xl flex justify-center"> <!-- Contenedor más ancho -->
            <!-- Tarjeta de login MÁS ANCHA -->
            <div class="login-container bg-white relative">
                <!-- Encabezado decorativo -->
                <div class="header-decoration p-5 flex items-center justify-between">
                    <div class="flex items-center space-x-3">
                        <div class="bg-white/20 p-2 rounded-lg">
                            <i class="fas fa-sign-in-alt text-white text-xl"></i>
                        </div>
                        <div>
                            <h1 class="text-white text-2xl font-bold">Iniciar Sesión</h1>
                            <p class="text-white/90 text-sm">Accede a tu cuenta COVEICYDET</p>
                        </div>
                    </div>
                    <div class="hidden md:block">
                        <div class="bg-white/20 p-2 rounded-lg">
                            <i class="fas fa-shield-alt text-white text-xl"></i>
                        </div>
                    </div>
                </div>

                <!-- Mostrar mensaje de error si existe -->
                <% if (errorLogin != null && !errorLogin.isEmpty()) { %>
                    <div class="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 m-4" role="alert">
                        <p class="font-medium">Error:</p>
                        <p><%= errorLogin %></p>
                    </div>
                <% } %>

                <!-- Formulario con más padding -->
                <form class="bg-white form-padding" action="procesar_login.jsp" method="post" id="loginForm">
                    <!-- Campo oculto para mantener la URL de redirección -->
                    <% if (nextUrl != null && !nextUrl.isEmpty()) { %>
                        <input type="hidden" name="next" value="<%= nextUrl %>">
                    <% } %>

                    <!-- Campo Email -->
                    <div class="floating-label">
                        <input type="email" id="email" name="email" required placeholder=" "
                            class="floating-input" value="<%= rememberedEmail %>" autocomplete="email">
                        <label for="email" class="floating-label-text">Correo Electrónico</label>
                        <i class="fas fa-envelope form-icon"></i>
                    </div>

                    <!-- Campo Password -->
                    <div class="floating-label">
                        <div class="password-field-wrapper">
                            <input type="password" id="password" name="password" required placeholder=" "
                                class="floating-input pr-12" autocomplete="current-password">
                            <label for="password" class="floating-label-text">Contraseña</label>
                            <button type="button" class="password-toggle" id="togglePassword">
                                <i class="fas fa-eye"></i>
                            </button>
                        </div>
                    </div>

                    <!-- Opciones adicionales -->
                    <div class="flex items-center justify-between text-sm mb-6 form-options">
                        <div class="flex items-center">
                            <input type="checkbox" id="remember-me" name="remember-me" class="w-4 h-4 text-[#A8253C] border-gray-300 rounded focus:ring-[#A8253C]">
                            <label for="remember-me" class="ml-2 block text-gray-700">Recordar inicio de sesión</label>
                        </div>

                        <div>
                            <a href="/proyectos/pages/recuperarContrasena/formulario.jsp" class="font-medium text-[#A8253C] hover:text-[#7A1737] transition">¿Olvidaste tu contraseña?</a>
                        </div>
                    </div>

                    <!-- Descarga el manual de usuario -->
                    <div class="text-center mb-4">
                        <a href="/proyectos/pages/login/Manual_de_Usuario_COVEICYDET.pdf" target="_blank" 
                           class="text-sm text-[#A8253C] hover:text-[#7A1737] font-medium">
                            <i class="fas fa-book mr-1"></i> Descargar Manual de Usuario
                        </a>
                    </div>
                    
                    <!-- CAPTCHA MÁS ANCHO -->
                    <div class="captcha-wrapper">
                        <div class="g-recaptcha" 
                             data-sitekey="6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI" 
                             data-callback="onCaptchaSuccess"
                             data-expired-callback="onCaptchaExpired"
                             data-error-callback="onCaptchaError">
                        </div>
                    </div>
                    
                    <!-- Mensaje de error simple -->
                    <div class="captcha-error-message" id="captchaError">
                        <i class="fas fa-exclamation-circle mr-1"></i> Marca la casilla "No soy un robot" para continuar
                    </div>

                    <!-- Botón de submit -->
                    <div class="mt-4 pt-3">
                        <button type="submit"
                                class="w-full py-3.5 px-4 rounded-xl shadow-lg text-base font-bold text-white 
                                       submit-btn focus:outline-none focus:ring-4 focus:ring-[#A8253C]/30"
                                id="submitBtn" disabled>
                            <i class="fas fa-lock mr-2"></i> Verifica la seguridad para iniciar sesión
                        </button>
                        <p class="text-xs text-gray-500 text-center mt-2" id="captchaRequiredText">
                            <i class="fas fa-shield-alt mr-1"></i>Debes marcar la casilla <strong>"No soy un robot"</strong> para habilitar el inicio de sesión
                        </p>
                    </div>
                    
                    <!-- Enlace de registro -->
                    <div class="text-center text-sm text-slate-600 pt-6 pb-2 border-t border-slate-100 mt-6">
                        ¿No tienes una cuenta? 
                        <a href="/proyectos/pages/registro/" class="font-semibold text-[#A8253C] hover:text-[#7A1737] ml-1">
                            <i class="fas fa-user-plus mr-1"></i>Registrarse
                        </a>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <!-- Footer al final -->
    <%@ include file="/footer.jsp" %>

    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <script>
    // Obtenemos el valor de la variable de Java 'msg' y la pasamos a JavaScript de forma segura
    const mensajeParam = "<%= (msg != null) ? msg : "" %>";
    // CASO 1: Registro correcto
    if (mensajeParam === "registro_ok") {
        Swal.fire({
            title: '¡Registro Realizado!',
            text: 'Su registro se ha realizado. Para proceder al ingreso favor de consultar su correo y validar su registro. Si el correo no aparece favor de revisar la bandeja de spam.',
            icon: 'success',
            confirmButtonText: 'Entendido',
            confirmButtonColor: '#A8253C', 
            background: '#fff',
            backdrop: `rgba(0,0,123,0.4)`
        });
    } 
    // CASO 2: Cuenta activada exitosamente
    else if (mensajeParam === "cuenta_activada") {
        Swal.fire({
            title: '¡Cuenta Activada!',
            text: 'Su cuenta ha sido activada, ya puede proceder a ingresar a la plataforma.',
            icon: 'success',
            confirmButtonText: 'Ingresar',
            confirmButtonColor: '#A8253C',
            background: '#fff',
            backdrop: `rgba(0,0,123,0.4)`
        });
    }
    // CASO 3: Token inválido (Opcional, pero recomendado por si el link caducó)
    else if (mensajeParam === "token_invalido") {
         Swal.fire({
            title: 'Enlace no válido',
            text: 'El enlace de activación es inválido o ya ha sido utilizado.',
            icon: 'error',
            confirmButtonText: 'Cerrar',
            confirmButtonColor: '#A8253C'
        });
    }

    // CASO 4: Solicitud de recuperación enviada
    else if (mensajeParam === "recuperacion_enviada") {
        Swal.fire({
            title: '¡Solicitud Enviada!',
            text: 'Se ha realizado la solicitud de contraseña. Favor de consultar su bandeja de entrada. En caso de no encontrar el correo, revise la carpeta de Spam o Correo no deseado.',
            icon: 'info',
            confirmButtonText: 'Entendido',
            confirmButtonColor: '#A8253C',
            background: '#fff',
            backdrop: `rgba(0,0,123,0.4)`
        });
    }
    // CASO 5: Contraseña actualizada correctamente
    else if (mensajeParam === "password_actualizado") {
        Swal.fire({
            title: '¡Contraseña Actualizada!',
            text: 'Su contraseña ha sido cambiada exitosamente. Ahora puede iniciar sesión con sus nuevas credenciales.',
            icon: 'success',
            confirmButtonText: 'Iniciar Sesión',
            confirmButtonColor: '#A8253C',
            background: '#fff',
            backdrop: `rgba(0,0,123,0.4)`
        });
    }
    // CASO 6: Error de token al intentar recuperar
    else if (mensajeParam === "token_invalido_pass") {
        Swal.fire({
            title: 'Enlace Expirado o Inválido',
            text: 'El enlace para recuperar contraseña ya fue usado o no es válido. Por favor solicite uno nuevo.',
            icon: 'error',
            confirmButtonText: 'Cerrar',
            confirmButtonColor: '#A8253C'
        });
    }

    //CASO 7 - RFC YA REGISTRADO ---
    else if (mensajeParam === "rfc_registrado") {
        Swal.fire({
            title: '¡RFC ya registrado!',
            text: 'Este RFC ya se encuentra asociado a una cuenta. Por favor inicie sesión o recupere su contraseña si la ha olvidado.',
            icon: 'warning',
            confirmButtonText: 'Entendido',
            confirmButtonColor: '#A8253C',
            background: '#fff',
            backdrop: `rgba(0,0,123,0.4)`
        });
    }

    document.addEventListener('DOMContentLoaded', () => {
        console.log('JS cargado - Login con CAPTCHA simplificado');
        
        // Variables de estado
        let captchaVerified = false;
        let captchaAttempted = false;
        
        // Elementos
        const form = document.getElementById('loginForm');
        const submitBtn = document.getElementById('submitBtn');
        const captchaRequiredText = document.getElementById('captchaRequiredText');
        const captchaError = document.getElementById('captchaError');
        const password = document.getElementById('password');
        const togglePassword = document.getElementById('togglePassword');
        
        // ========== ACTUALIZAR BOTÓN ==========
        function updateSubmitButtonState() {
            let isCaptchaVerified = false;
            
            if (typeof grecaptcha !== 'undefined') {
                const response = grecaptcha.getResponse();
                isCaptchaVerified = response.length > 0;
            }
            
            if (isCaptchaVerified) {
                submitBtn.disabled = false;
                captchaRequiredText.classList.add('hidden');
                captchaError.classList.remove('show');
                submitBtn.innerHTML = '<i class="fas fa-sign-in-alt mr-2"></i> Iniciar Sesión';
                captchaVerified = true;
            } else {
                submitBtn.disabled = true;
                captchaRequiredText.classList.remove('hidden');
                submitBtn.innerHTML = '<i class="fas fa-lock mr-2"></i> Verifica la seguridad para iniciar sesión';
                captchaVerified = false;
                
                if (captchaAttempted) {
                    captchaError.classList.add('show');
                }
            }
        }
        
        // ========== CALLBACKS reCAPTCHA ==========
        window.onCaptchaSuccess = function(response) {
            captchaVerified = true;
            captchaAttempted = false;
            captchaError.classList.remove('show');
            updateSubmitButtonState();
        };
        
        window.onCaptchaExpired = function() {
            captchaVerified = false;
            captchaError.classList.add('show');
            captchaError.innerHTML = '<i class="fas fa-clock mr-1"></i> La verificación ha expirado. Por favor, marca la casilla nuevamente.';
            updateSubmitButtonState();
        };
        
        window.onCaptchaError = function() {
            captchaVerified = false;
            captchaError.classList.add('show');
            captchaError.innerHTML = '<i class="fas fa-exclamation-triangle mr-1"></i> Error en la verificación. Intenta nuevamente.';
            updateSubmitButtonState();
        };
        
        // ========== MOSTRAR/OCULTAR CONTRASEÑA ==========
        togglePassword.addEventListener('click', function() {
            const type = password.getAttribute('type') === 'password' ? 'text' : 'password';
            password.setAttribute('type', type);
            this.querySelector('i').classList.toggle('fa-eye');
            this.querySelector('i').classList.toggle('fa-eye-slash');
        });
        
        // ========== ENVIAR FORMULARIO ==========
        form.addEventListener('submit', function(e) {
            e.preventDefault();
            
            captchaAttempted = true;
            
            if (typeof grecaptcha !== 'undefined') {
                const response = grecaptcha.getResponse();
                if (response.length === 0) {
                    alert('❌ Por favor, marca la casilla "No soy un robot" antes de continuar.');
                    captchaError.classList.add('show');
                    updateSubmitButtonState();
                    return;
                }
            }
            
            // Enviar formulario
            submitBtn.disabled = true;
            submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin mr-2"></i> Verificando...';
            form.submit();
        });
        
        // ========== VERIFICACIÓN PERIÓDICA ==========
        setInterval(updateSubmitButtonState, 1000);
        
        // ========== INICIALIZAR ==========
        updateSubmitButtonState();
        
        if (typeof grecaptcha !== 'undefined') {
            setTimeout(updateSubmitButtonState, 1000);
        }
    });
    </script>
</body>
</html>