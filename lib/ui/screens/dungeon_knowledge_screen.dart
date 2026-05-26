import 'package:flutter/material.dart';

import '../../data/dungeon_questions.dart';
import '../../data/mock_enemies.dart';
import '../../models/enemy.dart';
import '../../models/player_status.dart';
import '../../models/question.dart';

class DungeonKnowledgeScreen extends StatefulWidget {
  final PlayerStatus playerStatus;

  const DungeonKnowledgeScreen({
    super.key,
    required this.playerStatus,
  });

  @override
  State<DungeonKnowledgeScreen> createState() => _DungeonKnowledgeScreenState();
}

class _DungeonKnowledgeScreenState extends State<DungeonKnowledgeScreen> {
  late final List<Question> _questions;
  late int _playerHealth;

  int _currentQuestionIndex = 0;
  int _currentEnemyIndex = 0;
  int _enemyHealth = 1;

  int _correctAnswers = 0;
  int _wrongAnswers = 0;
  int _defeatedEnemies = 0;

  bool _showFeedback = false;
  bool _finished = false;
  bool _won = false;

  String _feedbackTitle = '';
  String _feedbackText = '';
  bool _lastAnswerCorrect = false;

  static const TextStyle medievalStyle = TextStyle(
    fontFamily: 'MedievalSharp',
  );

  @override
  void initState() {
    super.initState();

    _questions = List<Question>.from(dungeonQuestions);
    _playerHealth = widget.playerStatus.maxHealth;

    if (_dungeonEnemies.isNotEmpty) {
      _enemyHealth = _currentEnemy.maxHealth;
    }
  }

  List<Enemy> get _dungeonEnemies {
    return enemies.where((enemy) {
      return enemy.id == 'golem_cerradura_debil' ||
          enemy.id == 'heraldo_impostor' ||
          enemy.id == 'sombra_intrusa' ||
          enemy.id == 'devorador_memorias' ||
          enemy.id == '1' ||
          enemy.id == '2' ||
          enemy.id == '3';
    }).toList();
  }

  Enemy get _currentEnemy {
    final availableEnemies = _dungeonEnemies;

    if (availableEnemies.isEmpty) {
      return enemies.first;
    }

    return availableEnemies[_currentEnemyIndex % availableEnemies.length];
  }

  Question get _currentQuestion => _questions[_currentQuestionIndex];

  double get _playerHealthPercent {
    final maxHealth = widget.playerStatus.maxHealth <= 0
        ? 1
        : widget.playerStatus.maxHealth;

    return (_playerHealth / maxHealth).clamp(0.0, 1.0);
  }

  double get _enemyHealthPercent {
    final maxHealth = _currentEnemy.maxHealth <= 0 ? 1 : _currentEnemy.maxHealth;

    return (_enemyHealth / maxHealth).clamp(0.0, 1.0);
  }

