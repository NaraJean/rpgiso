import 'package:flutter/material.dart';
import '../../models/enemy.dart';
import '../../models/player_status.dart';
import '../widgets/combat_engine.dart';

class HangmanScreen extends StatefulWidget {
  final PlayerStatus playerStatus;
  final String wordToGuess;
  final Enemy enemy;

  const HangmanScreen({
    super.key,
    required this.playerStatus,
    required this.wordToGuess,
    required this.enemy,
  });

  @override
  State<HangmanScreen> createState() => _HangmanScreenState();
}

class _HangmanScreenState extends State<HangmanScreen> with TickerProviderStateMixin {
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
    setState(() {
      _victory = didWin;
      _showFinalPopup = true;
    });

    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _confirmExit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Combate: Ahorcado', style: TextStyle(color: Colors.white, fontFamily: 'MedievalSharp')),
          backgroundColor: const Color.fromARGB(255, 4, 14, 27),
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
                enemy: widget.enemy,
                playerStatus: widget.playerStatus,
                onVictory: () => _showFinalPopupAndExit(true),
                onDefeat: () => _showFinalPopupAndExit(false),
                child: (dealDamage, takeDamage) {
                  String displayWord = widget.wordToGuess
                      .split('')
                      .map((letter) => guessedLetters.contains(letter) ? letter : '_')
                      .join(' ');

                  return ScaleTransition(
                    scale: _enemyZoom,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            displayWord,
                            style: const TextStyle(fontSize: 28, color: Colors.white, fontFamily: 'MedievalSharp'),
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            alignment: WrapAlignment.center,
                            children: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('').map((letter) {
                              return Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.white),
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.transparent,
                                    textStyle: const TextStyle(fontFamily: 'MedievalSharp'),
                                  ),
                                  onPressed: guessedLetters.contains(letter)
                                      ? null
                                      : () {
                                          setState(() => guessedLetters.add(letter));
                                          if (widget.wordToGuess.contains(letter)) {
                                            dealDamage(widget.playerStatus.playerDamage);
                                            if (widget.wordToGuess.split('').every((l) => guessedLetters.contains(l))) {
                                              _showFinalPopupAndExit(true); // ✅ no más dealDamage extra
                                            }
                                          } else {
                                            takeDamage(widget.enemy.enemyDamage);
                                            wrongGuesses++;
                                          }
                                        },
                                  child: Text(letter),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
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
