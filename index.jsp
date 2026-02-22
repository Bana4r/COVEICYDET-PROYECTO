<%@page import="java.util.*" %>
<%@page import="java.sql.*"  %>
<%@page import="coveicydet.proyectos.cEjemplo" %>
<%@page contentType="text/html; charset=UTF-8" %>
<html>
<head>
    <title>Consulta PostgreSQL desde JSP</title>
</head>
<body>
    <h1>Datos de la Tabla PostgreSQL</h1>
    <table border="1">
        <tr>
            <th>ID</th>
            <th>Nombre</th>
            <th>Edad</th>
        </tr>
        <%
            Statement stmt = null;
            ResultSet rs = null;

            %> <%@ include file="/WEB-INF/conexion.jsp" %> <%

            if (conn != null) {
                try {
                    stmt = conn.createStatement();
                    String sql = "SELECT * FROM test"; 
                    rs = stmt.executeQuery(sql);

                    while (rs.next()) {
                        int id = rs.getInt("dni");
                        String nombre = rs.getString("nombre");
                        int edad = rs.getInt("edad");

                        out.println("<tr>");
                        out.println("<td>" + id     + "</td>");
                        out.println("<td>" + nombre + "</td>");
                        out.println("<td>" + edad   + "</td>");
                        out.println("</tr>");
                    }
                } catch (SQLException e) {
                    out.println("Error de base de datos: " + e.getMessage());
                } finally {
                    try {
                        if (rs != null) rs.close();
                        if (stmt != null) stmt.close();
                        if (conn != null) conn.close();
                    } catch (SQLException e) {
                        out.println("Error al cerrar los recursos: " + e.getMessage());
                    }
                }
            } else {
                out.println("Error de conexión: " + dbError);
            }
        %>
    </table>

<p>Ejemplo de acceso a una clase de Backend </p>

<!-- Ejemplo con Java Beans -->
<jsp:useBean id="obj_Ejemplo" class="coveicydet.proyectos.cEjemplo" scope="request" />


<p> Versi&oacute;n de la clase: <%= obj_Ejemplo.getVersion()%>  </p>


<!-- Ejemplo sin Beans -->
<p>Ejemplo de creacion de objeto sin usar Beans:</p>

<p>

<% 

  cEjemplo objEjem2 = new cEjemplo(); 
  out.println(objEjem2.getVersion());

%>

</p>


</body>
</html>

