import '../models/game_mission.dart';
import '../models/question.dart';
import '../models/minigame_type.dart';
import '../models/memory_pair.dart';
import '../data/mock_enemies.dart';

final List<GameMission> gameMissions = [
  GameMission(
    id: 'orco-amenaza',
    title: 'La Amenaza del Orco',
    narrative: '''
El Rey Aldric ha convocado a los más valientes del reino. 
Un orco astuto conocido como "Garruk el Sombrío" ha logrado infiltrarse en las cámaras reales y robar información crucial sobre las defensas del castillo.

Los sabios del reino temen que esta información sea utilizada para desestabilizar la seguridad de todas las aldeas vecinas. 
Tu misión es recuperar el conocimiento perdido y demostrar que eres digno de proteger la información más valiosa del reino.
''',
    shortDescription: 'El Rey Aldric necesita tu ayuda para recuperar información robada por un orco.',
    theoreticalHint: '''
La confidencialidad, integridad y disponibilidad son los pilares fundamentales de la seguridad de la información. 
Es tu deber como defensor del reino asegurarte de que esta información se mantenga protegida en todo momento.
''',
    minigameType: MinigameType.trivia,
    category: 'basico',
    missionType: MissionType.diaria,
    enemy: enemies[0],
    xpReward: 25,
    coinReward: 10,
    questions: [
      Question(
        text: '¿Qué significa la "C" en la tríada CIA de seguridad?',
        options: ['Confidencialidad', 'Control', 'Certificación', 'Conformidad'],
        correctIndex: 0,
        category: 'basico',
        explanation: 'La "C" representa la Confidencialidad, que asegura que la información solo sea accesible para quienes tienen autorización.',
      ),
      Question(
        text: '¿Qué principio asegura que la información esté disponible cuando se necesita?',
        options: ['Integridad', 'Disponibilidad', 'Autenticidad', 'Privacidad'],
        correctIndex: 1,
        category: 'basico',
        explanation: 'La Disponibilidad garantiza que la información esté accesible cuando sea requerida.',
      ),
      Question(
        text: '¿Qué significa "Integridad" en la seguridad de la información?',
        options: ['Acceso restringido', 'Precisión y consistencia de los datos', 'Cifrado de datos', 'Eliminación segura'],
        correctIndex: 1,
        category: 'basico',
        explanation: 'La Integridad asegura que la información no sea alterada de manera no autorizada.',
      ),
      Question(
        text: '¿Qué documento define las políticas y directrices para proteger la información en una organización?',
        options: ['Política de seguridad de la información', 'Manual del usuario', 'Política de vacaciones', 'Estatuto del empleado'],
        correctIndex: 0,
        category: 'basico',
        explanation: 'La Política de Seguridad de la Información establece las reglas para proteger los activos de información.',
      ),
      Question(
        text: '¿Qué es un control de acceso en seguridad de la información?',
        options: ['Un antivirus', 'Un permiso o restricción para acceder a recursos', 'Un firewall físico', 'Un respaldo manual'],
        correctIndex: 1,
        category: 'basico',
        explanation: 'Los controles de acceso limitan quién puede ver o modificar información según su rol y permisos.',
      ),
    ],
    memoryPairs: [], // ✅ Agregado
  ),
  GameMission(
    id: 'torre-saber',
    title: 'La Torre del Saber',
    narrative: '''
La Gran Torre del Saber, hogar de los Archimagos del Reino, ha sido infiltrada por una criatura misteriosa que alteró los registros de aprendizaje de los estudiantes.

El Archimago Eldrin te solicita personalmente que ingreses en la torre y restablezcas el conocimiento perdido, demostrando que comprendes los fundamentos que tanto se enseñan en sus salas.

El reino necesita guardianes que aseguren la integridad del saber.
''',
    shortDescription: 'El Archimago Eldrin necesita que restaures los registros alterados en la Torre del Saber.',
    theoreticalHint: '''
La integridad asegura que la información no sea alterada o destruida de manera no autorizada. 
Es crucial que toda la información del reino se mantenga precisa y confiable.
''',
    minigameType: MinigameType.trivia,
    category: 'basico',
    missionType: MissionType.diaria,
    enemy: enemies[1],
    xpReward: 25,
    coinReward: 10,
    questions: [
      Question(
        text: '¿Qué representa la "I" en la tríada CIA de seguridad?',
        options: ['Integridad', 'Interactividad', 'Identidad', 'Información'],
        correctIndex: 0,
        category: 'basico',
        explanation: 'La "I" significa Integridad, que asegura que la información no sea alterada sin autorización.',
      ),
      Question(
        text: '¿Qué elemento NO pertenece a la tríada CIA?',
        options: ['Confidencialidad', 'Integridad', 'Accesibilidad', 'Disponibilidad'],
        correctIndex: 2,
        category: 'basico',
        explanation: 'Accesibilidad no es parte de la tríada, los elementos son Confidencialidad, Integridad y Disponibilidad.',
      ),
      Question(
        text: '¿Qué es un incidente de integridad?',
        options: ['Acceso no autorizado', 'Modificación no autorizada de datos', 'Pérdida de acceso a la información', 'Divulgación accidental'],
        correctIndex: 1,
        category: 'basico',
        explanation: 'Un incidente de integridad es cuando los datos son modificados sin autorización.',
      ),
    ],
    memoryPairs: [], // ✅ Agregado
  ),
  GameMission(
    id: 'enigma-ahorcado',
    title: 'El Enigma del Ahorcado',
    narrative: '''
La Torre de los Susurros ha sido sellada por un antiguo hechicero. 
Para romper el hechizo, debes descifrar las palabras mágicas ocultas en el aire, letra por letra, o serás atrapado en la maldición eterna.

El sabio Orlen te ha confiado esta misión, solo un verdadero conocedor del lenguaje de la seguridad podrá liberar la torre.
''',
    shortDescription: 'Descifra las palabras mágicas para romper la maldición de la Torre de los Susurros.',
    theoreticalHint: '''
Presta atención a las terminologías claves sobre gestión y control. El conocimiento correcto es la clave para liberar el hechizo.
''',
    minigameType: MinigameType.hangman,
    category: 'intermedio',
    missionType: MissionType.semanal,
    hangmanWord: 'PASSWORD',
    enemy: enemies[2],
    questions: [],
    memoryPairs: [], // ✅ Agregado
  ),
  GameMission(
    id: 'desafio-guardian',
    title: 'El Desafío del Guardián de la Sabiduría',
    narrative: '''
El Guardián de la Sabiduría ha lanzado un hechizo sobre los libros del reino, mezclando conceptos con definiciones.

Tu misión es restablecer el conocimiento emparejando cada concepto con su definición antes de que el Guardián destruya las memorias del reino.
''',
    shortDescription: 'Empareja conceptos y definiciones para vencer al Guardián.',
    theoreticalHint: '''
Comprender cada término es esencial para aplicar correctamente las normas de seguridad de la información.
''',
    minigameType: MinigameType.memory,
    category: 'intermedio',
    missionType: MissionType.semanal,
    enemy: enemies[2],
    questions: [],
    memoryPairs: [
      MemoryPair(concept: 'Autenticación', definition: 'Verificar la identidad de un usuario.'),
      MemoryPair(concept: 'Autorización', definition: 'Permitir acceso solo a recursos permitidos.'),
      MemoryPair(concept: 'Trazabilidad', definition: 'Rastrear quién accedió y qué hizo.'),
    ], // ✅ Agregado con contenido
  ),
];
