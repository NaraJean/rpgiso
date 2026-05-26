import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/enemy.dart';
import '../../models/player_status.dart';
import '../../models/question.dart';
import '../../models/game_mission.dart';
import '../../models/minigame_type.dart';

import '../../services/local_storage_service.dart';
import '../widgets/combat_engine.dart';

class TriviaCombatScreen extends StatefulWidget {
  final PlayerStatus playerStatus;
  final List<Question> questions;
  final Enemy enemy;
  final GameMission mission;

  /// Callback al terminar el combate.
  /// Recibe true si ganó, false si perdió.
  final Function(bool won)? onComplete;

  const TriviaCombatScreen({
    super.key,
    required this.playerStatus,
    required this.questions,
    required this.enemy,
    required this.mission,
    this.onComplete,
  });

  @override
  State<TriviaCombatScreen> createState() => _TriviaCombatScreenState();
}

class _TriviaCombatScreenState extends State<TriviaCombatScreen>
    with TickerProviderStateMixin {
  late List<Question> _questions;

  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  int _wrongAnswers = 0;
  late int _damagePerCorrectAnswer;

  bool _showingFeedback = false;
  bool _showFinalPopup = false;
  bool _victory = false;
  bool _showIntro = true;
  bool _combatFinished = false;

  String _feedbackMessage = '';

  late AnimationController _introController;
  late Animation<double> _introScale;
  late Animation<double> _introFade;

  late AnimationController _feedbackController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  late AnimationController _enemyZoomController;
  late Animation<double> _enemyZoom;

  static const TextStyle _medievalStyle = TextStyle(
    fontFamily: 'MedievalSharp',
  );

  @override
  void initState() {
    super.initState();

    _questions = widget.questions;

    final questionCount = _questions.isEmpty ? 1 : _questions.length;
    final baseDynamicDamage = (widget.enemy.maxHealth / questionCount).ceil();

    /// Regla de balance:
    /// El daño por acierto debe ser suficiente para que, si responde todo bien,
    /// el jugador pueda derrotar al enemigo.
    ///
    /// También respetamos el daño del jugador si es mayor.
    _damagePerCorrectAnswer = max(
      widget.playerStatus.playerDamage,
      baseDynamicDamage,
    );

    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _feedbackController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _feedbackController,
        curve: Curves.easeIn,
      ),
    );

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _introScale = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: Curves.easeOutBack,
      ),
    );

    _introFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: Curves.easeIn,
      ),
    );

    _enemyZoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _enemyZoom = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _enemyZoomController,
        curve: Curves.easeOutBack,
      ),
    );

    _introController.forward();

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;

      setState(() {
        _showIntro = false;
      });

      _enemyZoomController.forward();
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
    if (_combatFinished) return true;

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color.fromARGB(255, 30, 30, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: Colors.amberAccent,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¿Abandonar el combate?',
                style: _medievalStyle.copyWith(
                  fontSize: 18,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Perderás tu progreso en esta batalla.',
                style: _medievalStyle.copyWith(
                  fontSize: 14,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                      ),
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(
                        'Cancelar',
                        style: _medievalStyle.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 90, 20, 20),
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(
                        'Salir',
                        style: _medievalStyle.copyWith(
                          color: Colors.white,
                        ),
                      ),
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

  Future<void> _finishCombat(bool didWin) async {
    if (_combatFinished) return;

    _combatFinished = true;

    if (didWin) {
      if (widget.mission.xpReward > 0) {
        widget.playerStatus.gainXp(widget.mission.xpReward);
      }

      if (widget.mission.coinReward > 0) {
        widget.playerStatus.coins += widget.mission.coinReward;
      }
    }

    await LocalStorageService().saveCharacter(
      widget.playerStatus.toCharacter(),
    );

    /// Si viene desde una misión narrativa, regresamos inmediatamente
    /// para que NarrativeMissionScreen continúe el flujo.
    if (widget.onComplete != null) {
      widget.onComplete!(didWin);

      if (mounted) {
        Navigator.pop(context);
      }

      return;
    }

    /// Flujo independiente para misiones antiguas.
    if (!mounted) return;

    setState(() {
      _victory = didWin;
      _showFinalPopup = true;
    });

    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  void _handleAnswer(
    bool isCorrect,
    String explanation,
    void Function(int damage) dealDamage,
    void Function(int damage) takeDamage,
  ) {
    if (_combatFinished || _showingFeedback) return;

    if (isCorrect) {
      _correctAnswers++;
      dealDamage(_damagePerCorrectAnswer);
    } else {
      _wrongAnswers++;
      takeDamage(widget.enemy.enemyDamage);
    }

    setState(() {
      _feedbackMessage = isCorrect
          ? '¡Correcto!\n\n$explanation'
          : 'Incorrecto.\n\n$explanation';
      _showingFeedback = true;
    });

    _feedbackController.forward(from: 0.0);
  }

  void _continueAfterFeedback() {
    if (_combatFinished) return;

    setState(() {
      _showingFeedback = false;
    });

    final isLastQuestion = _currentQuestionIndex >= _questions.length - 1;

    if (!isLastQuestion) {
      setState(() {
        _currentQuestionIndex++;
      });
      return;
    }

    /// Si se acabaron las preguntas y el enemigo no fue derrotado,
    /// el jugador pierde el paso.
    ///
    /// Esto evita la lógica vieja donde se mataba al enemigo artificialmente
    /// al final con dealDamage(widget.enemy.health).
    _finishCombat(false);
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
        ModalBarrier(
          dismissible: false,
          color: Colors.black.withOpacity(0.6),
        ),
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 30, 30, 60),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.amberAccent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  offset: const Offset(4, 4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _victory ? '¡Has ganado!' : 'Has sido derrotado...',
                  style: _medievalStyle.copyWith(
                    fontSize: 22,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                if (_victory)
                  Text(
                    'Recompensas:\n+${widget.mission.xpReward} XP\n+${widget.mission.coinReward} monedas',
                    textAlign: TextAlign.center,
                    style: _medievalStyle.copyWith(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  )
                else
                  Text(
                    'Respuestas correctas: $_correctAnswers / ${_questions.length}',
                    textAlign: TextAlign.center,
                    style: _medievalStyle.copyWith(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                const SizedBox(height: 16),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.amberAccent),
                  ),
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: Text(
                    'Volver al inicio',
                    style: _medievalStyle.copyWith(
                      color: Colors.white,
                    ),
                  ),
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
            style: _medievalStyle.copyWith(
              color: Colors.amberAccent[200],
              fontSize: 24,
              fontWeight: FontWeight.bold,
              shadows: const [
                Shadow(
                  color: Colors.black,
                  offset: Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyQuestionsView() {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 12, 12, 30),
      appBar: AppBar(
        title: Text(
          'Combate: Trivia',
          style: _medievalStyle.copyWith(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 2, 8, 15),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.45),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.amberAccent),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.amberAccent,
                  size: 50,
                ),
                const SizedBox(height: 12),
                Text(
                  'Este combate no tiene preguntas configuradas.',
                  style: _medievalStyle.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: () {
                    if (widget.onComplete != null) {
                      widget.onComplete!(false);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Volver'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return _buildEmptyQuestionsView();
    }

    final Enemy selectedEnemy = widget.enemy;
    final currentQuestion = _questions[_currentQuestionIndex];

    return WillPopScope(
      onWillPop: _confirmExit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Combate: Trivia',
            style: _medievalStyle.copyWith(color: Colors.white),
          ),
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
            Image.asset(
              'assets/backgrounds/battle_bg.png',
              fit: BoxFit.cover,
            ),
            Container(color: Colors.black.withOpacity(0.6)),

            if (_showIntro) _buildIntroOverlay(),

            if (!_showIntro)
              CombatEngine(
                enemy: selectedEnemy,
                playerStatus: widget.playerStatus,
                onVictory: () => _finishCombat(true),
                onDefeat: () => _finishCombat(false),
                child: (dealDamage, takeDamage) {
                  return ScaleTransition(
                    scale: _enemyZoom,
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        child: _showingFeedback
                            ? _buildFeedbackView()
                            : _buildQuestionView(
                                currentQuestion,
                                dealDamage,
                                takeDamage,
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

  Widget _buildFeedbackView() {
    return ScaleTransition(
      key: const ValueKey('feedback'),
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24.0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 46, 40, 65),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.amberAccent,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                offset: const Offset(3, 3),
                blurRadius: 6,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _feedbackMessage,
                textAlign: TextAlign.center,
                style: _medievalStyle.copyWith(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Correctas: $_correctAnswers / ${_questions.length}',
                style: _medievalStyle.copyWith(
                  fontSize: 13,
                  color: Colors.amberAccent,
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: Colors.amberAccent,
                    width: 1.5,
                  ),
                ),
                onPressed: _continueAfterFeedback,
                child: Text(
                  'Siguiente',
                  style: _medievalStyle.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionView(
    Question currentQuestion,
    void Function(int damage) dealDamage,
    void Function(int damage) takeDamage,
  ) {
    return Column(
      key: const ValueKey('question'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 18),

        Text(
          'Pregunta ${_currentQuestionIndex + 1} de ${_questions.length}',
          style: _medievalStyle.copyWith(
            fontSize: 13,
            color: Colors.amberAccent,
          ),
          textAlign: TextAlign.center,
        ),

        _buildDividerLine(),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            currentQuestion.text,
            style: _medievalStyle.copyWith(
              fontSize: 18,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 20),

        ...List.generate(
          currentQuestion.options.length,
          (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 7.0),
              child: FractionallySizedBox(
                widthFactor: 0.88,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black.withOpacity(0.12),
                    textStyle: _medievalStyle,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 10,
                    ),
                  ),
                  onPressed: _combatFinished || _showingFeedback
                      ? null
                      : () {
                          final isCorrect =
                              index == currentQuestion.correctIndex;

                          _handleAnswer(
                            isCorrect,
                            currentQuestion.explanation,
                            dealDamage,
                            takeDamage,
                          );
                        },
                  child: Text(
                    currentQuestion.options[index],
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}