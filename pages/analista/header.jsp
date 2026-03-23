<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
  // --- LÓGICA DE USUARIO ---
  String primerNombre = "";
  
  // Recuperar datos de la sesión
  String nombreCompleto = (String) session.getAttribute("nombre");
  
  if (nombreCompleto != null && !nombreCompleto.isEmpty()) {
    String[] partes = nombreCompleto.split(" ");
    if (partes.length > 0) primerNombre = partes[0];
  }
%>

<header class="bg-[#7A1737] border-l-4 border-[#7A1737] text-white shadow-md relative overflow-hidden">
    <div class="container mx-auto px-4 py-3">
        <div class="flex items-center justify-between gap-4 relative z-10">
            
            <div class="flex-1">
                <div class="flex items-center gap-3 mb-1">
                    <h1 class="text-xl md:text-2xl font-bold tracking-wide leading-tight">Sistema de Registro de Proyectos</h1>
                    <div class="bg-[#B28854] px-2 py-0.5 rounded text-xs font-bold shadow-sm self-start mt-1">
                        COVEICYDET
                    </div>
                </div>
                
                <%-- Bienvenida --%>
                <% if (!primerNombre.isEmpty()) { %>
                    <p class="text-gray-300 text-sm flex items-center gap-2">
                        <span class="w-1.5 h-1.5 bg-green-400 rounded-full shadow-[0_0_5px_rgba(74,222,128,0.8)]"></span>
                        Hola, <span class="font-bold text-white"><%= primerNombre %></span>
                    </p>
                <% } %>
            </div>
            
            <div class="hidden md:block">
                 <img id="appLogo" 
                    src="<%= request.getContextPath() %>/imagen/logo2.jpg" 
                    alt="Logo COVEICYDET" 
                    class="h-16 w-auto object-contain rounded-lg shadow-lg border-2 border-[#B28854] transform hover:scale-105 transition-transform duration-300">
            </div>
        </div>

        <nav class="mt-2 pt-2 border-t border-white/10 flex flex-wrap items-center justify-center gap-2 text-sm">
            
            <a class="flex items-center gap-1.5 px-3 py-1.5 rounded hover:bg-white/10 hover:text-[#B28854] transition-colors duration-200 font-medium group" 
               href="/proyectos/pages/analista/paginaPrincipal/">
                <svg class="w-4 h-4 group-hover:scale-110 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"></path></svg>
                Inicio
            </a>

            <span class="text-white/20">|</span>

            <a class="flex items-center gap-1.5 px-3 py-1.5 rounded hover:bg-white/10 hover:text-[#B28854] transition-colors duration-200 font-medium group" 
               href="/proyectos/pages/analista/convocatoria/">
                <svg class="w-4 h-4 group-hover:scale-110 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 20H5a2 2 0 01-2-2V6a2 2 0 012-2h10a2 2 0 012 2v1m2 13a2 2 0 01-2-2V7m2 13a2 2 0 002-2V9a2 2 0 00-2-2h-2m-4-3H9M7 16h6M7 8h6v4H7V8z"></path></svg>
                Convocatoria
            </a>

            <span class="text-white/20">|</span>

            <a class="flex items-center gap-1.5 px-3 py-1.5 rounded hover:bg-white/10 hover:text-[#B28854] transition-colors duration-200 font-medium group" 
               href="/proyectos/pages/analista/proyectos/">
                <svg class="w-4 h-4 group-hover:scale-110 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path></svg>
                Proyectos
            </a>

            <span class="text-white/20">|</span>

            <a class="flex items-center gap-1.5 px-3 py-1.5 rounded hover:bg-white/10 hover:text-[#B28854] transition-colors duration-200 font-medium group" 
               href="/proyectos/pages/analista/asignarProyectosEvaluador/">
                <svg class="w-4 h-4 group-hover:scale-110 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path></svg>
                Asignar Evaluadores
            </a>

            <span class="text-white/20">|</span>

            <a class="flex items-center gap-1.5 px-3 py-1.5 rounded hover:bg-white/10 hover:text-[#B28854] transition-colors duration-200 font-medium group" 
               href="/proyectos/pages/analista/usuarios/">
                <svg class="w-4 h-4 group-hover:scale-110 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"></path></svg>
                Usuarios
            </a>

            <span class="text-white/20">|</span>

            <a class="flex items-center gap-1.5 px-3 py-1.5 rounded text-red-300 hover:text-red-100 hover:bg-red-900/30 transition-colors duration-200 font-medium group" 
               href="<%= request.getContextPath() %>/pages/login/logout.jsp">
                <svg class="w-4 h-4 group-hover:scale-110 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path></svg>
                Salir
            </a>
        </nav>
    </div>
</header>
