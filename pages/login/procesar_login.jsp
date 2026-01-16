<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>

<%@ include file="../../WEB-INF/conexion.jsp" %>

<%!
    // DATOS DE CONEXIÓN YA NO SON NECESARIOS AQUÍ PORQUE USAMOS CONEXION.JSP
    private static final String APP_SALT = "C0v31cYd3T_Pr0y3ct0_2025_#Secreto!";
%>

<% 
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    String nextUrl = request.getParameter("next");
    String rememberMe = request.getParameter("remember-me");
    
    // Limpieza
    if (email != null) email = email.trim().toLowerCase();
    if (password != null) password = password.trim();
    
    boolean loginExitoso = false;
    String nombreUsuario = "";
    String rol = "";
    String mensaje = "";
    Integer usuarioId = null;

    if (email == null || password == null || email.isEmpty() || password.isEmpty()) {
        mensaje = "Por favor, complete todos los campos.";
    } else {
        // conn viene de conexion.jsp
        PreparedStatement stmt = null;
        ResultSet rs = null;

        if (conn != null) {
            try {
                // Class.forName y DriverManager ya manejados en conexion.jsp

                String passwordHasheada = hashPassword(password);

                // --- CORRECCIÓN FINAL ---
                // Eliminamos el JOIN a estado_usuario porque u.estado ya tiene el ID (1 o 2).
                String sql = "SELECT u.id_usuario, u.nombre, u.primer_apellido, u.segundo_apellido, u.estado, t.tipo_usuario " +
                             "FROM usuarios u " +
                             "JOIN tipo_usuario t ON u.tipousuario = t.id_tipo_usuario " +
                             "WHERE u.correo_electronico = ? AND u.contrasena = ?";

                stmt = conn.prepareStatement(sql);
                stmt.setString(1, cancelaInjeccion(email));
                stmt.setString(2, passwordHasheada);
                rs = stmt.executeQuery();
                
                if (rs.next()) {
                    // Leemos directamente el entero de la tabla usuarios
                    int estadoUsuario = rs.getInt("estado");

                    // VALIDACIÓN: 2 = Activo
                    if (estadoUsuario == 2) {
                        loginExitoso = true;
                        usuarioId = rs.getInt("id_usuario");
                        nombreUsuario = rs.getString("nombre") + " " + 
                                       rs.getString("primer_apellido") + " " + 
                                       rs.getString("segundo_apellido");
                        rol = rs.getString("tipo_usuario");
                    } else {
                        // Estado Inactivo (1 u otro)
                        loginExitoso = false;
                        mensaje = "Su usuario está inactivo. Debe validar su cuenta para continuar, en caso de no encontrar el correo de activación, revise su carpeta de spam o correo no deseado. si el correo ya fue validado y no puede ingresar, contacte al correo: marquez@coveicydet.gob.mx" ;
                    }
                } else {
                    mensaje = "Credenciales incorrectas o usuario no registrado.";
                }

            } catch (SQLException e) {
                mensaje = "Error SQL: " + e.getMessage(); 
                e.printStackTrace();
            } catch (Exception e) {
                mensaje = "Error interno del servidor.";
                e.printStackTrace();
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
                // NO cerramos conn aquí
            }
        } else {
             mensaje = "Error de conexión: " + dbError;
        }
    }
    
    if (loginExitoso) {
        // Crear Sesión
        session.setAttribute("email", email);
        session.setAttribute("nombre", nombreUsuario);
        session.setAttribute("rol", rol);
        session.setAttribute("id_usuario", usuarioId);
        session.setAttribute("autenticado", true);

        // Token
        if (rememberMe != null && rememberMe.equals("on")) {
            actualizarToken(usuarioId, conn, response);
            gestionarCookieEmail(email, true, request, response);
        } else {
            eliminarToken(response);
            gestionarCookieEmail(email, false, request, response);
        }

        // Redirección
        String redirectUrl = "";
        if (nextUrl != null && !nextUrl.isEmpty()) {
            redirectUrl = java.net.URLDecoder.decode(nextUrl, "UTF-8");
        } else {
            switch (rol) {
                case "responsable": redirectUrl = request.getContextPath() + "/pages/responsableDeproyecto/paginaPrincipal/"; break;
                case "analista": redirectUrl = request.getContextPath() + "/pages/analista/paginaPrincipal/"; break;
                case "evaluador": redirectUrl = request.getContextPath() + "/pages/evaluador/main.jsp"; break;
                default: redirectUrl = request.getContextPath() + "/index.jsp"; break;
            }
        }
        response.sendRedirect(redirectUrl);

    } else {
        session.setAttribute("error_login", mensaje);
        response.sendRedirect(request.getContextPath() + "/pages/login/login.jsp");
    }
%>

<%!
    // Métodos Auxiliares
    public String hashPassword(String password) {
        try {
            java.security.MessageDigest digest = java.security.MessageDigest.getInstance("SHA-256");
            String input = APP_SALT + password;
            byte[] encodedhash = digest.digest(input.getBytes(java.nio.charset.StandardCharsets.UTF_8));
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

    public String cancelaInjeccion (String valor){
        if (valor == null) return "";
        return valor.replace("'","").replace("\"","").replace("DROP","").replace("DELETE","");
    }

    public void actualizarToken(int usuarioId, Connection conn, HttpServletResponse response) {
        if (conn == null) return;
        try {
            String token = java.util.UUID.randomUUID().toString();
            String sql = "UPDATE usuarios SET token_sesion = ? WHERE id_usuario = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, token);
                ps.setInt(2, usuarioId);
                ps.executeUpdate();
            }
            Cookie c = new Cookie("auth_token", token);
            c.setMaxAge(30 * 24 * 60 * 60); c.setPath("/"); response.addCookie(c);
        } catch (Exception e) { e.printStackTrace(); }
    }

    public void eliminarToken(HttpServletResponse response) {
        Cookie c = new Cookie("auth_token", "");
        c.setMaxAge(0); c.setPath("/"); response.addCookie(c);
    }
    
    public void gestionarCookieEmail(String email, boolean guardar, HttpServletRequest req, HttpServletResponse resp) {
        Cookie c = new Cookie("remembered_email", guardar ? email : "");
        c.setMaxAge(guardar ? 2592000 : 0);
        c.setPath(req.getContextPath() + "/");
        resp.addCookie(c);
    }
%>
