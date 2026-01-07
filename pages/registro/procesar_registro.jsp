<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.UUID" %>
<%@ page import="java.net.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.security.MessageDigest" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="java.util.Base64" %>
<%@ page import="java.util.Properties" %>
<%@ page import="java.io.InputStream" %>

<%!
    // --- LÓGICA DE SEGURIDAD ---
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
    
    // LOG: Inicio del proceso
    System.out.println(">>> Iniciando registro de usuario...");

    String nombre = request.getParameter("nombreCompleto");
    String appPaterno = request.getParameter("primerApellido");
    String appMaterno = request.getParameter("segundoApellido");
    String rfc = request.getParameter("rfc");
    String email = request.getParameter("email");
    String password = request.getParameter("password"); 
    
    String passwordHashed = hashPassword(password);
    String token = UUID.randomUUID().toString();
    boolean registroExitoso = false;
    String errorMsg = "";
    int idUsuarioGenerado = -1;
    
    Connection conn = null;
    PreparedStatement ps = null;

    try {
        Class.forName("org.postgresql.Driver");
        String dbURL = "jdbc:postgresql://localhost:5432/proyectos";
        String dbUser = "dbusr25";
        String dbPass = "mxToro24000Chocolate";
        
        conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

        String sqlCheck = "SELECT id_usuario FROM usuarios WHERE rfc = ?";
        PreparedStatement psCheck = conn.prepareStatement(sqlCheck);
        psCheck.setString(1, rfc);
        ResultSet rsCheck = psCheck.executeQuery();

        if (rsCheck.next()) {
            // El RFC ya existe
            rsCheck.close();
            psCheck.close();
            conn.close();
            
            // Redirigir al login con el mensaje específico
            response.sendRedirect(request.getContextPath() + "/pages/login/login.jsp?msg=rfc_registrado");
            return; // Detener la ejecución del script aquí
        }
        
        // Cerrar recursos de la verificación antes de seguir
        rsCheck.close();
        psCheck.close();
        // ---------------------------------------------

        // PREPARAR QUERY: Agregamos el campo 'comprobantevigencia' aunque sea null al inicio
        // Y muy importante: RETURN_GENERATED_KEYS para obtener el ID
        String sql = "INSERT INTO usuarios (nombre, primer_apellido, segundo_apellido, rfc, correo_electronico, contrasena, tipousuario, token_sesion, estado, token_activacion, comprobantevigencia) VALUES (?, ?, ?, ?, ?, ?, 2, ?, 1, ?, ?)";

        // Usamos RETURN_GENERATED_KEYS
        ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
        
        ps.setString(1, nombre);
        ps.setString(2, appPaterno);
        ps.setString(3, appMaterno);
        ps.setString(4, rfc);
        ps.setString(5, email);
        ps.setString(6, passwordHashed); 
        ps.setString(7, null); // token_sesion
        ps.setString(8, token); // token_activacion
        ps.setString(9, null); // comprobantevigencia

        
        int filas = ps.executeUpdate();
        if (filas > 0) {
            registroExitoso = true;
            ResultSet generatedKeys = ps.getGeneratedKeys();
            if (generatedKeys.next()) {
                idUsuarioGenerado = generatedKeys.getInt(1);
            }
            generatedKeys.close();
        }
        

        String pdfBase64 = request.getParameter("pdfBase64");

        if (idUsuarioGenerado != -1 && pdfBase64 != null && !pdfBase64.isEmpty()) {
            try {
                // Definir ruta: /uploads/{ID}/
                String appPath = request.getServletContext().getRealPath("/");
                String savePath = appPath + "uploads" + File.separator + idUsuarioGenerado;

                // Crear carpetas
                File fileDir = new File(savePath);
                if (!fileDir.exists()) fileDir.mkdirs();

                // Limpiar el string Base64 (quitar "data:application/pdf;base64,")
                String base64Data = pdfBase64.substring(pdfBase64.indexOf(",") + 1);
                byte[] fileBytes = Base64.getDecoder().decode(base64Data);

                // Guardar archivo físico
                String nombreArchivo = "vigencia.pdf";
                File file = new File(savePath + File.separator + nombreArchivo);
                FileOutputStream output = new FileOutputStream(file);
                output.write(fileBytes);
                output.close();

                // 3. ACTUALIZAR LA BD CON LA RUTA
                // Guardamos la ruta relativa para usarla fácil en HTML después
                String rutaRelativa = "uploads/" + idUsuarioGenerado + "/" + nombreArchivo;

                String sqlUpdate = "UPDATE usuarios SET comprobantevigencia = ? WHERE id_usuario = ?";
                PreparedStatement psUpdate = conn.prepareStatement(sqlUpdate);
                psUpdate.setString(1, rutaRelativa);
                psUpdate.setInt(2, idUsuarioGenerado);
                psUpdate.executeUpdate();
                psUpdate.close();

                System.out.println(">>> PDF guardado y ruta actualizada: " + rutaRelativa);

            } catch (Exception ex) {
                System.out.println(">>> Error guardando PDF: " + ex.getMessage());
                // Opcional: Manejar error (borrar usuario o dejar log)
            }
        }
    } catch (Exception e) {
        errorMsg = e.getMessage();
        System.out.println(">>> Error en BD: " + errorMsg);
        e.printStackTrace();
    } finally {
        if(ps != null) try { ps.close(); } catch(Exception e){}
        if(conn != null) try { conn.close(); } catch(Exception e){}
    }

    if (registroExitoso) {
        try {
            // Construir URL del sistema
            String baseURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath();
            String linkActivacion = baseURL + "/activar_cuenta.jsp?t=" + token;

            System.out.println(">>> Link generado: " + linkActivacion);

            // Preparar parámetros para la API de correo
            String asunto = URLEncoder.encode("Confirmación de Cuenta - COVEICYDET", "UTF-8");
            
            // IMPORTANTE: Si sigue fallando, prueba quitando las etiquetas HTML del mensaje temporalmente
            String mensajeCuerpo = "Hola " + nombre + ". Gracias por registrarte. Para activar tu cuenta, haz clic aqui: " + linkActivacion;
            String mensajeEncoded = URLEncoder.encode(mensajeCuerpo, "UTF-8");

            String apiURL = "https://covecyt.gob.mx/libmail.php?DESTINATARIO=" + email + 
                            "&ASUNTO=" + asunto + 
                            "&MENSAJE=" + mensajeEncoded;

            System.out.println(">>> Conectando a API Correo...");

            URL url = new URL(apiURL);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            
            // CONFIGURACIÓN CRÍTICA PARA QUE FUNCIONE
            connection.setRequestMethod("GET");
            connection.setRequestProperty("User-Agent", "Mozilla/5.0"); // Simular navegador
            connection.setConnectTimeout(10000); // 10 segundos timeout
            connection.setReadTimeout(10000); // 10 segundos timeout
            
            connection.connect();
            
            // OBLIGATORIO: Leer la respuesta para que la petición salga realmente
            int responseCode = connection.getResponseCode();
            
            System.out.println(">>> Respuesta API Correo (Código): " + responseCode);

            // Leer contenido de respuesta (opcional pero bueno para debug)
            if (responseCode == 200) {
                BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
                String inputLine;
                StringBuilder content = new StringBuilder();
                while ((inputLine = in.readLine()) != null) {
                    content.append(inputLine);
                }
                in.close();
                System.out.println(">>> Respuesta API Cuerpo: " + content.toString());
            }

            // Redirigir al Login
            response.sendRedirect(request.getContextPath() + "/pages/login/login.jsp?msg=registro_ok");

        } catch (Exception e) {
            System.out.println(">>> ERROR ENVIANDO CORREO: " + e.getMessage());
            e.printStackTrace();
            // Redirigir con error de correo pero usuario creado
            response.sendRedirect(request.getContextPath() + "/pages/login/login.jsp?error=fallo_correo");
        }
    } else {
        // Error de BD
        response.sendRedirect("registrarse.jsp?error=" + URLEncoder.encode(errorMsg, "UTF-8"));
    }
%>