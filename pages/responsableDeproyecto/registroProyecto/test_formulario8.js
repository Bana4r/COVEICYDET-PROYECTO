// ========================================
// SCRIPT PARA CARGAR DATOS DE PRUEBA
// ========================================
// Copia y pega estas funciones en la consola del navegador (F12)
// Luego ejecuta: cargarDatosPrueba()

function cargarDatosPrueba() {
    console.log('🚀 Iniciando carga de datos de prueba...');
    
    // ============================================================
    // PÁGINA 1 - Información General
    // Estructura: {proyecto: {...}, responsables: [...]}
    // ============================================================
    const datosP1 = {
        proyecto: {
            institucion_proponente: "Universidad Tecnológica del Estado de Tlaxcala*",
            area_adscripcion: "División de Ingeniería Mecatrónica",
            municipio: "Apizaco",
            convocatoria: "2025-01",
            sector_impacto_proyecto: "Tecnología y Desarrollo",
            nivel_slr: "SRL 5",
            nivel_tlr: "TRL 4",
            area_conocimiento: "Ingeniería y Tecnología",
            doc_probatorio: "convenio_universidad.pdf"
        },
        responsables: [
            {
                tipo_responsable: "tecnico",
                nombre_completo: "Dr. Juan Pérez García",
                correo_electronico: "juan.perez@uttlax.edu.mx",
                telefono: "2461234567",
                documento: "curriculum_tecnico.pdf"
            },
            {
                tipo_responsable: "legal",
                nombre_completo: "Lic. María López Hernández",
                correo_electronico: "maria.lopez@uttlax.edu.mx",
                telefono: "2467654321",
                documento: "curriculum_legal.pdf"
            },
            {
                tipo_responsable: "administrativo",
                nombre_completo: "C.P. Carlos Ramírez Torres",
                correo_electronico: "carlos.ramirez@uttlax.edu.mx",
                telefono: "2469876543",
                documento: "curriculum_admin.pdf"
            }
        ]
    };
    localStorage.setItem('proyecto_borrador_pagina1', JSON.stringify(datosP1));
    localStorage.setItem('proyecto_borrador_pagina1_saved', '1');
    console.log('✅ Página 1 - Información General (estructura nested corregida)');

    // ============================================================
    // PÁGINA 2 - Justificación y Objetivos
    // Estructura: {pagina2: {...}}
    // ============================================================
    const datosP2 = {
            resumen_ejecutivo: "El proyecto desarrolla un sistema de monitoreo ambiental utilizando tecnologías IoT y machine learning para la detección temprana de anomalías en ecosistemas urbanos. Esta investigación aplicada busca mejorar la capacidad de respuesta ante eventos ambientales críticos mediante el análisis predictivo de datos en tiempo real, beneficiando a más de 100,000 habitantes de zonas urbanas con información oportuna y precisa.",
            antecedentes: "La contaminación ambiental y el cambio climático representan desafíos críticos para las ciudades modernas. Los sistemas tradicionales de monitoreo son costosos, limitados en cobertura y reactivos. La integración de sensores IoT de bajo costo con algoritmos de inteligencia artificial permite crear redes de monitoreo distribuidas y predictivas. Investigaciones previas han demostrado la viabilidad técnica de estos sistemas en contextos controlados, pero existe una brecha en su implementación práctica en entornos urbanos complejos con múltiples variables ambientales interrelacionadas.",
            pertinencia: "Este proyecto es pertinente porque aborda la necesidad urgente de herramientas tecnológicas accesibles para la gestión ambiental urbana. La solución propuesta es escalable, de bajo costo y puede ser implementada por gobiernos locales con recursos limitados. Además, genera conocimiento aplicable en múltiples contextos geográficos y contribuye al desarrollo de capacidades tecnológicas locales en áreas estratégicas como IoT, inteligencia artificial y ciencia de datos aplicada al medio ambiente.",
            preguntas_investigacion: "¿Cómo pueden los sistemas IoT de bajo costo proporcionar datos ambientales confiables en tiempo real? ¿Qué arquitecturas de machine learning son más efectivas para la predicción de eventos ambientales críticos con un horizonte temporal de 24 a 72 horas? ¿Cuál es la configuración óptima de red de sensores para maximizar cobertura espacial y minimizar costos operativos? ¿Cómo integrar múltiples fuentes de datos para mejorar la precisión predictiva del sistema?",
            objetivos_general: "Desarrollar e implementar un sistema de monitoreo ambiental basado en IoT y machine learning capaz de detectar y predecir anomalías ambientales en entornos urbanos con precisión superior al 85%, utilizando una red distribuida de sensores de bajo costo y algoritmos de aprendizaje automático.",
            objetivos_especificos: "1. Diseñar una arquitectura de red de sensores IoT optimizada para monitoreo ambiental urbano con cobertura de al menos 10 km². 2. Implementar algoritmos de machine learning (Random Forest, LSTM) para análisis predictivo de datos ambientales con precisión mínima del 85%. 3. Validar el sistema en un piloto urbano con al menos 50 nodos de sensores distribuidos estratégicamente. 4. Desarrollar una interfaz de usuario web y móvil para visualización de datos y sistema de alertas en tiempo real. 5. Capacitar a personal técnico local en operación y mantenimiento del sistema."
        }
    localStorage.setItem('proyecto_borrador_pagina2', JSON.stringify(datosP2));
    localStorage.setItem('proyecto_borrador_pagina2_saved', '1');
    console.log('✅ Página 2 - Justificación y Objetivos');

    // ============================================================
    // PÁGINA 3 - Planeación y Evaluación
    // Estructura: {pagina3: {...}}
    // ============================================================
    const datosP3 = {
        pagina3: {
            factores_riesgo_mitigacion: "Riesgos técnicos: Fallas en conectividad de red, degradación de sensores por condiciones ambientales extremas. Mitigación: Redundancia de equipos críticos, protocolos de mantenimiento preventivo mensual, respaldos automáticos de datos. Riesgos operativos: Resistencia de usuarios finales, complejidad en instalación y configuración. Mitigación: Programa de capacitación continua, documentación técnica detallada, soporte técnico permanente. Riesgos presupuestales: Aumento en costo de componentes electrónicos por inflación o disrupciones en cadena de suministro. Mitigación: Contratos con proveedores alternativos, diseño modular adaptable a diferentes componentes, reserva presupuestal del 10%.",
            resumen_metodologia: "Se empleará una metodología de desarrollo ágil con iteraciones de 4 semanas. Fase 1: Diseño y prototipado de hardware (8 semanas) - selección de sensores, diseño de PCB, pruebas de laboratorio. Fase 2: Desarrollo de software y algoritmos ML (12 semanas) - implementación de pipeline de datos, entrenamiento de modelos, optimización de algoritmos. Fase 3: Integración y pruebas de laboratorio (6 semanas) - pruebas de estrés, validación de precisión, calibración de sensores. Fase 4: Piloto en campo (12 semanas) - instalación de red de sensores, monitoreo continuo, ajustes operativos. Se utilizarán sensores comerciales BME280 para temperatura/humedad/presión y MQ-135 para calidad del aire, integrados con microcontroladores ESP32. Los datos se procesarán mediante algoritmos Random Forest para clasificación y LSTM para predicción de series temporales, implementados en Python con TensorFlow. La validación incluirá métricas de precisión, recall, F1-score y RMSE comparadas con estaciones meteorológicas certificadas.",
            resultados_esperados: "Productos tecnológicos: Prototipo funcional de sistema de monitoreo con 50 nodos distribuidos en zona piloto. Software de análisis predictivo con código abierto disponible en repositorio GitHub. Dashboard web y aplicación móvil para visualización de datos en tiempo real. Productos académicos: 2 artículos en revistas indexadas en JCR o Scopus, 3 ponencias en congresos nacionales e internacionales. Formación de recursos humanos: 2 tesis de maestría completadas, capacitación de 5 técnicos locales certificados. Impacto social: Sistema implementado beneficiando a 100,000 habitantes con información ambiental oportuna y alertas tempranas. Transferencia tecnológica: Manual técnico de replicación, capacitación a gobierno municipal para operación autónoma del sistema, plan de escalamiento a nivel estatal.",
            impacto_social: "El sistema beneficiará directamente a 100,000 habitantes de zonas urbanas proporcionando información ambiental en tiempo real y alertas tempranas sobre condiciones de riesgo. Mejorará la toma de decisiones de autoridades locales en gestión ambiental y salud pública. Incrementará la conciencia ciudadana sobre calidad del aire y cambio climático mediante datos accesibles y comprensibles.",
            impacto_ambiental: "Contribuirá a la reducción de emisiones contaminantes mediante detección temprana de fuentes de contaminación y optimización de recursos de monitoreo. Generará datos científicos sobre patrones ambientales locales que permitirán políticas públicas más efectivas. El sistema utiliza tecnología de bajo consumo energético con paneles solares, minimizando su huella de carbono.",
            impacto_economico: "Reducirá costos de monitoreo ambiental en 60% comparado con sistemas tradicionales. Generará empleos técnicos especializados en IoT e IA. Atraerá inversión en tecnologías limpias y smart cities. El modelo de negocio permitirá réplica en otras ciudades generando ingresos sostenibles para mantenimiento y escalamiento del sistema.",
            impacto_cientificoTecnologico: "Avanzará el estado del arte en redes de sensores IoT para monitoreo ambiental mediante optimización de arquitecturas de bajo costo. Generará conocimiento sobre aplicación de machine learning en predicción de eventos ambientales en contextos urbanos mexicanos. Desarrollará capacidades locales en tecnologías emergentes con potencial de réplica nacional e internacional. Publicaciones científicas contribuirán al cuerpo de conocimiento global en smart cities y sustentabilidad."
        }
    };
    localStorage.setItem('proyecto_borrador_pagina3', JSON.stringify(datosP3));
    localStorage.setItem('proyecto_borrador_pagina3_saved', '1');
    console.log('✅ Página 3 - Planeación y Evaluación');

    // ============================================================
    // PÁGINA 4 - Grupo de Trabajo
    // Estructura: {pagina4: {participante1_*, participante2_*, ...}}
    // IMPORTANTE: Campos numerados con sufijo (participante1, participante2)
    // ============================================================
    const datosP4 = {
        pagina4: {
            participante1_nombre: "Dr. Juan Pérez García",
            participante1_institucion: "Universidad Tecnológica del Estado de Tlaxcala",
            participante1_grado: "Doctorado en Ingeniería Electrónica",
            participante1_area: "Ingeniería y Tecnología",
            participante1_disciplina: "Sistemas IoT y Electrónica",
            participante1_actividades: "Responsable técnico del proyecto, diseño de hardware, coordinación general del equipo",
            participante1_comprobante: "cv_juan_perez.pdf",
            
            participante2_nombre: "Dra. María López Hernández",
            participante2_institucion: "Instituto Tecnológico de Apizaco",
            participante2_grado: "Doctorado en Ciencias Computacionales",
            participante2_area: "Ciencias de la Computación",
            participante2_disciplina: "Machine Learning e Inteligencia Artificial",
            participante2_actividades: "Desarrollo de algoritmos de ML, entrenamiento de modelos predictivos, análisis de datos",
            participante2_comprobante: "cv_maria_lopez.pdf",
            
            participante3_nombre: "M.C. Carlos Ramírez Torres",
            participante3_institucion: "Universidad Autónoma de Tlaxcala",
            participante3_grado: "Maestría en Ingeniería Ambiental",
            participante3_area: "Ciencias Ambientales",
            participante3_disciplina: "Monitoreo y Gestión Ambiental",
            participante3_actividades: "Diseño de protocolos de monitoreo, validación de datos ambientales, análisis de impacto",
            participante3_comprobante: "cv_carlos_ramirez.pdf",
            
            participante4_nombre: "Ing. Ana Martínez Silva",
            participante4_institucion: "Centro de Innovación Tecnológica de Tlaxcala",
            participante4_grado: "Licenciatura en Sistemas Computacionales",
            participante4_area: "Desarrollo de Software",
            participante4_disciplina: "Desarrollo Web y Móvil",
            participante4_actividades: "Desarrollo de interfaces de usuario, dashboard web, aplicación móvil, API REST",
            participante4_comprobante: "cv_ana_martinez.pdf",
            
            participante5_nombre: "Mtro. Roberto Sánchez Medina",
            participante5_institucion: "Universidad Politécnica de Tlaxcala",
            participante5_grado: "Maestría en Gestión de Proyectos",
            participante5_area: "Administración de Proyectos",
            participante5_disciplina: "Gestión de Proyectos Tecnológicos",
            participante5_actividades: "Administración del proyecto, seguimiento de cronograma, gestión de recursos",
            participante5_comprobante: "cv_roberto_sanchez.pdf"
        }
    };
    localStorage.setItem('proyecto_borrador_pagina4', JSON.stringify(datosP4));
    localStorage.setItem('proyecto_borrador_pagina4_saved', '1');
    console.log('✅ Página 4 - Grupo de Trabajo (5 participantes con patrón participanteN)');

    // ============================================================
    // PÁGINA 5 - Organizaciones Sociales
    // Estructura: {pagina5: {organizacion1_*, organizacion2_*, ...}}
    // ============================================================
    const datosP5 = {
        pagina5: {
            organizacion1_nombre: "Universidad Tecnológica del Estado de Tlaxcala",
            organizacion1_representante: "Dr. Luis García Romero - Rector",
            organizacion1_domicilio: "Av. Universidad Tecnológica No. 1, Apizaco, Tlaxcala",
            organizacion1_telefono: "2414172010",
            organizacion1_correo: "rectoria@uttlax.edu.mx",
            organizacion1_comprobante: "convenio_uttlax.pdf",
            
            organizacion2_nombre: "Instituto Nacional de Ecología y Cambio Climático",
            organizacion2_representante: "Dra. Patricia Morales Ruiz - Directora Regional",
            organizacion2_domicilio: "Periférico Sur 5000, Ciudad de México",
            organizacion2_telefono: "5554249000",
            organizacion2_correo: "direccion.regional@inecc.gob.mx",
            organizacion2_comprobante: "convenio_inecc.pdf",
            
            organizacion3_nombre: "H. Ayuntamiento de Apizaco",
            organizacion3_representante: "Ing. Fernando Gutiérrez León - Director de Medio Ambiente",
            organizacion3_domicilio: "Palacio Municipal, Centro, Apizaco, Tlaxcala",
            organizacion3_telefono: "2414172020",
            organizacion3_correo: "medioambiente@apizaco.gob.mx",
            organizacion3_comprobante: "convenio_ayuntamiento.pdf",
            
            organizacion4_nombre: "Centro de Investigación en Computación del IPN",
            organizacion4_representante: "Dr. Alejandro Torres Méndez - Director",
            organizacion4_domicilio: "Av. Juan de Dios Bátiz, Gustavo A. Madero, CDMX",
            organizacion4_telefono: "5557296000",
            organizacion4_correo: "direccion@cic.ipn.mx",
            organizacion4_comprobante: "convenio_cic_ipn.pdf",
            
            organizacion5_nombre: "Cámara Nacional de la Industria Electrónica y Tecnologías de la Información",
            organizacion5_representante: "Lic. Jorge Ramírez Santos - Presidente Delegación Tlaxcala",
            organizacion5_domicilio: "Blvd. Revolución 303, Tlaxcala Centro",
            organizacion5_telefono: "2462222000",
            organizacion5_correo: "tlaxcala@canieti.org",
            organizacion5_comprobante: "carta_apoyo_canieti.pdf"
        }
    };
    localStorage.setItem('proyecto_borrador_pagina5', JSON.stringify(datosP5));
    localStorage.setItem('proyecto_borrador_pagina5_saved', '1');
    console.log('✅ Página 5 - Organizaciones Sociales (5 organizaciones)');

    // ============================================================
    // PÁGINA 6 - Estudiantes
    // Estructura: {pagina6: {estudiante1_*, estudiante2_*, ...}}
    // ============================================================
    const datosP6 = {
        pagina6: {
            estudiante1_nombre: "Jorge Alberto Méndez Cruz",
            estudiante1_sexo: "Masculino",
            estudiante1_nivel: "Maestría",
            estudiante1_tiempo: "24 meses",
            estudiante1_institucion: "Universidad Tecnológica del Estado de Tlaxcala",
            estudiante1_programa: "Maestría en Sistemas Computacionales",
            estudiante1_actividades: "Desarrollo e implementación de algoritmos de machine learning para predicción ambiental, análisis de datos temporales, validación de modelos predictivos",
            estudiante1_carta: "carta_jorge_mendez.pdf",
            
            estudiante2_nombre: "Laura Patricia Vega Flores",
            estudiante2_sexo: "Femenino",
            estudiante2_nivel: "Maestría",
            estudiante2_tiempo: "24 meses",
            estudiante2_institucion: "Instituto Tecnológico de Apizaco",
            estudiante2_programa: "Maestría en Ingeniería Electrónica",
            estudiante2_actividades: "Diseño y construcción de nodos sensores IoT, optimización de consumo energético, desarrollo de protocolos de comunicación",
            estudiante2_carta: "carta_laura_vega.pdf",
            
            estudiante3_nombre: "Ricardo Hernández Rojas",
            estudiante3_sexo: "Masculino",
            estudiante3_nivel: "Licenciatura",
            estudiante3_tiempo: "12 meses",
            estudiante3_institucion: "Universidad Tecnológica del Estado de Tlaxcala",
            estudiante3_programa: "Ingeniería en Sistemas Computacionales",
            estudiante3_actividades: "Desarrollo de interfaz web responsive, implementación de dashboard de visualización, desarrollo de API REST para acceso a datos",
            estudiante3_carta: "carta_ricardo_hernandez.pdf",
            
            estudiante4_nombre: "Gabriela Sánchez Morales",
            estudiante4_sexo: "Femenino",
            estudiante4_nivel: "Licenciatura",
            estudiante4_tiempo: "12 meses",
            estudiante4_institucion: "Universidad Autónoma de Tlaxcala",
            estudiante4_programa: "Ingeniería Ambiental",
            estudiante4_actividades: "Calibración de sensores ambientales, validación de datos con estaciones certificadas, análisis de impacto ambiental",
            estudiante4_carta: "carta_gabriela_sanchez.pdf",
            
            estudiante5_nombre: "Miguel Ángel Torres Pérez",
            estudiante5_sexo: "Masculino",
            estudiante5_nivel: "Licenciatura",
            estudiante5_tiempo: "12 meses",
            estudiante5_institucion: "Universidad Politécnica de Tlaxcala",
            estudiante5_programa: "Ingeniería en Redes y Telecomunicaciones",
            estudiante5_actividades: "Configuración de red de comunicaciones IoT, implementación de protocolos de seguridad, monitoreo de infraestructura de red",
            estudiante5_carta: "carta_miguel_torres.pdf"
        }
    };
    localStorage.setItem('proyecto_borrador_pagina6', JSON.stringify(datosP6));
    localStorage.setItem('proyecto_borrador_pagina6_saved', '1');
    console.log('✅ Página 6 - Estudiantes (5 estudiantes)');

    // ============================================================
    // PÁGINA 7 - Calendario de Actividades
    // Estructura: {pagina7: {semestre1_actividad0_*, semestre1_actividad1_*, ...}}
    // ============================================================
    const datosP7 = {
        pagina7: {
            semestre1_actividad0_nombre: "Diseño de arquitectura del sistema IoT",
            semestre1_actividad0_entregables: "Documento de arquitectura técnica, diagramas de red, especificaciones de hardware",
            
            semestre1_actividad1_nombre: "Desarrollo de prototipo de nodo sensor",
            semestre1_actividad1_entregables: "Prototipo funcional de hardware, esquemáticos electrónicos, PCB diseñado",
            
            semestre1_actividad2_nombre: "Implementación de base de datos y API",
            semestre1_actividad2_entregables: "Base de datos PostgreSQL configurada, API REST documentada, scripts de migración",
            
            semestre2_actividad0_nombre: "Desarrollo de algoritmos de machine learning",
            semestre2_actividad0_entregables: "Modelos Random Forest y LSTM entrenados, código fuente en repositorio GitHub, reporte de métricas",
            
            semestre2_actividad1_nombre: "Construcción de red piloto de 50 sensores",
            semestre2_actividad1_entregables: "50 nodos instalados y operativos, mapa de ubicaciones, manual de instalación",
            
            semestre2_actividad2_nombre: "Desarrollo de dashboard web",
            semestre2_actividad2_entregables: "Interfaz web funcional, sistema de alertas implementado, documentación de usuario",
            
            semestre3_actividad0_nombre: "Validación de precisión del sistema",
            semestre3_actividad0_entregables: "Reporte de validación con estaciones certificadas, análisis estadístico de precisión, ajustes de calibración",
            
            semestre3_actividad1_nombre: "Capacitación de personal técnico",
            semestre3_actividad1_entregables: "5 técnicos capacitados y certificados, manuales de operación y mantenimiento, videos tutoriales",
            
            semestre3_actividad2_nombre: "Publicación de resultados preliminares",
            semestre3_actividad2_entregables: "1 artículo enviado a revista indexada, 2 ponencias en congresos, poster científico",
            
            semestre4_actividad0_nombre: "Optimización y escalamiento del sistema",
            semestre4_actividad0_entregables: "Sistema optimizado, plan de escalamiento a 200 nodos, análisis costo-beneficio",
            
            semestre4_actividad1_nombre: "Transferencia tecnológica al municipio",
            semestre4_actividad1_entregables: "Convenio de transferencia firmado, capacitación a personal municipal, código fuente transferido",
            
            semestre4_actividad2_nombre: "Documentación final y cierre del proyecto",
            semestre4_actividad2_entregables: "Reporte técnico final, 2 tesis de maestría, artículo final en revista JCR, manual de réplica del sistema"
        }
    };
    localStorage.setItem('proyecto_borrador_pagina7', JSON.stringify(datosP7));
    localStorage.setItem('proyecto_borrador_pagina7_saved', '1');
    console.log('✅ Página 7 - Calendario de Actividades (4 semestres)');

    // ============================================================
    // PÁGINA 8 - Presupuesto
    // Estructura: {pagina8: {justificacion1000, partida1000_s1, partida1000_s2, ...}}
    // ============================================================
    const datosP8 = {
        pagina8: {
            // Partida 1000 - Servicios Personales
            justificacion1000: "Pago de honorarios a investigadores y técnicos especializados: Dr. Juan Pérez (20 hrs/sem x 12 meses), Dra. María López (15 hrs/sem x 12 meses), personal de apoyo técnico (2 personas x 6 meses). Total: 4 investigadores durante el proyecto.",
            partida1000_s1: "45000",
            partida1000_s2: "45000",
            
            // Partida 2000 - Materiales y Suministros
            justificacion2000: "Consumibles de laboratorio: cables, conectores, soldadura, material eléctrico para ensamble de 50 nodos sensores. Material de oficina para documentación del proyecto.",
            partida2000_s1: "15000",
            partida2000_s2: "10000",
            
            // Partida 3000 - Servicios Generales
            justificacion3000: "Viáticos y pasajes para asistencia a congresos: 2 congresos nacionales (hospedaje, alimentación, inscripción) y 1 congreso internacional. Servicios de publicación en revistas científicas indexadas (2 artículos). Internet dedicado y almacenamiento en nube para 12 meses.",
            partida3000_s1: "35000",
            partida3000_s2: "40000",
            
            // Partida 4000 - Transferencias y Subsidios
            justificacion4000: "Becas para estudiantes de maestría durante el proyecto. Apoyo económico para 2 tesistas de maestría y 3 estudiantes de licenciatura durante su participación en el proyecto.",
            partida4000_s1: "15000",
            partida4000_s2: "20000",
            
            // Partida 5000 - Bienes Muebles
            justificacion5000: "Adquisición de componentes electrónicos: 60 sensores BME280 ($150 c/u), 60 sensores MQ-135 ($200 c/u), 60 microcontroladores ESP32 ($250 c/u), 10 estaciones base Raspberry Pi 4 ($2,000 c/u), gabinetes protectores IP65, paneles solares, baterías, antenas LoRa.",
            partida5000_s1: "150000",
            partida5000_s2: "50000",
            
            // Partida 6000 - Inversión Pública
            justificacion6000: "Desarrollo de software especializado: licencias de software para análisis de datos (MATLAB, TensorFlow Enterprise), desarrollo de dashboard web personalizado, desarrollo de aplicación móvil iOS y Android, servidor dedicado para procesamiento de datos en la nube (12 meses).",
            partida6000_s1: "80000",
            partida6000_s2: "30000",
            
            // Partida 7000 - Inversiones Financieras
            justificacion7000: "No se contempla inversión en infraestructura física permanente. El proyecto utiliza infraestructura existente de las instituciones participantes.",
            partida7000_s1: "0",
            partida7000_s2: "0"
        }
    };
    localStorage.setItem('proyecto_borrador_pagina8', JSON.stringify(datosP8));
    localStorage.setItem('proyecto_borrador_pagina8_saved', '1');
    console.log('✅ Página 8 - Presupuesto (7 partidas con justificaciones)');

    // ============================================================
    // PÁGINA 9 - Documentación Final
    // Estructura: {pagina9: {doc_extenso}}
    // ============================================================
    const datosP9 = {
        pagina9: {
            doc_extenso: "proyecto_monitoreo_ambiental_completo.pdf"
        }
    };
    localStorage.setItem('proyecto_borrador_pagina9', JSON.stringify(datosP9));
    localStorage.setItem('proyecto_borrador_pagina9_saved', '1');
    console.log('✅ Página 9 - Documentación Final');

    console.log('');
    console.log('🎉 ¡DATOS DE PRUEBA CARGADOS EXITOSAMENTE!');
    console.log('');
    console.log('📋 Resumen de datos cargados:');
    console.log('   ✓ Página 1: Proyecto + 3 Responsables (estructura nested)');
    console.log('   ✓ Página 2: Resumen, antecedentes, objetivos (pagina2)');
    console.log('   ✓ Página 3: Metodología e impactos (pagina3)');
    console.log('   ✓ Página 4: 5 Participantes (participante1-5)');
    console.log('   ✓ Página 5: 5 Organizaciones (organizacion1-5)');
    console.log('   ✓ Página 6: 5 Estudiantes (estudiante1-5)');
    console.log('   ✓ Página 7: 12 Actividades en 4 semestres');
    console.log('   ✓ Página 8: 7 Partidas presupuestales');
    console.log('   ✓ Página 9: Documento extenso');
    console.log('');
    console.log('✨ MAPEO CORREGIDO:');
    console.log('   → Página 1: {proyecto: {...}, responsables: [...]}');
    console.log('   → Páginas 2-9: {paginaN: {...}}');
    console.log('   → Campos numerados: participanteN_, organizacionN_, estudianteN_');
    console.log('');
    console.log('💡 Recarga la página actual para ver los datos cargados');
    console.log('💡 Ahora puedes navegar por el formulario y los datos estarán pre-llenados');
}

