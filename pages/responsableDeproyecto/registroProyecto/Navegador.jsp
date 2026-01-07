<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Obtener la página actual desde la URL o parámetro
    String paginaActual = request.getParameter("pagina");
    if (paginaActual == null) {
        // Intentar detectar desde la URL
        String requestURI = request.getRequestURI();
        if (requestURI.contains("registroProyecto10")) paginaActual = "10";
        else if (requestURI.contains("registroProyecto9")) paginaActual = "9";
        else if (requestURI.contains("registroProyecto8")) paginaActual = "8";
        else if (requestURI.contains("registroProyecto7")) paginaActual = "7";
        else if (requestURI.contains("registroProyecto6")) paginaActual = "6";
        else if (requestURI.contains("registroProyecto5")) paginaActual = "5";
        else if (requestURI.contains("registroProyecto4")) paginaActual = "4";
        else if (requestURI.contains("registroProyecto3")) paginaActual = "3";
        else if (requestURI.contains("registroProyecto2")) paginaActual = "2";
        else paginaActual = "1"; // Por defecto
    }
    
    int paginaNum = Integer.parseInt(paginaActual);
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <title>Navegación - Formulario COVEICYDET</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');
        
        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
            min-height: 100vh;
            margin: 0;
            padding: 0;
        }
        
        .container {
            max-width: 1400px;
            width: 100%;
            margin: 0 auto;
            padding: 20px;
        }
        
        .nav-container {
            background: white;
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
            padding: 30px;
            margin-bottom: 20px;
            width: 100%;
        }
        
        .step-indicator {
            display: flex;
            justify-content: space-between;
            position: relative;
            margin-bottom: 20px;
            width: 100%;
        }
        
        .step {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            z-index: 2;
            background-color: #e2e8f0;
            color: #64748b;
            cursor: pointer;
            transition: all 0.3s ease;
            border: none;
            font-size: 18px;
            text-decoration: none;
            position: relative;
        }
        
        .step:hover {
            transform: scale(1.05);
        }
        
        .step.active {
            background-color: #7A1737;
            color: white;
        }
        
        .step.completed {
            background-color: #B28854;
            color: white;
        }
        
        .step-line {
            position: absolute;
            top: 50%;
            left: 30px;
            right: 30px;
            height: 4px;
            background-color: #e2e8f0;
            transform: translateY(-50%);
            z-index: 1;
        }
        
        .step-fill {
            position: absolute;
            top: 50%;
            left: 30px;
            height: 4px;
            background-color: #7A1737;
            transform: translateY(-50%);
            z-index: 1;
            transition: width 0.3s ease;
        }
        
        .current-title {
            text-align: center;
            margin-top: 25px;
            padding: 20px;
            background-color: #f8fafc;
            border-radius: 8px;
            border-left: 4px solid #7A1737;
            width: 100%;
        }
        
        .current-title h2 {
            color: #7A1737;
            font-size: 28px;
            font-weight: 600;
            margin: 0;
        }
        
        .current-title p {
            color: #64748b;
            margin: 10px 0 0 0;
            font-size: 16px;
        }
        
        /* Tooltip styles */
        .step-tooltip {
            position: absolute;
            bottom: -40px;
            left: 50%;
            transform: translateX(-50%);
            background-color: #1e293b;
            color: white;
            padding: 6px 12px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 500;
            white-space: nowrap;
            opacity: 0;
            visibility: hidden;
            transition: all 0.3s ease;
            z-index: 10;
            pointer-events: none;
        }
        
        .step-tooltip:after {
            content: '';
            position: absolute;
            top: -5px;
            left: 50%;
            transform: translateX(-50%);
            width: 0;
            height: 0;
            border-left: 5px solid transparent;
            border-right: 5px solid transparent;
            border-bottom: 5px solid #1e293b;
        }
        
        .step:hover .step-tooltip {
            opacity: 1;
            visibility: visible;
            bottom: -35px;
        }
        
        @media (max-width: 768px) {
            .container {
                padding: 15px;
            }
            
            .nav-container {
                padding: 20px;
            }
            
            .step {
                width: 45px;
                height: 45px;
                font-size: 16px;
            }
            
            .step-line {
                left: 22px;
                right: 22px;
            }
            
            .step-fill {
                left: 22px;
            }
            
            .current-title h2 {
                font-size: 22px;
            }
            
            .current-title p {
                font-size: 14px;
            }
            
            .step-tooltip {
                font-size: 10px;
                padding: 4px 8px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="nav-container">
            <!-- Indicador de pasos -->
            <div class="step-indicator">
                <div class="step-line"></div>
                <div class="step-fill" id="stepFill" style="width: <%= ((paginaNum - 1) / 9.0) * 100 %>%"></div>
                
                <a href="registroProyecto.jsp?pagina=1" class="step <%= paginaNum > 1 ? "completed" : (paginaNum == 1 ? "active" : "") %>">
                    1
                    <span class="step-tooltip">Datos generales</span>
                </a>
                <a href="registroProyecto2.jsp?pagina=2" class="step <%= paginaNum > 2 ? "completed" : (paginaNum == 2 ? "active" : "") %>">
                    2
                    <span class="step-tooltip">Justificación y objetivos</span>
                </a>
                <a href="registroProyecto3.jsp?pagina=3" class="step <%= paginaNum > 3 ? "completed" : (paginaNum == 3 ? "active" : "") %>">
                    3
                    <span class="step-tooltip">Planeación y evaluación</span>
                </a>
                <a href="registroProyecto4.jsp?pagina=4" class="step <%= paginaNum > 4 ? "completed" : (paginaNum == 4 ? "active" : "") %>">
                    4
                    <span class="step-tooltip">Grupo de trabajo</span>
                </a>
                <a href="registroProyecto5.jsp?pagina=5" class="step <%= paginaNum > 5 ? "completed" : (paginaNum == 5 ? "active" : "") %>">
                    5
                    <span class="step-tooltip">Organizaciones participantes</span>
                </a>
                <a href="registroProyecto6.jsp?pagina=6" class="step <%= paginaNum > 6 ? "completed" : (paginaNum == 6 ? "active" : "") %>">
                    6
                    <span class="step-tooltip">Estudiantes participantes</span>
                </a>
                <a href="registroProyecto7.jsp?pagina=7" class="step <%= paginaNum > 7 ? "completed" : (paginaNum == 7 ? "active" : "") %>">
                    7
                    <span class="step-tooltip">Cronograma de actividades</span>
                </a>
                <a href="registroProyecto8.jsp?pagina=8" class="step <%= paginaNum > 8 ? "completed" : (paginaNum == 8 ? "active" : "") %>">
                    8
                    <span class="step-tooltip">Partidas</span>
                </a>
                <a href="registroProyecto9.jsp?pagina=9" class="step <%= paginaNum > 9 ? "completed" : (paginaNum == 9 ? "active" : "") %>">
                    9
                    <span class="step-tooltip">Descarga del archivo extenso</span>
                </a>
                <a href="registroProyecto10.jsp?pagina=10" class="step <%= paginaNum > 10 ? "completed" : (paginaNum == 10 ? "active" : "") %>">
                    10
                    <span class="step-tooltip">Cargar archivo extenso</span>
                </a>
            </div>
            
            <!-- Título del formulario actual -->
            <div class="current-title">
                <h2 id="currentFormTitle"><%= getTituloPagina(paginaNum) %></h2>
                <p id="currentFormDescription"><%= paginaNum %>/10 - <%= getDescripcionPagina(paginaNum) %></p>
            </div>
        </div>
    </div>

</body>
</html>

<%!
    // Métodos para obtener títulos y descripciones
    private String getTituloPagina(int pagina) {
        switch(pagina) {
            case 1: return "Datos generales";
            case 2: return "Justificación y objetivos";
            case 3: return "Planeación y evaluación";
            case 4: return "Grupo de Trabajo del Proponente";
            case 5: return "Organizaciones Participantes";
            case 6: return "Estudiantes Participantes";
            case 7: return "Cronograma de Actividades";
            case 8: return "Partidas";
            case 9: return "Descarga del archivo extenso";
            case 10: return "Cargar archivo extenso";
            default: return "Formulario COVEICYDET";
        }
    }
    
    private String getDescripcionPagina(int pagina) {
        switch(pagina) {
            case 1: return "Información básica del proyecto";
            case 2: return "Fundamentos y metas del proyecto";
            case 3: return "Estrategias y métricas";
            case 4: return "Equipo responsable";
            case 5: return "Instituciones colaboradoras";
            case 6: return "Alumnos involucrados";
            case 7: return "Planificación temporal";
            case 8: return "Presupuesto y recursos";
            case 9: return "Descargar Plantilla del Documento Extenso";
            case 10: return "Cargar Documento Extenso Completado";
            default: return "Formulario de registro";
        }
    }
%>