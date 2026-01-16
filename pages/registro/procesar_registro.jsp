<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.UUID" %>
<%@ page import="java.net.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.security.MessageDigest" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="java.util.Base64" %>

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
    System.out.println(">>> Iniciando registro de usuario...");

    // INCLUIR CONEXIÓN Y CORREO DESDE WEB-INF
    %><%@ include file="/WEB-INF/conexion.jsp" %><%
    %><%@ include file="/WEB-INF/correo.jsp" %><%

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
    
    PreparedStatement ps = null;

    try {
        // ...existing code... (verificación de RFC)
        String sqlCheck = "SELECT id_usuario FROM usuarios WHERE rfc = ?";
        PreparedStatement psCheck = conn.prepareStatement(sqlCheck);
        psCheck.setString(1, rfc);
        ResultSet rsCheck = psCheck.executeQuery();

        if (rsCheck.next()) {
            rsCheck.close();
            psCheck.close();
            conn.close();
            response.sendRedirect(request.getContextPath() + "/pages/login/login.jsp?msg=rfc_registrado");
            return;
        }
        
        rsCheck.close();
        psCheck.close();

        // ...existing code... (INSERT de usuario)
        String sql = "INSERT INTO usuarios (nombre, primer_apellido, segundo_apellido, rfc, correo_electronico, contrasena, tipousuario, token_sesion, estado, token_activacion, comprobantevigencia) VALUES (?, ?, ?, ?, ?, ?, 2, ?, 1, ?, ?)";
        ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
        
        ps.setString(1, nombre);
        ps.setString(2, appPaterno);
        ps.setString(3, appMaterno);
        ps.setString(4, rfc);
        ps.setString(5, email);
        ps.setString(6, passwordHashed); 
        ps.setString(7, null);
        ps.setString(8, token);
        ps.setString(9, null);

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
                String appPath = request.getServletContext().getRealPath("/");
                String savePath = appPath + "uploads" + File.separator + idUsuarioGenerado;
                File fileDir = new File(savePath);
                if (!fileDir.exists()) fileDir.mkdirs();
                String base64Data = pdfBase64.substring(pdfBase64.indexOf(",") + 1);
                byte[] fileBytes = Base64.getDecoder().decode(base64Data);
                String nombreArchivo = "vigencia.pdf";
                File file = new File(savePath + File.separator + nombreArchivo);
                FileOutputStream output = new FileOutputStream(file);
                output.write(fileBytes);
                output.close();
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
            String baseURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath();
            String linkActivacion = baseURL + "/activar_cuenta.jsp?t=" + token;

            String asunto = URLEncoder.encode("Confirmación de Cuenta - COVEICYDET", "UTF-8");
            String mensajeCuerpo = "Hola " + nombre + ". Gracias por registrarte. Para activar tu cuenta, haz clic aqui: " + linkActivacion;
            String mensajeEncoded = URLEncoder.encode(mensajeCuerpo, "UTF-8");

            // USA mailApiUrl DEL INCLUDE
            String apiURL = mailApiUrl + "?DESTINATARIO=" + email + 
                            "&ASUNTO=" + asunto + 
                            "&MENSAJE=" + mensajeEncoded;

            System.out.println(">>> Conectando a API Correo...");

            URL url = new URL(apiURL);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("GET");
            connection.setRequestProperty("User-Agent", "Mozilla/5.0");
            connection.setConnectTimeout(10000);
            connection.setReadTimeout(10000);
            connection.connect();
            
            int responseCode = connection.getResponseCode();
            System.out.println(">>> Respuesta API Correo (Código): " + responseCode);

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

            response.sendRedirect(request.getContextPath() + "/pages/login/login.jsp?msg=registro_ok");

        } catch (Exception e) {
            System.out.println(">>> ERROR ENVIANDO CORREO: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/pages/login/login.jsp?error=fallo_correo");
        }
    } else {
        response.sendRedirect("index.jsp?error=" + URLEncoder.encode(errorMsg, "UTF-8"));
    }
%>