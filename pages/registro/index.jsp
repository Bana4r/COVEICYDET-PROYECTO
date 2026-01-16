<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>COVEICYDET - Registro</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- reCAPTCHA v2 -->
    <script src="https://www.google.com/recaptcha/api.js" async defer></script>
    <style>
        :root {
            --primary: #7A1737;
            --primary-light: #A8253C;
            --secondary: #B28854;
            --secondary-light: #d4b683;
            --light-bg: #f8f9fa;
        }
        
        body {
            background: linear-gradient(135deg, #f8f9fa 0%, #f1f3f4 100%) !important;
            min-height: 100vh;
        }
        
        .register-container {
            box-shadow: 0 15px 35px rgba(122, 23, 55, 0.1), 0 5px 15px rgba(0, 0, 0, 0.07);
            border-radius: 16px;
            overflow: hidden;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            width: 100%;
            max-width: 800px; /* MÁS ANCHO - de 650px a 800px */
            margin: 0 auto;
        }
        
        .register-container:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 40px rgba(122, 23, 55, 0.15), 0 8px 20px rgba(0, 0, 0, 0.1);
        }
        
        .floating-label {
            position: relative;
            margin-bottom: 1.75rem;
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
            background-color: #fff;
        }
        
        .floating-input.valid {
            border-color: #10b981;
        }
        
        .floating-input.invalid {
            border-color: #ef4444;
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
        
        .floating-input:focus + .form-icon {
            color: var(--primary-light);
        }
        
        .password-strength {
            height: 6px;
            margin-top: 8px;
            border-radius: 3px;
            transition: all 0.3s ease;
            width: 0%;
        }
        
        .form-section-title {
            position: relative;
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--primary);
            margin-bottom: 1.5rem;
            padding-bottom: 0.5rem;
        }
        
        .form-section-title::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            width: 40px;
            height: 3px;
            background-color: var(--secondary);
            border-radius: 2px;
        }
        
        .input-hint {
            font-size: 0.75rem;
            color: #64748b;
            margin-top: 0.3rem;
            display: block;
        }
        
        .terms-box {
            background-color: #f8fafc;
            border-radius: 10px;
            padding: 1.2rem;
            border: 1.5px solid #e2e8f0;
            transition: all 0.3s;
            margin: 2rem 0 1.5rem 0;
        }
        
        .terms-box:has(input:checked) {
            border-color: var(--primary-light);
            background-color: rgba(168, 37, 60, 0.03);
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
            color: var(--primary-light);
            background-color: rgba(168, 37, 60, 0.05);
        }
        
        .progress-label {
            font-size: 0.8rem;
            margin-top: 4px;
            font-weight: 500;
        }
        
        .header-decoration {
            background: linear-gradient(90deg, var(--primary) 0%, var(--primary-light) 100%);
            position: relative;
            overflow: hidden;
            padding: 1.75rem 2.5rem; /* Más padding horizontal */
        }
        
        .header-decoration::after {
            content: '';
            position: absolute;
            top: 0;
            right: 0;
            width: 120px; /* Más ancho */
            height: 100%;
            background: linear-gradient(90deg, transparent 0%, var(--secondary) 100%);
            opacity: 0.7;
        }
        
        .submit-btn {
            background: linear-gradient(90deg, var(--primary) 0%, var(--primary-light) 100%);
            position: relative;
            overflow: hidden;
            transition: all 0.4s;
            font-weight: 600;
            letter-spacing: 0.5px;
            padding: 1rem 2rem; /* Más padding */
        }
        
        .submit-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(122, 23, 55, 0.3);
        }
        
        .submit-btn:active {
            transform: translateY(0);
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
        
        .submit-btn:hover::after {
            left: 100%;
        }
        
        .form-note {
            font-size: 0.85rem;
            color: #64748b;
            background-color: #f8fafc;
            border-radius: 8px;
            padding: 1rem; /* Más padding */
            border-left: 4px solid var(--secondary);
            margin-top: 1.5rem;
        }
        
        .two-column-layout {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 2.5rem; /* Más espacio entre columnas */
            margin-bottom: 1.5rem;
        }
        
        @media (max-width: 768px) {
            .two-column-layout {
                grid-template-columns: 1fr;
                gap: 1.5rem;
            }
        }
        
        .column-divider {
            position: relative;
        }
        
        .column-divider::after {
            content: '';
            position: absolute;
            right: -1.25rem; /* Más alejado */
            top: 0;
            height: 100%;
            width: 1px;
            background-color: #e2e8f0;
        }
        
        @media (max-width: 768px) {
            .column-divider::after {
                display: none;
            }
        }
        
        .password-info-grid {
            display: grid;
            grid-template-columns: 1fr auto;
            gap: 0.75rem; /* Más espacio */
            margin-top: 0.75rem;
            align-items: center;
        }
        
        .password-field-wrapper {
            position: relative;
        }
        
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            z-index: 1000;
            align-items: center;
            justify-content: center;
        }
        
        .modal-content {
            background-color: white;
            border-radius: 12px;
            width: 90%;
            max-width: 700px;
            max-height: 80vh;
            overflow: hidden;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            animation: modalFadeIn 0.3s ease;
        }
        
        @keyframes modalFadeIn {
            from { opacity: 0; transform: translateY(-20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .modal-header {
            background: linear-gradient(90deg, var(--primary) 0%, var(--primary-light) 100%);
            padding: 1.5rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .modal-body {
            padding: 2rem;
            overflow-y: auto;
            max-height: calc(80vh - 120px);
        }
        
        .privacy-link {
            color: var(--primary-light);
            cursor: pointer;
            font-weight: 600;
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }
        
        .privacy-link:hover {
            color: var(--primary);
            text-decoration: underline;
        }
        
        .modal-close {
            background: rgba(255, 255, 255, 0.2);
            border: none;
            color: white;
            width: 36px;
            height: 36px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.2s;
        }
        
        .modal-close:hover {
            background: rgba(255, 255, 255, 0.3);
        }
        
        .pdf-viewer {
            width: 100%;
            height: 500px;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
        }
        
        .privacy-preview {
            background: #f8fafc;
            border-radius: 8px;
            padding: 1.5rem;
            margin-top: 1rem;
            border: 1px solid #e2e8f0;
        }
        
        .file-upload-container {
            margin-top: 1.5rem;
            padding: 1.5rem; /* Más padding */
            background-color: #f8fafc;
            border-radius: 12px; /* Más redondeado */
            border: 2px dashed #e2e8f0;
            transition: all 0.3s;
        }
        
        .file-upload-container:hover {
            border-color: #A8253C;
            background-color: rgba(168, 37, 60, 0.03);
        }
        
        .file-upload-container.dragover {
            border-color: #10b981;
            background-color: rgba(16, 185, 129, 0.05);
        }
        
        .file-upload-container.file-uploaded {
            border-color: #10b981;
            background-color: rgba(16, 185, 129, 0.05);
            border-width: 2px;
        }
        
        .file-upload-container.file-uploaded:hover {
            border-color: #059669;
            background-color: rgba(16, 185, 129, 0.08);
        }
        
        .file-info {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-top: 1rem; /* Más espacio */
            padding: 1rem; /* Más padding */
            background-color: white;
            border-radius: 10px; /* Más redondeado */
            border: 1px solid #e2e8f0;
        }
        
        /* CAPTCHA SIMPLE - SOLO EL WIDGET */
        .captcha-wrapper {
            margin: 1.5rem 0 1.5rem 0;
            display: flex;
            justify-content: center;
        }
        
        .g-recaptcha {
            transform: scale(1.05); /* Un poco más grande */
            transform-origin: center;
        }
        
        @media (max-width: 768px) {
            .g-recaptcha {
                transform: scale(0.9);
            }
        }
        
        .captcha-error-message {
            font-size: 0.85rem;
            color: #ef4444;
            text-align: center;
            margin-top: 0.75rem; /* Más espacio */
            display: none;
        }
        
        .captcha-error-message.show {
            display: block;
        }
        
        /* Estados de verificación simplificados */
        .captcha-status-container {
            margin-top: 1rem;
            padding: 1rem; /* Más padding */
            border-radius: 10px; /* Más redondeado */
            font-size: 0.9rem;
            font-weight: 500;
            animation: fadeIn 0.3s ease;
            display: none;
            text-align: center;
        }
        
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-5px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .captcha-status-container.valid {
            display: block;
            background-color: rgba(16, 185, 129, 0.1);
            color: #065f46;
            border: 1px solid rgba(16, 185, 129, 0.2);
        }
        
        .captcha-status-container.invalid {
            display: block;
            background-color: rgba(239, 68, 68, 0.1);
            color: #991b1b;
            border: 1px solid rgba(239, 68, 68, 0.2);
        }
    </style>
</head>
<body class="min-h-screen antialiased font-sans flex flex-col">

    <%@ include file="/../header.jsp" %>

    <!-- Modal para Aviso de Privacidad -->
    <div id="privacyModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2 class="text-white text-xl font-bold">
                    <i class="fas fa-shield-alt mr-2"></i>Aviso de Privacidad COVEICYDET
                </h2>
                <button class="modal-close" id="closeModal">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <div class="modal-body">
                <div class="mb-6">
                    <h3 class="text-lg font-semibold text-gray-800 mb-4">Documento oficial de privacidad de datos</h3>
                    <p class="text-gray-600 mb-4">A continuación se muestra el aviso de privacidad oficial del Consejo Veracruzano de Investigación Científica y Desarrollo Tecnológico.</p>
                    
                    <!-- PDF Viewer Placeholder -->
                    <div class="pdf-viewer rounded-lg overflow-hidden border border-gray-300">
                        <iframe 
                            src="AvisoPrivacidad.pdf#toolbar=0" 
                            width="100%" 
                            height="100%" 
                            style="border: none;"
                            title="Visor de Aviso de Privacidad">

                            <p>Tu navegador no soporta la visualización de PDFs. 
                               <a href="AvisoPrivacidad.pdf" download>Descárgalo aquí</a>.
                            </p>
                        </iframe>
                    </div>

                    <div class="text-center mt-4">
                        <a href="AvisoPrivacidad.pdf" download="Aviso_Privacidad_COVEICYDET.pdf" 
                           class="inline-flex items-center gap-2 bg-[#A8253C] text-white px-4 py-2 rounded-lg hover:bg-[#7A1737] transition">
                            <i class="fas fa-download"></i>
                            Descargar PDF
                        </a>
                    </div>
                </div>
                
                <div class="mt-6 p-4 bg-blue-50 border border-blue-200 rounded-lg">
                    <div class="flex">
                        <i class="fas fa-exclamation-circle text-blue-500 mr-3 mt-0.5"></i>
                        <div>
                            <p class="text-blue-800 font-medium">Importante</p>
                            <p class="text-blue-700 text-sm">Al aceptar los términos y condiciones, usted reconoce haber leído y comprendido este aviso de privacidad en su totalidad.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Contenedor principal MÁS ANCHO -->
    <div class="flex-1 flex items-center justify-center px-4 py-8">
        <div class="w-full max-w-6xl mx-auto"> <!-- Más ancho (max-w-6xl) -->
            <!-- Encabezado con branding -->
            <div class="text-center mb-8">
                <h1 class="text-3xl font-bold text-gray-800 mb-2">Registro en COVEICYDET</h1>
    
            </div>
            
            <!-- Tarjeta de registro MÁS ANCHA -->
            <div class="register-container bg-white relative">
                <!-- Encabezado decorativo -->
                <div class="header-decoration p-5 flex items-center justify-between">
                    <div class="flex items-center space-x-3">
                        <div class="bg-white/20 p-3 rounded-lg"> <!-- Más grande -->
                            <i class="fas fa-user-plus text-white text-xl"></i>
                        </div>
                        <div>
                            <h1 class="text-white text-2xl font-bold">Crear Cuenta</h1>
                            <p class="text-white/90 text-sm">Completa tus datos para registrarte</p>
                        </div>
                    </div>
                    <div class="hidden md:block">
                        <div class="bg-white/20 p-3 rounded-lg"> <!-- Más grande -->
                            <i class="fas fa-shield-alt text-white text-xl"></i>
                        </div>
                    </div>
                </div>

                <!-- Formulario CON MÁS PADDING -->
                <form class="bg-white p-8" action="procesar_registro.jsp" method="post" id="registerForm">
                    <input type="hidden" id="pdfBase64" name="pdfBase64" value="">
                    <!-- Diseño de dos columnas MEJORADO -->
                    <div class="two-column-layout">
                        <!-- Columna izquierda: Credenciales -->
                        <div class="column-divider">
                            <div class="form-section-title">
                                <i class="fas fa-key mr-2"></i> Credenciales de acceso
                            </div>
                            
                            <!-- campos obligatorios con asterisco -->
                            <!-- Campo Email -->
                            <div class="floating-label">
                                <input type="email" id="email" name="email" required placeholder=" "
                                    class="floating-input" autocomplete="email">
                                <label for="email" class="floating-label-text">Correo Electrónico <span class="text-red-500">*</span></label>
                                <i class="fas fa-envelope form-icon"></i>
                                <p class="input-hint"></p>
                            </div>

                            <!-- Campo Password -->
                            <div class="floating-label">
                                <div class="password-field-wrapper">
                                    <input type="password" id="password" name="password" required placeholder=" "
                                        class="floating-input pr-12" autocomplete="new-password" minlength="6">
                                    <label for="password" class="floating-label-text">Contraseña <span class="text-red-500">*</span></label>
                                    <button type="button" class="password-toggle" id="togglePassword">
                                        <i class="fas fa-eye"></i>
                                    </button>
                                </div>
                                <div class="password-info-grid">
                                    <div>
                                        <div class="password-strength bg-gray-200" id="passwordStrength"></div>
                                        <span class="progress-label block mt-1" id="strengthLabel">Seguridad: baja</span>
                                    </div>
                                    <span class="text-xs text-gray-500 text-right">Mínimo 6 caracteres</span>
                                </div>
                            </div>

                            <!-- Confirmar Password -->
                            <div class="floating-label">
                                <div class="password-field-wrapper">
                                    <input type="password" id="confirmPassword" name="confirmPassword" required placeholder=" "
                                        class="floating-input pr-12" autocomplete="new-password">
                                    <label for="confirmPassword" class="floating-label-text">Confirmar Contraseña <span class="text-red-500">*</span></label>
                                    <button type="button" class="password-toggle" id="toggleConfirmPassword">
                                        <i class="fas fa-eye"></i>
                                    </button>
                                </div>
                                <p class="text-xs text-red-500 hidden mt-1" id="passwordError">
                                    <i class="fas fa-exclamation-circle mr-1"></i>Las contraseñas no coinciden
                                </p>
                            </div>
                        </div>
                        
                        <!-- Columna derecha: Datos personales -->
                        <div>
                            <div class="form-section-title">
                                <i class="fas fa-user-circle mr-2"></i> Datos personales
                            </div>
                            
                            <!-- Campo RFC CORREGIDO -->
                            <div class="floating-label">
                                <input type="text" id="rfc" name="rfc" required placeholder=" "
                                    class="floating-input" autocomplete="off"
                                    maxlength="13" minlength="12"
                                    oninput="this.value = this.value.toUpperCase().replace(/[^A-ZÑ&0-9]/g, '')" 
                                    pattern="^[A-ZÑ&]{3,4}[0-9]{6}[A-Z0-9]{3}$"
                                    title="Ingresa un RFC válido (12 o 13 caracteres, acepta letras al final)">
                                <label for="rfc" class="floating-label-text">RFC <span class="text-red-500">*</span></label>
                                <i class="fas fa-id-card form-icon"></i>
                                <p class="input-hint"> </p>
                            </div>

                            <!-- Nombre(s) -->
                            <div class="floating-label">
                                <input type="text" id="nombreCompleto" name="nombreCompleto" required placeholder=" "
                                    class="floating-input" autocomplete="name"
                                    pattern="[A-Za-zÁÉÍÓÚáéíóúÑñ\s']+"
                                    title="Por favor ingresa tu(s) nombre(s)">
                                <label for="nombreCompleto" class="floating-label-text">Nombre(s) <span class="text-red-500">*</span></label>
                                <i class="fas fa-user form-icon"></i>
                            </div>

                            <!-- Campo Apellido Paterno -->
                            <div class="floating-label">
                                <input type="text" id="primerApellido" name="primerApellido" required placeholder=" "
                                    class="floating-input" autocomplete="family-name"
                                    pattern="[A-Za-zÁÉÍÓÚáéíóúÑñ\s']+"
                                    title="Por favor ingresa un apellido paterno válido">
                                <label for="primerApellido" class="floating-label-text">Primer apellido <span class="text-red-500">*</span></label>
                                <i class="fas fa-signature form-icon"></i>
                            </div>

                            <!-- Campo Apellido Materno -->
                            <div class="floating-label">
                                <input type="text" id="segundoApellido" name="segundoApellido" placeholder=" "
                                    class="floating-input" autocomplete="additional-name"
                                    pattern="[A-Za-zÁÉÍÓÚáéíóúÑñ\s']*"
                                    title="Por favor ingresa un segundo apellido válido">
                                <label for="segundoApellido" class="floating-label-text">Segundo apellido (opcional)</label>
                                <i class="fas fa-signature form-icon"></i>
                            </div>
                        </div>
                    </div>

                    <!-- descarga el manual de usuario coveicydet -->
                    <div class="mb-6 text-center">
                        <a href="/proyectos/pages/login/Manual_de_Usuario_COVEICYDET.pdf" target="_blank" 
                           class="text-sm text-[#A8253C] hover:text-[#7A1737] font-medium">
                            <i class="fas fa-book mr-1"></i> Descargar Manual de Usuario
                        </a>
                    </div>
                    
                    <!-- Campo para subir PDF de Vigencia del Padrón Veracruzano -->
                    <div class="mt-6">
                        <div class="form-section-title">
                            <i class="fas fa-file-pdf mr-2 text-red-500"></i> Documentación requerida
                        </div>
                        
                        <div class="file-upload-container">
                            <label class="block text-sm font-medium text-gray-700 mb-3">
                                Comprobante de Vigencia del Padrón Veracruzano de Investigadores
                                <span class="text-[#A8253C]">*</span>
                            </label>
                            
                            <div class="flex flex-col space-y-4"> 
                                <div class="flex items-center justify-center w-full">
                                    <label for="pdfVigencia" class="flex flex-col items-center justify-center w-full h-36 border-2 border-dashed border-gray-300 rounded-lg cursor-pointer bg-gray-50 hover:bg-gray-100 transition">
                                        <div class="flex flex-col items-center justify-center pt-5 pb-6">
                                            <i class="fas fa-cloud-upload-alt text-3xl text-gray-400 mb-2"></i>
                                            <p class="mb-1 text-sm text-gray-500">
                                                <span class="font-semibold">Haz clic para subir</span> o arrastra el archivo
                                            </p>
                                            <p class="text-xs text-gray-500">PDF (máximo 1.5 MB)</p>
                                        </div>
                                        <input type="file" 
                                            id="pdfVigencia" 
                                            name="pdfVigencia" 
                                            accept=".pdf"
                                            class="hidden"
                                            onchange="handlePDFUpload(this)">
                                    </label>
                                </div>
                                
                                <div id="fileInfo" class="hidden file-info">
                                    <div class="flex items-center">
                                        <i class="fas fa-file-pdf text-red-500 text-lg mr-3"></i>
                                        <div>
                                            <span id="fileName" class="font-medium text-gray-700"></span>
                                            <p id="fileSize" class="text-xs text-gray-500"></p>
                                        </div>
                                    </div>
                                    <button type="button" 
                                            onclick="removePDF()"
                                            class="text-red-500 hover:text-red-700 transition">
                                        <i class="fas fa-times-circle text-lg"></i>
                                    </button>
                                </div>
                                
                                <p class="text-xs text-gray-500 mt-2">
                                    <i class="fas fa-info-circle mr-1"></i>
                                    Sube el documento oficial que acredite tu vigencia en el Padrón Veracruzano de Investigadores.
                                </p>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Términos y condiciones con enlace al aviso de privacidad -->
                    <div class="terms-box">
                        <div class="flex items-start">
                            <div class="flex items-center h-5">
                                <input id="terms" name="terms" type="checkbox" required
                                       class="h-5 w-5 text-[#A8253C] focus:ring-[#A8253C] border-slate-300 rounded cursor-pointer">
                            </div>
                            <div class="ml-3 text-sm">
                                <label for="terms" class="font-medium text-slate-800 select-none cursor-pointer">
                                    Acepto los términos y condiciones del servicio y he leído el 
                                    <span class="privacy-link" id="openPrivacyModal">
                                        <i class="fas fa-external-link-alt text-xs"></i> Aviso de Privacidad
                                    </span>
                                </label>
                                <p class="text-slate-600 mt-2">
                                    Al crear una cuenta, aceptas nuestras políticas de tratamiento de datos personales conforme al 
                                    <span class="privacy-link" id="openPrivacyModal2">Aviso de Privacidad</span> 
                                    de COVEICYDET. Tus datos están protegidos y serán utilizados únicamente para fines institucionales.
                                </p>
                                <div class="mt-3 flex items-center gap-2">
                                    <button type="button" id="viewPrivacyBtn" class="text-xs bg-gray-100 hover:bg-gray-200 text-gray-700 px-3 py-1.5 rounded-lg transition flex items-center gap-1">
                                        <i class="fas fa-file-pdf"></i> Visualizar Aviso de Privacidad
                                    </button>
                                    <button type="button" id="downloadPrivacyBtn" class="text-xs bg-[#A8253C] hover:bg-[#7A1737] text-white px-3 py-1.5 rounded-lg transition flex items-center gap-1">
                                        <i class="fas fa-download"></i> Descargar PDF
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Nota informativa -->
                    <div class="form-note">
                        <div class="flex">
                            <i class="fas fa-info-circle text-[#B28854] mr-2 mt-0.5"></i>
                            <div>
                                <p class="font-medium text-slate-700">Información importante</p>
                                <p class="text-sm text-slate-600">
                                    Todos los campos marcados con <span class="text-[#A8253C]">*</span> son obligatorios.
                                    Una vez completado el registro, recibirás un correo de confirmación. 
                                    <br><strong>⚠️ Por favor, revisa también tu bandeja de SPAM o Correo no deseado.</strong>
                                </p>
                            </div>
                        </div>
                    </div>
                    
                    <!-- CAPTCHA SIMPLE - SOLO EL WIDGET -->
                    <div class="captcha-wrapper">
                        <div class="g-recaptcha" 
                             data-sitekey="6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI" 
                             data-callback="onCaptchaSuccess"
                             data-expired-callback="onCaptchaExpired"
                             data-error-callback="onCaptchaError">
                        </div>
                    </div>
                    
                    <!-- Estado de verificación simplificado -->
                    <div class="captcha-status-container" id="captchaStatus">
                        <i class="fas fa-check-circle mr-2"></i> Verificación completada exitosamente
                    </div>
                    
                    <!-- Mensaje de error simple -->
                    <div class="captcha-error-message" id="captchaError">
                        <i class="fas fa-exclamation-circle mr-1"></i> Marca la casilla "No soy un robot" para continuar
                    </div>

                    <!-- Botón de submit MÁS GRANDE -->
                    <div class="mt-4 pt-3">
                        <button type="submit"
                                class="w-full py-4 px-4 rounded-xl shadow-lg text-base font-bold text-white 
                                       submit-btn focus:outline-none focus:ring-4 focus:ring-[#A8253C]/30"
                                id="submitBtn" disabled>
                            <i class="fas fa-user-plus mr-2"></i> Crear Cuenta
                        </button>
                        <p class="text-xs text-gray-500 text-center mt-2" id="captchaRequiredText">
                            <i class="fas fa-lock mr-1"></i>Debes completar la verificación de seguridad para continuar
                        </p>
                    </div>
                    
                    <!-- Enlace a login -->
                    <div class="text-center text-sm text-slate-600 pt-6 pb-2 border-t border-slate-100 mt-6">
                        ¿Ya tienes una cuenta?
                        <a href="/proyectos/pages/login/login.jsp" class="font-semibold text-[#A8253C] hover:text-[#7A1737] ml-1">
                            <i class="fas fa-sign-in-alt mr-1"></i>Iniciar Sesión
                        </a>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <%@ include file="/footer.jsp" %>

<script>
document.addEventListener('DOMContentLoaded', () => {
    console.log('JS cargado - Validación estricta activada');
    
    // Variables de estado
    let captchaVerified = false;
    let pdfUploaded = false;
    
    // Elementos del formulario
    const password = document.getElementById('password');
    const confirmPassword = document.getElementById('confirmPassword');
    const passwordError = document.getElementById('passwordError');
    const form = document.getElementById('registerForm');
    const passwordStrength = document.getElementById('passwordStrength');
    const strengthLabel = document.getElementById('strengthLabel');
    const togglePassword = document.getElementById('togglePassword');
    const toggleConfirmPassword = document.getElementById('toggleConfirmPassword');
    
    // Campos de datos
    const nombreCompleto = document.getElementById('nombreCompleto');
    const primerApellido = document.getElementById('primerApellido');
    const segundoApellido = document.getElementById('segundoApellido');
    const rfcInput = document.getElementById('rfc');
    const emailInput = document.getElementById('email');
    const termsCheckbox = document.getElementById('terms');
    
    const submitBtn = document.getElementById('submitBtn');
    const captchaRequiredText = document.getElementById('captchaRequiredText');
    const captchaError = document.getElementById('captchaError');
    const captchaStatus = document.getElementById('captchaStatus');

    // Elementos del modal de privacidad
    const privacyModal = document.getElementById('privacyModal');
    const openPrivacyModal = document.getElementById('openPrivacyModal');
    const openPrivacyModal2 = document.getElementById('openPrivacyModal2');
    const viewPrivacyBtn = document.getElementById('viewPrivacyBtn');
    const downloadPrivacyBtn = document.getElementById('downloadPrivacyBtn');
    const closeModal = document.getElementById('closeModal');
    
    // Elementos del campo PDF
    const pdfInput = document.getElementById('pdfVigencia');
    const fileInfo = document.getElementById('fileInfo');
    const fileNameDisplay = document.getElementById('fileName');
    const fileSizeDisplay = document.getElementById('fileSize');
    
    // --- FUNCIÓN MEJORADA DE VALIDACIÓN RFC ---
    function validateRFC() {
        const value = rfcInput.value.trim().toUpperCase();
        // Patrón corregido: ^[A-ZÑ&]{3,4}[0-9]{6}[A-Z0-9]{3}$
        const rfcPattern = /^[A-ZÑ&]{3,4}[0-9]{6}[A-Z0-9]{3}$/;
        
        // Validación de longitud
        if (value.length < 12 || value.length > 13) {
            rfcInput.classList.remove('valid');
            if (value.length > 0) rfcInput.classList.add('invalid');
            return false;
        }
        
        // Validación de patrón
        if (rfcPattern.test(value)) {
            rfcInput.classList.remove('invalid');
            rfcInput.classList.add('valid');
            return true;
        } else {
            rfcInput.classList.remove('valid');
            if (value.length > 0) rfcInput.classList.add('invalid');
            return false;
        }
    }
    
    // --- FUNCIÓN PARA MANEJAR SUBIDA DE PDF ---
    window.handlePDFUpload = function(input) {
        const file = input.files[0];
        if (file) {
            // Validaciones (tipo y tamaño)
            if (file.type !== 'application/pdf') {
                alert('Error: Solo se permiten archivos PDF');
                input.value = '';
                return;
            }
            
            // LÍMITE REDUCIDO: 1.5 MB (seguro para Tomcat por defecto)
            // 1.5 MB original = ~2 MB en Base64 (dentro del límite de 2MB de Tomcat)
            const maxSizeMB = 1.5;
            const maxSizeBytes = maxSizeMB * 1024 * 1024;
            
            if (file.size > maxSizeBytes) {
                alert('Error: El archivo excede ' + maxSizeMB + ' MB.\n\nPor favor, reduce el tamaño del PDF antes de subirlo.\n\nConsejo: Puedes usar herramientas como "Smallpdf" o "iLovePDF" para comprimir el archivo.');
                input.value = '';
                return;
            }

            // Feedback visual inmediato (mientras carga)
            document.getElementById('fileName').textContent = "Procesando archivo...";
            document.getElementById('fileSize').textContent = "";
            document.getElementById('fileInfo').classList.remove('hidden');

            // Deshabilitamos temporalmente para evitar clics prematuros
            pdfUploaded = false; 
            updateSubmitButtonState();

            const reader = new FileReader();

            // --- CAMBIO CLAVE AQUÍ ---
            reader.onload = function(e) {
                // 1. Guardamos la data REALMENTE
                document.getElementById('pdfBase64').value = e.target.result;

                // 2. AHORA SÍ actualizamos la UI final y habilitamos el botón
                document.getElementById('fileName').textContent = file.name;
                document.getElementById('fileSize').textContent = (file.size / (1024 * 1024)).toFixed(2) + ' MB';

                // 3. Agregar clase visual de éxito (borde verde)
                const fileUploadContainer = document.querySelector('.file-upload-container');
                fileUploadContainer.classList.add('file-uploaded');

                // 4. Marcamos como listo y actualizamos botón
                pdfUploaded = true;
                updateSubmitButtonState();

                console.log("Conversión a Base64 terminada con éxito");
            };
            // -------------------------

            reader.readAsDataURL(file); 
        }
    };
    
    // --- FUNCIÓN PARA ELIMINAR PDF ---
    window.removePDF = function() {
        pdfInput.value = '';
        fileInfo.classList.add('hidden');
        pdfUploaded = false;
        
        // Remover clase visual de éxito
        const fileUploadContainer = document.querySelector('.file-upload-container');
        fileUploadContainer.classList.remove('file-uploaded');
        
        updateSubmitButtonState();
    };
    
    // --- FUNCIÓN MAESTRA DE VALIDACIÓN ---
    function checkAllFieldsValid() {
        // 1. Validar Captcha
        if (!captchaVerified) return false;

        // 2. Validar Términos
        if (!termsCheckbox.checked) return false;

        // 3. Validar Contraseñas
        const pass = password.value;
        const confirm = confirmPassword.value;
        if (pass.length < 6 || pass !== confirm) return false;

        // 4. Validar Email
        if (!emailInput.classList.contains('valid')) return false;

        // 5. Validar RFC
        if (!validateRFC()) return false;

        // 6. Validar Nombres
        if (nombreCompleto.value.trim() === '') return false;
        if (primerApellido.value.trim() === '') return false;

        // 7. Validar PDF
        if (!pdfUploaded) return false;

        return true; // Todo está correcto
    }

    // Función para actualizar el estado del botón de envío
    function updateSubmitButtonState() {
        // Verificar estado de reCAPTCHA primero
        if (typeof grecaptcha !== 'undefined') {
            try {
                const response = grecaptcha.getResponse();
                if (response.length > 0) {
                    captchaVerified = true;
                    captchaStatus.classList.add('valid');
                    captchaStatus.classList.remove('invalid');
                    captchaError.classList.remove('show');
                } else {
                    captchaVerified = false;
                    captchaStatus.classList.remove('valid');
                }
            } catch(e) { /* ignorar si grecaptcha no está listo */ }
        }
        
        const isValid = checkAllFieldsValid();

        if (isValid) {
            submitBtn.disabled = false;
            captchaRequiredText.classList.add('hidden');
            submitBtn.classList.remove('opacity-50', 'cursor-not-allowed');
            submitBtn.innerHTML = '<i class="fas fa-user-plus mr-2"></i> Crear Cuenta';
        } else {
            submitBtn.disabled = true;
            // Mensaje dinámico dependiendo de qué falta
            if (!captchaVerified) {
                captchaRequiredText.textContent = "Completa la verificación de seguridad para continuar";
                captchaRequiredText.classList.remove('hidden');
                submitBtn.innerHTML = '<i class="fas fa-lock mr-2"></i> Verifica la seguridad';
            } else if (!pdfUploaded) {
                captchaRequiredText.textContent = "Sube el comprobante de vigencia del padrón";
                captchaRequiredText.classList.remove('hidden');
                submitBtn.innerHTML = '<i class="fas fa-file-pdf mr-2"></i> Sube el documento';
            } else {
                captchaRequiredText.textContent = "Completa todos los campos correctamente";
                captchaRequiredText.classList.remove('hidden');
                submitBtn.innerHTML = '<i class="fas fa-edit mr-2"></i> Faltan datos';
            }
        }
    }
    
    // Callbacks para reCAPTCHA
    window.onCaptchaSuccess = function(response) {
        captchaVerified = true;
        captchaStatus.innerHTML = '<i class="fas fa-check-circle mr-2"></i> Verificación completada exitosamente';
        captchaStatus.classList.add('valid');
        captchaStatus.classList.remove('invalid');
        captchaError.classList.remove('show');
        updateSubmitButtonState();
    };
    
    window.onCaptchaExpired = function() {
        captchaVerified = false;
        captchaStatus.innerHTML = '<i class="fas fa-clock mr-2"></i> Expirado. Verifica nuevamente.';
        captchaStatus.classList.remove('valid');
        captchaStatus.classList.add('invalid');
        updateSubmitButtonState();
    };

    window.onCaptchaError = function() {
        captchaVerified = false;
        captchaError.classList.add('show');
        updateSubmitButtonState();
    };

    // --- OTRAS FUNCIONES DE VALIDACIÓN ---

    function validateEmail() {
        const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (emailPattern.test(emailInput.value)) {
            emailInput.classList.remove('invalid');
            emailInput.classList.add('valid');
        } else {
            emailInput.classList.remove('valid');
            if (emailInput.value.length > 0) emailInput.classList.add('invalid');
        }
        updateSubmitButtonState();
    }

    function validatePassword() {
        if (password.value !== confirmPassword.value && confirmPassword.value.length > 0) {
            passwordError.classList.remove('hidden');
            confirmPassword.classList.add('invalid');
            confirmPassword.classList.remove('valid');
        } else {
            passwordError.classList.add('hidden');
            confirmPassword.classList.remove('invalid');
            if (confirmPassword.value.length > 0) confirmPassword.classList.add('valid');
        }
        updateSubmitButtonState();
    }
    
    // Validar nombre completo
    function validateTextField(inputElement) {
        if (inputElement.value.trim().length > 1) {
             inputElement.classList.add('valid');
             inputElement.classList.remove('invalid');
        } else if (inputElement.value.length > 0) {
             inputElement.classList.remove('valid');
        }
        updateSubmitButtonState();
    }

    function checkPasswordStrength() {
        const pass = password.value;
        let strength = 0;
        if (pass.length >= 6) strength += 20;
        if (pass.length >= 8) strength += 20;
        if (/[A-Z]/.test(pass)) strength += 20;
        if (/[0-9]/.test(pass)) strength += 20;
        if (/[^A-Za-z0-9]/.test(pass)) strength += 20;
        strength = Math.min(strength, 100);
        
        passwordStrength.style.width = strength + '%';
        let label = 'Débil', color = '#ef4444';
        
        if (strength >= 80) { label = 'Fuerte'; color = '#22c55e'; }
        else if (strength >= 60) { label = 'Moderada'; color = '#eab308'; }
        
        passwordStrength.style.backgroundColor = color;
        strengthLabel.textContent = `Seguridad: ${label}`;
        strengthLabel.style.color = color;
    }

    // --- EVENT LISTENERS ---

    // Alternar visibilidad passwords
    togglePassword.addEventListener('click', function() {
        const type = password.getAttribute('type') === 'password' ? 'text' : 'password';
        password.setAttribute('type', type);
        this.querySelector('i').classList.toggle('fa-eye');
        this.querySelector('i').classList.toggle('fa-eye-slash');
    });

    toggleConfirmPassword.addEventListener('click', function() {
        const type = confirmPassword.getAttribute('type') === 'password' ? 'text' : 'password';
        confirmPassword.setAttribute('type', type);
        this.querySelector('i').classList.toggle('fa-eye');
        this.querySelector('i').classList.toggle('fa-eye-slash');
    });

    // Validaciones en tiempo real (INPUT)
    password.addEventListener('input', () => { checkPasswordStrength(); validatePassword(); });
    confirmPassword.addEventListener('input', validatePassword);
    
    rfcInput.addEventListener('input', validateRFC);
    emailInput.addEventListener('input', validateEmail);
    
    nombreCompleto.addEventListener('input', () => validateTextField(nombreCompleto));
    primerApellido.addEventListener('input', () => validateTextField(primerApellido));
    segundoApellido.addEventListener('input', () => validateTextField(segundoApellido));
    
    // Listener especial para el checkbox
    termsCheckbox.addEventListener('change', updateSubmitButtonState);

    // Modales
    function openPrivacyModalFunc() { privacyModal.style.display = 'flex'; document.body.style.overflow = 'hidden'; }
    function closePrivacyModalFunc() { privacyModal.style.display = 'none'; document.body.style.overflow = 'auto'; }
    
    openPrivacyModal.addEventListener('click', openPrivacyModalFunc);
    openPrivacyModal2.addEventListener('click', openPrivacyModalFunc);
    viewPrivacyBtn.addEventListener('click', openPrivacyModalFunc);
    closeModal.addEventListener('click', closePrivacyModalFunc);
    
    privacyModal.addEventListener('click', (e) => {
        if (e.target === privacyModal) closePrivacyModalFunc();
    });

    downloadPrivacyBtn.addEventListener('click', () => {
        // Crea un enlace temporal invisible
        const link = document.createElement('a');
        link.href = 'AvisoPrivacidad.pdf'; // Ruta al archivo
        link.download = 'Aviso_Privacidad_COVEICYDET.pdf'; // Nombre con el que se guardará

        // Lo añade al documento, hace clic y lo elimina
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    });

    // Envío del formulario
    form.addEventListener('submit', function(e) {
        e.preventDefault();
        
        if (!checkAllFieldsValid()) {
            alert('Por favor, completa todos los campos requeridos correctamente.');
            
            // Encontrar el primer campo inválido para hacer focus
            if (!captchaVerified) {
                document.querySelector('.captcha-wrapper').scrollIntoView({ behavior: 'smooth', block: 'center' });
            } else if (!validateRFC()) {
                rfcInput.focus();
                rfcInput.scrollIntoView({ behavior: 'smooth', block: 'center' });
            } else if (!pdfUploaded) {
                pdfInput.scrollIntoView({ behavior: 'smooth', block: 'center' });
            } else if (!emailInput.classList.contains('valid')) {
                emailInput.focus();
            }
            return;
        }
        
        // Si todo ok
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin mr-2"></i> Procesando...';
        form.submit();
    });
    
    // Drag and drop para PDF
    const fileUploadContainer = document.querySelector('.file-upload-container');
    
    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
        fileUploadContainer.addEventListener(eventName, preventDefaults, false);
    });
    
    function preventDefaults(e) {
        e.preventDefault();
        e.stopPropagation();
    }
    
    ['dragenter', 'dragover'].forEach(eventName => {
        fileUploadContainer.addEventListener(eventName, highlight, false);
    });
    
    ['dragleave', 'drop'].forEach(eventName => {
        fileUploadContainer.addEventListener(eventName, unhighlight, false);
    });
    
    function highlight() {
        fileUploadContainer.classList.add('dragover');
    }
    
    function unhighlight() {
        fileUploadContainer.classList.remove('dragover');
    }
    
    fileUploadContainer.addEventListener('drop', handleDrop, false);
    
    function handleDrop(e) {
        const dt = e.dataTransfer;
        const files = dt.files;
        
        if (files.length > 0) {
            // Crear un input file temporal para usar la misma función
            const tempInput = document.createElement('input');
            tempInput.type = 'file';
            tempInput.files = files;
            handlePDFUpload(tempInput);
        }
    }
    
    // Inicialización
    updateSubmitButtonState();
});
</script>
</body>
</html>