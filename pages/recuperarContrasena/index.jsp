<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>COVEICYDET - Recuperar Contraseña</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://www.google.com/recaptcha/api.js" async defer></script>
    <style>
        /* ESTILOS HOMOGÉNEOS (Idénticos a Login/Registro) */
        :root {
            --primary: #7A1737;
            --primary-light: #A8253C;
            --secondary: #B28854;
        }

        body {
            background: linear-gradient(135deg, #f8f9fa 0%, #f1f3f4 100%) !important;
            min-height: 100vh;
        }
        
        .recovery-container {
            box-shadow: 0 15px 35px rgba(122, 23, 55, 0.1), 0 5px 15px rgba(0, 0, 0, 0.07);
            border-radius: 16px;
            overflow: hidden;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            width: 100%;
            max-width: 550px; /* Mismo ancho que el Login */
        }
        
        .recovery-container:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 40px rgba(122, 23, 55, 0.15), 0 8px 20px rgba(0, 0, 0, 0.1);
        }

        /* INPUTS FLOTANTES */
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
            border-color: var(--primary-light);
            box-shadow: 0 0 0 3px rgba(168, 37, 60, 0.15);
        }

        .floating-input.valid { border-color: #10b981; }
        .floating-input.invalid { border-color: #ef4444; }
        
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
            top: -0.75rem;
            left: 0.8rem;
            font-size: 0.85rem;
            font-weight: 600;
            color: var(--primary-light);
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
        
        .floating-input:focus + .form-icon { color: var(--primary-light); }

        /* HEADER DECORATIVO */
        .header-decoration {
            background: linear-gradient(90deg, var(--primary) 0%, var(--primary-light) 100%);
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
            background: linear-gradient(90deg, transparent 0%, var(--secondary) 100%);
            opacity: 0.7;
        }

        /* BOTÓN SUBMIT */
        .submit-btn {
            background: linear-gradient(90deg, var(--primary) 0%, var(--primary-light) 100%);
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
        
        .submit-btn:disabled {
            background: #9ca3af;
            cursor: not-allowed;
            opacity: 0.7;
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
        
        .submit-btn:hover:not(:disabled)::after { left: 100%; }

        /* EXTRAS */
        .captcha-wrapper {
            margin: 1.5rem 0;
            display: flex;
            justify-content: center;
        }
        
        .g-recaptcha { transform: scale(1.05); }
        
        .form-padding { padding: 2.5rem; }
    </style>
</head>
<body class="min-h-screen antialiased font-sans flex flex-col">

    <%@ include file="/../header.jsp" %>

    <div class="flex-1 flex items-center justify-center px-4 py-8">
        <div class="w-full flex justify-center">
            
            <div class="recovery-container bg-white relative">
                
                <div class="header-decoration p-5 flex items-center justify-between">
                    <div class="flex items-center space-x-3">
                        <div class="bg-white/20 p-2 rounded-lg">
                            <i class="fas fa-unlock-alt text-white text-xl"></i>
                        </div>
                        <div>
                            <h1 class="text-white text-2xl font-bold">Recuperar Acceso</h1>
                            <p class="text-white/90 text-sm">Restablece tu contraseña para acceder</p>
                        </div>
                    </div>
                    <div class="hidden md:block">
                        <div class="bg-white/20 p-2 rounded-lg">
                            <i class="fas fa-question-circle text-white text-xl"></i>
                        </div>
                    </div>
                </div>

                <form action="procesar_solicitud_recuperacion.jsp" method="post" id="recoveryForm" class="bg-white form-padding">
                    
                    <p class="text-gray-600 mb-6 text-sm text-center">
                        Ingresa el correo electrónico asociado a tu cuenta. Te enviaremos las instrucciones para restablecer tu contraseña.
                    </p>

                    <div class="floating-label">
                        <input type="email" id="email" name="email" required placeholder=" "
                               class="floating-input" autocomplete="email">
                        <label for="email" class="floating-label-text">Correo electrónico registrado</label>
                        <i class="fas fa-envelope form-icon"></i>
                        <p class="text-xs text-red-500 mt-1 hidden" id="emailError">Ingresa un correo válido</p>
                    </div>

                    <div class="captcha-wrapper">
                        <div class="g-recaptcha" 
                             data-sitekey="6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI"
                             data-callback="onCaptchaSuccess"
                             data-expired-callback="onCaptchaExpired">
                        </div>
                    </div>

                    <div class="mt-2">
                        <button type="submit"
                                class="w-full py-3.5 px-4 rounded-xl shadow-lg text-base font-bold text-white 
                                       submit-btn focus:outline-none focus:ring-4 focus:ring-[#A8253C]/30"
                                id="submitBtn" disabled>
                            <i class="fas fa-paper-plane mr-2"></i> Enviar Instrucciones
                        </button>
                    </div>

                    <div class="text-center text-sm text-slate-600 pt-6 pb-2 border-t border-slate-100 mt-6">
                        <a href="/proyectos/pages/login/login.jsp" class="font-semibold text-slate-500 hover:text-[#A8253C] transition ml-1 flex items-center justify-center gap-2">
                            <i class="fas fa-arrow-left"></i> Volver al Inicio de Sesión
                        </a>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <%@ include file="/../footer.jsp" %>

    <script>
    document.addEventListener('DOMContentLoaded', () => {
        const emailInput = document.getElementById('email');
        const submitBtn = document.getElementById('submitBtn');
        const emailError = document.getElementById('emailError');
        
        let isCaptchaVerified = false;
        let isEmailValid = false;

        // Validación de Email en tiempo real
        const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

        function validateEmail() {
            if (emailPattern.test(emailInput.value)) {
                emailInput.classList.add('valid');
                emailInput.classList.remove('invalid');
                emailError.classList.add('hidden');
                isEmailValid = true;
            } else {
                emailInput.classList.remove('valid');
                if(emailInput.value.length > 0) {
                    emailInput.classList.add('invalid');
                    emailError.classList.remove('hidden');
                } else {
                    emailInput.classList.remove('invalid');
                    emailError.classList.add('hidden');
                }
                isEmailValid = false;
            }
            updateButtonState();
        }

        emailInput.addEventListener('input', validateEmail);
        emailInput.addEventListener('change', validateEmail);

        // Callbacks de Recaptcha
        window.onCaptchaSuccess = function() {
            isCaptchaVerified = true;
            updateButtonState();
        };

        window.onCaptchaExpired = function() {
            isCaptchaVerified = false;
            updateButtonState();
        };

        // Actualizar estado del botón
        function updateButtonState() {
            if (isEmailValid && isCaptchaVerified) {
                submitBtn.disabled = false;
                submitBtn.innerHTML = '<i class="fas fa-paper-plane mr-2"></i> Enviar Instrucciones';
            } else {
                submitBtn.disabled = true;
                if (!isEmailValid && emailInput.value.length > 0) {
                     submitBtn.innerHTML = '<i class="fas fa-exclamation-circle mr-2"></i> Correo Inválido';
                } else if (!isCaptchaVerified) {
                    submitBtn.innerHTML = '<i class="fas fa-lock mr-2"></i> Verifica que no eres un robot';
                } else {
                    submitBtn.innerHTML = '<i class="fas fa-paper-plane mr-2"></i> Enviar Instrucciones';
                }
            }
        }
        
        // Inicializar
        validateEmail();
    });
    </script>
</body>
</html>