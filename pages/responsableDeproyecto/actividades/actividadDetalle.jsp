<% if (!"responsable".equals(String.valueOf(session.getAttribute("rol")))) { String n=request.getRequestURI()+(request.getQueryString()!=null?("?"+request.getQueryString()):""); response.sendRedirect(request.getContextPath()+"/pages/login/login.jsp?next="+java.net.URLEncoder.encode(n,"UTF-8")); return; } %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="es">
<%@ include file="../header.jsp" %>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Detalle de Actividad</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body>
<div class="p-6">
    <div class="mb-4">
        <a href="javascript:history.back()" class="text-blue-600 hover:text-blue-800 font-medium">
            ← Volver
        </a>
    </div>
    
    <h1 class="text-2xl font-bold mb-4">Detalle de Actividad</h1>

    <c:if test="${not empty mensajeError}">
        <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
            ${mensajeError}
        </div>
    </c:if>

    <c:choose>
        <c:when test="${not empty actividad}">
            <div class="bg-white rounded-lg shadow-sm border p-6">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
                    <div>
                        <h3 class="font-semibold text-gray-700">ID de Actividad:</h3>
                        <p class="text-gray-900">${actividad.id}</p>
                    </div>
                    <div>
                        <h3 class="font-semibold text-gray-700">Proyecto:</h3>
                        <p class="text-gray-900">${actividad.proyectoNombre}</p>
                    </div>
                    <div>
                        <h3 class="font-semibold text-gray-700">Trimestre:</h3>
                        <p class="text-gray-900">${actividad.trimestre}</p>
                    </div>
                    <div>
                        <h3 class="font-semibold text-gray-700">Fecha de Entrega:</h3>
                        <p class="text-gray-900">
                            <fmt:formatDate value="${actividad.fecha}" pattern="dd/MM/yyyy" />
                        </p>
                    </div>
                </div>
                
                <div class="mb-4">
                    <h3 class="font-semibold text-gray-700 mb-2">Meta:</h3>
                    <p class="text-gray-900">${actividad.meta}</p>
                </div>
                
                <div class="mb-4">
                    <h3 class="font-semibold text-gray-700 mb-2">Descripción de la Actividad:</h3>
                    <p class="text-gray-900">${actividad.actividad}</p>
                </div>
                
                <div class="mb-4">
                    <h3 class="font-semibold text-gray-700 mb-2">Productos Entregables:</h3>
                    <p class="text-gray-900">${actividad.productos}</p>
                </div>
                
                <div class="flex space-x-4 mt-6">
                    <a href="/COVEICYDETPROYECTOS/proyecto-info?id=${actividad.proyectoId}" 
                       class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">
                        Ver Proyecto Completo
                    </a>
                    <!-- Botón para entregar la actividad -->
                    <a href="/COVEICYDETPROYECTOS/entregar-actividad?id=${actividad.id}" 
                       class="bg-green-500 hover:bg-green-700 text-white font-bold py-2 px-4 rounded">
                        Entregar Actividad
                    </a>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="bg-yellow-100 border border-yellow-400 text-yellow-800 px-4 py-3 rounded">
                No se pudo cargar la información de la actividad.
            </div>
        </c:otherwise>
    </c:choose>
</div>

<!-- Espaciado antes del footer -->
<div class="mt-20 mb-16"></div>

<%@ include file="/footer.jsp" %>
</body>
</html>
