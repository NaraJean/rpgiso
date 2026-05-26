import 'step_type.dart';
import 'minigame_type.dart';
import 'npc_dialogue.dart';
import 'question.dart';
import 'memory_pair.dart';
import 'enemy.dart';

/// Representa un paso individual dentro de una misión narrativa.
///
/// Esta clase está pensada para soportar misiones narrativas más amplias:
/// - historia
/// - diálogos
/// - conceptos educativos
/// - minijuegos
/// - eventos posteriores
/// - combates
/// - cierres narrativos
///
/// No todos los campos se usan en todos los pasos.
/// Por ejemplo:
/// - Un paso de tipo story usa principalmente [contextText].
/// - Un paso de tipo dialogue usa [preStepDialogue] o [dialogues].
/// - Un paso de tipo minigame usa [minigameType].
/// - Un paso de tipo combat usa [enemy] y normalmente [questions].
class MissionStep {
  /// Identificador único del paso.
  final String id;

  /// Título visible del paso.
  ///
  /// Ejemplo:
  /// "La Forja de Sellos"
  /// "El Pergamino Sospechoso"
  /// "Defensa de la Fortaleza"
  final String title;

  /// Tipo narrativo del paso.
  ///
  /// Define la función del paso dentro de la misión:
  /// story, dialogue, concept, minigame, event, combat, bossCombat, closing, reward.
  final StepType stepType;

  /// Tipo de minijuego asociado al paso.
  ///
  /// Solo se usa cuando [stepType] sea:
  /// - StepType.minigame
  /// - StepType.combat
  /// - StepType.bossCombat
  ///
  /// Para pasos narrativos se deja en MinigameType.none.
  final MinigameType minigameType;

  /// Etiqueta visible para mostrar al usuario.
  ///
  /// Ejemplo:
  /// "Minijuego: Forja de la Llave"
  /// "Combate: Gólem de la Cerradura Débil"
  /// "Investigación del Pergamino"
  final String minigameLabel;

  /// Texto principal del paso.
  ///
  /// Puede ser:
  /// - narración de escena
  /// - contexto del problema
  /// - explicación breve
  /// - descripción del evento posterior
  final String contextText;

  /// Texto educativo que conecta la alegoría con el concepto real de ciberseguridad.
  ///
  /// Ejemplo:
  /// "En seguridad, una contraseña fuerte debe ser larga, única y difícil de adivinar."
  final String? allegoryText;

  /// Diálogo principal antes del paso.
  ///
  /// Se conserva para compatibilidad con tu estructura anterior.
  final NpcDialogue? preStepDialogue;

  /// Lista de diálogos del paso.
  ///
  /// Sirve para escenas donde hablan varios personajes.
  ///
  /// Ejemplo:
  /// Elyra habla, luego Brann responde, luego vuelve Elyra.
  final List<NpcDialogue> dialogues;

  // ---------------------------------------------------------------------------
  // DATOS PARA MINIJUEGOS EXISTENTES
  // ---------------------------------------------------------------------------

  /// Palabra para el ahorcado.
  ///
  /// Solo se usa cuando [minigameType] sea MinigameType.hangman.
  final String? hangmanWord;

  /// Pares concepto-definición para memoria/emparejamiento.
  ///
  /// Solo se usa cuando [minigameType] sea MinigameType.memory.
  final List<MemoryPair> memoryPairs;

  /// Preguntas para trivia o combate basado en preguntas.
  ///
  /// Se usa cuando [minigameType] sea:
  /// - MinigameType.trivia
  /// - algunos combates simples
  final List<Question> questions;

  // ---------------------------------------------------------------------------
  // DATOS PARA NUEVOS MINIJUEGOS
  // ---------------------------------------------------------------------------

  /// Opciones generales del paso.
  ///
  /// Sirve para:
  /// - runas disponibles
  /// - rutas de persecución
  /// - acciones posibles
  /// - alertas para clasificar
  /// - pasos para ordenar
  ///
  /// Por ahora se maneja como lista de texto para mantener el modelo simple.
  final List<String> options;

