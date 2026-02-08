import 'package:flutter/material.dart';
import '../../models/player_status.dart';
import '../../models/enemy.dart';
import '../../models/memory_pair.dart';
import '../../models/memory_card.dart';
import '../widgets/combat_engine.dart';

class MemoryGameScreen extends StatefulWidget {
  final PlayerStatus playerStatus;
  final Enemy enemy;
  final List<MemoryPair> memoryPairs;

  const MemoryGameScreen({
    super.key,
    required this.playerStatus,
    required this.enemy,
    required this.memoryPairs,
  });

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> with TickerProviderStateMixin {
  List<MemoryCard> _cards = [];
  final List<int> _selectedIndexes = [];
  bool _showAllInitially = true;
  bool _showIntro = true;
  bool _showFinalPopup = false;
  bool _victory = false;

  late AnimationController _introController;
  late Animation<double> _introScale;
  late Animation<double> _introFade;

  @override
  void initState() {
    super.initState();
    _prepareCards();
    _showCardsTemporarily();

    _introController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _introScale = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _introController, curve: Curves.easeOutBack));
    _introFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _introController, curve: Curves.easeIn));

    _introController.forward();
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _showIntro = false);
    });
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  void _prepareCards() {
    final pairs = widget.memoryPairs.expand((pair) => [
      MemoryCard(text: pair.concept, pairId: pair.concept),
      MemoryCard(text: pair.definition, pairId: pair.concept),
    ]).toList();
    pairs.shuffle();
    _cards = pairs;
  }

  void _showCardsTemporarily() async {
    setState(() => _showAllInitially = true);
    await Future.delayed(const Duration(seconds: 3));
    setState(() => _showAllInitially = false);
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
              const Text('¿Estás seguro de abandonar el combate?',
                  style: TextStyle(fontSize: 18, fontFamily: 'MedievalSharp', color: Colors.white),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              const Text('Perderás tu progreso en esta batalla.',
                  style: TextStyle(fontSize: 14, fontFamily: 'MedievalSharp', color: Colors.white70),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white)),
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancelar', style: TextStyle(fontFamily: 'MedievalSharp', color: Colors.white)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 90, 20, 20)),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Sí, abandonar', style: TextStyle(fontFamily: 'MedievalSharp', color: Colors.white)),
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

  void _triggerFinalPopup(bool didWin) {
    setState(() {
      _victory = didWin;
      _showFinalPopup = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
    });
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
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), offset: const Offset(4, 4), blurRadius: 10)],
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

  void _handleTap(int index, Function(int playerDamage, int enemyDamage) onDamage) {
    if (_selectedIndexes.contains(index) || _showAllInitially || _showFinalPopup) return;

    setState(() => _selectedIndexes.add(index));

    if (_selectedIndexes.length == 2) {
      final first = _cards[_selectedIndexes[0]];
      final second = _cards[_selectedIndexes[1]];

      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          if (first.pairId == second.pairId) {
            onDamage(0, widget.playerStatus.playerDamage);
            _cards.removeAt(_selectedIndexes[1]);
            _cards.removeAt(_selectedIndexes[0]);

            if (_cards.isEmpty) {
              onDamage(0, widget.enemy.health);
              _triggerFinalPopup(true);
            }
          } else {
            onDamage(widget.enemy.enemyDamage, 0);
          }
          _selectedIndexes.clear();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _confirmExit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Juego de Memoria', style: TextStyle(color: Colors.white, fontFamily: 'MedievalSharp')),
          backgroundColor: const Color.fromARGB(255, 2, 8, 15),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final confirm = await _confirmExit();
              if (confirm && mounted) Navigator.pop(context);
            },
          ),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/backgrounds/battle_bg.png', fit: BoxFit.cover),
            Container(color: Colors.black.withOpacity(0.6)),
            if (_showIntro) _buildIntroOverlay(),
            if (!_showIntro && !_showFinalPopup)
              CombatEngine(
                enemy: widget.enemy,
                playerStatus: widget.playerStatus,
                onVictory: () => _triggerFinalPopup(true),
                onDefeat: () => _triggerFinalPopup(false),
                child: (dealDamage, takeDamage) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final gridWidth = constraints.maxWidth > 400 ? 400.0 : constraints.maxWidth;
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: SizedBox(
                            width: gridWidth,
                            child: GridView.builder(
                              shrinkWrap: true,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 2.0,
                              ),
                              itemCount: _cards.length,
                              itemBuilder: (context, index) {
                                final isRevealed = _showAllInitially || _selectedIndexes.contains(index);
                                final card = _cards[index];
                                return GestureDetector(
                                  onTap: () => _handleTap(index, (pd, ed) {
                                    if (pd > 0) takeDamage(pd);
                                    if (ed > 0) dealDamage(ed);
                                  }),
                                  child: Card(
                                    elevation: 4,
                                    color: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(color: Colors.white),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          isRevealed ? card.text : '?',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                            fontFamily: 'MedievalSharp',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
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
