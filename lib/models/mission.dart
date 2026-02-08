enum MissionType { diaria, semanal }

class Mission {
  String id;
  String title;
  String description;
  MissionType type;
  int xpReward;
  int coinReward;
  bool completed;

  Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.xpReward,
    required this.coinReward,
    this.completed = false,
  });
}