  Future<bool> _confirmExit() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: const Color.fromARGB(255, 30, 30, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(
              color: Colors.amberAccent,
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '¿Salir de la mazmorra?',
                  style: medievalStyle.copyWith(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Perderás el avance de esta ronda.',
                  style: medievalStyle.copyWith(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white54),
                        ),
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(
                          'Cancelar',
                          style: medievalStyle.copyWith(
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
                          style: medievalStyle.copyWith(
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
        );
      },
    );

    return result ?? false;
  }

  void _answerQuestion(int selectedIndex) {
    if (_showFeedback || _finished) return;

    final isCorrect = selectedIndex == _currentQuestion.correctIndex;

    int enemyHealthAfter = _enemyHealth;
    int playerHealthAfter = _playerHealth;
    bool enemyDefeated = false;

    if (isCorrect) {
      final damage = widget.playerStatus.playerDamage;
      enemyHealthAfter -= damage;

      if (enemyHealthAfter <= 0) {
        enemyDefeated = true;
        _defeatedEnemies++;
      }

      _correctAnswers++;

      _feedbackTitle =
          enemyDefeated ? '¡Enemigo derrotado!' : '¡Respuesta correcta!';

      _feedbackText =
          '${_currentQuestion.explanation}\n\n'
          '${enemyDefeated ? 'La criatura cae y otra amenaza despierta en la mazmorra.' : 'Tu ataque impacta al enemigo.'}';
    } else {
      final damage = _currentEnemy.enemyDamage;
      playerHealthAfter -= damage;
      _wrongAnswers++;

      _feedbackTitle = 'Respuesta incorrecta';

      _feedbackText =
          '${_currentQuestion.explanation}\n\n'
          'El enemigo contraataca y pierdes $damage puntos de salud.';
    }

    setState(() {
      _lastAnswerCorrect = isCorrect;
      _enemyHealth = enemyHealthAfter <= 0 ? 0 : enemyHealthAfter;
      _playerHealth = playerHealthAfter <= 0 ? 0 : playerHealthAfter;
      _showFeedback = true;
    });

    if (_playerHealth <= 0) {
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        _finishDungeon(false);
      });
    }
  }

  void _continueAfterFeedback() {
    if (_finished) return;

    if (_playerHealth <= 0) {
      _finishDungeon(false);
      return;
    }

    final defeatedCurrentEnemy = _enemyHealth <= 0;

    if (_currentQuestionIndex >= _questions.length - 1) {
      _finishDungeon(true);
      return;
    }

    setState(() {
      _currentQuestionIndex++;
      _showFeedback = false;

      if (defeatedCurrentEnemy) {
        _currentEnemyIndex++;

        final nextEnemy =
            _dungeonEnemies[_currentEnemyIndex % _dungeonEnemies.length];

        _enemyHealth = nextEnemy.maxHealth;
      }
    });
  }

  void _finishDungeon(bool won) {
    setState(() {
      _finished = true;
      _won = won;
      _showFeedback = false;
    });
  }

  void _restartDungeon() {
    setState(() {
      _playerHealth = widget.playerStatus.maxHealth;
      _currentQuestionIndex = 0;
      _currentEnemyIndex = 0;
      _enemyHealth = _currentEnemy.maxHealth;
      _correctAnswers = 0;
      _wrongAnswers = 0;
      _defeatedEnemies = 0;
      _showFeedback = false;
      _finished = false;
      _won = false;
      _feedbackTitle = '';
      _feedbackText = '';
      _lastAnswerCorrect = false;
    });
  }

  Widget _buildBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          _currentEnemy.backgroundAsset,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Container(
              color: const Color.fromARGB(255, 8, 10, 22),
            );
          },
        ),
        Container(
          color: Colors.black.withOpacity(0.68),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: () async {
              final exit = await _confirmExit();

              if (exit && mounted) {
                Navigator.pop(context);
              }
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Mazmorra del Conocimiento',
                  style: medievalStyle.copyWith(
                    color: Colors.amberAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Pregunta ${_currentQuestionIndex + 1} de ${_questions.length}',
                  style: medievalStyle.copyWith(
                    color: Colors.white60,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildHealthBar({
    required String label,
    required int current,
    required int max,
    required double percent,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: medievalStyle.copyWith(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Container(
                height: 8,
                width: 230,
                color: Colors.white24,
              ),
              Container(
                height: 8,
                width: 230 * percent,
                color: color,
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$current / $max',
          style: medievalStyle.copyWith(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildEnemyPanel(BoxConstraints constraints) {
    final enemy = _currentEnemy;
    final bool compact = constraints.maxHeight < 740;
    final double spriteSize = compact ? 165 : 205;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            enemy.name,
            style: medievalStyle.copyWith(
              color: Colors.white,
              fontSize: compact ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          _buildHealthBar(
            label: 'Salud del enemigo',
            current: _enemyHealth,
            max: enemy.maxHealth,
            percent: _enemyHealthPercent,
            color: const Color.fromARGB(255, 122, 18, 18),
          ),
          SizedBox(height: compact ? 4 : 7),
          Image.asset(
            enemy.imageAsset,
            width: spriteSize,
            height: spriteSize,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) {
              return Icon(
                Icons.warning_amber_rounded,
                color: Colors.redAccent,
                size: spriteSize * 0.5,
              );
            },
          ),
          SizedBox(height: compact ? 4 : 7),
          _buildHealthBar(
            label: 'Tu salud',
            current: _playerHealth,
            max: widget.playerStatus.maxHealth,
            percent: _playerHealthPercent,
            color: const Color.fromARGB(255, 35, 130, 50),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPanel() {
    final question = _currentQuestion;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.74),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(22),
        ),
        border: Border.all(
          color: Colors.amberAccent.withOpacity(0.35),
          width: 1,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              question.category,
              style: medievalStyle.copyWith(
                color: Colors.amberAccent,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 7),
            Text(
              question.text,
              style: medievalStyle.copyWith(
                color: Colors.white,
                fontSize: 15,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ...List.generate(question.options.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.5),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Colors.white,
                        width: 1,
                      ),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () => _answerQuestion(index),
                    child: Text(
                      question.options[index],
                      style: medievalStyle.copyWith(
                        fontSize: 12.5,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.58),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(22),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 420,
          maxHeight: 360,
        ),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 30, 30, 60),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _lastAnswerCorrect ? Colors.greenAccent : Colors.redAccent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _lastAnswerCorrect
                  ? Icons.check_circle_rounded
                  : Icons.error_outline_rounded,
              color: _lastAnswerCorrect ? Colors.greenAccent : Colors.redAccent,
              size: 54,
            ),
            const SizedBox(height: 12),
            Text(
              _feedbackTitle,
              style: medievalStyle.copyWith(
                color:
                    _lastAnswerCorrect ? Colors.greenAccent : Colors.redAccent,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _feedbackText,
                  style: medievalStyle.copyWith(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 19, 34, 54),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
              ),
              onPressed: _continueAfterFeedback,
              icon: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
              ),
              label: Text(
                _currentQuestionIndex >= _questions.length - 1
                    ? 'Ver resultado'
                    : 'Continuar',
                style: medievalStyle.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalOverlay() {
    final int reachedQuestion = _won
        ? _questions.length
        : (_currentQuestionIndex + 1).clamp(1, _questions.length).toInt();

    return Container(
      color: Colors.black.withOpacity(0.72),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 430),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 30, 30, 60),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _won ? Colors.amberAccent : Colors.redAccent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _won
                  ? Icons.workspace_premium_rounded
                  : Icons.shield_outlined,
              color: _won ? Colors.amberAccent : Colors.redAccent,
              size: 72,
            ),
            const SizedBox(height: 14),
            Text(
              _won ? '¡Mazmorra completada!' : 'Has caído en la mazmorra',
              style: medievalStyle.copyWith(
                color: _won ? Colors.amberAccent : Colors.redAccent,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            Text(
              'Llegaste hasta la pregunta $reachedQuestion de ${_questions.length}.\n\n'
              'Respuestas correctas: $_correctAnswers\n'
              'Respuestas incorrectas: $_wrongAnswers\n'
              'Enemigos derrotados: $_defeatedEnemies',
              style: medievalStyle.copyWith(
                color: Colors.white70,
                fontSize: 15,
                height: 1.35,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white54),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Salir',
                      style: medievalStyle.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 19, 34, 54),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _restartDungeon,
                    child: Text(
                      'Reintentar',
                      style: medievalStyle.copyWith(
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
    );
  }

  Widget _buildStatsStrip() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 3),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 5,
        children: [
          _buildMiniStat(
            icon: Icons.check_circle_outline_rounded,
            label: 'Aciertos: $_correctAnswers',
            color: Colors.greenAccent,
          ),
          _buildMiniStat(
            icon: Icons.close_rounded,
            label: 'Fallos: $_wrongAnswers',
            color: Colors.redAccent,
          ),
          _buildMiniStat(
            icon: Icons.local_fire_department_rounded,
            label: 'Derrotados: $_defeatedEnemies',
            color: Colors.amberAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.42),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.45),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: medievalStyle.copyWith(
              color: Colors.white70,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty || enemies.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'La mazmorra no tiene preguntas o enemigos configurados.',
            style: medievalStyle.copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: _confirmExit,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            _buildBackground(),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    children: [
                      _buildHeader(),
                      _buildStatsStrip(),
                      Expanded(
                        flex: 44,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: _buildEnemyPanel(constraints),
                        ),
                      ),
                      Expanded(
                        flex: 56,
                        child: _buildQuestionPanel(),
                      ),
                    ],
                  );
                },
              ),
            ),
            if (_showFeedback) _buildFeedbackOverlay(),
            if (_finished) _buildFinalOverlay(),
          ],
        ),
      ),
    );
  }
}