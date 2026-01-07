<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<% if (!"responsable".equals(String.valueOf(session.getAttribute("rol")))) { String n=request.getRequestURI()+(request.getQueryString()!=null?("?"+request.getQueryString()):""); response.sendRedirect(request.getContextPath()+"/pages/login/login.jsp?next="+java.net.URLEncoder.encode(n,"UTF-8")); return; } %>

<%!
    private static final String DB_URL = "jdbc:postgresql://localhost:5432/proyectos";
    private static final String DB_USER = "dbusr25";
    private static final String DB_PASSWORD = "mxToro24000Chocolate";

    private static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
    }
%>

<%
    //--- BLOQUEO DE SEGURIDAD ---//
    Integer idUsuarioSeguridad = (Integer) session.getAttribute("id_usuario");

    if (idUsuarioSeguridad != null) {
        boolean yaTieneProyecto = false;

        try (Connection conn = getConnection();
            PreparedStatement ps = conn.prepareStatement("SELECT 1 FROM proyecto_usuarios WHERE id_usuario = ? LIMIT 1")) {

                ps.setInt(1, idUsuarioSeguridad);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        yaTieneProyecto = true;
                    }
                }
                } catch (Exception e) {
                    e.printStackTrace();
                }
                if (yaTieneProyecto) {
                    response.sendRedirect(request.getContextPath() + "/pages/responsableDeproyecto/paginaPrincipal/main.jsp");
                    return;
                }
        }
%>

<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Registro Proyecto - COVEICYDET</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <style>
    .word-counter {
      font-size: 0.75rem;
      color: #6b7280;
      text-align: right;
      margin-top: 0.25rem;
    }
    .word-counter.warning {
      color: #dc2626;
      font-weight: 600;
    }
    .justificacion-textarea.limit-reached {
      border-color: #dc2626;
      background-color: #fef2f2;
    }
    .partida-input {
      border: 1px solid #d1d5db;
      border-radius: 0.375rem;
      padding: 0.5rem;
      text-align: right;
    }
    .partida-input:focus {
      outline: none;
      border-color: #3b82f6;
      ring: 2px;
      ring-color: #3b82f6;
    }
    .input-wrapper {
      position: relative;
      display: inline-block;
      width: 100%;
    }
    .total-input {
      padding: 0.5rem;
      text-align: right;
    }
    .total-wrapper {
      position: relative;
      display: inline-block;
      width: 100%;
    }
  </style>
