import '../models/narrative_mission.dart';
import '../models/mission_step.dart';
import '../models/npc_dialogue.dart';
import '../models/step_type.dart';
import '../models/minigame_type.dart';
import '../models/question.dart';
import '../models/game_mission.dart';
import 'mock_enemies.dart';

/// Lista principal de misiones narrativas de DataGuardians.
///
/// Estas misiones representan la campaña principal del prototipo.
final List<NarrativeMission> narrativeMissions = [
  NarrativeMission(
    id: 'llave_guardian',
    order: 1,
    title: 'La Llave del Guardián',
    concept: 'Contraseñas seguras',
    isoRelation:
        'Relacionado con controles de acceso, autenticación y protección de credenciales dentro de la gestión de seguridad de la información.',
    shortDescription:
        'Forja tu primera llave mágica aprendiendo cómo crear contraseñas seguras y defenderlas ante un enemigo.',
    missionType: MissionType.diaria,
    category: 'basico',
    backgroundAsset: 'assets/backgrounds/story_bg.png',
    xpReward: 120,
    coinReward: 60,
    specialReward: 'Llave Rúnica',
    requiredMissionIds: const [],
    prologue: const NpcDialogue(
      npcName: 'Maestra Elyra',
      text:
          'Bienvenido, Guardián.\n\n'
          'Antes de proteger el Reino de los Datos, necesitas tu primera llave personal.\n\n'
          'Pero escucha bien: una llave débil puede abrirle la puerta al enemigo antes de que siquiera desenvaine su espada.',
    ),
    steps: [
      MissionStep(
        id: 'llave_guardian_escena_forja',
        title: 'La Forja de Sellos',
        stepType: StepType.story,
        minigameType: MinigameType.none,
        contextText:
            'Llegas a la Forja de Sellos, una sala circular iluminada por lava azul. '
            'En el centro hay un yunque de cristal donde los guardianes crean sus llaves personales.\n\n'
            'Las paredes están cubiertas de antiguas runas. Algunas brillan con fuerza. '
            'Otras parecen agrietadas, como si hubieran fallado demasiadas veces.',
        allegoryText:
            'En esta misión, las llaves representan las contraseñas. '
            'Una contraseña débil facilita que un atacante acceda a cuentas, sistemas o información protegida.',
        autoComplete: true,
        winDialogueText:
            'La Forja de Sellos está lista. Ahora debes aprender qué hace fuerte a una llave.',
        winNpcName: 'Maestra Elyra',
      ),
      MissionStep(
        id: 'llave_guardian_dialogo_inicial',
        title: 'La advertencia del Forjador',
        stepType: StepType.dialogue,
        minigameType: MinigameType.none,
        contextText:
            'Maestra Elyra y el Forjador Brann te explican la importancia de crear una llave segura.',
        dialogues: const [
          NpcDialogue(
            npcName: 'Maestra Elyra',
            text:
                'Todo guardián necesita una llave. Pero no cualquier llave.\n\n'
                'Una débil puede abrirle la puerta al enemigo antes de que siquiera desenvaine su espada.',
          ),
          NpcDialogue(
            npcName: 'Forjador Brann',
            text:
                'He visto aprendices usar su nombre, su cumpleaños y hasta “reino123”.\n\n'
                'Luego preguntan por qué los atacaron. Misterios de la inteligencia mortal.',
          ),
          NpcDialogue(
            npcName: 'Maestra Elyra',
            text:
                'Hoy no solo crearás una llave. Aprenderás a reconocer qué la hace resistente.',
          ),
        ],
        autoComplete: true,
        winDialogueText:
            'Brann coloca varias runas sobre la mesa. Algunas fortalecen la llave. Otras la debilitan.',
        winNpcName: 'Forjador Brann',
      ),
      MissionStep(
        id: 'llave_guardian_concepto',
        title: 'Códice: Contraseña segura',
        stepType: StepType.concept,
        minigameType: MinigameType.none,
        contextText:
            'Término real desbloqueado: Contraseña segura.\n\n'
            'Una contraseña segura es una credencial diseñada para ser difícil de adivinar, probar o reutilizar por un atacante.\n\n'
            'Debe tener buena longitud, combinar distintos tipos de caracteres, evitar datos personales y no repetirse en varias cuentas.',
        allegoryText:
            'En el reino, una llave fuerte protege una puerta. '
            'En ciberseguridad, una contraseña segura protege una cuenta, sistema o servicio.',
        dialogues: const [
          NpcDialogue(
            npcName: 'Forjador Brann',
            text:
                'Mira estas runas, Guardián. Una sola no basta para crear una llave resistente.\n\n'
                'Una llave corta se rompe rápido. Una llave obvia se copia fácil. Y una llave repetida... bueno, esa ya viene con invitación para el enemigo.',
          ),
          NpcDialogue(
            npcName: 'Maestra Elyra',
            text:
                'En tu mundo, esta llave se llama contraseña.\n\n'
                'Una contraseña protege el acceso a una cuenta o sistema, pero solo funciona bien si es difícil de adivinar y no se reutiliza en todas partes.',
          ),
          NpcDialogue(
            npcName: 'Forjador Brann',
            text:
                'Por eso combinamos runas: longitud, mezcla de letras, números, símbolos y secreto.\n\n'
                'Y por todos los dragones del reino, no uses tu nombre ni tu cumpleaños. Eso no es una llave, es una nota pegada en la puerta.',
          ),
          NpcDialogue(
            npcName: 'Maestra Elyra',
            text:
                'Recuerda estos términos reales: contraseña, credencial, datos personales y reutilización de contraseñas.\n\n'
                'La magia del reino es una metáfora, pero el riesgo existe fuera de aquí.',
          ),
        ],
        autoComplete: true,
        winDialogueText:
            'El Códice del Guardián registra el concepto de contraseña segura.',
        winNpcName: 'Maestra Elyra',
      ),
      MissionStep(
        id: 'llave_guardian_decision_runa_debil',
        title: 'Decisión: La runa sospechosa',
        stepType: StepType.event,
        minigameType: MinigameType.narrativeChoice,
        minigameLabel: 'Microevento: decisión de seguridad',
        preStepDialogue: const NpcDialogue(
          npcName: 'Forjador Brann',
          text:
              'Antes de tocar el yunque, quiero ver si aprendiste algo.\n\n'
              'Una llave puede verse brillante y aun así ser débil. Dime, Guardián: ¿qué elemento sería más peligroso al crear tu contraseña?',
        ),
        contextText:
            'Brann te muestra tres runas. Una de ellas representa una mala práctica que debilita una contraseña.',
        allegoryText:
            'Este microevento refuerza que una contraseña no debe basarse en datos personales ni patrones fáciles de adivinar.',
        options: const [
          'Usar una frase larga y difícil de adivinar',
          'Incluir tu nombre o fecha de nacimiento',
          'Combinar letras, números y símbolos',
        ],
        correctOptionIndexes: const [1],
        extraData: const {
          'npcName': 'Forjador Brann',
          'question':
              '¿Cuál de estas decisiones debilita más una contraseña?',
          'correctFeedback':
              'Correcto. Usar datos personales hace que una contraseña sea más fácil de adivinar o descubrir.',
          'wrongFeedback':
              'Esa no era la runa peligrosa. Una contraseña larga y variada suele ser más segura. El problema está en usar datos personales.',
          'technicalNote':
              'Una contraseña segura debe evitar nombres, fechas, apodos, documentos, equipos favoritos o datos que puedan encontrarse fácilmente.',
          'mustBeCorrect': false,
        },
        winDialogueText:
            'Brann retira la runa familiar del yunque.\n\n'
            'La forja queda lista para crear una llave más resistente.',
        winNpcName: 'Forjador Brann',
      ),
      MissionStep(
        id: 'llave_guardian_forja',
        title: 'Forja de la Llave',
        stepType: StepType.minigame,
        minigameType: MinigameType.runeForge,
        minigameLabel: 'Minijuego: Forja de la Llave',
        preStepDialogue: const NpcDialogue(
          npcName: 'Forjador Brann',
          text:
              'Sobre el yunque hay siete runas.\n\n'
              'Cinco harán que tu llave sea resistente. Dos parecen útiles, pero la debilitarán.\n\n'
              'Elige como guardián, no como alguien que usa “123456” y luego culpa al destino.',
        ),
        contextText:
            'Selecciona las runas que representan buenas prácticas para crear una contraseña segura.\n\n'
            'Recuerda los términos reales: longitud, variedad de caracteres, secreto y no reutilización.',
        allegoryText:
            'Seleccionar buenas runas equivale a construir una contraseña robusta. '
            'Usar datos personales o repetir contraseñas aumenta el riesgo.',
        options: const [
          'Runa de longitud',
          'Runa de mezcla',
          'Runa numérica',
          'Runa especial',
          'Runa secreta',
          'Runa repetida',
          'Runa familiar',
        ],
        correctOptionIndexes: const [0, 1, 2, 3, 4],
        extraData: const {
          'resultWeak': 'Llave débil',
          'resultMedium': 'Llave media',
          'resultStrong': 'Llave fuerte',
          'resultLegendary': 'Llave legendaria',
          'wrongOptionsExplanation':
              'La Runa repetida representa reutilizar contraseñas. La Runa familiar representa usar nombres, fechas o datos personales.',
        },
        winDialogueText:
            'La llave brilla sobre el yunque. No es solo metal encantado: es tu primera defensa.\n\n'
            'Has demostrado que una llave fuerte no depende de una sola runa, sino de la combinación correcta.',
        winNpcName: 'Forjador Brann',
      ),
      MissionStep(
        id: 'llave_guardian_evento_golem',
        title: 'La prueba de la Forja',
        stepType: StepType.event,
        minigameType: MinigameType.none,
        contextText:
            'Cuando terminas la llave, la Forja de Sellos tiembla.\n\n'
            'El yunque de cristal se abre lentamente y una figura de piedra despierta entre humo azul. '
            'Sus ojos brillan como cerraduras antiguas.\n\n'
            'La forja ha decidido probar si realmente entiendes cómo proteger tu llave.',
        preStepDialogue: const NpcDialogue(
          npcName: 'Forjador Brann',
          text:
              'No te emociones. La forja siempre prueba a los nuevos.\n\n'
              'Si tu llave es mala, el gólem te lo explicará con violencia pedagógica.',
        ),
        autoComplete: true,
        winDialogueText:
            'El Gólem de la Cerradura Débil se alza frente a ti. La prueba comienza.',
        winNpcName: 'Forjador Brann',
      ),
      MissionStep(
        id: 'llave_guardian_combate_golem',
        title: 'Combate: Gólem de la Cerradura Débil',
        stepType: StepType.combat,
        minigameType: MinigameType.trivia,
        minigameLabel: 'Combate RPG',
        contextText:
            'El Gólem de la Cerradura Débil intentará confundirte con malas prácticas de seguridad.\n\n'
            'Responde correctamente para atacar con tu Llave Rúnica. '
            'Si fallas, el gólem golpeará y perderás vida.',
        preStepDialogue: const NpcDialogue(
          npcName: 'Gólem de la Cerradura Débil',
          text:
              'Las llaves simples son cómodas.\n\n'
              'Los guardianes débiles prefieren recordar poco y arriesgar mucho.',
        ),
        enemy: getEnemyById('golem_cerradura_debil'),
        showBattleWidget: true,
        questions: [
          Question(
            text:
                'Usar la misma contraseña en todos los portales es cómodo. ¿Es una buena práctica?',
            options: [
              'Sí, porque así no se olvida',
              'No, si una cuenta cae, las demás quedan en riesgo',
              'Solo si nadie se da cuenta',
              'Sí, pero cambiando el color del portal',
            ],
            correctIndex: 1,
            category: 'basico',
            explanation:
                'Reutilizar contraseñas es riesgoso. Si una cuenta es comprometida, otras cuentas con la misma contraseña también pueden quedar expuestas.',
          ),
          Question(
            text: '¿Cuál de estas opciones representa una contraseña más segura?',
            options: [
              'juan123',
              '12345678',
              'MiReino!Azul#472',
              'cumple2005',
            ],
            correctIndex: 2,
            category: 'basico',
            explanation:
                'Una contraseña más segura combina longitud, letras, números, símbolos y evita datos personales fáciles de adivinar.',
          ),
          Question(
            text:
                '¿Por qué no es recomendable usar fechas de cumpleaños como contraseña?',
            options: [
              'Porque son difíciles de escribir',
              'Porque pueden ser datos fáciles de adivinar o encontrar',
              'Porque no se pueden usar números',
              'Porque hacen lenta la aplicación',
            ],
            correctIndex: 1,
            category: 'basico',
            explanation:
                'Las fechas personales pueden ser conocidas o encontradas por atacantes, por lo que no deben usarse como base de una contraseña.',
          ),
          Question(
            text: '¿Qué característica ayuda a fortalecer una contraseña?',
            options: [
              'Que sea corta',
              'Que use solo letras minúsculas',
              'Que combine longitud, variedad y secreto',
              'Que sea igual al nombre del usuario',
            ],
            correctIndex: 2,
            category: 'basico',
            explanation:
                'Una contraseña fuerte debe tener suficiente longitud, variedad de caracteres y no incluir información personal evidente.',
          ),
          Question(
            text:
                'Si sospechas que tu contraseña fue robada, ¿qué deberías hacer?',
            options: [
              'Esperar a ver si pasa algo',
              'Compartirla con alguien de confianza',
              'Cambiarla y cerrar sesiones activas si es posible',
              'Usarla solo en la noche',
            ],
            correctIndex: 2,
            category: 'basico',
            explanation:
                'Si una contraseña puede estar comprometida, debe cambiarse pronto y se recomienda cerrar sesiones activas para reducir el riesgo.',
          ),
        ],
        winDialogueText:
            'El Gólem cae de rodillas. Sus ojos de cerradura se apagan lentamente.\n\n'
            'Tu Llave Rúnica resistió la prueba.',
        winNpcName: 'Maestra Elyra',
      ),
      MissionStep(
        id: 'llave_guardian_cierre',
        title: 'Una llave también puede ser engañada',
        stepType: StepType.closing,
        minigameType: MinigameType.none,
        contextText:
            'La Forja de Sellos vuelve a quedar en silencio. '
            'La Llave Rúnica flota por un instante y luego se posa en tu mano.\n\n'
            'Has aprendido que una contraseña segura debe ser larga, variada, única y no basada en datos personales.',
        preStepDialogue: const NpcDialogue(
          npcName: 'Maestra Elyra',
          text:
              'Tu llave ya no es solo un objeto. Es una responsabilidad.\n\n'
              'Pero recuerda: incluso la mejor llave puede perderse si alguien te engaña para entregarla.',
        ),
        allegoryText:
            'Esta misión introduce la protección de credenciales. '
            'La siguiente misión abordará cómo los atacantes pueden engañar a las personas para que entreguen sus llaves mediante mensajes falsos.',
        autoComplete: true,
        winDialogueText:
            'Has completado tu entrenamiento inicial como Guardián.',
        winNpcName: 'Maestra Elyra',
      ),
    ],
  ),

  NarrativeMission(
    id: 'mensaje_impostor',
    order: 2,
    title: 'El Mensaje del Impostor',
    concept: 'Phishing',
    isoRelation:
        'Relacionado con concienciación en seguridad, protección de credenciales, reporte de eventos sospechosos y prevención de ingeniería social.',
    shortDescription:
        'Investiga un mensaje sospechoso, detecta señales de phishing y enfrenta al Heraldo Impostor antes de que robe más llaves.',
    missionType: MissionType.diaria,
    category: 'basico',
    backgroundAsset: 'assets/backgrounds/story_bg.png',
    xpReward: 150,
    coinReward: 75,
    specialReward: 'Sello Antiengaño',
    requiredMissionIds: const ['llave_guardian'],
    prologue: const NpcDialogue(
      npcName: 'Maestra Elyra',
      text:
          'Guardián, tu llave ya fue forjada.\n\n'
          'Pero una llave fuerte no sirve de nada si tú mismo se la entregas al enemigo.\n\n'
          'Hoy conocerás una amenaza más silenciosa: el engaño disfrazado de mensaje urgente.',
    ),
    steps: [
      MissionStep(
        id: 'mensaje_impostor_mercado',
        title: 'El Mercado de los Mensajes',
        stepType: StepType.story,
        minigameType: MinigameType.none,
        contextText:
            'Llegas al Mercado de los Mensajes, un lugar lleno de pergaminos voladores, cuervos mensajeros y sellos mágicos.\n\n'
            'Los ciudadanos reciben avisos del Consejo Real todos los días, pero hoy algo se siente distinto. '
            'Algunos pergaminos tiemblan, otros tienen tinta corrida, y varios ciudadanos parecen confundidos.',
        allegoryText:
            'El Mercado de los Mensajes representa el correo electrónico, mensajes de texto, redes sociales y otros canales digitales donde pueden aparecer intentos de phishing.',
        autoComplete: true,
        winDialogueText:
            'Entre el ruido del mercado, una mensajera se acerca con un pergamino extraño.',
        winNpcName: 'Maestra Elyra',
      ),
      MissionStep(
        id: 'mensaje_impostor_dialogo_lira',
        title: 'El pergamino sospechoso',
        stepType: StepType.dialogue,
        minigameType: MinigameType.none,
        contextText:
            'La Mensajera Lira ha interceptado un mensaje que parece venir del Consejo Real, pero varios detalles no encajan.',
        dialogues: const [
          NpcDialogue(
            npcName: 'Mensajera Lira',
            text:
                'Guardián, necesito tu ayuda.\n\n'
                'Este pergamino dice que varios ciudadanos perderán el acceso a sus cofres si no entregan su llave hoy mismo.',
          ),
          NpcDialogue(
            npcName: 'Ciudadano Nervioso',
            text:
                '¡Dice que es urgente! Si no obedezco, perderé mi cuenta del reino. Eso suena oficial, ¿no?',
          ),
          NpcDialogue(
            npcName: 'Maestra Elyra',
            text:
                'Los atacantes aman la urgencia. Hace que la gente actúe primero y piense después.\n\n'
                'Una estrategia brillante, considerando que muchos humanos ya hacen eso gratis.',
          ),
          NpcDialogue(
            npcName: 'Mensajera Lira',
            text:
                'Necesitamos revisar el pergamino antes de que alguien entregue su llave.',
          ),
        ],
        autoComplete: true,
        winDialogueText:
            'Lira extiende el pergamino sobre una mesa. Varias señales parecen sospechosas.',
        winNpcName: 'Mensajera Lira',
      ),
      MissionStep(
        id: 'mensaje_impostor_concepto',
        title: 'Códice: Phishing',
        stepType: StepType.concept,
        minigameType: MinigameType.none,
        contextText:
            'Término real desbloqueado: Phishing.\n\n'
            'El phishing es un ataque de ingeniería social en el que un atacante se hace pasar por una persona, empresa o institución confiable para robar información sensible.\n\n'
            'Puede buscar contraseñas, códigos, credenciales, datos personales o acceso a sistemas.',
        allegoryText:
            'En el reino, el impostor pide una llave usando un pergamino falso. '
            'En la vida real, un atacante puede usar correos, mensajes, enlaces o formularios falsos para robar credenciales.',
        dialogues: const [
          NpcDialogue(
            npcName: 'Mensajera Lira',
            text:
                'Este pergamino intenta asustar a los ciudadanos para que entreguen sus llaves.\n\n'
                'No rompe cerraduras. Convence a otros de abrirlas.',
          ),
          NpcDialogue(
            npcName: 'Maestra Elyra',
            text:
                'En tu mundo, este tipo de engaño se llama phishing.\n\n'
                'Es una forma de ingeniería social: el atacante manipula la confianza, el miedo o la urgencia para obtener información sensible.',
          ),
          NpcDialogue(
            npcName: 'Ciudadano Nervioso',
            text:
                'Entonces... ¿el peligro no es solo el enlace extraño?\n\n'
                'También es la presión que me hace querer obedecer sin pensar.',
          ),
          NpcDialogue(
            npcName: 'Maestra Elyra',
            text:
                'Exacto. El enlace es el anzuelo. La urgencia es la cuerda. Tu credencial es el premio.\n\n'
                'Por eso debes reconocer términos reales como phishing, credenciales, remitente, enlace sospechoso e ingeniería social.',
          ),
        ],
        autoComplete: true,
        winDialogueText:
            'El Códice del Guardián registra el concepto de phishing.',
        winNpcName: 'Maestra Elyra',
      ),
      MissionStep(
        id: 'mensaje_impostor_decision_revision',
        title: 'Decisión: ¿Qué revisas primero?',
        stepType: StepType.event,
        minigameType: MinigameType.narrativeChoice,
        minigameLabel: 'Microevento: análisis de phishing',
        preStepDialogue: const NpcDialogue(
          npcName: 'Mensajera Lira',
          text:
              'El pergamino parece oficial, pero algo no encaja.\n\n'
              'Antes de marcar pistas al azar como si estuvieras jugando lotería con la seguridad del reino, dime: ¿qué revisarías primero?',
        ),
        contextText:
            'Lira te entrega el pergamino sospechoso. Debes decidir cuál sería el primer elemento importante a revisar.',
        allegoryText:
            'En un posible phishing, es importante revisar el remitente, enlaces, urgencia, amenazas y solicitudes de información sensible.',
        options: const [
          'El remitente y el dominio desde donde fue enviado',
          'El color decorativo del pergamino',
          'Si el mensaje usa palabras elegantes',
        ],
        correctOptionIndexes: const [0],
        extraData: const {
          'npcName': 'Mensajera Lira',
          'question':
              '¿Qué revisarías primero para saber si el mensaje puede ser falso?',
          'correctFeedback':
              'Correcto. Revisar el remitente y el dominio ayuda a detectar si el mensaje viene de una fuente falsa o sospechosa.',
          'wrongFeedback':
              'No es lo más importante. Un mensaje puede verse bonito, formal o elegante y aun así ser phishing. Primero revisa remitente, dominio y enlaces.',
          'technicalNote':
              'En phishing, las señales clave incluyen remitentes extraños, dominios alterados, enlaces sospechosos, urgencia, amenazas y solicitudes de credenciales.',
          'mustBeCorrect': false,
        },
        winDialogueText:
            'Lira asiente y señala el remitente del pergamino.\n\n'
            'El dominio no pertenece realmente al Consejo Real.',
        winNpcName: 'Mensajera Lira',
      ),
      MissionStep(
        id: 'mensaje_impostor_pistas',
        title: 'Investigación del Pergamino',
        stepType: StepType.minigame,
        minigameType: MinigameType.phishingClues,
        minigameLabel: 'Minijuego: Detectar señales de phishing',
        preStepDialogue: const NpcDialogue(
          npcName: 'Mensajera Lira',
          text:
              'Mira el pergamino con calma, Guardián.\n\n'
              'Toca cada detalle que parezca una señal de engaño: urgencia, amenazas, remitentes extraños, enlaces raros o solicitudes de información sensible.',
        ),
        contextText:
            'Selecciona las señales que indiquen un posible ataque de phishing.\n\n'
            'Recuerda los términos reales: phishing, ingeniería social, credenciales, enlace sospechoso y remitente desconocido.',
        allegoryText:
            'Detectar señales de phishing ayuda a evitar que los usuarios entreguen credenciales o información sensible a atacantes.',
        options: const [
          'Tono de URGENCIA',
          'Solicitud de entregar tu llave',
          'Portal extraño',
          'Amenaza de perder acceso',
          'Sello borroso',
          'Remitente desconocido',
          'Saludo formal',
          'Color oscuro del pergamino',
        ],
        correctOptionIndexes: const [0, 1, 2, 3, 4, 5],
        extraData: const {
          'sender':
              'Consejo-Real-Seguridad <alerta@portal-reino-seguro-extraño.net>',
          'subject': 'URGENTE: entrega tu llave o perderás acceso',
          'messageBody':
              'Estimado guardián,\n\n'
              'Detectamos un problema grave en tu cuenta. Para evitar el cierre inmediato de tu acceso, entrega tu llave personal en el siguiente portal:\n\n'
              'portal-reino-seguro-extraño.net\n\n'
              'Si no lo haces antes del anochecer, perderás todos tus permisos.\n\n'
              'Consejo Real de Seguridad',
          'explanation':
              'Las señales importantes son la urgencia, la amenaza, la solicitud de entregar la llave, el enlace extraño, el remitente desconocido y el sello borroso.',
        },
        winDialogueText:
            'Has reunido suficiente evidencia. Este mensaje no viene del Consejo Real.\n\n'
            'Alguien está intentando robar llaves usando miedo y apariencia de autoridad.',
        winNpcName: 'Mensajera Lira',
      ),
      MissionStep(
        id: 'mensaje_impostor_evento_huida',
        title: 'El impostor se revela',
        stepType: StepType.event,
        minigameType: MinigameType.none,
        contextText:
            'Cuando marcas la última pista sospechosa, la tinta del pergamino se retuerce como humo negro.\n\n'
            'Una figura encapuchada aparece sobre el techo del mercado. Lleva una máscara con el símbolo falso del Consejo Real.\n\n'
            'El Heraldo Impostor observa la escena y retrocede al notar que su engaño fue descubierto.',
        preStepDialogue: const NpcDialogue(
          npcName: 'Heraldo Impostor',
          text:
              'Qué molesto. La mayoría entrega su llave apenas lee la palabra “urgente”.\n\n'
              'Tú haces demasiadas preguntas, Guardián.',
        ),
        autoComplete: true,
        winDialogueText:
            'El Heraldo Impostor intenta escapar entre los pergaminos del mercado.',
        winNpcName: 'Mensajera Lira',
      ),
      MissionStep(
        id: 'mensaje_impostor_persecucion',
        title: 'Persecución entre pergaminos',
        stepType: StepType.event,
        minigameType: MinigameType.none,
        contextText:
            'Corres entre puestos de tinta, sellos mágicos y cuervos mensajeros.\n\n'
            'El impostor lanza copias falsas del pergamino para distraerte, pero Lira abre un camino entre los mensajes auténticos.',
        preStepDialogue: const NpcDialogue(
          npcName: 'Mensajera Lira',
          text:
              '¡No sigas los pergaminos que brillan demasiado! Son señuelos.\n\n'
              'Los mensajes falsos siempre intentan llamar más la atención de lo necesario.',
        ),
        allegoryText:
            'En seguridad, no basta con identificar un intento de phishing. También es importante reportarlo y evitar que otros usuarios caigan en el mismo engaño.',
        autoComplete: true,
        winDialogueText:
            'Finalmente alcanzas al Heraldo Impostor en una plaza vacía. Ya no puede esconderse detrás de mensajes falsos.',
        winNpcName: 'Maestra Elyra',
      ),
      MissionStep(
        id: 'mensaje_impostor_combate',
        title: 'Combate: Heraldo Impostor',
        stepType: StepType.combat,
        minigameType: MinigameType.trivia,
        minigameLabel: 'Combate RPG',
        contextText:
            'El Heraldo Impostor usará engaños, mensajes falsos y presión psicológica para confundirte.\n\n'
            'Responde correctamente para romper sus máscaras. Si fallas, el impostor atacará usando dudas y falsas alertas.',
        preStepDialogue: const NpcDialogue(
          npcName: 'Heraldo Impostor',
          text:
              'No necesito romper cerraduras.\n\n'
              'Solo necesito que alguien me entregue la llave creyendo que soy de confianza.',
        ),
        enemy: getEnemyById('heraldo_impostor'),
        showBattleWidget: true,
        questions: [
          Question(
            text: '¿Cuál es una señal común de phishing?',
            options: [
              'Un mensaje urgente que pide datos sensibles',
              'Un mensaje claro de una fuente conocida',
              'Una notificación esperada por el usuario',
              'Un correo sin enlaces ni solicitudes',
            ],
            correctIndex: 0,
            category: 'basico',
            explanation:
                'Los mensajes de phishing suelen usar urgencia, miedo o presión para que la persona actúe sin pensar.',
          ),
          Question(
            text:
                'Si recibes un enlace sospechoso que pide tu contraseña, ¿qué deberías hacer?',
            options: [
              'Ingresar rápido antes de que cierre',
              'Compartirlo con amigos',
              'No ingresar datos y verificar por un canal oficial',
              'Responder con tu contraseña en el mensaje',
            ],
            correctIndex: 2,
            category: 'basico',
            explanation:
                'Nunca se deben ingresar credenciales en enlaces sospechosos. Es mejor verificar directamente por canales oficiales.',
          ),
          Question(
            text:
                '¿Por qué los atacantes usan amenazas como “perderás tu acceso”?',
            options: [
              'Para mejorar la experiencia del usuario',
              'Para presionar y reducir el pensamiento crítico',
              'Porque todos los mensajes oficiales amenazan',
              'Porque así el sistema carga más rápido',
            ],
            correctIndex: 1,
            category: 'basico',
            explanation:
                'La presión emocional busca que la víctima actúe rápido y no revise señales sospechosas.',
          ),
          Question(
            text:
                '¿Qué debe hacerse con un mensaje sospechoso dentro de una organización?',
            options: [
              'Ignorarlo y borrarlo sin avisar',
              'Reportarlo al área o canal de seguridad correspondiente',
              'Reenviarlo a todos para que lo revisen',
              'Publicarlo en redes sociales',
            ],
            correctIndex: 1,
            category: 'basico',
            explanation:
                'Reportar mensajes sospechosos ayuda a prevenir que otras personas caigan en el mismo ataque.',
          ),
          Question(
            text:
                '¿Qué dato nunca deberías entregar en respuesta a un mensaje sospechoso?',
            options: [
              'Tu color favorito',
              'Una contraseña, código o credencial de acceso',
              'El nombre de una ciudad famosa',
              'La hora del día',
            ],
            correctIndex: 1,
            category: 'basico',
            explanation:
                'Las contraseñas, códigos y credenciales son información sensible y no deben compartirse por mensajes sospechosos.',
          ),
        ],
        winDialogueText:
            'El Heraldo Impostor pierde sus máscaras una por una. Sus mensajes falsos caen al suelo como pergaminos vacíos.\n\n'
            'El mercado queda en silencio.',
        winNpcName: 'Maestra Elyra',
      ),
      MissionStep(
        id: 'mensaje_impostor_cierre',
        title: 'No toda autoridad es auténtica',
        stepType: StepType.closing,
        minigameType: MinigameType.none,
        contextText:
            'Lira recoge los pergaminos falsos y los marca con un sello rojo para que nadie más caiga en la trampa.\n\n'
            'Los ciudadanos entienden que un mensaje puede parecer oficial y aun así ser peligroso.',
        preStepDialogue: const NpcDialogue(
          npcName: 'Maestra Elyra',
          text:
              'Hoy aprendiste algo esencial: el enemigo no siempre ataca la puerta.\n\n'
              'A veces toca la puerta con una sonrisa, una amenaza y un enlace falso.',
        ),
        allegoryText:
            'Esta misión introduce el phishing como técnica de ingeniería social. También conecta con la importancia de reportar eventos sospechosos y proteger credenciales.',
        autoComplete: true,
        winDialogueText: 'Has completado la investigación del impostor.',
        winNpcName: 'Mensajera Lira',
      ),
    ],
  ),

  NarrativeMission(
    id: 'puertas_reino',
    order: 3,
    title: 'Las Puertas del Reino',
    concept: 'Control de acceso',
    isoRelation:
        'Relacionado con la gestión de accesos, autorización, asignación de permisos, roles de usuario y aplicación del principio de mínimo privilegio.',
    shortDescription:
        'Aprende a asignar permisos correctos a distintos roles del reino para evitar accesos indebidos.',
    missionType: MissionType.diaria,
    category: 'basico',
    backgroundAsset: 'assets/backgrounds/story_bg.png',
    xpReward: 180,
    coinReward: 90,
    specialReward: 'Sello de Acceso Justo',
    requiredMissionIds: const ['mensaje_impostor'],
    prologue: const NpcDialogue(
      npcName: 'Capitán Rowan',
      text:
          'Guardián, has aprendido a proteger tu llave y a no entregarla ante engaños.\n\n'
          'Ahora debes aprender algo igual de importante: no todas las puertas deben abrirse para todos.\n\n'
          'El Reino de los Datos necesita orden. Y el acceso sin control es solo caos con uniforme.',
    ),
    steps: [
      MissionStep(
        id: 'puertas_reino_llegada',
        title: 'La Fortaleza de Puertas',
        stepType: StepType.story,
        minigameType: MinigameType.none,
        contextText:
            'Llegas a una fortaleza enorme, construida con piedra oscura y puertas mágicas de distintos colores.\n\n'
            'Cada puerta protege una zona diferente del Reino de los Datos: archivos públicos, salas de entrenamiento, cámaras administrativas, tesoros privados y registros del Consejo.\n\n'
            'Algunas puertas brillan suavemente. Otras están selladas con runas de advertencia.',
        allegoryText:
            'La fortaleza representa un sistema de información. Cada puerta simboliza un recurso, módulo, archivo o área del sistema que no debería estar disponible para cualquier usuario.',
        autoComplete: true,
        winDialogueText:
            'Frente a la puerta principal te espera el Capitán Rowan, encargado de proteger los accesos del reino.',
        winNpcName: 'Capitán Rowan',
      ),
      MissionStep(
        id: 'puertas_reino_dialogo_rowan',
        title: 'El problema de los accesos',
        stepType: StepType.dialogue,
        minigameType: MinigameType.none,
        contextText:
            'El Capitán Rowan y el Guardia Toren explican por qué asignar accesos de forma incorrecta puede poner en riesgo todo el reino.',
        dialogues: const [
          NpcDialogue(
            npcName: 'Capitán Rowan',
            text:
                'Cada habitante del reino necesita ciertas puertas para cumplir su labor.\n\n'
                'Pero algunos no deberían entrar a zonas sensibles, aunque pidan permiso con cara de inocentes.',
          ),
          NpcDialogue(
            npcName: 'Guardia Toren',
            text:
                'Ayer un aprendiz pidió acceso al Tesoro Real porque “quería mirar”.\n\n'
                'Esa frase ha destruido más sistemas que muchas maldiciones antiguas.',
          ),
          NpcDialogue(
            npcName: 'Capitán Rowan',
            text:
                'El acceso no se entrega por confianza ciega. Se entrega por necesidad.\n\n'
                'Si alguien solo necesita leer un pergamino, no debe poder modificarlo, borrarlo o venderlo en el mercado negro. Parece obvio, pero la humanidad insiste en sorprender.',
          ),
          NpcDialogue(
            npcName: 'Guardia Toren',
            text:
                'Hoy deberás revisar varios roles del reino y decidir qué puertas puede abrir cada uno.',
          ),
        ],
        autoComplete: true,
        winDialogueText:
            'Rowan señala una mesa con mapas de acceso, sellos de permisos y registros de usuarios.',
        winNpcName: 'Capitán Rowan',
      ),
      MissionStep(
        id: 'puertas_reino_concepto',
        title: 'Códice: Control de acceso',
        stepType: StepType.concept,
        minigameType: MinigameType.none,
        contextText:
            'Término real desbloqueado: Control de acceso.\n\n'
            'El control de acceso es el conjunto de reglas y mecanismos que determinan quién puede ingresar, consultar, modificar o administrar recursos dentro de un sistema.\n\n'
            'Incluye conceptos como usuarios, roles, permisos, autorización y principio de mínimo privilegio.',
        allegoryText:
            'En el reino, las puertas controlan quién puede entrar a cada zona. En ciberseguridad, el control de acceso define qué puede hacer cada usuario dentro de una aplicación, red o sistema.',
        dialogues: const [
          NpcDialogue(
            npcName: 'Capitán Rowan',
            text:
                'En el reino, una puerta no pregunta si alguien parece amable. Pregunta si tiene permiso.\n\n'
                'Esa diferencia mantiene vivo al reino. Y evita que un visitante curioso termine administrando el tesoro.',
          ),
          NpcDialogue(
            npcName: 'Maestra Elyra',
            text:
                'En tu mundo, esto se llama control de acceso.\n\n'
                'Sirve para definir qué usuarios pueden entrar a ciertos recursos y qué acciones pueden realizar dentro de un sistema.',
          ),
          NpcDialogue(
            npcName: 'Guardia Toren',
            text:
                'No es lo mismo mirar un archivo que modificarlo.\n\n'
                'Tampoco es lo mismo entrenar en una sala pública que entrar a la Cámara del Consejo como si uno fuera dueño del reino.',
          ),
          NpcDialogue(
            npcName: 'Maestra Elyra',
            text:
                'Recuerda este término: principio de mínimo privilegio.\n\n'
                'Significa que cada usuario debe tener solo los permisos necesarios para cumplir su función, nada más.',
          ),
          NpcDialogue(
            npcName: 'Capitán Rowan',
            text:
                'Dar permisos de más puede parecer generoso, pero en seguridad eso se llama abrirle la puerta al desastre y ponerle alfombra roja.',
          ),
        ],
        autoComplete: true,
        winDialogueText:
            'El Códice del Guardián registra los conceptos de control de acceso, autorización, roles, permisos y mínimo privilegio.',
        winNpcName: 'Maestra Elyra',
      ),
      MissionStep(
        id: 'puertas_reino_decision_permiso_temporal',
        title: 'Decisión: El permiso tentador',
        stepType: StepType.event,
        minigameType: MinigameType.narrativeChoice,
        minigameLabel: 'Microevento: mínimo privilegio',
        preStepDialogue: const NpcDialogue(
          npcName: 'Capitán Rowan',
          text:
              'Un aprendiz acaba de pedir acceso temporal al Tesoro Real.\n\n'
              'Dice que es “solo por hoy” y que promete no tocar nada. Qué frase tan tranquilizadora, casi como dejar un dragón cuidando velas.',
        ),
        contextText:
            'Rowan te pide decidir si el aprendiz debe recibir acceso temporal a una zona crítica del reino.',
        allegoryText:
            'Este microevento aplica el principio de mínimo privilegio: cada usuario debe tener solo los permisos necesarios para cumplir su función.',
        options: const [
          'Negar el acceso al Tesoro Real porque no lo necesita para su función',
          'Dar acceso total porque parece una persona confiable',
          'Compartir una cuenta de administrador para ahorrar tiempo',
        ],
        correctOptionIndexes: const [0],
        extraData: const {
          'npcName': 'Capitán Rowan',
          'question':
              '¿Qué decisión respeta mejor el principio de mínimo privilegio?',
          'correctFeedback':
              'Correcto. Si el aprendiz no necesita acceder al Tesoro Real para cumplir su función, no debe recibir ese permiso.',
          'wrongFeedback':
              'Esa decisión aumenta el riesgo. La confianza no reemplaza el control de acceso. Los permisos deben asignarse por necesidad, no por simpatía.',
          'technicalNote':
              'El principio de mínimo privilegio reduce el impacto de errores, abusos o cuentas comprometidas limitando los permisos a lo estrictamente necesario.',
          'mustBeCorrect': false,
        },
        winDialogueText:
            'Rowan cierra el sello del Tesoro Real.\n\n'
            'El aprendiz conserva acceso a la sala de entrenamiento, que es lo que realmente necesita.',
        winNpcName: 'Capitán Rowan',
      ),
      MissionStep(
        id: 'puertas_reino_reto_accesos',
        title: 'Asignación de Permisos',
        stepType: StepType.minigame,
        minigameType: MinigameType.accessPuzzle,
        minigameLabel: 'Minijuego: Control de acceso',
        preStepDialogue: const NpcDialogue(
          npcName: 'Capitán Rowan',
          text:
              'Sobre esta mesa verás distintos habitantes del reino y varias puertas posibles.\n\n'
              'Tu tarea es simple en teoría y peligrosa en la práctica: asigna únicamente los accesos necesarios.\n\n'
              'Si das acceso de más, creas una vulnerabilidad. Si das acceso de menos, impides que alguien cumpla su trabajo. Maravilloso equilibrio, como caminar sobre cuchillos administrativos.',
        ),
        contextText:
            'Selecciona los permisos adecuados para cada rol.\n\n'
            'Aplica el principio de mínimo privilegio: cada usuario debe recibir solo los accesos necesarios para realizar su función.',
        allegoryText:
            'En sistemas reales, los permisos deben asignarse según el rol del usuario. Un usuario común no debería tener permisos administrativos, y un aprendiz no debería acceder a información crítica.',
        extraData: const {
          'accessCases': [
            {
              'role': 'Aprendiz del Reino',
              'description':
                  'Está comenzando su entrenamiento. Solo necesita consultar materiales básicos y practicar en la sala de formación.',
              'permissions': [
                'Biblioteca pública',
                'Sala de entrenamiento',
                'Tesoro Real',
                'Cámara del Consejo',
              ],
              'correctIndexes': [0, 1],
              'explanation':
                  'El aprendiz solo necesita acceso a recursos básicos. Darle acceso al Tesoro Real o a la Cámara del Consejo violaría el principio de mínimo privilegio.',
            },
            {
              'role': 'Archivista Real',
              'description':
                  'Debe consultar y organizar documentos oficiales, pero no administra permisos ni accede al tesoro.',
              'permissions': [
                'Archivo central',
                'Biblioteca pública',
                'Panel de administración de usuarios',
                'Tesoro Real',
              ],
              'correctIndexes': [0, 1],
              'explanation':
                  'El archivista requiere acceso al archivo y a información pública. No necesita administrar usuarios ni acceder a recursos financieros o críticos.',
            },
            {
              'role': 'Administrador del Sistema',
              'description':
                  'Debe gestionar usuarios, permisos y configuraciones del sistema. Su acceso es alto, pero debe seguir siendo controlado.',
              'permissions': [
                'Panel de administración de usuarios',
                'Configuración del sistema',
                'Biblioteca pública',
                'Cofres personales de todos los ciudadanos',
              ],
              'correctIndexes': [0, 1, 2],
              'explanation':
                  'El administrador necesita gestionar usuarios y configuraciones, pero no debería acceder libremente a cofres personales sin justificación. Los permisos altos también deben tener límites.',
            },
            {
              'role': 'Mercader del Reino',
              'description':
                  'Solo necesita consultar productos, registrar ventas y revisar sus propios movimientos comerciales.',
              'permissions': [
                'Registro de ventas propias',
                'Catálogo público',
                'Cámara del Consejo',
                'Panel de permisos globales',
              ],
              'correctIndexes': [0, 1],
              'explanation':
                  'El mercader necesita operar sobre sus ventas y el catálogo, pero no debe acceder a zonas de gobierno ni administrar permisos globales.',
            },
          ],
        },
        winDialogueText:
            'Las puertas responden a tus decisiones. Los sellos correctos brillan y las entradas innecesarias quedan cerradas.\n\n'
            'Has aplicado el principio de mínimo privilegio.',
        winNpcName: 'Capitán Rowan',
      ),
      MissionStep(
        id: 'puertas_reino_evento_intruso',
        title: 'Una sombra entre las puertas',
        stepType: StepType.event,
        minigameType: MinigameType.none,
        contextText:
            'Cuando terminas la asignación de permisos, una de las puertas laterales se estremece.\n\n'
            'Una figura oscura intenta deslizarse entre los sellos, buscando una entrada mal configurada.\n\n'
            'No viene con llave. No viene con permiso. Solo busca un descuido.',
        preStepDialogue: const NpcDialogue(
          npcName: 'Guardia Toren',
          text:
              '¡Capitán! Algo intenta cruzar por una puerta secundaria.\n\n'
              'No tiene sello válido. Está buscando un permiso mal asignado.',
        ),
        allegoryText:
            'Un atacante puede intentar aprovechar permisos excesivos o configuraciones débiles para acceder a recursos que no debería ver.',
        autoComplete: true,
        winDialogueText:
            'La Sombra Intrusa aparece frente a las puertas, furiosa por no encontrar un acceso fácil.',
        winNpcName: 'Capitán Rowan',
      ),
      MissionStep(
        id: 'puertas_reino_combate_sombra',
        title: 'Combate: Sombra Intrusa',
        stepType: StepType.combat,
        minigameType: MinigameType.trivia,
        minigameLabel: 'Combate RPG',
        contextText:
            'La Sombra Intrusa intentará confundirte con malas decisiones de acceso.\n\n'
            'Responde correctamente para reforzar los sellos de autorización. Si fallas, la sombra atacará aprovechando permisos débiles.',
        preStepDialogue: const NpcDialogue(
          npcName: 'Sombra Intrusa',
          text:
              'No necesito romper todas las puertas.\n\n'
              'Solo necesito que alguien haya dejado una abierta para quien no debía.',
        ),
        enemy: getEnemyById('sombra_intrusa'),
        showBattleWidget: true,
        questions: [
          Question(
            text: '¿Qué significa el principio de mínimo privilegio?',
            options: [
              'Dar todos los permisos para evitar problemas',
              'Dar solo los permisos necesarios para cumplir una función',
              'Eliminar todos los accesos de todos los usuarios',
              'Permitir que cada usuario elija sus permisos',
            ],
            correctIndex: 1,
            category: 'basico',
            explanation:
                'El principio de mínimo privilegio indica que cada usuario debe tener únicamente los permisos necesarios para realizar su tarea.',
          ),
          Question(
            text:
                '¿Cuál de estos casos representa un riesgo de control de acceso?',
            options: [
              'Un estudiante accede solo al material del curso',
              'Un administrador gestiona usuarios autorizados',
              'Un usuario común puede modificar permisos globales',
              'Un empleado consulta su propio perfil',
            ],
            correctIndex: 2,
            category: 'basico',
            explanation:
                'Un usuario común no debería poder modificar permisos globales. Ese acceso excesivo puede poner en riesgo todo el sistema.',
          ),
          Question(
            text: '¿Qué diferencia hay entre autenticación y autorización?',
            options: [
              'Autenticación verifica identidad; autorización define permisos',
              'Son exactamente lo mismo',
              'Autorización solo aplica a contraseñas',
              'Autenticación significa borrar usuarios',
            ],
            correctIndex: 0,
            category: 'basico',
            explanation:
                'La autenticación confirma quién eres. La autorización determina qué puedes hacer después de ingresar.',
          ),
          Question(
            text:
                '¿Por qué no conviene dar permisos administrativos a todos?',
            options: [
              'Porque todos trabajarían más rápido',
              'Porque aumenta el riesgo de errores, abuso o accesos indebidos',
              'Porque los permisos administrativos no existen',
              'Porque solo cambia el color de la interfaz',
            ],
            correctIndex: 1,
            category: 'basico',
            explanation:
                'Los permisos administrativos permiten acciones críticas. Si demasiados usuarios los tienen, aumenta el riesgo de incidentes.',
          ),
          Question(
            text:
                '¿Qué debería hacerse cuando una persona cambia de rol dentro de una organización?',
            options: [
              'Mantener todos sus permisos antiguos',
              'Revisar y ajustar sus accesos según sus nuevas funciones',
              'Darle permisos de administrador por precaución',
              'Eliminar su cuenta para siempre',
            ],
            correctIndex: 1,
            category: 'basico',
            explanation:
                'Cuando una persona cambia de rol, sus permisos deben revisarse para evitar accesos innecesarios o desactualizados.',
          ),
        ],
        winDialogueText:
            'La Sombra Intrusa se desvanece al no encontrar puertas abiertas por error.\n\n'
            'Los sellos de acceso brillan con fuerza en toda la fortaleza.',
        winNpcName: 'Capitán Rowan',
      ),
      MissionStep(
        id: 'puertas_reino_cierre',
        title: 'Las puertas correctas',
        stepType: StepType.closing,
        minigameType: MinigameType.none,
        contextText:
            'La fortaleza queda protegida. Cada puerta responde solo al sello correcto, y cada habitante conserva únicamente los accesos que necesita.\n\n'
            'Has aprendido que proteger un sistema no solo significa crear buenas contraseñas o evitar engaños, sino también controlar quién puede hacer qué dentro del entorno.',
        preStepDialogue: const NpcDialogue(
          npcName: 'Maestra Elyra',
          text:
              'Hoy aprendiste que el acceso también es una forma de poder.\n\n'
              'Y como todo poder, debe entregarse con medida. Dar acceso de más puede ser tan peligroso como perder una llave.',
        ),
        allegoryText:
            'Esta misión introduce el control de acceso y el principio de mínimo privilegio. Estos conceptos ayudan a reducir riesgos limitando los permisos de cada usuario según su función real.',
        autoComplete: true,
        winDialogueText:
            'Has completado el entrenamiento de control de acceso.',
        winNpcName: 'Capitán Rowan',
      ),
    ],
  ),

  NarrativeMission(
    id: 'cristal_respaldo',
    order: 4,
    title: 'El Cristal de Respaldo',
    concept: 'Copias de seguridad',
    isoRelation:
        'Relacionado con la protección de la información, disponibilidad, continuidad operativa, recuperación ante incidentes y gestión de copias de seguridad.',
    shortDescription:
        'Aprende a proteger la memoria del reino mediante copias de seguridad, verificación y restauración correcta.',
    missionType: MissionType.diaria,
    category: 'basico',
    backgroundAsset: 'assets/backgrounds/story_bg.png',
    xpReward: 210,
    coinReward: 105,
    specialReward: 'Cristal de Restauración',
    requiredMissionIds: const ['puertas_reino'],
    prologue: const NpcDialogue(
      npcName: 'Archivista Thalen',
      text:
          'Guardián, las puertas del reino ya están mejor protegidas.\n\n'
          'Pero incluso una fortaleza bien cerrada puede perder algo valioso: su memoria.\n\n'
          'Hoy entrarás al Archivo de Cristales, donde se guardan registros, mapas, acuerdos y recuerdos importantes del Reino de los Datos.',
    ),
    steps: [
      MissionStep(
        id: 'cristal_respaldo_llegada',
        title: 'El Archivo de Cristales',
        stepType: StepType.story,
        minigameType: MinigameType.none,
        contextText:
            'Llegas a una biblioteca subterránea iluminada por miles de cristales flotantes.\n\n'
            'Cada cristal contiene información esencial del reino: rutas, registros de ciudadanos, permisos, inventarios y antiguas decisiones del Consejo.\n\n'
            'Algunos cristales brillan con fuerza. Otros parpadean como si estuvieran a punto de apagarse.',
        allegoryText:
            'El Archivo de Cristales representa los sistemas donde se almacena información importante. Los cristales simbolizan datos, bases de datos, documentos y registros digitales.',
        autoComplete: true,
        winDialogueText:
            'Un archivista de túnica azul se acerca con expresión preocupada.',
        winNpcName: 'Archivista Thalen',
      ),
      MissionStep(
        id: 'cristal_respaldo_dialogo_thalen',
        title: 'La memoria del reino',
        stepType: StepType.dialogue,
        minigameType: MinigameType.none,
        contextText:
            'El Archivista Thalen explica por qué proteger la información no solo consiste en evitar accesos indebidos, sino también en conservar copias recuperables.',
        dialogues: const [
          NpcDialogue(
            npcName: 'Archivista Thalen',
            text:
                'Cada cristal guarda una parte de nuestra historia.\n\n'
                'Si uno se rompe y no existe una copia, esa información puede perderse para siempre.',
          ),
          NpcDialogue(
            npcName: 'Maestra Elyra',
            text:
                'En tu mundo, estos cristales representan datos.\n\n'
                'Pueden ser archivos, bases de datos, registros académicos, información financiera o cualquier recurso digital importante.',
          ),
          NpcDialogue(
            npcName: 'Archivista Thalen',
            text:
                'Muchos creen que hacer una copia basta.\n\n'
                'Pero una copia que nadie prueba, que nadie actualiza o que nadie puede restaurar es solo decoración cara. Muy bonita, completamente inútil.',
          ),
          NpcDialogue(
            npcName: 'Maestra Elyra',
            text:
                'Por eso hoy aprenderás tres ideas clave: copia de seguridad, verificación y restauración.\n\n'
                'No basta con guardar información. Hay que poder recuperarla cuando algo falla.',
          ),
        ],
        autoComplete: true,
        winDialogueText:
            'Thalen te guía hasta una mesa donde varios cristales están desordenados en una línea temporal.',
        winNpcName: 'Archivista Thalen',
      ),
      MissionStep(
        id: 'cristal_respaldo_concepto',
        title: 'Códice: Copias de seguridad',
        stepType: StepType.concept,
        minigameType: MinigameType.none,
        contextText:
            'Término real desbloqueado: Copia de seguridad.\n\n'
            'Una copia de seguridad es una réplica de información importante que se guarda para poder recuperarla si ocurre una pérdida, daño, error, ataque o falla del sistema.\n\n'
            'Una buena estrategia de respaldo debe incluir creación de copias, almacenamiento seguro, actualización periódica, verificación y restauración.',
        allegoryText:
            'En el reino, un cristal de respaldo conserva una copia de la memoria original. En ciberseguridad, un backup permite recuperar información cuando los datos principales se pierden o se dañan.',
        dialogues: const [
          NpcDialogue(
            npcName: 'Archivista Thalen',
            text:
                'Cuando un cristal original se agrieta, buscamos su reflejo guardado.\n\n'
                'Ese reflejo no es adorno. Es la diferencia entre recuperar la memoria del reino o fingir que “seguro estaba en otra carpeta”.',
          ),
          NpcDialogue(
            npcName: 'Maestra Elyra',
            text:
                'En tu mundo, ese reflejo se llama copia de seguridad o backup.\n\n'
                'Sirve para recuperar información cuando ocurre una falla, eliminación accidental, corrupción de datos o ataque.',
          ),
          NpcDialogue(
            npcName: 'Archivista Thalen',
            text:
                'Pero escucha bien: una copia antigua puede dejarte con información incompleta.\n\n'
                'Y una copia que nunca se prueba puede fallar justo cuando más la necesitas. Porque al desastre le encanta la ironía.',
          ),
          NpcDialogue(
            npcName: 'Maestra Elyra',
            text:
                'Recuerda estos términos reales: respaldo, restauración, disponibilidad, continuidad y verificación.\n\n'
                'La información no solo debe existir. Debe poder recuperarse.',
          ),
        ],
        autoComplete: true,
        winDialogueText:
            'El Códice del Guardián registra el concepto de copias de seguridad y restauración.',
        winNpcName: 'Maestra Elyra',
      ),
      MissionStep(
        id: 'cristal_respaldo_decision_copia_valida',
        title: 'Decisión: El cristal que parpadea',
        stepType: StepType.event,
        minigameType: MinigameType.narrativeChoice,
        minigameLabel: 'Microevento: respaldo seguro',
        preStepDialogue: const NpcDialogue(
          npcName: 'Archivista Thalen',
          text:
              'Uno de los cristales principales acaba de parpadear.\n\n'
              'Antes de tocar cualquier cosa, debemos actuar con cuidado. Un movimiento desesperado puede convertir una falla pequeña en una catástrofe administrativa, el deporte favorito de las organizaciones.',
        ),
        contextText:
            'Thalen te pide decidir cuál es la primera acción prudente cuando una fuente de información crítica empieza a fallar.',
        allegoryText:
            'Este microevento refuerza que ante una posible pérdida de información se debe verificar la existencia de copias recientes, seguras y restaurables.',
        options: const [
          'Revisar si existe una copia reciente y verificada',
          'Borrar el cristal dañado de inmediato',
          'Usar cualquier copia antigua sin comprobarla',
        ],
        correctOptionIndexes: const [0],
        extraData: const {
          'npcName': 'Archivista Thalen',
          'question':
              '¿Qué harías primero ante una posible pérdida de información?',
          'correctFeedback':
              'Correcto. Antes de restaurar o borrar, se debe verificar que exista una copia reciente, íntegra y restaurable.',
          'wrongFeedback':
              'Esa decisión puede empeorar el incidente. No se debe borrar ni restaurar al azar. Primero se revisa si existe una copia válida y verificada.',
          'technicalNote':
              'Una estrategia de respaldo no solo consiste en crear copias. También requiere verificar que sean recientes, estén protegidas y puedan restaurarse correctamente.',
          'mustBeCorrect': false,
        },
        winDialogueText:
            'Thalen revisa el registro de copias y encuentra un respaldo reciente.\n\n'
            'Ahora puedes ordenar el ciclo correcto de respaldo y restauración.',
        winNpcName: 'Archivista Thalen',
      ),
      MissionStep(
        id: 'cristal_respaldo_linea_tiempo',
        title: 'Línea Temporal del Respaldo',
        stepType: StepType.minigame,
        minigameType: MinigameType.backupTimeline,
        minigameLabel: 'Minijuego: ordenar respaldo y restauración',
        preStepDialogue: const NpcDialogue(
          npcName: 'Archivista Thalen',
          text:
              'Estos cristales muestran el ciclo correcto para proteger información.\n\n'
              'Pero están desordenados. Necesito que los organices desde la creación del dato hasta su restauración segura.\n\n'
              'Hazlo bien, Guardián. Un respaldo mal ordenado es como un mapa sin rutas: tranquiliza hasta que intentas usarlo.',
        ),
        contextText:
            'Ordena los pasos correctos de un proceso de copia de seguridad y restauración.\n\n'
            'Recuerda: no basta con crear una copia. También hay que almacenarla, verificarla y restaurarla cuando sea necesario.',
        allegoryText:
            'En sistemas reales, las copias de seguridad deben seguir una estrategia clara. Si no se verifican o no pueden restaurarse, no protegen realmente la información.',
        options: const [
          'Identificar qué información es crítica para el reino',
          'Crear una copia de seguridad del cristal principal',
          'Guardar la copia en una cámara protegida',
          'Probar que la copia puede restaurarse sin errores',
          'Restaurar la información cuando el cristal original falla',
        ],
        correctOrder: const [0, 1, 2, 3, 4],
        extraData: const {
          'npcName': 'Archivista Thalen',
          'npcInstruction':
              'Ordena los cristales en el ciclo correcto. No basta con crear una copia: primero se identifica qué proteger, luego se respalda, se guarda, se prueba y solo entonces puede usarse para restaurar.',
          'explanation':
              'El ciclo correcto inicia identificando la información crítica, continúa con la creación de la copia, su almacenamiento seguro, la verificación de restauración y finalmente la recuperación cuando ocurre un incidente.',
        },
        winDialogueText:
            'Los cristales se alinean en orden y una luz azul recorre toda la mesa.\n\n'
            'El ciclo de respaldo queda restaurado.',
        winNpcName: 'Archivista Thalen',
      ),
      MissionStep(
        id: 'cristal_respaldo_evento_corrupcion',
        title: 'El cristal corrupto',
        stepType: StepType.event,
        minigameType: MinigameType.none,
        contextText:
            'De pronto, uno de los cristales principales comienza a oscurecerse.\n\n'
            'Su superficie se llena de grietas negras y los registros que contiene empiezan a desaparecer como humo.\n\n'
            'Algo está devorando la memoria del archivo.',
        preStepDialogue: const NpcDialogue(
          npcName: 'Archivista Thalen',
          text:
              'No... este cristal contiene registros esenciales del Consejo.\n\n'
              'Si se pierde y no logramos restaurarlo, el reino quedará sin parte de su memoria administrativa. Y créeme, ya bastante caos produce la administración funcionando bien.',
        ),
        allegoryText:
            'La corrupción de un cristal representa pérdida o daño de información. Puede ocurrir por errores humanos, fallas técnicas, ataques, malware o problemas físicos en los sistemas.',
        autoComplete: true,
        winDialogueText:
            'Una criatura oscura surge entre los fragmentos del cristal dañado.',
        winNpcName: 'Archivista Thalen',
      ),
      MissionStep(
        id: 'cristal_respaldo_combate_devorador',
        title: 'Combate: Devorador de Memorias',
        stepType: StepType.combat,
        minigameType: MinigameType.trivia,
        minigameLabel: 'Combate RPG',
        contextText:
            'El Devorador de Memorias intentará destruir registros y confundir conceptos sobre respaldo.\n\n'
            'Responde correctamente para restaurar fragmentos del cristal. Si fallas, la criatura corromperá más información.',
        preStepDialogue: const NpcDialogue(
          npcName: 'Devorador de Memorias',
          text:
              'Las copias olvidadas se pudren.\n\n'
              'Los respaldos no probados fallan. Y cuando fallan, yo me alimento.',
        ),
        enemy: getEnemyById('devorador_memorias'),
        showBattleWidget: true,
        questions: [
          Question(
            text:
                '¿Cuál es el propósito principal de una copia de seguridad?',
            options: [
              'Hacer que los archivos se vean más bonitos',
              'Permitir recuperar información si se pierde o daña',
              'Eliminar usuarios antiguos',
              'Aumentar el brillo de la pantalla',
            ],
            correctIndex: 1,
            category: 'basico',
            explanation:
                'Una copia de seguridad permite recuperar información cuando ocurre una pérdida, daño, eliminación accidental o incidente.',
          ),
          Question(
            text:
                '¿Por qué es importante verificar una copia de seguridad?',
            options: [
              'Para confirmar que puede restaurarse correctamente',
              'Para cambiarle el nombre',
              'Para hacer que ocupe más espacio',
              'Para que nadie la encuentre nunca',
            ],
            correctIndex: 0,
            category: 'basico',
            explanation:
                'No basta con crear una copia. Es necesario verificar que pueda restaurarse cuando sea necesaria.',
          ),
          Question(
            text:
                '¿Cuál de estas prácticas es más segura para una copia de respaldo?',
            options: [
              'Guardar la única copia en el mismo lugar que los datos originales',
              'No actualizarla nunca',
              'Mantenerla en un lugar seguro y accesible para recuperación',
              'Compartirla públicamente',
            ],
            correctIndex: 2,
            category: 'basico',
            explanation:
                'Una copia debe guardarse de forma segura y estar disponible para restauración cuando ocurra un incidente.',
          ),
          Question(
            text:
                '¿Qué puede pasar si una organización no tiene respaldos actualizados?',
            options: [
              'Puede perder información importante ante una falla o ataque',
              'Sus sistemas se vuelven mágicamente más rápidos',
              'Los usuarios obtienen mejores contraseñas',
              'Se eliminan todos los riesgos automáticamente',
            ],
            correctIndex: 0,
            category: 'basico',
            explanation:
                'Sin respaldos actualizados, una falla, ataque o error puede causar pérdida de información importante.',
          ),
          Question(
            text: '¿Qué significa restaurar información?',
            options: [
              'Crear usuarios nuevos sin permisos',
              'Recuperar datos desde una copia de seguridad',
              'Cambiar el color del sistema',
              'Borrar todos los registros antiguos',
            ],
            correctIndex: 1,
            category: 'basico',
            explanation:
                'Restaurar significa recuperar información desde una copia de seguridad para volver a un estado útil o funcional.',
          ),
        ],
        winDialogueText:
            'El Devorador de Memorias se fragmenta en sombras pequeñas y desaparece entre los estantes.\n\n'
            'El cristal dañado comienza a reconstruirse usando la copia correcta.',
        winNpcName: 'Archivista Thalen',
      ),
      MissionStep(
        id: 'cristal_respaldo_cierre',
        title: 'La memoria restaurada',
        stepType: StepType.closing,
        minigameType: MinigameType.none,
        contextText:
            'El Archivo de Cristales vuelve a brillar. Los registros perdidos se restauran desde una copia verificada y segura.\n\n'
            'Has aprendido que proteger información no solo significa evitar ataques, sino también prepararse para fallas, errores y pérdidas.',
        preStepDialogue: const NpcDialogue(
          npcName: 'Archivista Thalen',
          text:
              'Hoy salvaste una parte de la memoria del reino.\n\n'
              'Recuerda esto: una copia no probada es una promesa. Una copia verificada es una defensa.',
        ),
        allegoryText:
            'Esta misión introduce copias de seguridad, restauración y disponibilidad. Estos conceptos ayudan a mantener la continuidad cuando ocurre un incidente.',
        autoComplete: true,
        winDialogueText:
            'Has completado el entrenamiento sobre copias de seguridad.',
        winNpcName: 'Archivista Thalen',
      ),
    ],
  ),
];

/// Obtiene una misión narrativa por su ID.
///
/// Si no la encuentra, devuelve la primera misión.
NarrativeMission getNarrativeMissionById(String id) {
  return narrativeMissions.firstWhere(
    (mission) => mission.id == id,
    orElse: () => narrativeMissions.first,
  );
}