  /// Índices correctos dentro de [options].
  ///
  /// Sirve para minijuegos donde puede haber varias respuestas correctas,
  /// como detectar pistas de phishing o seleccionar runas seguras.
  final List<int> correctOptionIndexes;

  /// Orden correcto de opciones.
  ///
  /// Sirve para minijuegos de ordenar pasos.
  ///
  /// Ejemplo:
  /// [0, 1, 2, 3, 4]
  final List<int> correctOrder;

  /// Datos adicionales del paso.
  ///
  /// Sirve para información flexible sin tener que crear un modelo nuevo
  /// por cada minijuego desde el primer día.
  ///
  /// Ejemplo para respaldos:
  /// {
  ///   'cristalA': 'Hace 1 mes - Estable - Muy antiguo',
  ///   'cristalB': 'Hace 1 semana - Estable - Incompleto'
  /// }
  ///
  /// Ejemplo para riesgo:
  /// {
  ///   'riskOnFail': 20,
  ///   'riskOnSuccess': -10
  /// }
  final Map<String, dynamic> extraData;

  // ---------------------------------------------------------------------------
  // DATOS DE COMBATE
  // ---------------------------------------------------------------------------

  /// Enemigo asociado al paso.
  ///
  /// Se usa normalmente en:
  /// - StepType.combat
  /// - StepType.bossCombat
  final Enemy? enemy;

  /// Controla si el minijuego debe mostrarse con interfaz de batalla.
  ///
  /// Por defecto:
  /// - true para combat y bossCombat
  /// - false para otros pasos
  final bool showBattleWidget;

  // ---------------------------------------------------------------------------
  // RESULTADO DEL PASO
  // ---------------------------------------------------------------------------

  /// Texto que aparece cuando el paso se completa con éxito.
  ///
  /// Para pasos narrativos puede usarse como texto de transición o cierre.
  final String winDialogueText;

  /// Nombre del NPC que pronuncia el diálogo de victoria.
  final String winNpcName;

  /// Indica si este paso debe completarse automáticamente al mostrarse.
  ///
  /// Útil para pasos story, dialogue, concept, event o closing.
  /// En esos casos no se lanza minijuego, solo se muestra el contenido y se avanza.
  final bool autoComplete;

  const MissionStep({
    required this.id,
    required this.title,
    required this.stepType,
    this.minigameType = MinigameType.none,
    this.minigameLabel = '',
    required this.contextText,
    this.allegoryText,
    this.preStepDialogue,
    this.dialogues = const [],
    this.hangmanWord,
    this.memoryPairs = const [],
    this.questions = const [],
    this.options = const [],
    this.correctOptionIndexes = const [],
    this.correctOrder = const [],
    this.extraData = const {},
    this.enemy,
    bool? showBattleWidget,
    this.winDialogueText = '',
    this.winNpcName = '',
    this.autoComplete = false,
  }) : showBattleWidget = showBattleWidget ??
            (stepType == StepType.combat || stepType == StepType.bossCombat);

  /// Devuelve true si este paso debe abrir una pantalla de minijuego.
  bool get launchesMinigame {
    return stepType == StepType.minigame ||
        stepType == StepType.combat ||
        stepType == StepType.bossCombat;
  }

  /// Devuelve true si el paso es principalmente narrativo.
  bool get isNarrativeOnly {
    return stepType == StepType.story ||
        stepType == StepType.dialogue ||
        stepType == StepType.concept ||
        stepType == StepType.event ||
        stepType == StepType.closing ||
        stepType == StepType.reward;
  }

  /// Devuelve el texto de victoria seguro.
  ///
  /// Si no se configuró [winDialogueText], entrega un mensaje genérico.
  String get safeWinText {
    if (winDialogueText.trim().isNotEmpty) return winDialogueText;

    return 'Has completado este paso correctamente.';
  }

  /// Devuelve el NPC de victoria seguro.
  String get safeWinNpcName {
    if (winNpcName.trim().isNotEmpty) return winNpcName;

    if (preStepDialogue != null) return preStepDialogue!.npcName;

    if (dialogues.isNotEmpty) return dialogues.last.npcName;

    return 'DataGuardians';
  }
}