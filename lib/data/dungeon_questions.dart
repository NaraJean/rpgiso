import '../models/question.dart';

final List<Question> dungeonQuestions = [
  // Tema 1: Contraseñas seguras
  Question(
    text: '¿Cuál de las siguientes opciones representa una contraseña más segura?',
    options: [
      'Usar el nombre propio y el año de nacimiento',
      'Usar una contraseña larga con letras, números y caracteres especiales',
      'Usar la misma contraseña para todas las cuentas',
      'Usar una palabra corta fácil de recordar',
    ],
    correctIndex: 1,
    category: 'Contraseñas seguras',
    explanation:
        'Una contraseña segura debe ser larga, combinar diferentes tipos de caracteres y evitar datos personales.',
  ),
  Question(
    text: '¿Por qué no se recomienda usar datos personales en una contraseña?',
    options: [
      'Porque pueden ser fáciles de adivinar',
      'Porque hacen que la cuenta sea más rápida',
      'Porque bloquean el acceso automáticamente',
      'Porque impiden usar números',
    ],
    correctIndex: 0,
    category: 'Contraseñas seguras',
    explanation:
        'Los datos personales pueden ser conocidos o encontrados fácilmente por un atacante.',
  ),
  Question(
    text:
        'Reutilizar la misma contraseña en varias cuentas aumenta el riesgo si una de ellas es comprometida.',
    options: [
      'Verdadero',
      'Falso',
    ],
    correctIndex: 0,
    category: 'Contraseñas seguras',
    explanation:
        'Si una contraseña se filtra, todas las cuentas que usen esa misma clave pueden quedar en riesgo.',
  ),
  Question(
    text: '¿Cuál de estas prácticas debilita una contraseña?',
    options: [
      'Usar mayúsculas y minúsculas',
      'Agregar números',
      'Usar caracteres especiales',
      'Usar nombres o fechas personales',
    ],
    correctIndex: 3,
    category: 'Contraseñas seguras',
    explanation:
        'Los nombres, fechas y datos personales hacen que la contraseña sea más fácil de adivinar.',
  ),
  Question(
    text: '¿Qué puede pasar si una persona usa la misma clave en varios servicios?',
    options: [
      'Si una cuenta cae, las demás pueden quedar en riesgo',
      'Todas las cuentas quedan automáticamente protegidas',
      'La contraseña se vuelve más fuerte',
      'El sistema detecta menos ataques',
    ],
    correctIndex: 0,
    category: 'Contraseñas seguras',
    explanation:
        'La reutilización de contraseñas facilita que un atacante pruebe la misma clave en otros servicios.',
  ),
  Question(
    text: 'Una contraseña fuerte debe evitar información personal fácil de conocer.',
    options: [
      'Verdadero',
      'Falso',
    ],
    correctIndex: 0,
    category: 'Contraseñas seguras',
    explanation:
        'Una contraseña fuerte debe evitar datos personales como nombres, fechas o identificaciones.',
  ),

  // Tema 2: Phishing y mensajes falsos
  Question(
    text: '¿Cuál de estas señales puede indicar un intento de phishing?',
    options: [
      'Un mensaje con urgencia falsa',
      'Una comunicación por canal oficial',
      'Un respaldo verificado',
      'Un inicio de sesión normal',
    ],
    correctIndex: 0,
    category: 'Phishing',
    explanation:
        'La urgencia falsa busca que la persona actúe rápido sin verificar la información.',
  ),
  Question(
    text:
        'Si un mensaje pide entregar una clave o información sensible, ¿qué se debe hacer?',
    options: [
      'Responder rápido para evitar problemas',
      'Entregar los datos si el mensaje parece urgente',
      'Verificar por un canal oficial antes de actuar',
      'Compartir el mensaje con otros usuarios',
    ],
    correctIndex: 2,
    category: 'Phishing',
    explanation:
        'Nunca se deben entregar claves por mensajes sospechosos. Lo correcto es verificar por canales oficiales.',
  ),
  Question(
    text:
        'La urgencia falsa puede usarse para presionar a una persona y hacer que actúe sin pensar.',
    options: [
      'Verdadero',
      'Falso',
    ],
    correctIndex: 0,
    category: 'Phishing',
    explanation:
        'La presión psicológica es una técnica común en ataques de ingeniería social.',
  ),
  Question(
    text: '¿Qué se debe hacer ante un enlace sospechoso o desconocido?',
    options: [
      'Abrirlo para confirmar si funciona',
      'Evitar usarlo',
      'Ingresar los datos y luego cambiar la contraseña',
      'Reenviarlo para que otros lo revisen',
    ],
    correctIndex: 1,
    category: 'Phishing',
    explanation:
        'Los enlaces sospechosos pueden llevar a sitios falsos o descargar contenido malicioso.',
  ),
  Question(
    text: '¿Qué es la suplantación de identidad en un ataque digital?',
    options: [
      'Fingir ser una persona o entidad confiable',
      'Crear una copia de seguridad',
      'Cambiar los permisos de acceso',
      'Restaurar información dañada',
    ],
    correctIndex: 0,
    category: 'Phishing',
    explanation:
        'La suplantación ocurre cuando el atacante finge ser alguien confiable para engañar a la víctima.',
  ),
  Question(
    text:
        'Un mensaje que amenaza con perder el acceso si no se actúa rápido puede ser sospechoso.',
    options: [
      'Verdadero',
      'Falso',
    ],
    correctIndex: 0,
    category: 'Phishing',
    explanation:
        'Las amenazas urgentes son una señal frecuente de phishing o ingeniería social.',
  ),

  // Tema 3: Control de acceso
  Question(
    text: '¿Qué significa aplicar el principio de mínimo privilegio?',
    options: [
      'Dar acceso total a todos los usuarios',
      'Dar solo el acceso necesario para realizar una tarea',
      'Eliminar todas las cuentas del sistema',
      'Compartir una cuenta de administrador',
    ],
    correctIndex: 1,
    category: 'Control de acceso',
    explanation:
        'El mínimo privilegio reduce riesgos dando solo los permisos necesarios.',
  ),
  Question(
    text: '¿Cuál es un riesgo de dar permisos excesivos?',
    options: [
      'Aumenta la posibilidad de accesos indebidos',
      'Reduce los incidentes automáticamente',
      'Hace innecesario controlar usuarios',
      'Mejora la seguridad sin revisión',
    ],
    correctIndex: 0,
    category: 'Control de acceso',
    explanation:
        'Los permisos excesivos aumentan el impacto si una cuenta es mal usada o comprometida.',
  ),
  Question(
    text:
        'Mantener activos los permisos de un usuario que ya no pertenece a la organización representa un riesgo.',
    options: [
      'Verdadero',
      'Falso',
    ],
    correctIndex: 0,
    category: 'Control de acceso',
    explanation:
        'Los accesos de usuarios retirados deben eliminarse para evitar usos indebidos.',
  ),
  Question(
    text: '¿Qué debe hacerse con una persona que ya no debe tener acceso al sistema?',
    options: [
      'Mantenerle el acceso por si vuelve',
      'Retirar sus permisos',
      'Darle acceso limitado al panel técnico',
      'Compartirle otra cuenta',
    ],
    correctIndex: 1,
    category: 'Control de acceso',
    explanation:
        'Cuando una persona ya no necesita acceso, sus permisos deben retirarse.',
  ),
  Question(
    text: '¿Por qué no se deben compartir cuentas de administrador?',
    options: [
      'Porque dificulta el control y aumenta el riesgo',
      'Porque hace que el sistema sea más lento',
      'Porque impide crear respaldos',
      'Porque elimina los mensajes falsos',
    ],
    correctIndex: 0,
    category: 'Control de acceso',
    explanation:
        'Compartir cuentas impide saber quién realizó una acción y aumenta el riesgo de abuso.',
  ),
  Question(
    text: 'Dar acceso mínimo necesario ayuda a reducir el riesgo.',
    options: [
      'Verdadero',
      'Falso',
    ],
    correctIndex: 0,
    category: 'Control de acceso',
    explanation:
        'El acceso mínimo limita daños y reduce posibilidades de uso indebido.',
  ),

  // Tema 4: Copias de seguridad
  Question(
    text: '¿Para qué sirven las copias de seguridad?',
    options: [
      'Para recuperar información perdida o dañada',
      'Para reemplazar las contraseñas',
      'Para permitir accesos excesivos',
      'Para evitar revisar permisos',
    ],
    correctIndex: 0,
    category: 'Copias de seguridad',
    explanation:
        'Los respaldos permiten recuperar información ante pérdida, daño o incidentes.',
  ),
  Question(
    text: '¿Qué característica debe tener un respaldo confiable?',
    options: [
      'Estar verificado y servir para restaurar información',
      'Ser antiguo, incompleto y no probado',
      'Estar corrupto pero disponible',
      'No necesitar revisión',
    ],
    correctIndex: 0,
    category: 'Copias de seguridad',
    explanation:
        'Un respaldo confiable debe probarse y permitir restaurar información correctamente.',
  ),
  Question(
    text:
        'Guardar una copia de seguridad sin comprobar si funciona puede ser una mala práctica.',
    options: [
      'Verdadero',
      'Falso',
    ],
    correctIndex: 0,
    category: 'Copias de seguridad',
    explanation:
        'Un respaldo no probado puede fallar cuando más se necesita.',
  ),
  Question(
    text:
        'Si existen varias versiones de respaldo, ¿qué se debe revisar antes de restaurar?',
    options: [
      'Fecha, estado e integridad',
      'Color del archivo',
      'Nombre del usuario',
      'Diseño del sistema',
    ],
    correctIndex: 0,
    category: 'Copias de seguridad',
    explanation:
        'Antes de restaurar se debe verificar fecha, estado e integridad del respaldo.',
  ),
  Question(
    text: '¿Cuál es un paso correcto en un proceso de recuperación?',
    options: [
      'Identificar los datos afectados',
      'Compartir la cuenta de administrador',
      'Abrir enlaces desconocidos',
      'Ignorar el daño',
    ],
    correctIndex: 0,
    category: 'Copias de seguridad',
    explanation:
        'Identificar los datos afectados ayuda a restaurar correctamente la información.',
  ),
  Question(
    text:
        'Después de restaurar información, es importante comprobar que funcione correctamente.',
    options: [
      'Verdadero',
      'Falso',
    ],
    correctIndex: 0,
    category: 'Copias de seguridad',
    explanation:
        'Después de restaurar se debe validar que los datos y sistemas funcionen correctamente.',
  ),

  // Tema 5: Incidentes de seguridad
  Question(
    text: '¿Cuál de estas situaciones puede considerarse un incidente de seguridad?',
    options: [
      'Un usuario inicia sesión normalmente',
      'Una cuenta robada accede a archivos sensibles',
      'Un usuario consulta sus propios datos',
      'Una contraseña tiene caracteres especiales',
    ],
    correctIndex: 1,
    category: 'Incidentes de seguridad',
    explanation:
        'Una cuenta robada con acceso a información sensible es un incidente de seguridad.',
  ),
  Question(
    text: '¿Cuál de estas acciones tiene prioridad alta ante una cuenta comprometida?',
    options: [
      'Cambiar la estética del portal',
      'Contener la cuenta comprometida',
      'Ignorar la alerta',
      'Esperar a que el problema desaparezca',
    ],
    correctIndex: 1,
    category: 'Incidentes de seguridad',
    explanation:
        'Contener la cuenta comprometida reduce el daño y evita accesos indebidos.',
  ),
  Question(
    text: 'Un respaldo corrupto detectado puede representar un riesgo crítico.',
    options: [
      'Verdadero',
      'Falso',
    ],
    correctIndex: 0,
    category: 'Incidentes de seguridad',
    explanation:
        'Un respaldo corrupto puede impedir la recuperación ante un incidente.',
  ),
  Question(
    text: '¿Cuál es una acción adecuada ante una cuenta comprometida?',
    options: [
      'Cambiar contraseña, cerrar sesiones y activar doble factor',
      'Compartir la contraseña con otros usuarios',
      'Ignorar el acceso sospechoso',
      'Usar la misma contraseña en más cuentas',
    ],
    correctIndex: 0,
    category: 'Incidentes de seguridad',
    explanation:
        'Cambiar la contraseña, cerrar sesiones y activar doble factor ayuda a recuperar el control.',
  ),
  Question(
    text: '¿Cuál es un orden adecuado dentro de la respuesta a un incidente?',
    options: [
      'Detectar, reportar, contener, analizar y recuperar',
      'Recuperar, ignorar, compartir y olvidar',
      'Cambiar colores, cerrar sesión y borrar evidencias',
      'Capacitar primero y detectar después',
    ],
    correctIndex: 0,
    category: 'Incidentes de seguridad',
    explanation:
        'Una respuesta ordenada permite controlar el incidente y recuperar la operación.',
  ),
  Question(
    text:
        'Después de un incidente, documentar, capacitar y mejorar ayuda a prevenir futuros problemas.',
    options: [
      'Verdadero',
      'Falso',
    ],
    correctIndex: 0,
    category: 'Incidentes de seguridad',
    explanation:
        'Documentar y mejorar después del incidente ayuda a reducir la repetición de errores.',
  ),
];