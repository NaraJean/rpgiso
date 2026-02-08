import 'package:flutter/material.dart';
import '../../models/enemy.dart';
import '../../models/player_status.dart';
import '../../models/question.dart';
import '../../models/game_mission.dart';
import '../../services/local_storage_service.dart';
import '../widgets/combat_engine.dart';

class TriviaCombatScreen extends StatefulWidget {
  final PlayerStatus playerStatus;
  final List<Question> questions;
  final Enemy enemy;
  final GameMission mission;

  const TriviaCombatScreen({
    super.key,
    required this.playerStatus,
    required this.questions,
    required this.enemy,
    required this.mission,
  });

  @override
  State<TriviaCombatScreen> createState() => _TriviaCombatScreenState();
}

class _TriviaCombatScreenState extends State<TriviaCombatScreen> with TickerProviderStateMixin {
  late List<Question> _questions;
  int _currentQuestionIndex = 0;
  bool _showingFeedback = false;
  bool _showFinalPopup = false;
  bool _victory = false;
  bool _showIntro = true;
  String _feedbackMessage = '';

  late AnimationController _introController;
  late Animation<double> _introScale;
  late Animation<double> _introFade;

  late AnimationController _feedbackController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  late AnimationController _enemyZoomController;
  late Animation<double> _enemyZoom;

