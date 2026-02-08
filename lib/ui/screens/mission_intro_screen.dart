import 'package:flutter/material.dart';
import '../../models/player_status.dart';
import '../../models/game_mission.dart';
import '../../models/minigame_type.dart';
import 'trivia_combat_screen.dart';
import 'hangman_screen.dart';
import 'memory_game_screen.dart';
import '../../data/mock_enemies.dart';

class MissionIntroScreen extends StatefulWidget {
  final PlayerStatus playerStatus;
  final GameMission mission;

  const MissionIntroScreen({
    super.key,
    required this.playerStatus,
    required this.mission,
  });

  @override
  State<MissionIntroScreen> createState() => _MissionIntroScreenState();
}

class _MissionIntroScreenState extends State<MissionIntroScreen> with TickerProviderStateMixin {
  bool _showHint = false;
  String _visibleText = '';
  late AnimationController _controller;
  late Animation<int> _animation;
  String _fullText = '';

  @override
  void initState() {
    super.initState();
    _startTyping(widget.mission.narrative);
  }

  void _startTyping(String text) {
    _fullText = text;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: text.length * 40),
    );
    _animation = StepTween(begin: 0, end: text.length).animate(_controller)
      ..addListener(() {
        setState(() {
          _visibleText = text.substring(0, _animation.value);
        });
      });
    _controller.forward();
  }

  void _skipOrNext() {
    if (_controller.isAnimating) {
      _controller.stop();
      setState(() {
        _visibleText = _fullText;
      });
    } else if (!_showHint) {
      _controller.dispose();
      setState(() {
        _showHint = true;
      });
      _startTyping(widget.mission.theoreticalHint);
    } else {
      _startMission();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _skipOrNext,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/backgrounds/pergamino_vertical.png', fit: BoxFit.cover),
            Container(color: Colors.black.withOpacity(0.6)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400), // Limita el ancho
                  child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _showHint ? 'Recuerda:' : widget.mission.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'MedievalSharp',
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _visibleText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontFamily: 'MedievalSharp',
                        color: Color.fromARGB(255, 104, 142, 192),
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (!_controller.isAnimating)
                      ElevatedButton(
                        onPressed: _skipOrNext,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          backgroundColor: const Color.fromARGB(255, 19, 34, 54),
                        ),
                        child: Text(
                          _showHint ? 'Comenzar Misión' : 'Continuar',
                          style: const TextStyle(fontFamily: 'MedievalSharp'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            )
          ],
        ),
      ),
    );
  }

  void _startMission() {
    widget.playerStatus.health = widget.playerStatus.maxHealth;

    Widget nextScreen;
    if (widget.mission.minigameType == MinigameType.trivia) {
      nextScreen = TriviaCombatScreen(
        playerStatus: widget.playerStatus,
        questions: widget.mission.questions,
        enemy: widget.mission.enemy ?? enemies[0],
        mission: widget.mission,

      );
    } else if (widget.mission.minigameType == MinigameType.hangman) {
      nextScreen = HangmanScreen(
        playerStatus: widget.playerStatus,
        wordToGuess: widget.mission.hangmanWord ?? 'ISO27001',
        enemy: widget.mission.enemy ?? enemies[0],
      );
    } else if (widget.mission.minigameType == MinigameType.memory) {
      nextScreen = MemoryGameScreen(
        playerStatus: widget.playerStatus,
        enemy: widget.mission.enemy ?? enemies[0],
        memoryPairs: widget.mission.memoryPairs,
      );
    } else {
      nextScreen = TriviaCombatScreen(
        playerStatus: widget.playerStatus,
        questions: widget.mission.questions,
        enemy: widget.mission.enemy ?? enemies[0],
        mission: widget.mission,
      );
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }
}
