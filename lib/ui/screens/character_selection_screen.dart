import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/character.dart';
import '../../services/local_storage_service.dart';

class CharacterSelectionScreen extends StatefulWidget {
  const CharacterSelectionScreen({super.key});

  @override
  State<CharacterSelectionScreen> createState() => _CharacterSelectionScreenState();
}

class _CharacterSelectionScreenState extends State<CharacterSelectionScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController(viewportFraction: 0.75);
  final TextEditingController _nameController = TextEditingController();
  CharacterClass _selectedClass = CharacterClass.mago;
  CharacterClass? _confirmedClass;
  bool _namePhase = false;

  bool _showConfirmation = false;
  late AnimationController _typingController;
  late Animation<int> _textAnimation;
  String _confirmationMessage = '';
  String _typedText = '';
  String? _errorMessage;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isFadingOut = false;

  final Map<CharacterClass, String> classImages = {
    CharacterClass.mago: 'assets/characters/mago.png',
    CharacterClass.guerrero: 'assets/characters/guerrero.png',
    CharacterClass.arquero: 'assets/characters/arquero.png',
    CharacterClass.nigromante: 'assets/characters/nigromante.png',
  };

  final Map<CharacterClass, String> classDescriptions = {
    CharacterClass.mago: 'Maestro de los hechizos y el conocimiento.',
    CharacterClass.guerrero: 'Valiente luchador de cuerpo a cuerpo.',
    CharacterClass.arquero: 'Ágil y preciso desde la distancia.',
    CharacterClass.nigromante: 'Maestro de las artes oscuras.',
  };

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _typingController.addListener(() {
      setState(() {
        final length = _textAnimation.value;
        _typedText = _confirmationMessage.substring(0, length);
      });
    });

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _fadeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
      }
    });
  }

  @override
  void dispose() {
    _typingController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedClass = CharacterClass.values[index];
    });
  }

  void _goToNamePhase() {
    setState(() {
      _confirmedClass = _selectedClass;
      _namePhase = true;
    });
  }

  void _goBackStep() {
    if (_namePhase) {
      setState(() {
        _namePhase = false;
        _confirmedClass = null;
      });
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _createCharacterConfirmed() async {
    final character = Character(
      name: _nameController.text.trim(),
      characterClass: _confirmedClass!,
      avatarAsset: classImages[_confirmedClass]!,
    );

    await LocalStorageService().saveCharacter(character);

    setState(() {
      _isFadingOut = true;
    });

    _fadeController.forward();
  }

  void _showTypingConfirmation() {
    setState(() {
      _showConfirmation = true;
      _confirmationMessage = '¿Estás seguro de que quieres llamarte "${_nameController.text.trim()}"?';
      _textAnimation = IntTween(begin: 0, end: _confirmationMessage.length).animate(_typingController);
      _typedText = '';
      _typingController.forward(from: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final classList = CharacterClass.values;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/backgrounds/character_selection_bg.png', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.7)),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 40,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 40,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: _goBackStep,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                FadeInDown(
                  child: Text(
                    _namePhase ? 'Elige tu Nombre' : 'Elige tu Clase',
                    style: const TextStyle(
                      fontSize: 28,
                      fontFamily: 'MedievalSharp',
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: classList.length,
                    itemBuilder: (context, index) {
                      final c = classList[index];
                      final isActive = _confirmedClass == c;

                      return Center(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: _confirmedClass == null || isActive ? 1.0 : 0.0,
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 300),
                            scale: isActive ? 1.15 : 1.0,
                            curve: Curves.easeInOut,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white,
                                  width: isActive ? 2.0 : 0.0,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.black38,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0, bottom: 8.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      classImages[c]!,
                                      fit: BoxFit.contain,
                                      height: MediaQuery.of(context).size.height * 0.45,
                                    ),
                                    if (!_namePhase && _confirmedClass == null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Column(
                                          children: [
                                            Text(
                                              c.name.toUpperCase(),
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'MedievalSharp',
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              classDescriptions[c]!,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontFamily: 'MedievalSharp',
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                if (!_namePhase)
                  FadeInUp(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                          onPressed: _selectedClass.index > 0
                              ? () => _pageController.previousPage(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeOut,
                                  )
                              : null,
                        ),
                        TextButton(
                          onPressed: _goToNamePhase,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            side: const BorderSide(color: Colors.white),
                          ),
                          child: const Text('Elegir', style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'MedievalSharp')),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                          onPressed: _selectedClass.index < classList.length - 1
                              ? () => _pageController.nextPage(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeOut,
                                  )
                              : null,
                        ),
                      ],
                    ),
                  )
                else
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        TextField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Ej: SirSecure',
                            hintStyle: const TextStyle(color: Colors.white38),
                            filled: true,
                            fillColor: Colors.black54,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            final name = _nameController.text.trim();
                            final isValid = RegExp(r'^[a-zA-Z0-9]{5,12}$').hasMatch(name);

                            if (!isValid) {
                              setState(() {
                                _errorMessage = 'El nombre debe tener entre 5 y 12 caracteres sin espacios ni acentos.';
                              });
                              Future.delayed(const Duration(seconds: 3), () {
                                if (mounted) setState(() => _errorMessage = null);
                              });
                              return;
                            }

                            _showTypingConfirmation();
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            side: const BorderSide(color: Colors.white),
                          ),
                          child: const Text(
                            'Comenzar Aventura',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'MedievalSharp'),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (_showConfirmation)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.95),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _typedText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'MedievalSharp',
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextButton(
                      onPressed: _createCharacterConfirmed,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        side: const BorderSide(color: Colors.white),
                      ),
                      child: const Text(
                        'Sí, comenzar',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'MedievalSharp'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => setState(() => _showConfirmation = false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        side: const BorderSide(color: Colors.white),
                      ),
                      child: const Text(
                        'No, cambiar',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'MedievalSharp'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_errorMessage != null)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: 1.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade700.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          if (_isFadingOut)
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(color: Colors.black),
            ),
        ],
      ),
    );
  }
}
