class MissionProgressService {
  static final MissionProgressService _instance = MissionProgressService._internal();
  factory MissionProgressService() => _instance;
  MissionProgressService._internal();

  final Set<String> _completedMissions = {};

  bool isCompleted(String missionId) => _completedMissions.contains(missionId);

  void markAsCompleted(String missionId) => _completedMissions.add(missionId);
}
