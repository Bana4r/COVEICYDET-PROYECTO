<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.security.MessageDigest" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="java.net.URLEncoder" %>

<%@ include file="../../../WEB-INF/conexion.jsp" %>

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

    public String sanitizeInput(String valor) {
        if (valor == null) return "";
        return valor.replace("'", "").replace("\"", "").replace("DROP", "").replace("DELETE", "");
    }

    public void actualizarToken(int usuarioId, Connection conn, HttpServletResponse response) {
        if (conn == null) return;
        try {
            String token = UUID.randomUUID().toString();
            String sql = "UPDATE usuarios SET token_sesion = ? WHERE id_usuario = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, token);
            ps.setInt(2, usuarioId);
            ps.executeUpdate();
            ps.close();
            
            Cookie c = new Cookie("auth_token", token);
            c.setMaxAge(30 * 24 * 60 * 60);
            c.setPath("/");
            response.addCookie(c);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void eliminarToken(HttpServletResponse response) {
        Cookie c = new Cookie("auth_token", "");
        c.setMaxAge(0);
        c.setPath("/");
        response.addCookie(c);
    }
%>

<%
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    String rememberMe = request.getParameter("remember-me");

    // Limpieza
    if (email != null) email = email.trim().toLowerCase();
    if (password != null) password = password.trim();

    boolean loginExitoso = false;
    String nombreUsuario = "";
    String mensaje = "";
    Integer usuarioId = null;

    if (email == null || password == null || email.isEmpty() || password.isEmpty()) {
        mensaje = "Por favor, complete todos los campos.";
    } else {
        PreparedStatement stmt = null;
        ResultSet rs = null;

        if (conn != null) {
            try {
                String passwordHasheada = hashPassword(password);

                // Login SOLO para evaluadores (tipousuario = 3)
                String sql = "SELECT u.id_usuario, u.nombre, u.primer_apellido, u.segundo_apellido, u.estado, u.tipousuario AS id_tipo, t.tipo_usuario AS nombre_tipo " +
                             "FROM usuarios u " +
                             "JOIN tipo_usuario t ON u.tipousuario = t.id_tipo_usuario " +
                             "WHERE u.correo_electronico = ? AND u.contrasena = ?";

                stmt = conn.prepareStatement(sql);
                stmt.setString(1, sanitizeInput(email));
                stmt.setString(2, passwordHasheada);
                rs = stmt.executeQuery();

                if (rs.next()) {
                    int estadoUsuario = rs.getInt("estado");
                    int idTipoUsuario = rs.getInt("id_tipo");
                    String nombreTipoUsuario = rs.getString("nombre_tipo");

                    if (estadoUsuario == 2 && (idTipoUsuario == 3 || "evaluador".equals(nombreTipoUsuario))) {
                        // Cuenta activa y es evaluador - login exitoso
                        loginExitoso = true;
                        usuarioId = rs.getInt("id_usuario");
                        nombreUsuario = rs.getString("nombre") + " " +
                                       rs.getString("primer_apellido") + " " +
                                       rs.getString("segundo_apellido");
                    } else if (estadoUsuario != 2) {
                        // Cuenta inactiva
                        loginExitoso = false;
                        mensaje = "Su usuario está inactivo (estado=" + estadoUsuario + "). Debe validar su cuenta. Revise su correo de activación.";
                    } else {
                        // No es evaluador
                        loginExitoso = false;
                        mensaje = "El correo no está registrado como evaluador (id_tipo=" + idTipoUsuario + "). Si es responsable, use el login de responsables.";
                    }
                } else {
                    mensaje = "Credenciales incorrectas. Verifique que su cuenta esté registrada como evaluador.";
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
            }
        } else {
             mensaje = "Error de conexión a la base de datos.";
        }
    }

    if (loginExitoso) {
        // Crear sesión
        session.setAttribute("email", email);
        session.setAttribute("nombre", nombreUsuario);
        session.setAttribute("rol", "evaluador");
        session.setAttribute("id_usuario", usuarioId);
        session.setAttribute("autenticado", true);

        // Manejar token de sesión
        if (rememberMe != null && rememberMe.equals("on")) {
            actualizarToken(usuarioId, conn, response);
        } else {
            eliminarToken(response);
        }

        // Redirigir al dashboard del evaluador
        response.sendRedirect(request.getContextPath() + "/pages/evaluador/index.jsp");

    } else {
        // Pasar error como parámetro en la URL (sin decoraciones)
        response.sendRedirect("login.jsp?error=" + URLEncoder.encode(mensaje, "UTF-8"));
    }
%>