</head>
<%@ include file="../header.jsp" %>
<%@ include file="Navegador.jsp" %>
<body class="bg-gray-50 min-h-screen antialiased">
    <div class="max-w-7xl mx-auto px-4 py-10">
        <div class="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden">
            <div class="bg-[#B28854] p-6">
                <h1 class="text-2xl font-bold text-white flex items-center">
                    <i class="fas fa-box-open mr-3"></i>Partidas 8/10
                </h1>
                <p class="text-white/90 mt-2">Desglose las partidas utilizadas durante el desarrollo del proyecto</p>
            </div>
            
            <form id="formPagina8" class="p-8 space-y-8" action="#" method="post">
                <!-- una lista con los topes maximos del total de las partidas 300000 para ciencia basica y 500000 para ciencia aplicada -->
                <h2 class="text-lg font-semibold text-gray-800">Selecciona el tipo de ciencia del proyecto:</h2>
                <select id="tipoProyecto" name="tipoProyecto" class="mb-6 border border-gray-300 rounded-md shadow-sm p-2">
                    <option value="ciencia_basica">Ciencia Básica y de Frontera</option>
                    <option value="ciencia_aplicada">Ciencia Aplicada</option>
                </select>

                <div id="indicadorLimiteGlobal" class="p-4 rounded-lg mb-6 border transition-colors duration-200">
                    <div class="flex justify-between items-center">
                        <span class="font-semibold text-gray-700">Estado del Presupuesto Total:</span>
                        <span id="textoLimiteGlobal" class="text-sm font-medium"></span>
                    </div>
                    <div class="w-full bg-gray-200 rounded-full h-2.5 mt-2">
                        <div id="barraProgresoGlobal" class="h-2.5 rounded-full" style="width: 0%"></div>
                    </div>
                </div>

                <div class="space-y-6">
                    <div>
                        <h2 class="text-xl font-semibold text-gray-800 mb-4">Gasto corriente</h2>
                        
                        <div class="overflow-x-auto">
                            <table class="min-w-full border-collapse border border-gray-300">
                                <thead>
                                    <tr class="bg-gray-100">
                                        <th class="border border-gray-300 px-4 py-2 text-left text-sm font-medium text-gray-700">Información de las partidas</th>
                                        <th class="border border-gray-300 px-4 py-2 text-center text-sm font-medium text-gray-700">Semestre 1</th>
                                        <th class="border border-gray-300 px-4 py-2 text-center text-sm font-medium text-gray-700">Semestre 2</th>
                                        <th class="border border-gray-300 px-4 py-2 text-center text-sm font-medium text-gray-700">Total</th>
                                        <th class="border border-gray-300 px-4 py-2 text-left text-sm font-medium text-gray-700">Justificación de partida<br><span class="text-xs font-normal"></span></th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <!-- Pasajes y viáticos -->
                                    <tr>
                                        <td class="border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700">Pasajes y viáticos</td>
                                        <td class="border border-gray-300 px-4 py-2">
                                            <div class="input-wrapper">
                                                <input type="text" name="pasajesViaticos_s1" class="w-full partida-input" placeholder="0.00" value="$0.00" data-partida="pasajesViaticos" data-semestre="s1">
                                            </div>
                                        </td>
                                        <td class="border border-gray-300 px-4 py-2">
                                            <div class="input-wrapper">
                                                <input type="text" name="pasajesViaticos_s2" class="w-full partida-input" placeholder="0.00" value="$0.00" data-partida="pasajesViaticos" data-semestre="s2">
                                            </div>
                                        </td>
                                        <td class="border border-gray-300 px-4 py-2">
                                            <div class="total-wrapper">
                                                <input type="text" name="pasajesViaticos_total" class="w-full border-0 focus:ring-0 bg-gray-100 font-semibold total-input" readonly value="$0.00">
                                            </div>
                                        </td>
                                        <td class="border border-gray-300 px-4 py-2">
                                            <textarea name="pasajesViaticos_justificacion" class="w-full border border-gray-300 rounded p-2 text-sm justificacion-textarea" rows="2" placeholder="Descripción del bien o servicio y justificación"></textarea>
                                            <div class="word-counter" data-for="pasajesViaticos_justificacion">0/200 palabras</div>
                                        </td>
                                    </tr>
                                    
                                    <!-- Gastos de operación -->
                                    <tr>
                                        <td class="border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700">Gastos de operación</td>
                                        <td class="border border-gray-300 px-4 py-2">
                                            <div class="input-wrapper">
                                                <input type="text" name="gastosOperacion_s1" class="w-full partida-input" placeholder="0.00" value="$0.00" data-partida="gastosOperacion" data-semestre="s1">
                                            </div>
                                        </td>
                                        <td class="border border-gray-300 px-4 py-2">
                                            <div class="input-wrapper">
                                                <input type="text" name="gastosOperacion_s2" class="w-full partida-input" placeholder="0.00" value="$0.00" data-partida="gastosOperacion" data-semestre="s2">
                                            </div>
                                        </td>
                                        <td class="border border-gray-300 px-4 py-2">
                                            <div class="total-wrapper">
                                                <input type="text" name="gastosOperacion_total" class="w-full border-0 focus:ring-0 bg-gray-100 font-semibold total-input" readonly value="$0.00">
                                            </div>
                                        </td>
                                        <td class="border border-gray-300 px-4 py-2">
                                            <textarea name="gastosOperacion_justificacion" class="w-full border border-gray-300 rounded p-2 text-sm justificacion-textarea" rows="2" placeholder="Descripción del bien o servicio y justificación"></textarea>
                                            <div class="word-counter" data-for="gastosOperacion_justificacion">0/200 palabras</div>
                                        </td>
                                    </tr>
                                    
                                    <!-- Gastos de trabajo de campo -->
                                    <tr>
                                        <td class="border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700">Gastos de trabajo de campo</td>
                                        <td class="border border-gray-300 px-4 py-2">
                                            <div class="input-wrapper">
                                                <input type="text" name="gastosTrabajoCampo_s1" class="w-full partida-input" placeholder="0.00" value="$0.00" data-partida="gastosTrabajoCampo" data-semestre="s1" id="gastosTrabajoCampo_s1">
                                            </div>
                                        </td>
                                        <td class="border border-gray-300 px-4 py-2">
                                            <div class="input-wrapper">
                                                <input type="text" name="gastosTrabajoCampo_s2" class="w-full partida-input" placeholder="0.00" value="$0.00" data-partida="gastosTrabajoCampo" data-semestre="s2" id="gastosTrabajoCampo_s2">
                                            </div>
                                        </td>
                                        <td class="border border-gray-300 px-4 py-2">
                                            <div class="total-wrapper">
                                                <input type="text" name="gastosTrabajoCampo_total" class="w-full border-0 focus:ring-0 bg-gray-100 font-semibold total-input" readonly value="$0.00">
                                            </div>
                                        </td>
                                        <td class="border border-gray-300 px-4 py-2">
                                            <textarea name="gastosTrabajoCampo_justificacion" class="w-full border border-gray-300 rounded p-2 text-sm justificacion-textarea" rows="2" placeholder="Descripción del bien o servicio y justificación"></textarea>
                                            <div class="word-counter" data-for="gastosTrabajoCampo_justificacion">0/200 palabras</div>
                                        </td>
                                    </tr>
                                    
                                    <!-- Indicador de límite para Gastos de trabajo de campo -->
                                    <tr>
                                        <td colspan="5" class="border border-gray-300 px-4 py-2 bg-gray-50">
                                            <div id="indicadorLimiteGastosCampo" class="text-sm">
                                                <span class="font-medium">Límite de gastos de trabajo de campo:</span>
                                                <span id="limiteTexto" class="ml-2">Máximo permitido: $0.00 (10% del presupuesto total)</span>
                                                <span id="actualTexto" class="ml-4">Actual: $0.00 (0.00%)</span>
                                            </div>
                                        </td>
                                    </tr>
                                    
                                    <!-- Estudiantes incorporados -->
                                    <tr>
                                        <td class="border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700">Estudiantes incorporados</td>
                                        <td class="border border-gray-300 px-4 py-2">
                                            <div class="input-wrapper">
                                                <input type="text" name="estudiantesIncorporados_s1" class="w-full partida-input" placeholder="0.00" value="$0.00" data-partida="estudiantesIncorporados" data-semestre="s1">
                                            </div>
                                        </td>
                                        <td class="border border-gray-300 px-4 py-2">
                                            <div class="input-wrapper">
                                                <input type="text" name="estudiantesIncorporados_s2" class="w-full partida-input" placeholder="0.00" value="$0.00" data-partida="estudiantesIncorporados" data-semestre="s2">
                                            </div>
                                        </td>
                                        <td class="border border-gray-300 px-4 py-2">
                                            <div class="total-wrapper">
                                                <input type="text" name="estudiantesIncorporados_total" class="w-full border-0 focus:ring-0 bg-gray-100 font-semibold total-input" readonly value="$0.00">
                                            </div>
                                        </td>
                                        <td class="border border-gray-300 px-4 py-2">
                                            <textarea name="estudiantesIncorporados_justificacion" class="w-full border border-gray-300 rounded p-2 text-sm justificacion-textarea" rows="2" placeholder="Descripción del bien o servicio y justificación"></textarea>
                                            <div class="word-counter" data-for="estudiantesIncorporados_justificacion">0/200 palabras</div>
                                        </td>
                                    </tr>
                                    
                                    <!-- Total de gasto corriente -->
                                    <tr class="bg-blue-50">
                                        <td class="border border-gray-300 px-4 py-2 text-sm font-bold text-gray-800">Total de gasto corriente</td>
                                        <td class="border border-gray-300 px-4 py-2">
                                            <div class="total-wrapper">
                                                <input type="text" name="totalGastoCorriente_s1" class="w-full border-0 focus:ring-0 bg-blue-100 font-bold total-input" readonly value="$0.00">
                                            </div>
                                        </td>
                                        <td class="border border-gray-300 px-4 py-2">
                                            <div class="total-wrapper">
                                                <input type="text" name="totalGastoCorriente_s2" class="w-full border-0 focus:ring-0 bg-blue-100 font-bold total-input" readonly value="$0.00">
                                            </div>
                                        </td>
                                        <td class="border border-gray-300 px-4 py-2">
                                            <div class="total-wrapper">
                                                <input type="text" name="totalGastoCorriente_total" class="w-full border-0 focus:ring-0 bg-blue-200 font-bold total-input" readonly value="$0.00">
                                            </div>
                                        </td>
                                        <td class="border border-gray-300 px-4 py-2"></td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                        
                        <!-- Sección de gastos de inversión -->
                        <div class="mt-8">
                            <h2 class="text-xl font-semibold text-gray-800 mb-4">Gasto de inversión</h2>
                            
                            <div class="overflow-x-auto">
                                <table class="min-w-full border-collapse border border-gray-300">
                                    <thead>
                                        <tr class="bg-gray-100">
                                            <th class="border border-gray-300 px-4 py-2 text-left text-sm font-medium text-gray-700">Información de las partidas</th>
                                            <th class="border border-gray-300 px-4 py-2 text-center text-sm font-medium text-gray-700">Semestre 1</th>
                                            <th class="border border-gray-300 px-4 py-2 text-center text-sm font-medium text-gray-700">Semestre 2</th>
                                            <th class="border border-gray-300 px-4 py-2 text-center text-sm font-medium text-gray-700">Total</th>
                                            <th class="border border-gray-300 px-4 py-2 text-left text-sm font-medium text-gray-700">Justificación de partida<br></th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <!-- Adquisiciones de instrumentos y equipo de laboratorio -->
                                        <tr>
                                            <td class="border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700">Adquisiciones de instrumentos y equipo de laboratorio</td>
                                            <td class="border border-gray-300 px-4 py-2">
                                                <div class="input-wrapper">
                                                    <input type="text" name="adquisicionesInstrumentosEquipoLaboratorio_s1" class="w-full partida-input" placeholder="0.00" value="$0.00" data-partida="adquisicionesInstrumentosEquipoLaboratorio" data-semestre="s1">
                                                </div>
                                            </td>
                                            <td class="border border-gray-300 px-4 py-2">
                                                <div class="input-wrapper">
                                                    <input type="text" name="adquisicionesInstrumentosEquipoLaboratorio_s2" class="w-full partida-input" placeholder="0.00" value="$0.00" data-partida="adquisicionesInstrumentosEquipoLaboratorio" data-semestre="s2">
                                                </div>
                                            </td>
                                            <td class="border border-gray-300 px-4 py-2">
                                                <div class="total-wrapper">
                                                    <input type="text" name="adquisicionesInstrumentosEquipoLaboratorio_total" class="w-full border-0 focus:ring-0 bg-gray-100 font-semibold total-input" readonly value="$0.00">
                                                </div>
                                            </td>
                                            <td class="border border-gray-300 px-4 py-2">
                                                <textarea name="adquisicionesInstrumentosEquipoLaboratorio_justificacion" class="w-full border border-gray-300 rounded p-2 text-sm justificacion-textarea" rows="2" placeholder="Descripción del bien o servicio y justificación"></textarea>
                                                <div class="word-counter" data-for="adquisicionesInstrumentosEquipoLaboratorio_justificacion">0/200 palabras</div>
                                            </td>
                                        </tr>
                                        
                                        <!-- Adquisición de equipos para planta piloto -->
                                        <tr>
                                            <td class="border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700">Adquisición de equipos para planta piloto</td>
                                            <td class="border border-gray-300 px-4 py-2">
                                                <div class="input-wrapper">
                                                    <input type="text" name="adquisicionEquiposPlantaPiloto_s1" class="w-full partida-input" placeholder="0.00" value="$0.00" data-partida="adquisicionEquiposPlantaPiloto" data-semestre="s1">
                                                </div>
                                            </td>
                                            <td class="border border-gray-300 px-4 py-2">
                                                <div class="input-wrapper">
                                                    <input type="text" name="adquisicionEquiposPlantaPiloto_s2" class="w-full partida-input" placeholder="0.00" value="$0.00" data-partida="adquisicionEquiposPlantaPiloto" data-semestre="s2">
                                                </div>
                                            </td>
                                            <td class="border border-gray-300 px-4 py-2">
                                                <div class="total-wrapper">
                                                    <input type="text" name="adquisicionEquiposPlantaPiloto_total" class="w-full border-0 focus:ring-0 bg-gray-100 font-semibold total-input" readonly value="$0.00">
                                                </div>
                                            </td>
                                            <td class="border border-gray-300 px-4 py-2">
                                                <textarea name="adquisicionEquiposPlantaPiloto_justificacion" class="w-full border border-gray-300 rounded p-2 text-sm justificacion-textarea" rows="2" placeholder="Descripción del bien o servicio y justificación"></textarea>
                                                <div class="word-counter" data-for="adquisicionEquiposPlantaPiloto_justificacion">0/200 palabras</div>
                                            </td>
                                        </tr>
                                        
                                        <!-- Total de gasto de inversión -->
                                        <tr class="bg-green-50">
                                            <td class="border border-gray-300 px-4 py-2 text-sm font-bold text-gray-800">Total de gasto de inversión</td>
                                            <td class="border border-gray-300 px-4 py-2">
                                                <div class="total-wrapper">
                                                    <input type="text" name="totalGastoInversion_s1" class="w-full border-0 focus:ring-0 bg-green-100 font-bold total-input" readonly value="$0.00">
                                                </div>
                                            </td>
                                            <td class="border border-gray-300 px-4 py-2">
                                                <div class="total-wrapper">
                                                    <input type="text" name="totalGastoInversion_s2" class="w-full border-0 focus:ring-0 bg-green-100 font-bold total-input" readonly value="$0.00">
                                                </div>
                                            </td>
                                            <td class="border border-gray-300 px-4 py-2">
                                                <div class="total-wrapper">
                                                    <input type="text" name="totalGastoInversion_total" class="w-full border-0 focus:ring-0 bg-green-200 font-bold total-input" readonly value="$0.00">
                                                </div>
                                            </td>
                                            <td class="border border-gray-300 px-4 py-2"></td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Totales -->
                <div class="space-y-4">
                    <!-- Total Gasto Corriente -->
                    <div class="flex items-center space-x-4">
                        <label class="w-1/2 text-lg font-semibold text-gray-800">Total gasto corriente:</label>
                        <div class="total-wrapper w-1/2">
                            <input type="text" id="totalGastoCorrienteResumen" name="totalGastoCorrienteResumen" class="w-full border border-gray-300 rounded-md shadow-sm p-2 bg-blue-50 text-gray-700 font-semibold total-input" value="$0.00" readonly>
                        </div>
                    </div>
                    
                    <!-- Total Gasto de Inversión -->
                    <div class="flex items-center space-x-4">
                        <label class="w-1/2 text-lg font-semibold text-gray-800">Total gasto de inversión:</label>
                        <div class="total-wrapper w-1/2">
                            <input type="text" id="totalGastoInversionResumen" name="totalGastoInversionResumen" class="w-full border border-gray-300 rounded-md shadow-sm p-2 bg-green-50 text-gray-700 font-semibold total-input" value="$0.00" readonly>
                        </div>
                    </div>
                    
                    <!-- Total Presupuesto del Proyecto -->
                    <div class="flex items-center space-x-4 pt-4 border-t border-gray-200">
                        <label class="w-1/2 text-lg font-semibold text-gray-800">Total presupuesto del proyecto:</label>
                        <div class="total-wrapper w-1/2">
                            <input type="text" id="totalPresupuesto" name="totalPresupuesto" class="w-full border border-gray-300 rounded-md shadow-sm p-2 bg-gray-100 text-gray-700 font-semibold total-input" value="$0.00" readonly>
                        </div>
                    </div>
                </div>

                <!-- Botones de acción -->
                <div class="flex flex-col-reverse gap-4 pt-8 border-t border-gray-200 sm:flex-row sm:justify-end">
                        <button type="button" onclick="guardarBorrador('formPagina8', 'pagina8', this)"
                                class="bg-gray-500 hover:bg-gray-600 text-white font-medium py-2 px-6 rounded-lg transition duration-200 flex items-center justify-center">
                            <i class="fas fa-save mr-2"></i>Guardar borrador
                        </button>
                        <div class="flex gap-4">
                            <button type="button"
                                    class="bg-gray-600 hover:bg-gray-700 text-white font-medium py-2 px-6 rounded-lg transition duration-200 flex items-center justify-center"
                                    onclick="location.href='/proyectos/pages/responsableDeproyecto/registroProyecto/registroProyecto7.jsp'">
                                <i class="fas fa-arrow-left mr-2"></i>Anterior
                            </button>
                            <button type="button"
                                    class="bg-[#7A1737] hover:bg-[#5c0f2a] text-white font-medium py-2 px-6 rounded-lg transition duration-200 flex items-center justify-center"
                                    id="btnSiguiente">
                                Siguiente <i class="fas fa-arrow-right ml-2"></i>
                            </button>
                        </div>
                    </div>
            </form>
        </div>
    </div>

    <script>
        // ========== CONFIGURACIÓN INICIAL ==========
        document.addEventListener('DOMContentLoaded', function() {
            console.log('Inicializando formulario...');
            setupCalculos();
            setupContadoresPalabras();
            setupFormatoMoneda();
            cargarBorrador();
            setupNavegacion();
        });

        // ========== FORMATO DE MONEDA ==========
        function formatearMoneda(valor) {
            // Convertir a número y validar
            const numero = parseFloat(valor) || 0;
            
            // Formatear con separador de miles y 2 decimales
            return '$' + numero.toLocaleString('es-MX', {
                minimumFractionDigits: 2,
                maximumFractionDigits: 2
            });
        }

        function extraerNumero(valorFormateado) {
            // Remover el símbolo $ y las comas, convertir a número
            return parseFloat(valorFormateado.replace(/[$,]/g, '')) || 0;
        }

        function setupFormatoMoneda() {
            const inputs = document.querySelectorAll('.partida-input');
            
            inputs.forEach(input => {
                // Formatear al perder el foco
                input.addEventListener('blur', function() {
                    const numero = extraerNumero(this.value);
                    this.value = formatearMoneda(numero);
                });

                // Limpiar formato al obtener el foco para facilitar edición
                input.addEventListener('focus', function() {
                    const numero = extraerNumero(this.value);
                    if (numero === 0) {
                        this.value = '';
                    } else {
                        this.value = numero.toFixed(2);
                    }
                });

                // Validar que solo se ingresen números
                input.addEventListener('input', function(e) {
                    let valor = this.value;
                    // Permitir solo números, punto decimal y comas
                    valor = valor.replace(/[^0-9.]/g, '');
                    // Permitir solo un punto decimal
                    const partes = valor.split('.');
                    if (partes.length > 2) {
                        valor = partes[0] + '.' + partes.slice(1).join('');
                    }
                    this.value = valor;
                });
            });
        }

        // ========== CÁLCULOS AUTOMÁTICOS ==========
        function setupCalculos() {
            const inputs = document.querySelectorAll('.partida-input');
            inputs.forEach(input => {
                input.addEventListener('input', calcularTodo);
                input.addEventListener('blur', calcularTodo);
            });
        }

        function calcularTodo() {
            const partidasCorrientes = [
                'pasajesViaticos', 'gastosOperacion', 
                'gastosTrabajoCampo', 'estudiantesIncorporados'
            ];
            
            const partidasInversion = [
                'adquisicionesInstrumentosEquipoLaboratorio', 
                'adquisicionEquiposPlantaPiloto'
            ];

            let totalGeneral = 0;
            let totalCorrienteS1 = 0;
            let totalCorrienteS2 = 0;
            let totalCorriente = 0;
            let totalInversionS1 = 0;
            let totalInversionS2 = 0;
            let totalInversion = 0;

            // Calcular partidas de gasto corriente
            partidasCorrientes.forEach(partida => {
                const inputS1 = document.querySelector('[name="' + partida + '_s1"]');
                const inputS2 = document.querySelector('[name="' + partida + '_s2"]');
                const inputTotal = document.querySelector('[name="' + partida + '_total"]');
                
                const s1 = extraerNumero(inputS1.value);
                const s2 = extraerNumero(inputS2.value);
                const total = s1 + s2;
                
                inputTotal.value = formatearMoneda(total);
                totalCorrienteS1 += s1;
                totalCorrienteS2 += s2;
                totalCorriente += total;
                totalGeneral += total;
            });

            // Calcular partidas de gasto de inversión
            partidasInversion.forEach(partida => {
                const inputS1 = document.querySelector('[name="' + partida + '_s1"]');
                const inputS2 = document.querySelector('[name="' + partida + '_s2"]');
                const inputTotal = document.querySelector('[name="' + partida + '_total"]');
                
                const s1 = extraerNumero(inputS1.value);
                const s2 = extraerNumero(inputS2.value);
                const total = s1 + s2;
                
                inputTotal.value = formatearMoneda(total);
                totalInversionS1 += s1;
                totalInversionS2 += s2;
                totalInversion += total;
                totalGeneral += total;
            });

            // Actualizar total de gasto corriente
            document.querySelector('[name="totalGastoCorriente_s1"]').value = formatearMoneda(totalCorrienteS1);
            document.querySelector('[name="totalGastoCorriente_s2"]').value = formatearMoneda(totalCorrienteS2);
            document.querySelector('[name="totalGastoCorriente_total"]').value = formatearMoneda(totalCorriente);
            
            // Actualizar total de gasto de inversión
            document.querySelector('[name="totalGastoInversion_s1"]').value = formatearMoneda(totalInversionS1);
            document.querySelector('[name="totalGastoInversion_s2"]').value = formatearMoneda(totalInversionS2);
            document.querySelector('[name="totalGastoInversion_total"]').value = formatearMoneda(totalInversion);

            // Actualizar resúmenes
            document.getElementById('totalGastoCorrienteResumen').value = formatearMoneda(totalCorriente);
            document.getElementById('totalGastoInversionResumen').value = formatearMoneda(totalInversion);
            document.getElementById('totalPresupuesto').value = formatearMoneda(totalGeneral);
            
            // Actualizar indicador de límite de gastos de campo
            actualizarIndicadorLimiteGastosCampo();
            
            // Actualizar indicador de límite global (Ciencia Básica vs Aplicada)
            actualizarIndicadorGlobal();
        }

        // ========== VALIDACIÓN DE LÍMITE GLOBAL ==========
        function actualizarIndicadorGlobal() {
            const tipo = document.getElementById('tipoProyecto').value;
            const total = extraerNumero(document.getElementById('totalPresupuesto').value);
            const limite = tipo === 'ciencia_basica' ? 300000 : 500000;
            const porcentaje = (total / limite) * 100;
            
            const barra = document.getElementById('barraProgresoGlobal');
            const texto = document.getElementById('textoLimiteGlobal');
            const contenedor = document.getElementById('indicadorLimiteGlobal');
            const inputTotal = document.getElementById('totalPresupuesto');

            if (!barra || !texto || !contenedor) return;

            const nombreTipo = tipo === 'ciencia_basica' ? 'Ciencia Básica' : 'Ciencia Aplicada';
            texto.textContent = formatearMoneda(total) + ' / ' + formatearMoneda(limite) + ' (' + porcentaje.toFixed(1) + '%) - ' + nombreTipo;
            barra.style.width = Math.min(porcentaje, 100) + '%';

            // Reset classes
            contenedor.classList.remove('bg-red-50', 'border-red-200', 'bg-green-50', 'border-green-200', 'bg-yellow-50', 'border-yellow-200', 'bg-gray-50');
            barra.classList.remove('bg-red-600', 'bg-green-600', 'bg-yellow-500', 'bg-gray-600');
            inputTotal.classList.remove('text-red-600', 'font-bold', 'bg-red-50');

            if (total > limite) {
                // Excedido (Rojo)
                contenedor.classList.add('bg-red-50', 'border-red-200');
                barra.classList.add('bg-red-600');
                texto.classList.add('text-red-700', 'font-bold');
                inputTotal.classList.add('text-red-600', 'font-bold', 'bg-red-50');
            } else if (porcentaje > 90) {
                // Advertencia (Amarillo)
                contenedor.classList.add('bg-yellow-50', 'border-yellow-200');
                barra.classList.add('bg-yellow-500');
                texto.classList.remove('text-red-700', 'font-bold');
                texto.classList.add('text-yellow-800');
            } else {
                // OK (Verde)
                contenedor.classList.add('bg-green-50', 'border-green-200');
                barra.classList.add('bg-green-600');
                texto.classList.remove('text-red-700', 'font-bold', 'text-yellow-800');
                texto.classList.add('text-green-800');
            }
        }

        // ========== VALIDACIÓN DE LÍMITE DE GASTOS DE CAMPO ==========
        function validarLimiteGastosCampo() {
            const totalPresupuesto = extraerNumero(document.getElementById('totalPresupuesto').value);
            const limitePermitido = totalPresupuesto * 0.10; // 10%
            
            const gastosCampoS1 = extraerNumero(document.querySelector('[name="gastosTrabajoCampo_s1"]').value);
            const gastosCampoS2 = extraerNumero(document.querySelector('[name="gastosTrabajoCampo_s2"]').value);
            const totalGastosCampo = gastosCampoS1 + gastosCampoS2;
            
            return {
                valido: totalGastosCampo <= limitePermitido,
                totalGastosCampo: totalGastosCampo,
                limitePermitido: limitePermitido,
                porcentaje: totalPresupuesto > 0 ? (totalGastosCampo / totalPresupuesto * 100) : 0
            };
        }

        function actualizarIndicadorLimiteGastosCampo() {
            const validacion = validarLimiteGastosCampo();
            const limiteTexto = document.getElementById('limiteTexto');
            const actualTexto = document.getElementById('actualTexto');
            const indicador = document.getElementById('indicadorLimiteGastosCampo');
            
            if (!limiteTexto || !actualTexto || !indicador) return;
            
            limiteTexto.textContent = 'Máximo permitido: ' + formatearMoneda(validacion.limitePermitido) + ' (10% del presupuesto total)';
            actualTexto.textContent = 'Actual: ' + formatearMoneda(validacion.totalGastosCampo) + ' (' + validacion.porcentaje.toFixed(2) + '%)';
            
            // Cambiar color según el porcentaje
            actualTexto.classList.remove('text-green-600', 'text-yellow-600', 'text-red-600', 'font-semibold');
            
            if (validacion.porcentaje > 10) {
                // Excede el límite
                actualTexto.classList.add('text-red-600', 'font-semibold');
                indicador.classList.remove('bg-gray-50', 'bg-yellow-50');
                indicador.classList.add('bg-red-50');
            } else if (validacion.porcentaje >= 8) {
                // Cerca del límite (8-10%)
                actualTexto.classList.add('text-yellow-600', 'font-semibold');
                indicador.classList.remove('bg-gray-50', 'bg-red-50');
                indicador.classList.add('bg-yellow-50');
            } else {
                // Dentro del límite
                actualTexto.classList.add('text-green-600');
                indicador.classList.remove('bg-yellow-50', 'bg-red-50');
                indicador.classList.add('bg-gray-50');
            }
        }

        // ========== CONTADOR DE PALABRAS ==========
        function setupContadoresPalabras() {
            const textareas = document.querySelectorAll('.justificacion-textarea');
            textareas.forEach(textarea => {
                actualizarContador(textarea);
                textarea.addEventListener('input', function() {
                    actualizarContador(this);
                });
            });
        }

        function actualizarContador(textarea) {
            const texto = textarea.value.trim();
            const palabras = texto === '' ? 0 : texto.split(/\s+/).length;
            const maxPalabras = 200;
            
            const counter = document.querySelector('.word-counter[data-for="' + textarea.name + '"]');
            if (counter) {
                counter.textContent = palabras + '/' + maxPalabras + ' palabras';
                
                if (palabras > maxPalabras) {
                    counter.classList.add('warning');
                    textarea.classList.add('limit-reached');
                } else {
                    counter.classList.remove('warning');
                    textarea.classList.remove('limit-reached');
                }
            }
        }

        // ========== GUARDAR Y CARGAR ==========
        function guardarBorrador(formId, pageKey, targetBtn) {
            // 1. Validar Límite Global (Ciencia Básica vs Aplicada)
            const tipo = document.getElementById('tipoProyecto').value;
            const total = extraerNumero(document.getElementById('totalPresupuesto').value);
            const limite = tipo === 'ciencia_basica' ? 300000 : 500000;
            
            if (total > limite) {
                mostrarMensaje('No se puede guardar: El presupuesto (' + formatearMoneda(total) + ') excede el límite de ' + formatearMoneda(limite), 'error', targetBtn);
                const indicador = document.getElementById('indicadorLimiteGlobal');
                if(indicador) indicador.scrollIntoView({behavior: 'smooth', block: 'center'});
                return false;
            }

            // 2. Validar Límite Gastos de Campo
            const validacion = validarLimiteGastosCampo();
            
            if (!validacion.valido && validacion.totalGastosCampo > 0) {
                const mensaje = 'Los gastos de trabajo de campo (' + formatearMoneda(validacion.totalGastosCampo) + ') ' +
                               'exceden el 10% del presupuesto total.\n' +
                               'Máximo permitido: ' + formatearMoneda(validacion.limitePermitido) + ' ' +
                               '(Actualmente: ' + validacion.porcentaje.toFixed(2) + '%)';
                
                mostrarMensaje(mensaje, 'error', targetBtn);
                
                // Resaltar los campos problemáticos
                const campo1 = document.getElementById('gastosTrabajoCampo_s1');
                const campo2 = document.getElementById('gastosTrabajoCampo_s2');
                
                campo1.classList.add('border-red-500', 'bg-red-50');
                campo2.classList.add('border-red-500', 'bg-red-50');
                
                // Remover el resaltado después de 5 segundos
                setTimeout(function() {
                    campo1.classList.remove('border-red-500', 'bg-red-50');
                    campo2.classList.remove('border-red-500', 'bg-red-50');
                }, 5000);
                
                return false; // No guardar
            }
            
            // Definir las partidas con sus nombres y campos asociados
            const partidasConfig = [
                { 
                    nombre: 'Pasajes y viáticos',
                    campo: 'pasajesViaticos',
                    justificacionCampo: 'pasajesViaticos_justificacion'
                },
                { 
                    nombre: 'Gastos de operación',
                    campo: 'gastosOperacion',
                    justificacionCampo: 'gastosOperacion_justificacion'
                },
                { 
                    nombre: 'Gastos de trabajo de campo',
                    campo: 'gastosTrabajoCampo',
                    justificacionCampo: 'gastosTrabajoCampo_justificacion'
                },
                { 
                    nombre: 'Estudiantes incorporados',
                    campo: 'estudiantesIncorporados',
                    justificacionCampo: 'estudiantesIncorporados_justificacion'
                },
                { 
                    nombre: 'Adquisiciones de instrumentos y equipo de laboratorio',
                    campo: 'adquisicionesInstrumentosEquipoLaboratorio',
                    justificacionCampo: 'adquisicionesInstrumentosEquipoLaboratorio_justificacion'
                },
                { 
                    nombre: 'Adquisición de equipos para planta piloto',
                    campo: 'adquisicionEquiposPlantaPiloto',
                    justificacionCampo: 'adquisicionEquiposPlantaPiloto_justificacion'
                }
            ];
            
            // Recopilar partidas en un array estructurado
            const partidas = [];
            
            partidasConfig.forEach(config => {
                const inputS1 = document.querySelector('[name="' + config.campo + '_s1"]');
                const inputS2 = document.querySelector('[name="' + config.campo + '_s2"]');
                const justificacionEl = document.querySelector('[name="' + config.justificacionCampo + '"]');
                
                const montoS1 = inputS1 ? extraerNumero(inputS1.value) : 0;
                const montoS2 = inputS2 ? extraerNumero(inputS2.value) : 0;
                const justificacion = justificacionEl ? justificacionEl.value : '';
                
                // Solo agregar si tiene al menos un monto o justificación
                if (montoS1 > 0 || montoS2 > 0 || justificacion.trim() !== '') {
                    partidas.push({
                        nombre: config.nombre,
                        justificacion: justificacion,
                        montos: {
                            semestre1: montoS1,
                            semestre2: montoS2
                        }
                    });
                }
            });
            
            const jsonData = {
                partida: {
                    partidas: partidas
                }
            };
            
            localStorage.setItem('proyecto_borrador_pagina8', JSON.stringify(jsonData));
            mostrarMensaje('Borrador guardado exitosamente', 'success', targetBtn);

            // Notificar éxito para habilitar navegación
            if (window.notificarGuardadoExitoso) {
                window.notificarGuardadoExitoso();
            }
        }

        function cargarBorrador() {
            const saved = localStorage.getItem('proyecto_borrador_pagina8');
            if (saved) {
                const datos = JSON.parse(saved);
                
                if (datos.partida && datos.partida.partidas) {
                    // Mapeo de nombres de partidas a campos del formulario
                    const partidasMap = {
                        'Pasajes y viáticos': {
                            campo: 'pasajesViaticos',
                            justificacionCampo: 'pasajesViaticos_justificacion'
                        },
                        'Gastos de operación': {
                            campo: 'gastosOperacion',
                            justificacionCampo: 'gastosOperacion_justificacion'
                        },
                        'Gastos de trabajo de campo': {
                            campo: 'gastosTrabajoCampo',
                            justificacionCampo: 'gastosTrabajoCampo_justificacion'
                        },
                        'Estudiantes incorporados': {
                            campo: 'estudiantesIncorporados',
                            justificacionCampo: 'estudiantesIncorporados_justificacion'
                        },
                        'Adquisiciones de instrumentos y equipo de laboratorio': {
                            campo: 'adquisicionesInstrumentosEquipoLaboratorio',
                            justificacionCampo: 'adquisicionesInstrumentosEquipoLaboratorio_justificacion'
                        },
                        'Adquisición de equipos para planta piloto': {
                            campo: 'adquisicionEquiposPlantaPiloto',
                            justificacionCampo: 'adquisicionEquiposPlantaPiloto_justificacion'
                        }
                    };
                    
                    // Restaurar datos de cada partida
                    datos.partida.partidas.forEach(partida => {
                        const config = partidasMap[partida.nombre];
                        if (config) {
                            // Restaurar montos
                            const inputS1 = document.querySelector('[name="' + config.campo + '_s1"]');
                            const inputS2 = document.querySelector('[name="' + config.campo + '_s2"]');
                            
                            if (inputS1) inputS1.value = formatearMoneda(partida.montos.semestre1 || 0);
                            if (inputS2) inputS2.value = formatearMoneda(partida.montos.semestre2 || 0);
                            
                            // Restaurar justificación
                            const justificacionEl = document.querySelector('[name="' + config.justificacionCampo + '"]');
                            if (justificacionEl) justificacionEl.value = partida.justificacion || '';
                        }
                    });
                    
                    // Recalcular totales
                    calcularTodo();
                    setupContadoresPalabras();
                }
            }
        }

        // ========== MENSAJES ==========
        function mostrarMensaje(texto, tipo, targetEl) {
            const mensajesExistentes = document.querySelectorAll('.mensaje-temporal');
            mensajesExistentes.forEach(function(msg) {
                msg.remove();
            });
            
            const div = document.createElement('div');
            var clases = 'font-medium mensaje-temporal ';
            
            if (tipo === 'success') {
                clases += 'bg-green-100 text-green-800 border-green-200';
            } else if (tipo === 'error') {
                clases += 'bg-red-100 text-red-800 border-red-200';
            } else {
                clases += 'bg-blue-100 text-blue-800 border-blue-200';
            }
            
            div.className = clases + ' p-4 rounded-md shadow-lg z-50 border';
            div.textContent = texto;

            if (targetEl && targetEl.getBoundingClientRect) {
                div.style.position = 'absolute';
                div.style.visibility = 'hidden';
                document.body.appendChild(div);

                const rect = targetEl.getBoundingClientRect();
                const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
                const scrollLeft = window.pageXOffset || document.documentElement.scrollLeft;

                const mw = div.offsetWidth;
                const mh = div.offsetHeight;

                let left = rect.left + scrollLeft + (rect.width - mw) / 2;
                let top = rect.top + scrollTop - mh - 8;
                if (top < (window.pageYOffset || document.documentElement.scrollTop)) {
                    top = rect.top + scrollTop + rect.height + 8;
                }

                const maxLeft = (window.pageXOffset || document.documentElement.scrollLeft) + document.documentElement.clientWidth - mw - 8;
                if (left < 8) left = 8;
                if (left > maxLeft) left = maxLeft;

                div.style.left = left + 'px';
                div.style.top = top + 'px';
                div.style.visibility = 'visible';
            } else {
                div.style.position = 'fixed';
                div.style.top = '1rem';
                div.style.right = '1rem';
                document.body.appendChild(div);
            }
            
            setTimeout(function() {
                if (div.parentNode) {
                    div.parentNode.removeChild(div);
                }
            }, 4000);
        }

        // ========== CONTROL DE NAVEGACIÓN ==========
        function setupNavegacion() {
            const KEY = 'proyecto_borrador_pagina8_saved';
            const form = document.getElementById('formPagina8');
            const buttons = Array.from(document.querySelectorAll('button'));
            const guardarBtn = buttons.find(b => (b.getAttribute('onclick')||'').includes('guardarBorrador') || /guardar borrador/i.test(b.textContent));
            const siguienteBtn = document.getElementById('btnSiguiente') || buttons.find(b => /siguiente/i.test(b.textContent));

            function setDisabled(btn, disabled){
                if(!btn) return;
                // No usar disabled real para que los eventos sigan funcionando
                btn.setAttribute('aria-disabled', disabled ? 'true' : 'false');
                btn.setAttribute('data-disabled', disabled ? 'true' : 'false');
                if(disabled) {
                    btn.classList.add('opacity-60', 'cursor-not-allowed');
                    btn.classList.remove('hover:bg-[#5c0f2a]');
                } else {
                    btn.classList.remove('opacity-60', 'cursor-not-allowed');
                    btn.classList.add('hover:bg-[#5c0f2a]');
                }
            }

            if(!guardarBtn || !siguienteBtn){
                console.warn('No se encontraron botones Guardar/Siguiente en página8');
            }

            let saved = localStorage.getItem(KEY) === '1';
            setDisabled(siguienteBtn, !saved);

            // Exponer función para marcar como guardado desde guardarBorrador()
            window.notificarGuardadoExitoso = function() {
                localStorage.setItem(KEY,'1');
                saved = true;
                setDisabled(siguienteBtn, false);
                console.log('Borrador pagina8 guardado -> Siguiente habilitado');
            };

            // Agregar evento al botón siguiente para manejar navegación y advertencias
            if(siguienteBtn){
                siguienteBtn.addEventListener('click', function(e){
                    e.preventDefault();
                    e.stopPropagation();
                    
                    // Verificar si está "deshabilitado" (visualmente)
                    if(siguienteBtn.getAttribute('data-disabled') === 'true'){
                        mostrarMensaje('Debe guardar el borrador antes de continuar', 'error', siguienteBtn);
                        return false;
                    }
                    
                    // Si está habilitado, navegar a la siguiente página
                    window.location.href = '/proyectos/pages/responsableDeproyecto/registroProyecto/registroProyecto9.jsp';
                });
            }

            if(form){
                const inputs = Array.from(form.querySelectorAll('input, textarea, select'));
                const onChange = function(){
                    if(saved){
                        saved = false;
                        localStorage.setItem(KEY,'0');
                        setDisabled(siguienteBtn, true);
                        console.log('Formulario pagina8 modificado después de guardar: Siguiente bloqueado');
                    }
                };
                inputs.forEach(el => el.addEventListener('input', onChange));
                inputs.forEach(el => el.addEventListener('change', onChange));

                // beforeunload
                window.addEventListener('beforeunload', function(e){
                    try{
                        if(!saved){
                            var msg = 'Tiene cambios sin guardar. ¿Desea salir sin guardar?';
                            e.preventDefault(); e.returnValue = msg; return msg;
                        }
                    }catch(err){ return undefined; }
                });
            }
        }

        //lanzar una alerta si se excede el limite de la ciencia seleccionada
        document.getElementById('tipoProyecto').addEventListener('change', function() {
            // Recalcular validaciones visuales al cambiar el tipo
            calcularTodo();
            
            // Mostrar notificación toast informativa
            const tipo = this.value;
            const limite = tipo === 'ciencia_basica' ? 300000 : 500000;
            const nombre = tipo === 'ciencia_basica' ? 'Ciencia Básica y de Frontera' : 'Ciencia Aplicada';
            
            // Verificar si ya excede con el nuevo límite
            const total = extraerNumero(document.getElementById('totalPresupuesto').value);
            if (total > limite) {
                mostrarMensaje('Al cambiar a ' + nombre + ', el presupuesto actual excede el límite de ' + formatearMoneda(limite), 'error', this);
            } else {
                mostrarMensaje('Límite actualizado para ' + nombre + ': ' + formatearMoneda(limite), 'info', this);
            }
        });
    </script>
    <%@ include file="/footer.jsp" %>
</body>
</html>