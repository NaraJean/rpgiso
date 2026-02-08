import 'question.dart';
import 'minigame_type.dart';
import 'enemy.dart';
import 'memory_pair.dart';

enum MissionType { diaria, semanal }

class GameMission {
  final String id;  
  final String title;
  final String narrative;
  final String shortDescription;
  final String theoreticalHint;
  final MinigameType minigameType;
  final String category;
  final MissionType missionType;
  final List<Question> questions;
  final String? hangmanWord;
  final List<MemoryPair> memoryPairs;
  final Enemy? enemy;
  final int xpReward;
  final int coinReward;

  GameMission({
    required this.id,  
    required this.title,
    required this.narrative,
    required this.shortDescription,
    required this.theoreticalHint,
    required this.minigameType,
    required this.category,
    required this.missionType,
    this.questions = const [],
    this.hangmanWord,
    this.memoryPairs = const [],
    this.enemy,
    this.xpReward = 50, 
    this.coinReward = 50,
  });
}