// Función para limpiar todos los datos
function limpiarDatosPrueba() {
    console.log('🧹 Limpiando todos los datos de localStorage...');
    for (let i = 1; i <= 9; i++) {
        localStorage.removeItem('proyecto_borrador_pagina' + i);
        localStorage.removeItem('proyecto_borrador_pagina' + i + '_saved');
    }
    console.log('✅ Todos los datos han sido eliminados');
    console.log('💡 Recarga la página para ver los cambios');
}

// Función para exportar datos actuales
function exportarDatos() {
    console.log('📤 Exportando datos actuales...');
    const datosExportados = {};
    
    for (let i = 1; i <= 9; i++) {
        const key = 'proyecto_borrador_pagina' + i;
        const data = localStorage.getItem(key);
        if (data) {
            datosExportados[key] = JSON.parse(data);
        }
    }
    
    console.log('📋 Datos exportados (copia el objeto JSON de abajo):');
    console.log(JSON.stringify(datosExportados, null, 2));
    
    // Copiar al portapapeles si está disponible
    if (navigator.clipboard) {
        navigator.clipboard.writeText(JSON.stringify(datosExportados, null, 2))
            .then(() => console.log('✅ Datos copiados al portapapeles'))
            .catch(() => console.log('⚠️ No se pudo copiar al portapapeles automáticamente'));
    }
    
    return datosExportados;
}

