<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.UUID" %>
<%@ page import="java.net.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.security.MessageDigest" %>
<%@ page import="java.nio.charset.StandardCharsets" %>

<%!
    private static final String APP_SALT = "C0v31cYd3T_Pr0y3ct0_2025_#Secreto!";

    public String hashPassword(String password) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            String input = APP_SALT + password;
            byte[] encodedhash = digest.digest(input.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : encodedhash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
%>

<%
    request.setCharacterEncoding("UTF-8");
    System.out.println(">>> [EVALUADOR] Iniciando registro de evaluador...");

    // INCLUIR CONEXIÓN Y CORREO DESDE WEB-INF
    %><%@ include file="/WEB-INF/conexion.jsp" %><%
    %><%@ include file="/WEB-INF/correo.jsp" %><%

    String email = request.getParameter("email");
    String password = request.getParameter("password");

    System.out.println(">>> [EVALUADOR] Email recibido: " + email);

    String passwordHashed = hashPassword(password);
    String token = UUID.randomUUID().toString();
    boolean registroExitoso = false;
    String errorMsg = "";
    int idEvaluadorGenerado = -1;

    PreparedStatement ps = null;

    try {
        // Verificar si el correo ya está registrado
        System.out.println(">>> [EVALUADOR] Verificando si el correo ya existe...");
        String sqlCheck = "SELECT id_usuario FROM usuarios WHERE correo_electronico = ?";
        PreparedStatement psCheck = conn.prepareStatement(sqlCheck);
        psCheck.setString(1, email);
        ResultSet rsCheck = psCheck.executeQuery();

        if (rsCheck.next()) {
            System.out.println(">>> [EVALUADOR] El correo YA está registrado");
            rsCheck.close();
            psCheck.close();
            if (conn != null) conn.close();
            // Pasar error como parámetro en la URL
            response.sendRedirect("index.jsp?error=" + URLEncoder.encode("El correo electrónico ya está registrado", "UTF-8"));
            return;
        }

        rsCheck.close();
        psCheck.close();

        // Generar datos temporales para campos requeridos
        // Estos datos se completarán cuando el evaluador llene su perfil
        String nombreTemporal = "EVALUADOR";
        String primerApellidoTemporal = "USUARIO";
        String segundoApellidoTemporal = "";
        // Generar RFC único de 13 caracteres (límite de la BD)
        // Formato: EVAL + timestamp corto (8 dígitos) + random (1 dígito)
        long timestampCorto = System.currentTimeMillis() % 100000000; // Últimos 8 dígitos
        int random = new java.util.Random().nextInt(10); // 0-9
        String rfcTemporal = "EVAL" + String.format("%08d", timestampCorto) + random; // Total: 13 caracteres
        
        System.out.println(">>> [EVALUADOR] RFC temporal generado (13 chars): " + rfcTemporal);

        // INSERT de evaluador con token de activación
        // estado = 1 (inactivo), tipousuario = 3 (evaluador)
        System.out.println(">>> [EVALUADOR] Insertando nuevo evaluador en BD...");
        String sql = "INSERT INTO usuarios (nombre, primer_apellido, segundo_apellido, rfc, correo_electronico, contrasena, tipousuario, token_activacion, estado) VALUES (?, ?, ?, ?, ?, ?, 3, ?, 1)";
        ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);

        ps.setString(1, nombreTemporal);
        ps.setString(2, primerApellidoTemporal);
        ps.setString(3, segundoApellidoTemporal);
        ps.setString(4, rfcTemporal);
        ps.setString(5, email);
        ps.setString(6, passwordHashed);
        ps.setString(7, token);

        int filas = ps.executeUpdate();
        System.out.println(">>> [EVALUADOR] Filas insertadas: " + filas);
        
        if (filas > 0) {
            registroExitoso = true;
            ResultSet generatedKeys = ps.getGeneratedKeys();
            if (generatedKeys.next()) {
                idEvaluadorGenerado = generatedKeys.getInt(1);
            }
            generatedKeys.close();
            System.out.println(">>> [EVALUADOR] Evaluador registrado con ID: " + idEvaluadorGenerado);
            System.out.println(">>> [EVALUADOR] Token generado: " + token);
        }

    } catch (SQLException e) {
        errorMsg = e.getMessage();
        System.out.println(">>> [EVALUADOR] Error SQL en BD: " + errorMsg);
        System.out.println(">>> [EVALUADOR] SQLState: " + e.getSQLState() + ", ErrorCode: " + e.getErrorCode());
        e.printStackTrace();

        // Escribir en log
        try {
            String logsDirPath = application.getRealPath("/WEB-INF/logs");
            if (logsDirPath == null) logsDirPath = application.getRealPath("/") + "WEB-INF/logs";
            File logsDir = new File(logsDirPath);
            if (!logsDir.exists()) logsDir.mkdirs();
            String logPath = logsDirPath + File.separator + "registro_evaluador.log";
            FileWriter fw = new FileWriter(logPath, true);
            fw.write(new java.util.Date() + " - email=" + email + " - " + errorMsg + " - " + e.toString() + System.lineSeparator());
            StringWriter sw = new StringWriter();
            e.printStackTrace(new PrintWriter(sw));
            fw.write(sw.toString() + System.lineSeparator());
            fw.close();
        } catch (Exception ioe) {
            System.err.println("[registro_evaluador] No se pudo escribir log: " + ioe.getMessage());
        }
    } catch (Exception e) {
        errorMsg = e.getMessage();
        System.out.println(">>> [EVALUADOR] Error general: " + errorMsg);
        e.printStackTrace();
    } finally {
        if(ps != null) try { ps.close(); } catch(Exception e){}
        if(conn != null) try { conn.close(); } catch(Exception e){}
    }

    if (registroExitoso) {
        try {
            // Construir enlace de activación
            String baseURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath();
            String linkActivacion = baseURL + "/activar_cuenta.jsp?t=" + token;

            System.out.println(">>> [EVALUADOR] Enlace de activación: " + linkActivacion);

            String asunto = URLEncoder.encode("Activación de Cuenta - Evaluador COVEICYDET", "UTF-8");
            String mensajeCuerpo = "Estimado evaluador. Gracias por registrarse en el Sistema COVEICYDET. " +
                                   "Para activar su cuenta y proceder con la validación y cotejo de documentos, " +
                                   "haga clic en el siguiente enlace: " + linkActivacion +
                                   " Si usted no solicitó este registro, ignore este mensaje.";
            String mensajeEncoded = URLEncoder.encode(mensajeCuerpo, "UTF-8");

            // USA mailApiUrl DEL INCLUDE
            String apiURL = mailApiUrl + "?DESTINATARIO=" + email +
                            "&ASUNTO=" + asunto +
                            "&MENSAJE=" + mensajeEncoded;

            System.out.println(">>> [EVALUADOR] Conectando a API Correo...");
            System.out.println(">>> [EVALUADOR] URL API: " + apiURL);

            URL url = new URL(apiURL);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("GET");
            connection.setRequestProperty("User-Agent", "Mozilla/5.0");
            connection.setConnectTimeout(10000);
            connection.setReadTimeout(10000);
            connection.connect();

            int responseCode = connection.getResponseCode();
            System.out.println(">>> [EVALUADOR] Respuesta API Correo (Código): " + responseCode);

            if (responseCode == 200) {
                BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
                String inputLine;
                StringBuilder content = new StringBuilder();
                while ((inputLine = in.readLine()) != null) {
                    content.append(inputLine);
                }
                in.close();
                System.out.println(">>> [EVALUADOR] Respuesta API Cuerpo: " + content.toString());

                // Redirigir a página de éxito
                response.sendRedirect("registroExitoso.jsp?registrado=1");
            } else {
                System.out.println(">>> [EVALUADOR] Error enviando correo. Código: " + responseCode);
                // El registro fue exitoso, pero el correo falló - redirigir a éxito con advertencia
                response.sendRedirect("registroExitoso.jsp?registrado=1&mail_error=1");
            }

        } catch (Exception e) {
            System.out.println(">>> [EVALUADOR] ERROR ENVIANDO CORREO: " + e.getMessage());
            e.printStackTrace();
            // El registro fue exitoso, pero el correo falló - redirigir a éxito con advertencia
            response.sendRedirect("registroExitoso.jsp?registrado=1&mail_error=1");
        }
    } else {
        System.out.println(">>> [EVALUADOR] Registro fallido. Error: " + errorMsg);
        // Pasar error como parámetro en la URL
        response.sendRedirect("index.jsp?error=" + URLEncoder.encode("Error al registrar: " + errorMsg, "UTF-8"));
    }
%>
