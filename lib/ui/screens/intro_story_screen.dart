import 'package:flutter/material.dart';
import 'character_selection_screen.dart';

class IntroStoryScreen extends StatefulWidget {
  const IntroStoryScreen({super.key});

  @override
  State<IntroStoryScreen> createState() => _IntroStoryScreenState();
}

class _IntroStoryScreenState extends State<IntroStoryScreen> with TickerProviderStateMixin {
  final List<String> _lines = [
    'Cuando el reino se ve amenazado por la ignorancia y el caos...',
    'Una figura emerge desde las sombras.',
    'Un héroe destinado a restaurar el conocimiento...',
    'Y proteger los secretos más valiosos.',
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
      duration: const Duration(milliseconds: 1000),
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
          Image.asset('assets/backgrounds/story_bg.png', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.6)),
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
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: const RoundedRectangleBorder(), // No border radius
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
