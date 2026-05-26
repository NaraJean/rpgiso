import 'package:flutter/material.dart';
import '../../models/enemy.dart';
import '../../models/player_status.dart';
import '../widgets/combat_engine.dart';

class HangmanScreen extends StatefulWidget {
  final PlayerStatus playerStatus;
  final String wordToGuess;

  /// Enemigo para el widget de batalla. Solo requerido cuando [showBattleWidget] = true.
  final Enemy? enemy;

  /// Si es `true`, muestra el widget de batalla (HP bars + sprite).
  /// Si es `false`, muestra solo la mecánica del ahorcado con fondo narrativo.
  /// Por defecto `true` para mantener compatibilidad con el flujo standalone.
  final bool showBattleWidget;

  /// Callback al terminar el minijuego. Recibe `true` si ganó, `false` si perdió.
  final Function(bool won)? onComplete;

  const HangmanScreen({
    super.key,
    required this.playerStatus,
    required this.wordToGuess,
    this.enemy,
    this.showBattleWidget = true,
    this.onComplete,
  });

  @override
  State<HangmanScreen> createState() => _HangmanScreenState();
}

class _HangmanScreenState extends State<HangmanScreen> with TickerProviderStateMixin {
  static const int _maxWrongGuesses = 6;

  List<String> guessedLetters = [];
  int wrongGuesses = 0;
  bool _showIntro = true;
  bool _showFinalPopup = false;
  bool _victory = false;

  late AnimationController _introController;
  late Animation<double> _introScale;
  late Animation<double> _introFade;

