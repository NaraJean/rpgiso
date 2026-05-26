import 'package:flutter/material.dart';

import '../../models/narrative_mission.dart';
import '../../models/mission_step.dart';
import '../../models/player_status.dart';
import '../../models/step_type.dart';
import '../../models/minigame_type.dart';
import '../../models/game_mission.dart';
import '../../models/npc_dialogue.dart';

import '../../services/local_storage_service.dart';
import '../../services/mission_progress_service.dart';

import 'hangman_screen.dart';
import 'memory_game_screen.dart';
import 'trivia_combat_screen.dart';
import 'rune_forge_screen.dart';
import 'phishing_clues_screen.dart';
import 'access_puzzle_screen.dart';
import 'backup_timeline_screen.dart';
import 'narrative_choice_screen.dart';

enum _Phase {
  prologue,
  stepContent,
  stepWin,
  stepRetry,
  missionComplete,
}

class NarrativeMissionScreen extends StatefulWidget {
  final PlayerStatus playerStatus;
  final NarrativeMission mission;

  const NarrativeMissionScreen({
    super.key,
    required this.playerStatus,
    required this.mission,
  });

  @override
  State<NarrativeMissionScreen> createState() => _NarrativeMissionScreenState();
}

class _NarrativeMissionScreenState extends State<NarrativeMissionScreen>
    with TickerProviderStateMixin {
  _Phase _phase = _Phase.prologue;
  int _currentStepIndex = 0;

  bool _callbackHandled = false;
  bool _missionSaved = false;

  bool _showingStepDialogue = false;
  int _currentDialogueIndex = 0;

  AnimationController? _typingController;
  String _fullText = '';
  String _visibleText = '';

  bool get _isTyping => _typingController?.isAnimating ?? false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  static const _medievalStyle = TextStyle(fontFamily: 'MedievalSharp');

  static final _noRewardMission = GameMission(
    id: '_narrative_combat_step',
    title: 'Combate Narrativo',
    narrative: '',
    shortDescription: '',
    theoreticalHint: '',
    minigameType: MinigameType.trivia,
    category: 'basico',
    missionType: MissionType.diaria,
    xpReward: 0,
    coinReward: 0,
  );

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _setTypewriterText(widget.mission.prologue.text);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _typingController?.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  MissionStep get _currentStep => widget.mission.steps[_currentStepIndex];

  List<NpcDialogue> get _currentStepDialogues {
    final step = _currentStep;
    final dialogues = <NpcDialogue>[];

    if (step.preStepDialogue != null) {
      dialogues.add(step.preStepDialogue!);
    }

    dialogues.addAll(step.dialogues);

    return dialogues;
  }

  void _setTypewriterText(String text) {
    _typingController?.stop();
    _typingController?.dispose();
    _typingController = null;

    _fullText = text;
    _visibleText = '';

    final safeDuration = text.isEmpty ? 300 : text.length * 24;

    final controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: safeDuration),
    );

    final animation = StepTween(
      begin: 0,
      end: text.length,
    ).animate(controller);

    animation.addListener(() {
      if (!mounted) return;

      setState(() {
        _visibleText = _fullText.substring(0, animation.value);
      });
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() {});
      }
    });

    _typingController = controller;
    controller.forward();

    setState(() {});
  }

  void _skipTyping() {
    if (!_isTyping) return;

    _typingController?.stop();

    setState(() {
      _visibleText = _fullText;
    });
  }

  void _prepareCurrentStepPresentation() {
    final dialogues = _currentStepDialogues;

    if (dialogues.isNotEmpty) {
      _showingStepDialogue = true;
      _currentDialogueIndex = 0;
      _setTypewriterText(dialogues.first.text);
    } else {
      _showingStepDialogue = false;
      _currentDialogueIndex = 0;
      _visibleText = '';
      _fullText = '';
    }
  }

  void _goFromPrologue() {
    if (_isTyping) {
      _skipTyping();
      return;
    }

    if (widget.mission.steps.isEmpty) {
      _completeMission();
      return;
    }

    _transitionTo(_Phase.stepContent, stepIndex: 0);
  }

  void _advanceStep() {
    final nextIndex = _currentStepIndex + 1;

    if (nextIndex < widget.mission.steps.length) {
      _transitionTo(_Phase.stepContent, stepIndex: nextIndex);
    } else {
      _completeMission();
    }
  }

  void _goFromStepWin() {
    if (_isTyping) {
      _skipTyping();
      return;
    }

    _advanceStep();
  }

  void _goNextStepDialogue() {
    if (_isTyping) {
      _skipTyping();
      return;
    }

    final dialogues = _currentStepDialogues;
    final nextDialogueIndex = _currentDialogueIndex + 1;

    if (nextDialogueIndex < dialogues.length) {
      setState(() {
        _currentDialogueIndex = nextDialogueIndex;
      });

      _setTypewriterText(dialogues[nextDialogueIndex].text);
    } else {
      setState(() {
        _showingStepDialogue = false;
      });
    }
  }

  void _transitionTo(_Phase newPhase, {int? stepIndex}) {
    _fadeController.reverse().then((_) {
      if (!mounted) return;

      setState(() {
        _phase = newPhase;

        if (stepIndex != null) {
          _currentStepIndex = stepIndex;
        }
      });

      if (newPhase == _Phase.stepContent) {
        _prepareCurrentStepPresentation();
      }

      if (newPhase == _Phase.stepWin) {
        _setTypewriterText(_currentStep.safeWinText);
      }

      _fadeController.forward();
    });
  }

  void _launchCurrentStep() {
    final step = _currentStep;

    if (!step.launchesMinigame) {
      _advanceStep();
      return;
    }

    _callbackHandled = false;

    late Widget nextScreen;

    switch (step.minigameType) {
      case MinigameType.runeForge:
        nextScreen = RuneForgeScreen(
          playerStatus: widget.playerStatus,
          step: step,
          onComplete: _onMinigameComplete,
        );
        break;

      case MinigameType.phishingClues:
        nextScreen = PhishingCluesScreen(
          playerStatus: widget.playerStatus,
          step: step,
          onComplete: _onMinigameComplete,
        );
        break;

      case MinigameType.accessPuzzle:
        nextScreen = AccessPuzzleScreen(
          playerStatus: widget.playerStatus,
          step: step,
          onComplete: _onMinigameComplete,
        );
        break;

      case MinigameType.backupTimeline:
        nextScreen = BackupTimelineScreen(
          playerStatus: widget.playerStatus,
          step: step,
          onComplete: _onMinigameComplete,
        );
        break;

      case MinigameType.narrativeChoice:
        nextScreen = NarrativeChoiceScreen(
          playerStatus: widget.playerStatus,
          step: step,
          onComplete: _onMinigameComplete,
        );
        break;

      case MinigameType.hangman:
        nextScreen = HangmanScreen(
          playerStatus: widget.playerStatus,
          wordToGuess: step.hangmanWord ?? 'SEGURIDAD',
          enemy: step.enemy,
          showBattleWidget: step.showBattleWidget,
          onComplete: _onMinigameComplete,
        );
        break;

      case MinigameType.memory:
        nextScreen = MemoryGameScreen(
          playerStatus: widget.playerStatus,
          enemy: step.enemy,
          memoryPairs: step.memoryPairs,
          showBattleWidget: step.showBattleWidget,
          onComplete: _onMinigameComplete,
        );
        break;

      case MinigameType.trivia:
        if (step.enemy == null) {
          _showSimpleError('Este paso de combate no tiene enemigo asignado.');
          return;
        }

        nextScreen = TriviaCombatScreen(
          playerStatus: widget.playerStatus,
          questions: step.questions,
          enemy: step.enemy!,
          mission: _noRewardMission,
          onComplete: _onMinigameComplete,
        );
        break;

      case MinigameType.routeDecision:
      case MinigameType.orderSteps:
      case MinigameType.alertClassification:
      case MinigameType.shieldBoss:
        _showSimpleError('Este minijuego aún no está implementado.');
        return;

      case MinigameType.none:
        _advanceStep();
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }

  void _onMinigameComplete(bool won) {
    if (_callbackHandled) return;

    _callbackHandled = true;

    if (won) {
      _transitionTo(_Phase.stepWin);
    } else {
      _transitionTo(_Phase.stepRetry);
    }
  }

  Future<void> _completeMission() async {
    if (_missionSaved) return;
    _missionSaved = true;

    widget.playerStatus.gainXp(widget.mission.xpReward);
    widget.playerStatus.coins += widget.mission.coinReward;

    await LocalStorageService().saveCharacter(
      widget.playerStatus.toCharacter(),
    );

    await MissionProgressService().loadProgress();
    await MissionProgressService().markAsCompleted(widget.mission.id);

    if (!mounted) return;

    _fadeController.reverse().then((_) {
      if (!mounted) return;

      setState(() {
        _phase = _Phase.missionComplete;
      });

      _fadeController.forward();
    });
  }

  Future<bool> _confirmExit() async {
    final result = await showDialog<bool>(
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
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¿Abandonar la misión?',
                style: _medievalStyle.copyWith(
                  fontSize: 18,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Perderás el progreso de esta misión.',
                style: _medievalStyle.copyWith(
                  fontSize: 13,
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
                        side: const BorderSide(color: Colors.white54),
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

    return result ?? false;
  }

  void _showSimpleError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _confirmExit,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            _buildBackground(),
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: _buildCurrentPhase(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    final bg = widget.mission.backgroundAsset.trim().isNotEmpty
        ? widget.mission.backgroundAsset
        : 'assets/backgrounds/story_bg.png';

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          bg,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Container(
              color: const Color.fromARGB(255, 14, 16, 35),
            );
          },
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.45),
                Colors.black.withOpacity(0.65),
                Colors.black.withOpacity(0.82),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentPhase() {
    switch (_phase) {
      case _Phase.prologue:
        return _buildDialogueScene(
          key: const ValueKey('prologue'),
          headerLabel: widget.mission.title,
          npcName: widget.mission.prologue.npcName,
          visibleText: _visibleText,
          continueLabel: 'Comenzar misión',
          onContinue: _goFromPrologue,
        );

      case _Phase.stepContent:
        if (_showingStepDialogue) {
          return _buildStepNpcDialogueScene(
            key: ValueKey(
              'dialogue_${_currentStep.id}_$_currentDialogueIndex',
            ),
          );
        }

        return _buildStepContentView(
          key: ValueKey('step_${_currentStep.id}'),
        );

      case _Phase.stepWin:
        return _buildDialogueScene(
          key: ValueKey('step_win_${_currentStep.id}'),
          headerLabel: '✓ ${_currentStep.title}',
          headerColor: const Color(0xFF4CAF50),
          npcName: _currentStep.safeWinNpcName,
          visibleText: _visibleText,
          continueLabel: _currentStepIndex + 1 < widget.mission.steps.length
              ? 'Siguiente paso'
              : 'Completar misión',
          onContinue: _goFromStepWin,
        );

      case _Phase.stepRetry:
        return _buildRetryView(
          key: ValueKey('retry_${_currentStep.id}'),
        );

      case _Phase.missionComplete:
        return _buildMissionCompleteView(
          key: const ValueKey('mission_complete'),
        );
    }
  }

  Widget _buildDialogueScene({
    required Key key,
    required String headerLabel,
    required String npcName,
    required String visibleText,
    required String continueLabel,
    required VoidCallback onContinue,
    Color? headerColor,
  }) {
    return GestureDetector(
      key: key,
      onTap: _isTyping ? _skipTyping : null,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 720;

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 16 : 22,
              vertical: compact ? 12 : 18,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionLabel(
                  headerLabel,
                  color: headerColor ?? _accentForCharacter(npcName),
                ),
                SizedBox(height: compact ? 10 : 14),
                Expanded(
                  child: _buildCharacterStage(
                    npcName,
                    compact: compact,
                  ),
                ),
                SizedBox(height: compact ? 10 : 14),
                _buildRpgDialogueBox(
                  characterName: npcName,
                  text: visibleText,
                  continueLabel: continueLabel,
                  onContinue: _isTyping ? null : onContinue,
                  compact: compact,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepNpcDialogueScene({required Key key}) {
    final dialogues = _currentStepDialogues;
    final dialogue = dialogues[_currentDialogueIndex];
    final isLastDialogue = _currentDialogueIndex == dialogues.length - 1;

    return GestureDetector(
      key: key,
      onTap: _isTyping ? _skipTyping : null,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 720;

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 16 : 22,
              vertical: compact ? 12 : 18,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionLabel(
                  _currentStep.title,
                  color: _accentForCharacter(dialogue.npcName),
                ),
                SizedBox(height: compact ? 6 : 8),
                _buildDialogueCounter(
                  current: _currentDialogueIndex + 1,
                  total: dialogues.length,
                ),
                SizedBox(height: compact ? 8 : 12),
                Expanded(
                  child: _buildCharacterStage(
                    dialogue.npcName,
                    compact: compact,
                  ),
                ),
                SizedBox(height: compact ? 10 : 14),
                _buildRpgDialogueBox(
                  characterName: dialogue.npcName,
                  text: _visibleText,
                  continueLabel:
                      isLastDialogue ? 'Continuar escena' : 'Siguiente diálogo',
                  onContinue: _isTyping ? null : _goNextStepDialogue,
                  compact: compact,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCharacterStage(
    String characterName, {
    required bool compact,
  }) {
    final assetPath = _characterAssetForName(characterName);
    final accent = _accentForCharacter(characterName);

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: compact ? 260 : 330,
            height: compact ? 260 : 330,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withOpacity(0.08),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.25),
                  blurRadius: 46,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          Container(
            width: compact ? 225 : 290,
            height: compact ? 225 : 290,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: accent.withOpacity(0.55),
                width: 2.4,
              ),
            ),
          ),
          Container(
            width: compact ? 205 : 265,
            height: compact ? 205 : 265,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.45),
              border: Border.all(
                color: accent.withOpacity(0.88),
                width: 2.8,
              ),
            ),
            child: ClipOval(
              child: assetPath == null
                  ? _buildCharacterFallbackIcon(accent)
                  : Image.asset(
                      assetPath,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (_, __, ___) =>
                          _buildCharacterFallbackIcon(accent),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRpgDialogueBox({
    required String characterName,
    required String text,
    required String continueLabel,
    required VoidCallback? onContinue,
    required bool compact,
  }) {
    final accent = _accentForCharacter(characterName);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16,
        compact ? 18 : 20,
        16,
        14,
      ),
      decoration: BoxDecoration(
        color: const Color.fromARGB(240, 12, 14, 30),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accent.withOpacity(0.72),
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: accent.withOpacity(0.10),
            blurRadius: 22,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _buildCharacterNamePlate(characterName, accent),
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: _medievalStyle.copyWith(
              fontSize: compact ? 13.5 : 15,
              color: const Color(0xFFCBD8F0),
              height: 1.28,
            ),
            maxLines: compact ? 4 : 5,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (_isTyping)
                Expanded(
                  child: Text(
                    'Toca para mostrar todo',
                    style: _medievalStyle.copyWith(
                      color: Colors.white38,
                      fontSize: 10.5,
                    ),
                  ),
                )
              else
                const Spacer(),
              AnimatedOpacity(
                opacity: _isTyping ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 250),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 19, 34, 54),
                    disabledBackgroundColor: Colors.grey.shade800,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 14,
                    ),
                    side: BorderSide(
                      color: accent.withOpacity(0.85),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: onContinue,
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white70,
                    size: 17,
                  ),
                  label: Text(
                    continueLabel,
                    style: _medievalStyle.copyWith(
                      fontSize: compact ? 12.5 : 13.5,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterNamePlate(String characterName, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: const Color.fromARGB(245, 20, 20, 48),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accent.withOpacity(0.85),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.16),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _iconForCharacter(characterName),
            color: accent,
            size: 16,
          ),
          const SizedBox(width: 7),
          Text(
            characterName,
            style: _medievalStyle.copyWith(
              fontSize: 14,
              color: accent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContentView({required Key key}) {
    final step = _currentStep;
    final totalSteps = widget.mission.steps.length;
    final bool isPlayable = step.launchesMinigame;

    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProgressIndicator(_currentStepIndex + 1, totalSteps),
              const SizedBox(height: 12),
              Text(
                step.title,
                style: _medievalStyle.copyWith(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Colors.amberAccent,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _buildInfoBox(
                icon: _iconForStepType(step.stepType),
                label: _labelForStepType(step.stepType),
                text: step.contextText,
                borderColor: _colorForStepType(step.stepType),
              ),
              if (step.allegoryText != null &&
                  step.allegoryText!.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildInfoBox(
                  icon: Icons.lightbulb_outline,
                  label: 'Conexión con ciberseguridad',
                  text: step.allegoryText!,
                  borderColor: const Color(0xFFB8A040),
                ),
              ],
              if (isPlayable) ...[
                const SizedBox(height: 16),
                _buildMinigameBadge(step),
              ],
              const SizedBox(height: 22),
              _buildPrimaryButton(
                label: isPlayable
                    ? _playButtonLabel(step)
                    : _continueButtonLabel(step.stepType),
                onPressed: isPlayable ? _launchCurrentStep : _advanceStep,
                icon: isPlayable
                    ? Icons.play_arrow_rounded
                    : Icons.arrow_forward_rounded,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () async {
                  final exit = await _confirmExit();
                  if (exit && mounted) Navigator.pop(context);
                },
                child: Text(
                  'Abandonar misión',
                  style: _medievalStyle.copyWith(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRetryView({required Key key}) {
    return Center(
      key: key,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.shield_outlined,
                color: Colors.redAccent,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Derrota temporal...',
                style: _medievalStyle.copyWith(
                  fontSize: 23,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              _buildTextBox(
                'El camino aún no ha terminado, Guardián.\n\n'
                'Puedes volver a intentar este paso para continuar la misión.',
                fontSize: 15,
              ),
              const SizedBox(height: 26),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white38),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () async {
                        final exit = await _confirmExit();
                        if (exit && mounted) Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white54,
                      ),
                      label: Text(
                        'Abandonar',
                        style: _medievalStyle.copyWith(
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 27, 54, 100),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(
                          color: Colors.blueAccent,
                          width: 1,
                        ),
                      ),
                      onPressed: () => _transitionTo(
                        _Phase.stepContent,
                        stepIndex: _currentStepIndex,
                      ),
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: Text(
                        'Reintentar',
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
  }

  Widget _buildMissionCompleteView({required Key key}) {
    return Center(
      key: key,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star_rounded,
                color: Colors.amberAccent,
                size: 82,
              ),
              const SizedBox(height: 16),
              Text(
                '¡Misión completada!',
                style: _medievalStyle.copyWith(
                  fontSize: 27,
                  color: Colors.amberAccent,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                widget.mission.title,
                style: _medievalStyle.copyWith(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildInfoBox(
                icon: Icons.security_rounded,
                label: 'Concepto aprendido',
                text: widget.mission.concept,
                borderColor: const Color(0xFF6E8CBA),
              ),
              const SizedBox(height: 12),
              _buildInfoBox(
                icon: Icons.verified_user_outlined,
                label: 'Relación con ISO 27001',
                text: widget.mission.isoRelation,
                borderColor: const Color(0xFFB8A040),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.amberAccent.withOpacity(0.6),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Recompensas obtenidas',
                      style: _medievalStyle.copyWith(
                        fontSize: 14,
                        color: Colors.amberAccent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 20,
                      runSpacing: 12,
                      children: [
                        _buildRewardItem(
                          icon: Icons.bolt,
                          label: '+${widget.mission.xpReward} XP',
                        ),
                        _buildRewardItem(
                          icon: Icons.monetization_on_rounded,
                          label: '+${widget.mission.coinReward} monedas',
                        ),
                        if (widget.mission.specialReward != null)
                          _buildRewardItem(
                            icon: Icons.workspace_premium_rounded,
                            label: widget.mission.specialReward!,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              _buildPrimaryButton(
                label: 'Volver',
                onPressed: () => Navigator.pop(context, true),
                icon: Icons.home_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardItem({
    required IconData icon,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.amberAccent, size: 21),
        const SizedBox(width: 5),
        Text(
          label,
          style: _medievalStyle.copyWith(
            fontSize: 15,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(
    String label, {
    Color color = Colors.amberAccent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.42),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          bottom: BorderSide(
            color: color.withOpacity(0.65),
            width: 1,
          ),
        ),
      ),
      child: Text(
        label,
        style: _medievalStyle.copyWith(
          fontSize: 13,
          color: color,
          letterSpacing: 0.5,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildDialogueCounter({
    required int current,
    required int total,
  }) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white24,
            width: 1,
          ),
        ),
        child: Text(
          'Diálogo $current de $total',
          style: _medievalStyle.copyWith(
            fontSize: 11,
            color: Colors.white60,
          ),
        ),
      ),
    );
  }

  Widget _buildTextBox(String text, {double fontSize = 15}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.46),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: Colors.white24,
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: _medievalStyle.copyWith(
          fontSize: fontSize,
          color: const Color(0xFFCBD8F0),
          height: 1.25,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildInfoBox({
    required IconData icon,
    required String label,
    required String text,
    required Color borderColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.36),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: borderColor.withOpacity(0.55),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: borderColor, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: _medievalStyle.copyWith(
                    fontSize: 13,
                    color: borderColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: _medievalStyle.copyWith(
              fontSize: 14,
              color: Colors.white70,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(int current, int total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color.fromARGB(180, 20, 20, 50),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.amberAccent.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Text(
            'PASO $current DE $total',
            style: _medievalStyle.copyWith(
              fontSize: 11,
              color: Colors.amberAccent,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMinigameBadge(MissionStep step) {
    final color = _colorForMinigame(step.minigameType);
    final icon = _iconForMinigame(step.minigameType);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: color.withOpacity(0.19),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: color.withOpacity(0.75),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              step.minigameLabel.isNotEmpty
                  ? step.minigameLabel
                  : 'Actividad',
              style: _medievalStyle.copyWith(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 19, 34, 54),
        disabledBackgroundColor: Colors.grey.shade800,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        side: const BorderSide(
          color: Color.fromARGB(255, 148, 147, 255),
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white70, size: 18),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              label,
              style: _medievalStyle.copyWith(
                fontSize: 15,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterFallbackIcon(Color accent) {
    return Container(
      color: const Color.fromARGB(255, 24, 24, 52),
      child: Icon(
        Icons.person_outline_rounded,
        color: accent,
        size: 72,
      ),
    );
  }

  String? _characterAssetForName(String characterName) {
    final normalized = characterName.toLowerCase();

    // NPC aliados
    if (normalized.contains('elyra')) {
      return 'assets/npcs/elyra.png';
    }

    if (normalized.contains('brann') || normalized.contains('forjador')) {
      return 'assets/npcs/brann.png';
    }

    if (normalized.contains('lira') || normalized.contains('mensajera')) {
      return 'assets/npcs/lira.png';
    }

    if (normalized.contains('rowan') || normalized.contains('capitán')) {
      return 'assets/npcs/rowan.png';
    }

    if (normalized.contains('thalen') || normalized.contains('archivista')) {
      return 'assets/npcs/thalen.png';
    }

    // Enemigos narrativos que pueden hablar en escenas
    if (normalized.contains('gólem') ||
        normalized.contains('golem') ||
        normalized.contains('cerradura')) {
      return 'assets/enemies/golem_cerradura.png';
    }

    if (normalized.contains('heraldo') || normalized.contains('impostor')) {
      return 'assets/enemies/heraldo_impostor.png';
    }

    if (normalized.contains('sombra') || normalized.contains('intrusa')) {
      return 'assets/enemies/sombra_intrusa.png';
    }

    if (normalized.contains('devorador') || normalized.contains('memorias')) {
      return 'assets/enemies/devorador_memorias.png';
    }

    // Enemigos viejos o respaldo
    if (normalized.contains('orco') || normalized.contains('orc')) {
      return 'assets/enemies/orc.png';
    }

    if (normalized.contains('hechicero') ||
        normalized.contains('mage') ||
        normalized.contains('mago') ||
        normalized.contains('caos')) {
      return 'assets/enemies/mage.png';
    }

    if (normalized.contains('defensor') || normalized.contains('defender')) {
      return 'assets/enemies/defender.png';
    }

    return null;
  }

  Color _accentForCharacter(String characterName) {
    final normalized = characterName.toLowerCase();

    if (normalized.contains('elyra')) {
      return const Color(0xFFB8A040);
    }

    if (normalized.contains('brann') || normalized.contains('forjador')) {
      return Colors.amberAccent;
    }

    if (normalized.contains('lira') || normalized.contains('mensajera')) {
      return const Color(0xFFD19A3A);
    }

    if (normalized.contains('rowan') || normalized.contains('capitán')) {
      return const Color(0xFF4CAF90);
    }

    if (normalized.contains('thalen') || normalized.contains('archivista')) {
      return const Color(0xFF7DD3FC);
    }

    if (normalized.contains('gólem') ||
        normalized.contains('golem') ||
        normalized.contains('cerradura')) {
      return const Color(0xFF94A3B8);
    }

    if (normalized.contains('heraldo') || normalized.contains('impostor')) {
      return const Color(0xFFF97316);
    }

    if (normalized.contains('sombra') || normalized.contains('intrusa')) {
      return const Color(0xFFA78BFA);
    }

    if (normalized.contains('devorador') || normalized.contains('memorias')) {
      return const Color(0xFFFB7185);
    }

    return Colors.amberAccent;
  }

  IconData _iconForCharacter(String characterName) {
    final normalized = characterName.toLowerCase();

    if (normalized.contains('elyra')) {
      return Icons.auto_awesome_rounded;
    }

    if (normalized.contains('brann') || normalized.contains('forjador')) {
      return Icons.handyman_rounded;
    }

    if (normalized.contains('lira') || normalized.contains('mensajera')) {
      return Icons.mark_email_unread_rounded;
    }

    if (normalized.contains('rowan') || normalized.contains('capitán')) {
      return Icons.shield_rounded;
    }

    if (normalized.contains('thalen') || normalized.contains('archivista')) {
      return Icons.menu_book_rounded;
    }

    if (normalized.contains('gólem') ||
        normalized.contains('golem') ||
        normalized.contains('cerradura')) {
      return Icons.account_tree_rounded;
    }

    if (normalized.contains('heraldo') || normalized.contains('impostor')) {
      return Icons.warning_amber_rounded;
    }

    if (normalized.contains('sombra') || normalized.contains('intrusa')) {
      return Icons.visibility_off_rounded;
    }

    if (normalized.contains('devorador') || normalized.contains('memorias')) {
      return Icons.psychology_alt_rounded;
    }

    return Icons.person_outline_rounded;
  }

  IconData _iconForStepType(StepType type) {
    switch (type) {
      case StepType.story:
        return Icons.auto_stories_rounded;
      case StepType.dialogue:
        return Icons.forum_rounded;
      case StepType.concept:
        return Icons.menu_book_rounded;
      case StepType.minigame:
        return Icons.extension_rounded;
      case StepType.event:
        return Icons.warning_amber_rounded;
      case StepType.combat:
        return Icons.gavel_rounded;
      case StepType.bossCombat:
        return Icons.local_fire_department_rounded;
      case StepType.closing:
        return Icons.flag_rounded;
      case StepType.reward:
        return Icons.workspace_premium_rounded;
    }
  }

  Color _colorForStepType(StepType type) {
    switch (type) {
      case StepType.story:
        return const Color(0xFF6E8CBA);
      case StepType.dialogue:
        return const Color(0xFFB8A040);
      case StepType.concept:
        return const Color(0xFF4CAF90);
      case StepType.minigame:
        return const Color(0xFF7B4EA0);
      case StepType.event:
        return const Color(0xFFD19A3A);
      case StepType.combat:
        return const Color(0xFFB33A3A);
      case StepType.bossCombat:
        return const Color(0xFFE05A3A);
      case StepType.closing:
        return const Color(0xFF6EA86E);
      case StepType.reward:
        return Colors.amberAccent;
    }
  }

  String _labelForStepType(StepType type) {
    switch (type) {
      case StepType.story:
        return 'Escena del Reino';
      case StepType.dialogue:
        return 'Conversación';
      case StepType.concept:
        return 'Códice del Guardián';
      case StepType.minigame:
        return 'Reto del Guardián';
      case StepType.event:
        return 'Evento';
      case StepType.combat:
        return 'Combate';
      case StepType.bossCombat:
        return 'Jefe';
      case StepType.closing:
        return 'Cierre de misión';
      case StepType.reward:
        return 'Recompensa';
    }
  }

  IconData _iconForMinigame(MinigameType type) {
    switch (type) {
      case MinigameType.trivia:
        return Icons.quiz_rounded;
      case MinigameType.hangman:
        return Icons.abc_rounded;
      case MinigameType.memory:
        return Icons.grid_view_rounded;
      case MinigameType.runeForge:
        return Icons.key_rounded;
      case MinigameType.phishingClues:
        return Icons.search_rounded;
      case MinigameType.routeDecision:
        return Icons.alt_route_rounded;
      case MinigameType.accessPuzzle:
        return Icons.door_front_door_rounded;
      case MinigameType.backupTimeline:
        return Icons.timeline_rounded;
      case MinigameType.narrativeChoice:
        return Icons.psychology_alt_rounded;
      case MinigameType.orderSteps:
        return Icons.format_list_numbered_rounded;
      case MinigameType.alertClassification:
        return Icons.crisis_alert_rounded;
      case MinigameType.shieldBoss:
        return Icons.shield_rounded;
      case MinigameType.none:
        return Icons.info_outline_rounded;
    }
  }

  Color _colorForMinigame(MinigameType type) {
    switch (type) {
      case MinigameType.trivia:
        return const Color(0xFF8B1A1A);
      case MinigameType.hangman:
        return const Color(0xFF7B4EA0);
      case MinigameType.memory:
        return const Color(0xFF2E7D72);
      case MinigameType.runeForge:
        return Colors.amberAccent;
      case MinigameType.phishingClues:
        return const Color(0xFFD19A3A);
      case MinigameType.routeDecision:
        return const Color(0xFF6E8CBA);
      case MinigameType.accessPuzzle:
        return const Color(0xFF4CAF90);
      case MinigameType.backupTimeline:
        return const Color(0xFF6EA86E);
      case MinigameType.narrativeChoice:
        return const Color(0xFFB8A040);
      case MinigameType.orderSteps:
        return const Color(0xFFB8A040);
      case MinigameType.alertClassification:
        return const Color(0xFFE05A3A);
      case MinigameType.shieldBoss:
        return const Color(0xFFB33A3A);
      case MinigameType.none:
        return Colors.white70;
    }
  }

  String _playButtonLabel(MissionStep step) {
    switch (step.minigameType) {
      case MinigameType.runeForge:
        return 'Comenzar forja';
      case MinigameType.phishingClues:
        return 'Investigar pergamino';
      case MinigameType.trivia:
        return 'Iniciar combate';
      case MinigameType.hangman:
        return 'Comenzar ahorcado';
      case MinigameType.memory:
        return 'Comenzar memoria';
      case MinigameType.routeDecision:
        return 'Iniciar persecución';
      case MinigameType.accessPuzzle:
        return 'Asignar permisos';
      case MinigameType.backupTimeline:
        return 'Ordenar respaldo';
      case MinigameType.narrativeChoice:
        return 'Tomar decisión';
      case MinigameType.orderSteps:
        return 'Ordenar pasos';
      case MinigameType.alertClassification:
        return 'Clasificar alertas';
      case MinigameType.shieldBoss:
        return 'Enfrentar jefe';
      case MinigameType.none:
        return 'Continuar';
    }
  }

  String _continueButtonLabel(StepType type) {
    switch (type) {
      case StepType.story:
        return 'Continuar historia';
      case StepType.dialogue:
        return 'Continuar diálogo';
      case StepType.concept:
        return 'Abrir códice';
      case StepType.event:
        return 'Continuar';
      case StepType.closing:
        return 'Finalizar misión';
      case StepType.reward:
        return 'Recibir recompensa';
      case StepType.minigame:
      case StepType.combat:
      case StepType.bossCombat:
        return 'Comenzar';
    }
  }
}