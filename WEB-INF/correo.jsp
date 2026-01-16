<%@ page import="java.util.Properties" %>
<%@ page import="java.io.*" %>
<%
    String mailApiUrl = "";
    String mailError = "";

    try {
        Properties mailProps = new Properties();
        String path = application.getRealPath("/WEB-INF/classes/mail.properties");

        if (path != null && new java.io.File(path).exists()) {
            FileInputStream fis = new FileInputStream(path);
            mailProps.load(fis);
            fis.close();
        } else {
            InputStream is = this.getClass().getResourceAsStream("/mail.properties");
            if (is != null) {
                mailProps.load(is);
                is.close();
            } else {
                throw new Exception("No se encontró el archivo mail.properties");
            }
        }

        mailApiUrl = mailProps.getProperty("mail.api.url");

    } catch (Exception e) {
        mailError = "Error cargando configuración de correo: " + e.getMessage();
        System.err.println(mailError);
        e.printStackTrace();
    }
%>