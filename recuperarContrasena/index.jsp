<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>COVEICYDET - Recuperar Contraseña</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        html, body { height: 100%; overflow: hidden; }
        iframe { width: 100%; height: 100%; border: none; }
    </style>
</head>
<body>
    <iframe id="contentFrame" src="/proyectos/pages/recuperarContrasena/"></iframe>
    
    <script>
        if (window.history.replaceState) {
            window.history.replaceState(null, null, '/proyectos/recuperarContrasena/');
        }
    </script>
</body>
</html>
