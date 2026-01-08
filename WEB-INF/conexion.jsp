<%@ page import="java.sql.*" %>
<%@ page import="java.util.Properties" %>
<%@ page import="java.io.*" %>
<%
    Connection conn = null;
    String dbError = "";
    
    try {
        Class.forName("org.postgresql.Driver");
        
        Properties props = new Properties();
        // Usamos getRealPath para leer el archivo físicamente, asegurando que los cambios se detecten al instante
        // Ajustamos la ruta para buscar en WEB-INF/classes/db.properties donde lo movimos
        String path = application.getRealPath("/WEB-INF/classes/db.properties");
        
        if (path != null && new java.io.File(path).exists()) {
            FileInputStream fis = new FileInputStream(path);
            props.load(fis);
            fis.close();
        } else {
            // Intento alternativo por si getRealPath falla
            InputStream is = this.getClass().getResourceAsStream("/db.properties");
            if (is != null) {
                props.load(is);
            } else {
                throw new Exception("No se encontró el archivo db.properties");
            }
        }

        conn = DriverManager.getConnection(
            props.getProperty("db.url"),
            props.getProperty("db.user"),
            props.getProperty("db.pass")
        );

    } catch (Exception e) {
        dbError = "Error de conexión centralizada: " + e.getMessage();
        System.err.println(dbError);
        e.printStackTrace();
    }
%>