  @override
  void initState() {
    super.initState();
    _questions = widget.questions;

    _feedbackController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(CurvedAnimation(parent: _feedbackController, curve: Curves.easeOutBack));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _feedbackController, curve: Curves.easeIn));

    _introController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _introScale = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _introController, curve: Curves.easeOutBack));
    _introFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _introController, curve: Curves.easeIn));

    _enemyZoomController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _enemyZoom = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _enemyZoomController, curve: Curves.easeOutBack));

    _introController.forward();
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) {
        setState(() => _showIntro = false);
        _enemyZoomController.forward();
      }
    });
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _introController.dispose();
    _enemyZoomController.dispose();
    super.dispose();
  }

  Future<bool> _confirmExit() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color.fromARGB(255, 30, 30, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.amberAccent, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '¿Estás seguro de abandonar el combate?',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'MedievalSharp',
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Perderás tu progreso en esta batalla.',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'MedievalSharp',
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                    ),
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(fontFamily: 'MedievalSharp', color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 90, 20, 20),
                    ),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text(
                      'Sí, abandonar',
                      style: TextStyle(fontFamily: 'MedievalSharp', color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return shouldExit ?? false;
  }

  void _showFinalPopupAndExit(bool didWin) async {
    widget.playerStatus.gainXp(widget.mission.xpReward);
    widget.playerStatus.coins += widget.mission.coinReward;
    await LocalStorageService().saveCharacter(widget.playerStatus.toCharacter());

    setState(() {
      _victory = didWin;
      _showFinalPopup = true;
    });

    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  void _handleAnswer(bool isCorrect, String explanation, void Function(int) dealDamage, void Function(int) takeDamage) {
    if (isCorrect) {
      dealDamage(widget.playerStatus.playerDamage);
    } else {
      takeDamage(widget.enemy.enemyDamage);
    }

    setState(() {
      _feedbackMessage = isCorrect ? '¡Correcto! $explanation' : 'Incorrecto. $explanation';
      _showingFeedback = true;
    });

    _feedbackController.forward(from: 0.0);
  }

  void _continueAfterFeedback(void Function(int) dealDamage) {
    setState(() => _showingFeedback = false);

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() => _currentQuestionIndex++);
    } else {
      dealDamage(widget.enemy.health);
      _showFinalPopupAndExit(true);
    }
  }

  Widget _buildDividerLine() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
      height: 2,
      color: Colors.amberAccent.withOpacity(0.5),
    );
  }

  Widget _buildFinalPopupOverlay() {
    return Stack(
      children: [
        ModalBarrier(dismissible: false, color: Colors.black.withOpacity(0.6)),
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 30, 30, 60),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amberAccent, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  offset: const Offset(4, 4),
                  blurRadius: 10,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _victory ? '¡Has ganado!' : 'Has sido derrotado...',
                  style: const TextStyle(fontSize: 22, fontFamily: 'MedievalSharp', color: Colors.white),
                ),
                const SizedBox(height: 12),
                if (_victory)
                  Text(
                    'Recompensas:\n+${widget.mission.xpReward} XP\n+${widget.mission.coinReward} monedas',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 16, fontFamily: 'MedievalSharp'),
                  ),
                const SizedBox(height: 16),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.amberAccent)),
                  onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                  child: const Text('Volver al inicio', style: TextStyle(color: Colors.white, fontFamily: 'MedievalSharp')),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIntroOverlay() {
    return FadeTransition(
      opacity: _introFade,
      child: ScaleTransition(
        scale: _introScale,
        child: Container(
          color: Colors.black.withOpacity(0.85),
          alignment: Alignment.center,
          child: Text(
            '¡Prepárate para el combate!',
            style: TextStyle(
              fontFamily: 'MedievalSharp',
              color: Colors.amberAccent[200],
              fontSize: 24,
              fontWeight: FontWeight.bold,
              shadows: const [
                Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 4),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Enemy selectedEnemy = widget.enemy;
    final currentQuestion = _questions[_currentQuestionIndex];

    return WillPopScope(
      onWillPop: _confirmExit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Combate: Trivia', style: TextStyle(color: Colors.white, fontFamily: 'MedievalSharp')),
          backgroundColor: const Color.fromARGB(255, 2, 8, 15),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final confirm = await _confirmExit();
              if (confirm && mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/backgrounds/battle_bg.png', fit: BoxFit.cover),
            Container(color: Colors.black.withOpacity(0.6)),

            if (_showIntro) _buildIntroOverlay(),

            if (!_showIntro)
              CombatEngine(
                enemy: selectedEnemy,
                playerStatus: widget.playerStatus,
                onVictory: () => _showFinalPopupAndExit(true),
                onDefeat: () => _showFinalPopupAndExit(false),
                child: (dealDamage, takeDamage) {
                  return ScaleTransition(
                    scale: _enemyZoom,
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                        child: _showingFeedback
                            ? ScaleTransition(
                                scale: _scaleAnimation,
                                child: FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: Container(
                                    key: const ValueKey('feedback'),
                                    margin: const EdgeInsets.symmetric(horizontal: 24.0),
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(255, 46, 40, 65),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.amberAccent, width: 1.5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.4),
                                          offset: const Offset(3, 3),
                                          blurRadius: 6,
                                        )
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _feedbackMessage,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontFamily: 'MedievalSharp',
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(color: Colors.amberAccent, width: 1.5),
                                          ),
                                          onPressed: () => _continueAfterFeedback(dealDamage),
                                          child: const Text(
                                            'Siguiente',
                                            style: TextStyle(color: Colors.white, fontFamily: 'MedievalSharp'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Column(
                                key: const ValueKey('question'),
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 20),
                                  _buildDividerLine(),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Text(
                                      currentQuestion.text,
                                      style: const TextStyle(fontSize: 18, fontFamily: 'MedievalSharp', color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  ...List.generate(currentQuestion.options.length, (index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: FractionallySizedBox(
                                        widthFactor: 0.85,
                                        child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(color: Colors.white),
                                            foregroundColor: Colors.white,
                                            backgroundColor: Colors.transparent,
                                            textStyle: const TextStyle(fontFamily: 'MedievalSharp'),
                                          ),
                                          onPressed: () {
                                            final isCorrect = index == currentQuestion.correctIndex;
                                            _handleAnswer(
                                              isCorrect,
                                              currentQuestion.explanation,
                                              dealDamage,
                                              takeDamage,
                                            );
                                          },
                                          child: Text(currentQuestion.options[index]),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                      ),
                    ),
                  );
                },
              ),

            if (_showFinalPopup) _buildFinalPopupOverlay(),
          ],
        ),
      ),
    );
  }
}
