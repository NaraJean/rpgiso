import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio encargado de guardar y consultar el progreso de las misiones.
///
/// Este servicio usa SharedPreferences para que el progreso no se pierda
/// cuando el usuario cierre la app.
///
/// Guarda principalmente:
/// - Misiones narrativas completadas.
/// - Consulta si una misión está desbloqueada según sus requisitos.
class MissionProgressService {
  static final MissionProgressService _instance =
      MissionProgressService._internal();

  factory MissionProgressService() => _instance;

  MissionProgressService._internal();

  static const String _completedMissionsKey = 'completed_narrative_missions';

  final Set<String> _completedMissions = {};

  bool _loaded = false;

  /// Carga desde SharedPreferences las misiones completadas.
  ///
  /// Debe llamarse antes de consultar progreso si quieres asegurar
  /// que los datos estén actualizados.
  Future<void> loadProgress() async {
    if (_loaded) return;

    final prefs = await SharedPreferences.getInstance();
    final rawData = prefs.getString(_completedMissionsKey);

    if (rawData != null && rawData.isNotEmpty) {
      final decoded = jsonDecode(rawData);

      if (decoded is List) {
        _completedMissions
          ..clear()
          ..addAll(decoded.map((item) => item.toString()));
      }
    }

    _loaded = true;
  }

  /// Guarda en SharedPreferences las misiones completadas.
  Future<void> saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_completedMissions.toList());
    await prefs.setString(_completedMissionsKey, encoded);
  }

  /// Retorna true si la misión ya fue completada.
  bool isCompleted(String missionId) {
    return _completedMissions.contains(missionId);
  }

  /// Marca una misión como completada y guarda el progreso.
  Future<void> markAsCompleted(String missionId) async {
    _completedMissions.add(missionId);
    await saveProgress();
  }

  /// Retorna true si la misión está desbloqueada.
  ///
  /// Una misión está desbloqueada si:
  /// - No tiene requisitos previos.
  /// - O todas las misiones requeridas ya están completadas.
  bool isUnlocked(List<String> requiredMissionIds) {
    if (requiredMissionIds.isEmpty) return true;

    return requiredMissionIds.every(_completedMissions.contains);
  }

  /// Retorna la lista de IDs de misiones completadas.
  List<String> get completedMissionIds {
    return _completedMissions.toList();
  }

  /// Limpia todo el progreso de misiones.
  ///
  /// Útil para pruebas durante desarrollo.
  Future<void> resetProgress() async {
    _completedMissions.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_completedMissionsKey);

    _loaded = true;
  }
}