  late AnimationController _enemyZoomController;
  late Animation<double> _enemyZoom;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _introScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _introController, curve: Curves.easeOutBack),
    );
    _introFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _introController, curve: Curves.easeIn),
    );

    _enemyZoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _enemyZoom = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _enemyZoomController, curve: Curves.easeOutBack),
    );

    if (widget.showBattleWidget) {
      // Flujo con batalla: mostrar intro animada
      _introController.forward();
      Future.delayed(const Duration(milliseconds: 1600), () {
        if (mounted) {
          setState(() => _showIntro = false);
          _enemyZoomController.forward();
        }
      });
    } else {
      // Sin batalla: saltar intro directamente
      _showIntro = false;
    }
  }

  @override
  void dispose() {
    _introController.dispose();
    _enemyZoomController.dispose();
    super.dispose();
  }

  // ── Confirmación de salida ────────────────────────────────────────────────
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
                '¿Estás seguro de abandonar?',
                style: TextStyle(fontSize: 18, fontFamily: 'MedievalSharp', color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Perderás tu progreso en este paso.',
                style: TextStyle(fontSize: 14, fontFamily: 'MedievalSharp', color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white)),
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancelar',
                        style: TextStyle(fontFamily: 'MedievalSharp', color: Colors.white)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 90, 20, 20)),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Sí, abandonar',
                        style: TextStyle(fontFamily: 'MedievalSharp', color: Colors.white)),
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

  // ── Finalización del minijuego ────────────────────────────────────────────
  void _showFinalPopupAndExit(bool didWin) async {
    // En contexto narrativo: regresar inmediatamente sin mostrar popup
    if (widget.onComplete != null) {
      widget.onComplete!(didWin);
      if (mounted) Navigator.pop(context);
      return;
    }
    // Flujo standalone: mostrar popup y volver a la raíz
    setState(() {
      _victory = didWin;
      _showFinalPopup = true;
    });
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
  }

  // ── Lógica de letra sin batalla ───────────────────────────────────────────
  void _handleLetterNoBattle(String letter) {
    setState(() => guessedLetters.add(letter));
    if (widget.wordToGuess.contains(letter)) {
      if (widget.wordToGuess.split('').every((l) => guessedLetters.contains(l))) {
        _showFinalPopupAndExit(true);
      }
    } else {
      wrongGuesses++;
      if (wrongGuesses >= _maxWrongGuesses) {
        _showFinalPopupAndExit(false);
      }
    }
  }

  // ── Widgets auxiliares ────────────────────────────────────────────────────
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
              shadows: const [Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 4)],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
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
                BoxShadow(color: Colors.black.withOpacity(0.5), offset: const Offset(4, 4), blurRadius: 10)
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _victory ? '¡Has ganado!' : 'Has sido derrotado...',
                  style: const TextStyle(fontSize: 22, fontFamily: 'MedievalSharp', color: Colors.white),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.amberAccent)),
                  onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                  child: const Text('Volver al inicio',
                      style: TextStyle(color: Colors.white, fontFamily: 'MedievalSharp')),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Indicador de vidas restantes (corazones)
  Widget _buildLivesIndicator() {
    final remaining = _maxWrongGuesses - wrongGuesses;
    return Column(
      children: [
        Text(
          'Intentos restantes',
          style: TextStyle(
            fontFamily: 'MedievalSharp',
            color: Colors.amberAccent.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_maxWrongGuesses, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Icon(
                i < remaining ? Icons.favorite : Icons.favorite_border,
                color: remaining <= 2 ? Colors.redAccent : Colors.amberAccent,
                size: 22,
              ),
            );
          }),
        ),
      ],
    );
  }

  /// Teclado de letras reutilizable
  Widget _buildKeyboard({required void Function(String) onLetterTap}) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      runSpacing: 4,
      children: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('').map((letter) {
        final isGuessed = guessedLetters.contains(letter);
        final isCorrect = isGuessed && widget.wordToGuess.contains(letter);
        final isWrong = isGuessed && !widget.wordToGuess.contains(letter);
        return SizedBox(
          width: 38,
          height: 38,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              side: BorderSide(
                color: isCorrect
                    ? Colors.greenAccent
                    : isWrong
                        ? Colors.redAccent.withOpacity(0.4)
                        : Colors.white70,
              ),
              backgroundColor: isCorrect
                  ? Colors.green.withOpacity(0.15)
                  : isWrong
                      ? Colors.red.withOpacity(0.08)
                      : Colors.transparent,
            ),
            onPressed: isGuessed ? null : () => onLetterTap(letter),
            child: Text(
              letter,
              style: TextStyle(
                fontFamily: 'MedievalSharp',
                fontSize: 12,
                color: isWrong ? Colors.redAccent.withOpacity(0.5) : Colors.white,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD PRINCIPAL
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _confirmExit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.showBattleWidget ? 'Combate: Ahorcado' : 'El Rastro de Tinta',
            style: const TextStyle(color: Colors.white, fontFamily: 'MedievalSharp'),
          ),
          backgroundColor: const Color.fromARGB(255, 4, 14, 27),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final confirm = await _confirmExit();
              if (confirm && mounted) Navigator.pop(context);
            },
          ),
        ),
        body: widget.showBattleWidget
            ? _buildWithBattleWidget()
            : _buildWithoutBattleWidget(),
      ),
    );
  }

  // ── Modo CON widget de batalla (flujo original) ───────────────────────────
  Widget _buildWithBattleWidget() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/backgrounds/battle_bg.png', fit: BoxFit.cover),
        Container(color: Colors.black.withOpacity(0.6)),
        if (_showIntro) _buildIntroOverlay(),
        if (!_showIntro)
          CombatEngine(
            enemy: widget.enemy!,
            playerStatus: widget.playerStatus,
            onVictory: () => _showFinalPopupAndExit(true),
            onDefeat: () => _showFinalPopupAndExit(false),
            child: (dealDamage, takeDamage) {
              final displayWord = widget.wordToGuess
                  .split('')
                  .map((l) => guessedLetters.contains(l) ? l : '_')
                  .join(' ');
              return ScaleTransition(
                scale: _enemyZoom,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(displayWord,
                          style: const TextStyle(
                              fontSize: 28, color: Colors.white, fontFamily: 'MedievalSharp')),
                      const SizedBox(height: 20),
                      _buildKeyboard(onLetterTap: (letter) {
                        setState(() => guessedLetters.add(letter));
                        if (widget.wordToGuess.contains(letter)) {
                          dealDamage(widget.playerStatus.playerDamage);
                          if (widget.wordToGuess.split('').every((l) => guessedLetters.contains(l))) {
                            _showFinalPopupAndExit(true);
                          }
                        } else {
                          takeDamage(widget.enemy!.enemyDamage);
                          wrongGuesses++;
                        }
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
        if (_showFinalPopup) _buildFinalPopupOverlay(),
      ],
    );
  }

  // ── Modo SIN widget de batalla (narrativo puro) ───────────────────────────
  Widget _buildWithoutBattleWidget() {
    final displayWord = widget.wordToGuess
        .split('')
        .map((l) => guessedLetters.contains(l) ? l : '_')
        .join('  ');

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/backgrounds/story_bg.png', fit: BoxFit.cover),
        Container(color: Colors.black.withOpacity(0.5)),
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Indicador de vidas ──────────────────────────
                    _buildLivesIndicator(),
                    const SizedBox(height: 28),

                    // ── Palabra a adivinar ──────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amberAccent.withOpacity(0.4), width: 1),
                      ),
                      child: Text(
                        displayWord,
                        style: const TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          fontFamily: 'MedievalSharp',
                          letterSpacing: 2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.wordToGuess.length} letras',
                      style: TextStyle(
                        fontFamily: 'MedievalSharp',
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Teclado ─────────────────────────────────────
                    _buildKeyboard(onLetterTap: _handleLetterNoBattle),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_showFinalPopup) _buildFinalPopupOverlay(),
      ],
    );
  }
}
