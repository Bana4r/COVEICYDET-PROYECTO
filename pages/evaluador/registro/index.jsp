<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    request.setCharacterEncoding("UTF-8");

    // Obtener mensajes de error o éxito de la sesión O de la URL
    String mensajeError = request.getParameter("error");
    String mensajeExito = request.getParameter("registrado");
    
    // Si viene por sesión, también usarlo (compatibilidad)
    if (mensajeError == null) {
        mensajeError = (String) session.getAttribute("registro_evaluador_error");
        if (mensajeError != null) session.removeAttribute("registro_evaluador_error");
    }
    if (mensajeExito == null) {
        mensajeExito = (String) session.getAttribute("registro_evaluador_msg");
        if (mensajeExito != null) session.removeAttribute("registro_evaluador_msg");
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>COVEICYDET - Alta de Evaluador</title>
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
                        'slide-up': 'slideUp 0.3s ease-out',
                        'shake': 'shake 0.5s ease-in-out'
                    },
                    keyframes: {
                        fadeIn: {
                            '0%': { opacity: '0' },
                            '100%': { opacity: '1' }
                        },
                        slideUp: {
                            '0%': { transform: 'translateY(20px)', opacity: '0' },
                            '100%': { transform: 'translateY(0)', opacity: '1' }
                        },
                        shake: {
                            '0%, 100%': { transform: 'translateX(0)' },
                            '10%, 30%, 50%, 70%, 90%': { transform: 'translateX(-5px)' },
                            '20%, 40%, 60%, 80%': { transform: 'translateX(5px)' }
                        }
                    }
                }
            }
        }
    </script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">

    <!-- Google reCAPTCHA API -->
    <script src="https://www.google.com/recaptcha/api.js?hl=es" async defer></script>

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

        .gradient-text {
            background: linear-gradient(135deg, #7A1737 0%, #B28854 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .password-strength {
            height: 4px;
            border-radius: 2px;
            margin-top: 0.5rem;
            transition: all 0.3s ease;
        }

        .password-strength.weak { background-color: #ef4444; width: 33.33%; }
        .password-strength.medium { background-color: #f59e0b; width: 66.66%; }
        .password-strength.strong { background-color: #10b981; width: 100%; }

        .input-field {
            border: 1px solid #e5e7eb;
            border-radius: 14px;
            padding: 0.9rem 1rem 0.9rem 3rem;
            width: 100%;
            transition: all 0.3s;
            font-size: 1rem;
            background-color: white;
        }

        .input-field:focus {
            border-color: #B28854;
            box-shadow: 0 0 0 4px rgba(178, 136, 84, 0.15);
            outline: none;
        }

        .input-field.input-error {
            border-color: #ef4444;
            animation: shake 0.5s ease-in-out;
        }

        .input-icon {
            position: absolute;
            left: 1rem;
            top: 50%;
            transform: translateY(-50%);
            color: #B28854;
            font-size: 1.2rem;
            z-index: 10;
        }

        .error-message {
            color: #ef4444;
            font-size: 0.875rem;
            margin-top: 0.25rem;
            display: none;
            align-items: center;
            gap: 0.25rem;
        }

        .error-message.show {
            display: flex;
        }

        .captcha-container {
            background: linear-gradient(145deg, #f8f4ee, #f0e8dd);
            border: 2px solid #e5d5c0;
            border-radius: 20px;
            padding: 1.5rem;
            transition: all 0.3s;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100px;
            margin-bottom: 0;
        }

        .captcha-container:hover {
            border-color: #B28854;
            box-shadow: 0 8px 25px rgba(178, 136, 84, 0.15);
        }

        .g-recaptcha {
            transform: scale(1);
            transform-origin: center;
            margin: 0 auto;
        }

        @media (max-width: 480px) {
            .g-recaptcha {
                transform: scale(0.9);
            }
        }

        .btn-primary {
            background: linear-gradient(145deg, #7A1737, #A8253C);
            color: white;
            padding: 0.9rem 2rem;
            border-radius: 14px;
            font-weight: 600;
            font-size: 1.1rem;
            transition: all 0.3s;
            border: none;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 0.75rem;
            box-shadow: 0 4px 15px rgba(122, 23, 55, 0.2);
        }

        .btn-primary:hover:not(:disabled) {
            background: linear-gradient(145deg, #A8253C, #7A1737);
            transform: translateY(-3px);
            box-shadow: 0 8px 25px rgba(122, 23, 55, 0.3);
        }

        .btn-primary:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }

        .btn-secondary {
            background: white;
            color: #4b5563;
            padding: 0.9rem 2rem;
            border-radius: 14px;
            font-weight: 600;
            font-size: 1.1rem;
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
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.08);
        }

        .checkbox-custom {
            width: 1.3rem;
            height: 1.3rem;
            border: 2px solid #d1d5db;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.2s;
            appearance: none;
            -webkit-appearance: none;
        }

        .checkbox-custom:checked {
            background-color: #B28854;
            border-color: #B28854;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='white'%3E%3Cpath d='M20 6L9 17l-5-5' stroke='white' stroke-width='3' fill='none' stroke-linecap='round' stroke-linejoin='round'/%3E%3C/svg%3E");
            background-size: 1rem;
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
            cursor: pointer;
        }

        .link-aviso:hover {
            color: #B28854;
            text-decoration-color: #7A1737;
        }

        .decorative-line {
            height: 2px;
            background: linear-gradient(90deg, transparent, #B28854, #7A1737, #B28854, transparent);
            width: 100%;
            margin: 1rem 0;
        }

        .simple-divider {
            height: 1px;
            background: linear-gradient(90deg, transparent, #e5d5c0, transparent);
            width: 100%;
            margin: 1.5rem 0;
        }
    </style>
</head>
<body class="bg-gradient-to-br from-[#fcf9f5] via-white to-[#faf5ee] min-h-screen font-sans text-gray-800">

    <!-- Header -->
    <header class="gradient-bg text-white shadow-lg">
        <div class="container mx-auto px-6 py-5">
            <div class="flex items-center justify-between">
                <div class="flex items-center space-x-4">
                    <div class="bg-white/20 p-3 rounded-xl">
                        <i class="fas fa-user-plus text-2xl"></i>
                    </div>
                    <div>
                        <h1 class="text-2xl font-bold tracking-tight">Alta de Nuevo Evaluador</h1>
                        <p class="text-white/90 text-sm">COVEICYDET • Sistema de Evaluación de Proyectos</p>
                    </div>
                </div>

                <div class="flex items-center space-x-3">
                    <a href="../login/login.jsp"
                       class="bg-white/20 hover:bg-white/30 px-5 py-2.5 rounded-xl font-medium transition-all flex items-center gap-2 backdrop-blur-sm">
                        <i class="fas fa-arrow-left"></i>
                        Volver
                    </a>
                </div>
            </div>
        </div>

        <!-- Barra decorativa dorada -->
        <div class="h-1 w-full bg-gradient-to-r from-[#B28854] via-[#d4a574] to-[#B28854]"></div>
    </header>

    <!-- Main Content -->
    <main class="container mx-auto px-6 py-8 max-w-3xl">
        <!-- Título de sección -->
        <div class="text-center mb-8 animate-slide-up">
            <h2 class="text-3xl font-bold gradient-text mb-3">Crear Cuenta de Evaluador</h2>
            <p class="text-gray-600 text-lg">Complete los siguientes datos para registrar un nuevo evaluador</p>
            <div class="decorative-line"></div>
        </div>

        <!-- Formulario -->
        <form id="formAltaEvaluador" class="space-y-6" action="<%= request.getContextPath() %>/pages/evaluador/registro/procesar_registro.jsp" method="POST">
            <div class="glass-card rounded-2xl p-8 shadow-card">

                <!-- Sección: Información de acceso -->
                <div class="space-y-6">
                    <div class="flex items-center gap-3 mb-2">
                        <div class="w-1 h-8 bg-gradient-to-b from-primary to-secondary rounded-full"></div>
                        <h3 class="text-xl font-bold text-gray-800">Información de acceso</h3>
                    </div>

                    <!-- Email -->
                    <div class="relative">
                        <label class="block text-sm font-semibold text-gray-700 mb-2">
                            <i class="fas fa-envelope text-secondary mr-1"></i>
                            Correo Electrónico
                            <span class="text-red-500">*</span>
                        </label>
                        <div class="relative">
                            <i class="fas fa-envelope input-icon"></i>
                            <input type="email"
                                   name="email"
                                   id="email"
                                   class="input-field"
                                   placeholder="ejemplo@correo.com"
                                   required>
                        </div>
                        <div class="error-message" id="emailError">
                            <i class="fas fa-exclamation-circle"></i>
                            <span></span>
                        </div>
                    </div>

                    <!-- Confirmar Email -->
                    <div class="relative">
                        <label class="block text-sm font-semibold text-gray-700 mb-2">
                            <i class="fas fa-envelope text-secondary mr-1"></i>
                            Confirmar Correo Electrónico
                            <span class="text-red-500">*</span>
                        </label>
                        <div class="relative">
                            <i class="fas fa-envelope input-icon"></i>
                            <input type="email"
                                   name="confirmEmail"
                                   id="confirmEmail"
                                   class="input-field"
                                   placeholder="Confirme su correo electrónico"
                                   required>
                        </div>
                        <div class="error-message" id="confirmEmailError">
                            <i class="fas fa-exclamation-circle"></i>
                            <span></span>
                        </div>
                    </div>

                    <!-- Contraseña -->
                    <div class="relative">
                        <label class="block text-sm font-semibold text-gray-700 mb-2">
                            <i class="fas fa-lock text-secondary mr-1"></i>
                            Contraseña
                            <span class="text-red-500">*</span>
                        </label>
                        <div class="relative">
                            <i class="fas fa-lock input-icon"></i>
                            <input type="password"
                                   name="password"
                                   id="password"
                                   class="input-field pr-12"
                                   placeholder="Cree una contraseña"
                                   required>
                            <button type="button"
                                    class="absolute right-4 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-secondary transition-colors"
                                    onclick="togglePassword('password', this)">
                                <i class="fas fa-eye text-lg"></i>
                            </button>
                        </div>
                        <div class="password-strength" id="passwordStrength"></div>
                    </div>

                    <!-- Confirmar Contraseña -->
                    <div class="relative">
                        <label class="block text-sm font-semibold text-gray-700 mb-2">
                            <i class="fas fa-lock text-secondary mr-1"></i>
                            Confirmar Contraseña
                            <span class="text-red-500">*</span>
                        </label>
                        <div class="relative">
                            <i class="fas fa-lock input-icon"></i>
                            <input type="password"
                                   name="confirmPassword"
                                   id="confirmPassword"
                                   class="input-field pr-12"
                                   placeholder="Confirme su contraseña"
                                   required>
                            <button type="button"
                                    class="absolute right-4 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-secondary transition-colors"
                                    onclick="togglePassword('confirmPassword', this)">
                                <i class="fas fa-eye text-lg"></i>
                            </button>
                        </div>
                        <div class="error-message" id="confirmPasswordError">
                            <i class="fas fa-exclamation-circle"></i>
                            <span></span>
                        </div>
                    </div>
                </div>

                <!-- Divisor simple -->
                <div class="simple-divider"></div>

                <!-- Google reCAPTCHA v2 - Solo el widget -->
                <div>
                    <div class="captcha-container">
                        <div class="g-recaptcha" 
                             data-sitekey="6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI"
                             data-callback="recaptchaCallback"></div>
                    </div>

                    <div class="error-message" id="recaptchaError">
                        <i class="fas fa-exclamation-circle"></i>
                        <span>Debe completar la verificación de seguridad</span>
                    </div>
                </div>

                <!-- Divisor simple -->
                <div class="simple-divider"></div>

                <!-- Aviso de Privacidad -->
                <div class="bg-gradient-to-r from-primary/5 to-secondary/5 rounded-2xl p-6 border border-secondary/20">
                    <div class="flex items-center justify-between mb-4 pb-4 border-b border-secondary/20">
                        <div class="flex items-center gap-3">
                            <div class="w-12 h-12 bg-white rounded-xl flex items-center justify-center shadow-soft">
                                <i class="fas fa-file-pdf text-2xl text-secondary"></i>
                            </div>
                            <div>
                                <h4 class="font-bold text-gray-800">Aviso de Privacidad</h4>
                                <p class="text-xs text-gray-500">Documento oficial COVEICYDET</p>
                            </div>
                        </div>
                        <a href="#" onclick="descargarAvisoPrivacidad(event)"
                           class="link-aviso flex items-center gap-2 px-4 py-2 bg-white rounded-xl shadow-soft hover:shadow-gold transition-all">
                            <i class="fas fa-download"></i>
                            Descargar PDF
                        </a>
                    </div>

                    <div class="flex items-start gap-4">
                        <div class="pt-1">
                            <input type="checkbox" name="aceptoTerminos" id="aceptoTerminos" class="checkbox-custom">
                        </div>
                        <div class="flex-1">
                            <label for="aceptoTerminos" class="text-gray-700 font-medium cursor-pointer">
                                Declaro que he leído y acepto el
                                <a href="#" onclick="descargarAvisoPrivacidad(event)" class="link-aviso font-semibold">Aviso de Privacidad</a>.
                            </label>
                        </div>
                    </div>
                </div>

                <!-- Botones Navegación -->
                <div class="flex justify-between gap-4 mt-8 pt-6 border-t border-gray-200">
                    <a href="../login/login.jsp"
                       class="btn-secondary">
                        <i class="fas fa-times"></i>
                        Cancelar
                    </a>
                    <button type="submit"
                            class="btn-primary" id="btnRegistrar">
                        <i class="fas fa-user-plus"></i>
                        Crear Evaluador
                    </button>
                </div>
            </div>
        </form>
    </main>

    <div id="toastContainer" class="fixed bottom-6 right-6 z-40 space-y-3"></div>

    <% if (mensajeError != null && !mensajeError.isEmpty()) { %>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            mostrarToast('<%= mensajeError.replace("'", "\\'").replace("\n", " ") %>', 'error');
        });
    </script>
    <% } %>

    <% if ("1".equals(mensajeExito)) { %>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            mostrarToast('Evaluador registrado exitosamente', 'success');
            document.getElementById('formAltaEvaluador').reset();
        });
    </script>
    <% } %>

    <script>
        let recaptchaWidgetId = null;

        function togglePassword(fieldId, button) {
            const input = document.getElementById(fieldId);
            const icon = button.querySelector('i');

            if (input.type === 'password') {
                input.type = 'text';
                icon.classList.remove('fa-eye');
                icon.classList.add('fa-eye-slash');
            } else {
                input.type = 'password';
                icon.classList.remove('fa-eye-slash');
                icon.classList.add('fa-eye');
            }
        }

        function validateEmail(email) {
            const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            return re.test(email);
        }

        function showError(fieldId, message) {
            const errorElement = document.getElementById(`${fieldId}Error`);
            const inputElement = document.getElementById(fieldId);

            if (errorElement && inputElement) {
                errorElement.querySelector('span').textContent = message;
                errorElement.classList.add('show');
                inputElement.classList.add('input-error');
            }
        }

        function hideError(fieldId) {
            const errorElement = document.getElementById(`${fieldId}Error`);
            const inputElement = document.getElementById(fieldId);

            if (errorElement && inputElement) {
                errorElement.classList.remove('show');
                inputElement.classList.remove('input-error');
            }
        }

        function recaptchaCallback(response) {
            recaptchaWidgetId = response;
            hideError('recaptcha');
        }

        function validarRecaptcha() {
            // Verificar si grecaptcha está disponible
            if (typeof grecaptcha === 'undefined') {
                showError('recaptcha', 'Error al cargar el captcha. Recargue la página.');
                return false;
            }
            
            const response = grecaptcha.getResponse();

            if (!response || response.length === 0) {
                showError('recaptcha', 'Debe completar la verificación de seguridad');
                return false;
            } else {
                hideError('recaptcha');
                return true;
            }
        }

        function setupPasswordValidation() {
            const passwordInput = document.getElementById('password');

            passwordInput.addEventListener('input', function() {
                const password = this.value;
                const strengthBar = document.getElementById('passwordStrength');

                strengthBar.classList.remove('weak', 'medium', 'strong');

                if (password.length === 0) {
                    strengthBar.style.width = '0';
                } else if (password.length < 6) {
                    strengthBar.classList.add('weak');
                } else if (password.length < 8) {
                    strengthBar.classList.add('medium');
                } else {
                    strengthBar.classList.add('strong');
                }
            });
        }

        function validarContrasena(password) {
            return password.length >= 6;
        }

        function descargarAvisoPrivacidad(event) {
            event.preventDefault();
            mostrarToast('Iniciando descarga del Aviso de Privacidad...', 'info');

            setTimeout(() => {
                mostrarToast('Aviso de Privacidad descargado', 'success');
            }, 1500);
        }

        function mostrarToast(mensaje, tipo = 'info') {
            const container = document.getElementById('toastContainer');
            const toast = document.createElement('div');

            const config = {
                success: { bg: 'bg-gradient-to-r from-[#B28854] to-[#d4a574]', icon: 'check-circle' },
                error: { bg: 'bg-gradient-to-r from-red-500 to-red-600', icon: 'exclamation-circle' },
                info: { bg: 'bg-gradient-to-r from-blue-500 to-blue-600', icon: 'info-circle' },
                warning: { bg: 'bg-gradient-to-r from-yellow-500 to-yellow-600', icon: 'exclamation-triangle' }
            };

            toast.className = `${config[tipo].bg} text-white px-6 py-4 rounded-xl shadow-floating flex items-center animate-slide-up`;
            toast.innerHTML = `
                <i class="fas fa-${config[tipo].icon} mr-3 text-lg"></i>
                <span class="font-medium">${mensaje}</span>
                <button onclick="this.parentElement.remove()" class="ml-4 hover:opacity-80">
                    <i class="fas fa-times"></i>
                </button>
            `;

            container.appendChild(toast);

            setTimeout(() => {
                if (toast.parentElement) {
                    toast.remove();
                }
            }, 5000);
        }

        function validarFormulario() {
            let isValid = true;

            const email = document.getElementById('email').value;
            const confirmEmail = document.getElementById('confirmEmail').value;

            if (!validateEmail(email)) {
                showError('email', 'Ingrese un correo electrónico válido');
                isValid = false;
            } else {
                hideError('email');
            }

            if (email !== confirmEmail) {
                showError('confirmEmail', 'Los correos electrónicos no coinciden');
                isValid = false;
            } else {
                hideError('confirmEmail');
            }

            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirmPassword').value;

            if (!validarContrasena(password)) {
                showError('password', 'La contraseña debe tener al menos 6 caracteres');
                isValid = false;
            } else {
                hideError('password');
            }

            if (password !== confirmPassword) {
                showError('confirmPassword', 'Las contraseñas no coinciden');
                isValid = false;
            } else {
                hideError('confirmPassword');
            }

            if (!validarRecaptcha()) {
                isValid = false;
            }

            if (!document.getElementById('aceptoTerminos').checked) {
                mostrarToast('Debe aceptar el Aviso de Privacidad', 'warning');
                isValid = false;
            }

            return isValid;
        }

        document.addEventListener('DOMContentLoaded', function() {
            setupPasswordValidation();

            document.getElementById('formAltaEvaluador').addEventListener('submit', function(e) {
                e.preventDefault(); // Siempre prevenir primero
                
                if (validarFormulario()) {
                    // Si la validación pasa, enviar el formulario
                    this.submit();
                } else {
                    mostrarToast('Por favor, corrija los errores en el formulario', 'error');
                }
            });
        });
    </script>
</body>
</html>