// Función para importar datos desde un objeto JSON
function importarDatos(datosJSON) {
    console.log('📥 Importando datos...');
    
    let contador = 0;
    for (let key in datosJSON) {
        localStorage.setItem(key, JSON.stringify(datosJSON[key]));
        contador++;
    }
    
    console.log(`✅ ${contador} páginas importadas exitosamente`);
    console.log('💡 Recarga la página para ver los datos importados');
}

// Mostrar instrucciones al cargar el script
console.log('');
console.log('═══════════════════════════════════════════════════════════');
console.log('  📝 HERRAMIENTAS DE PRUEBA - REGISTRO DE PROYECTOS');
console.log('═══════════════════════════════════════════════════════════');
console.log('');
console.log('Comandos disponibles:');
console.log('');
console.log('  cargarDatosPrueba()    - Carga datos de ejemplo en todas las páginas');
console.log('  limpiarDatosPrueba()   - Elimina todos los datos guardados');
console.log('  exportarDatos()        - Exporta datos actuales como JSON');
console.log('  importarDatos(json)    - Importa datos desde un objeto JSON');
console.log('');
console.log('Ejemplo de uso:');
console.log('  1. cargarDatosPrueba()');
console.log('  2. Recarga la página');
console.log('  3. Navega por el formulario para ver los datos');
console.log('');
console.log('═══════════════════════════════════════════════════════════');
console.log('');
