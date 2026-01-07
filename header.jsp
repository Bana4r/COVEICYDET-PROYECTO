<header class="bg-[#7A1737] border-l-8 border-[#7A1737]">
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/favicon.png">
    <div class="container mx-auto px-6 py-8">
        <div class="flex items-center justify-between gap-8">
            <!-- Texto a la izquierda -->
            <div class="text-center flex-1">
                <h1 class="text-4xl font-bold text-white mb-4">Sistema de Registro de Proyectos</h1>
                <div class="text-lg">
                    <span class="bg-[#B28854] text-white px-6 py-3 rounded-lg text-xl font-bold shadow-lg">COVEICYDET</span>
                </div>
            </div>
            
            <!-- Imagen del lado derecho -->
            <a href="<%= request.getContextPath() %>/" class="transform hover:scale-105 transition-transform duration-300">
                <img id="appLogo" 
                    src="<%= request.getContextPath() %>/imagen/logo2.jpg" 
                    alt="Logo COVEICYDET" 
                    width="600" 
                    height="100"
                    class="rounded-xl shadow-2xl border-4 border-[#B26854]">
            </a>
        </div>
        
        <!-- Líneas de papel centradas -->
        <div class="mt-6 space-y-1 flex flex-col items-center">
            <div class="h-1 bg-white w-3/4 opacity-40"></div>
            <div class="h-1 bg-white w-2/3 opacity-30"></div>
            <div class="h-1 bg-white w-1/2 opacity-20"></div>
        </div>
    </div>
</header>