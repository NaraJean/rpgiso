import 'package:flutter/material.dart';
import 'character_selection_screen.dart';

class PreCharacterSelectionScreen extends StatefulWidget {
  const PreCharacterSelectionScreen({super.key});

  @override
  State<PreCharacterSelectionScreen> createState() => _PreCharacterSelectionScreenState();
}

class _PreCharacterSelectionScreenState extends State<PreCharacterSelectionScreen> with TickerProviderStateMixin {
  final List<String> _lines = [
    'Bienvenido, aventurero.',
    'El destino te ha traído a este lugar...',
    'Ahora debes elegir tu camino.',
    'Selecciona el personaje que representa tu esencia.',
  ];

  int _currentLine = 0;
  String _visibleText = '';
  bool _showNextButton = false;

  late AnimationController _textController;
  late Animation<int> _textAnimation;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _startTyping();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_fadeController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const CharacterSelectionScreen()),
          );
        }
      });
  }

  void _startTyping() {
    final fullLine = _lines[_currentLine];
    _textController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: fullLine.length * 40),
    );
    _textAnimation = StepTween(begin: 0, end: fullLine.length).animate(_textController)
      ..addListener(() {
        setState(() {
          _visibleText = fullLine.substring(0, _textAnimation.value);
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(const Duration(milliseconds: 800), () {
            if (_currentLine < _lines.length - 1) {
              _currentLine++;
              _textController.dispose();
              _startTyping();
            } else {
              setState(() => _showNextButton = true);
            }
          });
        }
      });

    _textController.forward();
  }

  @override
  void dispose() {
    _textController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _goToCharacterSelection() {
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.black),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _visibleText,
                  style: const TextStyle(
                    fontSize: 22,
                    height: 1.6,
                    color: Colors.white,
                    fontFamily: 'MedievalSharp',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                if (_showNextButton)
                  ElevatedButton(
                    onPressed: _goToCharacterSelection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: const RoundedRectangleBorder(),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'MedievalSharp',
                        fontWeight: FontWeight.bold,
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Continuar'),
                  ),
              ],
            ),
          ),
          IgnorePointer(
            ignoring: !_fadeController.isAnimating,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
