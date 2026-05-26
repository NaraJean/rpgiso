import 'mission_step.dart';
import 'npc_dialogue.dart';
import 'game_mission.dart';

/// Representa una misión narrativa completa.
///
/// Este modelo es el sistema principal para las nuevas misiones de DataGuardians.
/// A diferencia de GameMission, una NarrativeMission puede tener múltiples pasos:
/// historia, diálogos, conceptos, minijuegos, combates, eventos y cierre.
class NarrativeMission {
  /// Identificador único de la misión.
  ///
  /// Ejemplo:
  /// "llave_guardian"
  final String id;

  /// Número de orden dentro de la campaña.
  ///
  /// Sirve para mostrar la progresión:
  /// 1, 2, 3, 4, 5.
  final int order;

  /// Título de la misión.
  ///
  /// Ejemplo:
  /// "La Llave del Guardián"
  final String title;

  /// Concepto educativo principal.
  ///
  /// Ejemplo:
  /// "Contraseñas seguras"
  final String concept;

  /// Relación breve con ISO 27001.
  ///
  /// Ejemplo:
  /// "Control de acceso, autenticación y protección de credenciales."
  final String isoRelation;

  /// Descripción corta para la tarjeta de misiones.
  final String shortDescription;

  /// Tipo de misión: diaria o semanal.
  ///
  /// Se reutiliza MissionType para no romper tu estructura actual.
  final MissionType missionType;

  /// Categoría o dificultad.
  ///
  /// Ejemplo:
  /// "basico", "intermedio", "avanzado".
  final String category;

  /// Ruta de imagen o fondo para la tarjeta de misión.
  ///
  /// Puede dejarse vacío si todavía no tienes assets.
  final String backgroundAsset;

  /// Diálogo inicial del NPC que introduce la misión.
  final NpcDialogue prologue;

  /// Lista ordenada de pasos de la misión.
  final List<MissionStep> steps;

  /// IDs de misiones requeridas para desbloquear esta misión.
  ///
  /// Ejemplo:
  /// Misión 2 requiere ["llave_guardian"].
  /// Misión 5 puede requerir las primeras cuatro.
  final List<String> requiredMissionIds;

  /// XP otorgada al completar la misión.
  final int xpReward;

  /// Monedas otorgadas al completar la misión.
  final int coinReward;

  /// Recompensa especial opcional.
  ///
  /// Puede ser el id de un objeto, una insignia o un texto.
  final String? specialReward;

  const NarrativeMission({
    required this.id,
    required this.order,
    required this.title,
    required this.concept,
    required this.isoRelation,
    required this.shortDescription,
    required this.missionType,
    required this.category,
    this.backgroundAsset = '',
    required this.prologue,
    required this.steps,
    this.requiredMissionIds = const [],
    this.xpReward = 100,
    this.coinReward = 50,
    this.specialReward,
  });

  /// Retorna true si la misión no tiene requisitos previos.
  bool get isInitiallyUnlocked => requiredMissionIds.isEmpty;
}