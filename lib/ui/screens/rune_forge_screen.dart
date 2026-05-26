import 'package:flutter/material.dart';
import '../../models/mission_step.dart';
import '../../models/player_status.dart';

class RuneForgeScreen extends StatefulWidget {
  final PlayerStatus playerStatus;
  final MissionStep step;
  final void Function(bool won) onComplete;

  const RuneForgeScreen({
    super.key,
    required this.playerStatus,
    required this.step,
    required this.onComplete,
  });

  @override
  State<RuneForgeScreen> createState() => _RuneForgeScreenState();
}

class _RuneForgeScreenState extends State<RuneForgeScreen>
    with SingleTickerProviderStateMixin {
  final Set<int> _selectedIndexes = {};

  bool _showResult = false;
  bool _won = false;

  String _resultTitle = '';
  String _resultDescription = '';
  int _score = 0;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  static const TextStyle _medievalStyle = TextStyle(
    fontFamily: 'MedievalSharp',
  );

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 0.25,
      end: 0.75,
    ).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _toggleRune(int index) {
    if (_showResult) return;

    setState(() {
      if (_selectedIndexes.contains(index)) {
        _selectedIndexes.remove(index);
      } else {
        _selectedIndexes.add(index);
      }
    });
  }

  void _evaluateForge() {
    final correctIndexes = widget.step.correctOptionIndexes.toSet();

    int correctSelected = 0;
    int wrongSelected = 0;

    for (final index in _selectedIndexes) {
      if (correctIndexes.contains(index)) {
        correctSelected++;
      } else {
        wrongSelected++;
      }
    }

    final missedCorrect = correctIndexes.length - correctSelected;
    final rawScore = correctSelected - wrongSelected;

    _score = rawScore < 0 ? 0 : rawScore;

    if (correctSelected == correctIndexes.length && wrongSelected == 0) {
      _resultTitle = 'Llave legendaria';
      _resultDescription =
          'La llave despierta por completo. Elegiste todas las runas seguras y evitaste las runas peligrosas.';
      _won = true;
    } else if (_score >= 4 && wrongSelected == 0) {
      _resultTitle = 'Llave fuerte';
      _resultDescription =
          'La llave queda firme y resistente. Seleccionaste la mayoría de elementos correctos para una contraseña segura.';
      _won = true;
    } else if (_score >= 3 && wrongSelected <= 1) {
      _resultTitle = 'Llave inestable';
      _resultDescription =
          'La llave funciona, pero todavía vibra con debilidades. Te faltaron $missedCorrect runas seguras o seleccionaste una opción riesgosa.';
      _won = false;
    } else {
      _resultTitle = 'Llave débil';
      _resultDescription =
          'La llave se agrieta sobre el yunque. Una contraseña débil puede ser adivinada, reutilizada o comprometida con facilidad.';
      _won = false;
    }

    setState(() {
      _showResult = true;
    });
  }

  void _retry() {
    setState(() {
      _selectedIndexes.clear();
      _showResult = false;
      _won = false;
      _resultTitle = '';
      _resultDescription = '';
      _score = 0;
    });
  }

  void _finish() {
    widget.onComplete(_won);
    Navigator.pop(context);
  }

  int get _correctSelectedCount {
    final correctIndexes = widget.step.correctOptionIndexes.toSet();

    int count = 0;

    for (final index in _selectedIndexes) {
      if (correctIndexes.contains(index)) {
        count++;
      }
    }

    return count;
  }

  int get _wrongSelectedCount {
    final correctIndexes = widget.step.correctOptionIndexes.toSet();

    int count = 0;

    for (final index in _selectedIndexes) {
      if (!correctIndexes.contains(index)) {
        count++;
      }
    }

    return count;
  }

  double get _forgeStrength {
    final totalCorrect = widget.step.correctOptionIndexes.length;

    if (totalCorrect == 0) {
      return 0;
    }

    final value = _correctSelectedCount / totalCorrect;
    return value.clamp(0.0, 1.0);
  }

  String get _forgeStateLabel {
    if (_showResult) {
      return _resultTitle;
    }

    if (_selectedIndexes.isEmpty) {
      return 'Llave sin forjar';
    }

    if (_wrongSelectedCount > 0) {
      return 'Energía inestable';
    }

    if (_forgeStrength >= 0.9) {
      return 'Forja casi completa';
    }

    if (_forgeStrength >= 0.55) {
      return 'Llave en formación';
    }

    return 'Primeras runas activas';
  }

  Color get _forgeStateColor {
    if (_showResult) {
      return _won ? Colors.greenAccent : Colors.redAccent;
    }

    if (_wrongSelectedCount > 0) {
      return Colors.redAccent;
    }

    if (_forgeStrength >= 0.9) {
      return Colors.amberAccent;
    }

    if (_forgeStrength >= 0.55) {
      return const Color(0xFF7DD3FC);
    }

    return Colors.white70;
  }

  Color _getRuneBaseColor(int index) {
    if (!_showResult) {
      if (_selectedIndexes.contains(index)) {
        return const Color.fromARGB(255, 37, 59, 110);
      }

      return const Color.fromARGB(210, 18, 18, 42);
    }

    final correctIndexes = widget.step.correctOptionIndexes.toSet();

    if (correctIndexes.contains(index) && _selectedIndexes.contains(index)) {
      return const Color.fromARGB(255, 25, 88, 51);
    }

    if (!correctIndexes.contains(index) && _selectedIndexes.contains(index)) {
      return const Color.fromARGB(255, 105, 30, 34);
    }

    if (correctIndexes.contains(index) && !_selectedIndexes.contains(index)) {
      return const Color.fromARGB(255, 105, 85, 25);
    }

    return const Color.fromARGB(200, 18, 18, 42);
  }

  Color _getRuneBorderColor(int index) {
    if (!_showResult) {
      return _selectedIndexes.contains(index)
          ? Colors.amberAccent
          : Colors.white24;
    }

    final correctIndexes = widget.step.correctOptionIndexes.toSet();

    if (correctIndexes.contains(index) && _selectedIndexes.contains(index)) {
      return Colors.greenAccent;
    }

    if (!correctIndexes.contains(index) && _selectedIndexes.contains(index)) {
      return Colors.redAccent;
    }

    if (correctIndexes.contains(index) && !_selectedIndexes.contains(index)) {
      return Colors.amberAccent;
    }

    return Colors.white24;
  }

  Color _getRuneGemColor(int index) {
    final label = widget.step.options[index].toLowerCase();

    if (_showResult) {
      final correctIndexes = widget.step.correctOptionIndexes.toSet();

      if (correctIndexes.contains(index) && _selectedIndexes.contains(index)) {
        return const Color(0xFF1F8A54);
      }

      if (!correctIndexes.contains(index) && _selectedIndexes.contains(index)) {
        return const Color(0xFF8A2631);
      }

      if (correctIndexes.contains(index) && !_selectedIndexes.contains(index)) {
        return const Color(0xFF9A7A22);
      }
    }

    if (label.contains('longitud')) {
      return const Color(0xFF2563EB);
    }

    if (label.contains('mezcla')) {
      return const Color(0xFF7C3AED);
    }

    if (label.contains('num')) {
      return const Color(0xFF0891B2);
    }

    if (label.contains('especial')) {
      return const Color(0xFFD97706);
    }

    if (label.contains('secreta') || label.contains('secreto')) {
      return const Color(0xFF16A34A);
    }

    if (label.contains('repetida')) {
      return const Color(0xFFB91C1C);
    }

    if (label.contains('familiar')) {
      return const Color(0xFFBE185D);
    }

    return const Color(0xFF475569);
  }

  IconData _getRuneIcon(int index) {
    final label = widget.step.options[index].toLowerCase();

    if (_showResult) {
      final correctIndexes = widget.step.correctOptionIndexes.toSet();

      if (correctIndexes.contains(index) && _selectedIndexes.contains(index)) {
        return Icons.check_circle_rounded;
      }

      if (!correctIndexes.contains(index) && _selectedIndexes.contains(index)) {
        return Icons.cancel_rounded;
      }

      if (correctIndexes.contains(index) && !_selectedIndexes.contains(index)) {
        return Icons.warning_amber_rounded;
      }
    }

    if (label.contains('longitud')) {
      return Icons.straighten_rounded;
    }

    if (label.contains('mezcla')) {
      return Icons.all_inclusive_rounded;
    }

    if (label.contains('num')) {
      return Icons.pin_rounded;
    }

    if (label.contains('especial')) {
      return Icons.auto_awesome_rounded;
    }

    if (label.contains('secreta') || label.contains('secreto')) {
      return Icons.lock_rounded;
    }

    if (label.contains('repetida')) {
      return Icons.copy_rounded;
    }

    if (label.contains('familiar')) {
      return Icons.person_search_rounded;
    }

    return Icons.blur_on_rounded;
  }

  String _getRuneGlyph(int index) {
    final label = widget.step.options[index].toLowerCase();

    if (label.contains('longitud')) {
      return 'ᛚ';
    }

    if (label.contains('mezcla')) {
      return 'ᛗ';
    }

    if (label.contains('num')) {
      return 'ᚾ';
    }

    if (label.contains('especial')) {
      return 'ᛟ';
    }

    if (label.contains('secreta') || label.contains('secreto')) {
      return 'ᛉ';
    }

    if (label.contains('repetida')) {
      return 'ᚱ';
    }

    if (label.contains('familiar')) {
      return 'ᚠ';
    }

    return 'ᚷ';
  }

  String _getRuneSubtitle(int index) {
    final label = widget.step.options[index].toLowerCase();

    if (label.contains('longitud')) {
      return 'Más difícil de adivinar';
    }

    if (label.contains('mezcla')) {
      return 'Combina tipos de caracteres';
    }

    if (label.contains('num')) {
      return 'Agrega variedad';
    }

    if (label.contains('especial')) {
      return 'Refuerza la complejidad';
    }

    if (label.contains('secreta') || label.contains('secreto')) {
      return 'No debe compartirse';
    }

    if (label.contains('repetida')) {
      return 'Riesgo por reutilización';
    }

    if (label.contains('familiar')) {
      return 'Datos fáciles de descubrir';
    }

    return 'Runa desconocida';
  }

  String _getRuneHelpText() {
    if (!_showResult) {
      return 'Selecciona solo las runas que fortalecen una contraseña segura. Algunas parecen útiles, pero esconden debilidades.';
    }

    return 'Verde: runas correctas elegidas. Rojo: runas peligrosas elegidas. Amarillo: runas correctas que faltaron.';
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.step.options;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            _buildBackground(),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 22,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 18),
                        _buildForgeAltar(),
                        const SizedBox(height: 16),
                        _buildInstructionBox(),
                        const SizedBox(height: 18),
                        _buildRuneGrid(options),
                        const SizedBox(height: 18),
                        if (_showResult) _buildResultBox(),
                        const SizedBox(height: 18),
                        _buildBottomButtons(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/backgrounds/story_bg.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Container(
              color: const Color.fromARGB(255, 10, 10, 24),
            );
          },
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.55),
                const Color.fromARGB(255, 18, 10, 10).withOpacity(0.78),
                Colors.black.withOpacity(0.82),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.42),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.amberAccent.withOpacity(0.55),
            ),
          ),
          child: Text(
            'FORJA RÚNICA',
            style: _medievalStyle.copyWith(
              color: Colors.amberAccent,
              fontSize: 12,
              letterSpacing: 1.6,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.step.title,
          style: _medievalStyle.copyWith(
            fontSize: 25,
            color: Colors.amberAccent,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.amberAccent.withOpacity(0.35),
                blurRadius: 12,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Elige las runas que convertirán tu contraseña en una llave resistente.',
          style: _medievalStyle.copyWith(
            fontSize: 14,
            color: Colors.white70,
            height: 1.25,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForgeAltar() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        final glowValue = _glowAnimation.value;

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(235, 24, 20, 42),
                Color.fromARGB(235, 12, 12, 28),
                Color.fromARGB(235, 38, 20, 12),
              ],
            ),
            border: Border.all(
              color: _forgeStateColor.withOpacity(0.45 + glowValue * 0.35),
              width: 1.6,
            ),
            boxShadow: [
              BoxShadow(
                color: _forgeStateColor.withOpacity(0.12 + glowValue * 0.16),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              _buildAnvilAndKey(glowValue),
              const SizedBox(height: 14),
              Text(
                _forgeStateLabel,
                style: _medievalStyle.copyWith(
                  color: _forgeStateColor,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              _buildStrengthBar(),
              const SizedBox(height: 12),
              _buildRuneSlots(),
              const SizedBox(height: 10),
              Text(
                _showResult
                    ? 'Puntuación de forja: $_score / ${widget.step.correctOptionIndexes.length}'
                    : 'Runas seleccionadas: ${_selectedIndexes.length}',
                style: _medievalStyle.copyWith(
                  color: Colors.white70,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnvilAndKey(double glowValue) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 150,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _forgeStateColor.withOpacity(0.08 + glowValue * 0.12),
          ),
        ),
        Positioned(
          bottom: 6,
          child: Icon(
            Icons.foundation_rounded,
            size: 54,
            color: Colors.white.withOpacity(0.35),
          ),
        ),
        Transform.rotate(
          angle: -0.35,
          child: Icon(
            Icons.key_rounded,
            size: 86,
            color: _showResult
                ? (_won ? Colors.amberAccent : Colors.redAccent)
                : Colors.amberAccent.withOpacity(0.45 + _forgeStrength * 0.5),
            shadows: [
              Shadow(
                color: _forgeStateColor.withOpacity(0.55),
                blurRadius: 18,
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          right: 116,
          child: Icon(
            Icons.local_fire_department_rounded,
            size: 28,
            color: Colors.deepOrangeAccent.withOpacity(0.75),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 74,
          child: Icon(
            Icons.auto_awesome_rounded,
            size: 22,
            color: Colors.amberAccent.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildStrengthBar() {
    final totalCorrect = widget.step.correctOptionIndexes.length;

    final value = totalCorrect == 0
        ? 0.0
        : _showResult
            ? (_score / totalCorrect).clamp(0.0, 1.0)
            : _forgeStrength;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fuerza de la llave',
          style: _medievalStyle.copyWith(
            color: Colors.white60,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Container(
                height: 10,
                color: Colors.white.withOpacity(0.12),
              ),
              FractionallySizedBox(
                widthFactor: value,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _forgeStateColor.withOpacity(0.7),
                        Colors.amberAccent.withOpacity(0.95),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRuneSlots() {
    final total = widget.step.correctOptionIndexes.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        final filled = index < _correctSelectedCount;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled
                ? Colors.amberAccent.withOpacity(0.20)
                : Colors.white.withOpacity(0.06),
            border: Border.all(
              color: filled ? Colors.amberAccent : Colors.white24,
              width: 1.2,
            ),
            boxShadow: filled
                ? [
                    BoxShadow(
                      color: Colors.amberAccent.withOpacity(0.22),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: Icon(
            filled ? Icons.auto_awesome_rounded : Icons.circle_outlined,
            size: 15,
            color: filled ? Colors.amberAccent : Colors.white24,
          ),
        );
      }),
    );
  }

  Widget _buildInstructionBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color.fromARGB(185, 20, 25, 50),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color.fromARGB(255, 120, 150, 210).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFCBD8F0),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _getRuneHelpText(),
              style: _medievalStyle.copyWith(
                fontSize: 13.5,
                color: const Color(0xFFCBD8F0),
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuneGrid(List<String> options) {
    return GridView.builder(
      itemCount: options.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.88,
      ),
      itemBuilder: (context, index) {
        return _buildRuneGem(index, options[index]);
      },
    );
  }

  Widget _buildRuneGem(int index, String label) {
    final selected = _selectedIndexes.contains(index);
    final borderColor = _getRuneBorderColor(index);
    final gemColor = _getRuneGemColor(index);
    final glyph = _getRuneGlyph(index);

    final correctIndexes = widget.step.correctOptionIndexes.toSet();

    final bool correctWhenResult =
        _showResult && correctIndexes.contains(index) && selected;

    final bool wrongWhenResult =
        _showResult && !correctIndexes.contains(index) && selected;

    final bool missedWhenResult =
        _showResult && correctIndexes.contains(index) && !selected;

    return GestureDetector(
      onTap: () => _toggleRune(index),
      child: AnimatedScale(
        scale: selected && !_showResult ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (selected || correctWhenResult)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: borderColor.withOpacity(0.38),
                        blurRadius: 24,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ClipPath(
              clipper: _RuneGemClipper(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      gemColor.withOpacity(0.95),
                      gemColor.withOpacity(0.58),
                      Colors.black.withOpacity(0.78),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _RuneCarvingPainter(
                          color: Colors.white.withOpacity(0.10),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      left: 8,
                      right: 8,
                      child: Container(
                        height: 24,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.28),
                              Colors.white.withOpacity(0.03),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          glyph,
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: _showResult ? borderColor : Colors.white,
                            shadows: [
                              Shadow(
                                color: borderColor.withOpacity(0.60),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          label,
                          style: _medievalStyle.copyWith(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            height: 1.05,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _getRuneSubtitle(index),
                          style: _medievalStyle.copyWith(
                            color: Colors.white70,
                            fontSize: 10.5,
                            height: 1.1,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: _RuneGemBorderPainter(
                  color: borderColor.withOpacity(
                    selected || _showResult ? 0.95 : 0.40,
                  ),
                  strokeWidth: selected || _showResult ? 2.2 : 1.2,
                ),
              ),
            ),
            if (selected && !_showResult)
              Positioned(
                top: 14,
                right: 18,
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.amberAccent.withOpacity(0.95),
                  size: 22,
                ),
              ),
            if (correctWhenResult)
              Positioned(
                top: 14,
                right: 18,
                child: Icon(
                  Icons.check_circle_rounded,
                  color: Colors.greenAccent.withOpacity(0.95),
                  size: 23,
                ),
              ),
            if (wrongWhenResult)
              Positioned(
                top: 14,
                right: 18,
                child: Icon(
                  Icons.cancel_rounded,
                  color: Colors.redAccent.withOpacity(0.95),
                  size: 23,
                ),
              ),
            if (missedWhenResult)
              Positioned(
                top: 14,
                right: 18,
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.amberAccent.withOpacity(0.95),
                  size: 23,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultBox() {
    final wrongOptionsExplanation =
        widget.step.extraData['wrongOptionsExplanation']?.toString();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _won
              ? Colors.greenAccent.withOpacity(0.65)
              : Colors.redAccent.withOpacity(0.65),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (_won ? Colors.greenAccent : Colors.redAccent)
                .withOpacity(0.12),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            _won
                ? Icons.workspace_premium_rounded
                : Icons.warning_amber_rounded,
            color: _won ? Colors.greenAccent : Colors.redAccent,
            size: 42,
          ),
          const SizedBox(height: 10),
          Text(
            _resultTitle,
            style: _medievalStyle.copyWith(
              fontSize: 20,
              color: _won ? Colors.greenAccent : Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            _resultDescription,
            style: _medievalStyle.copyWith(
              fontSize: 14,
              color: Colors.white70,
              height: 1.25,
            ),
            textAlign: TextAlign.center,
          ),
          if (!_won && wrongOptionsExplanation != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amberAccent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amberAccent.withOpacity(0.35),
                ),
              ),
              child: Text(
                wrongOptionsExplanation,
                style: _medievalStyle.copyWith(
                  fontSize: 12.2,
                  color: Colors.amberAccent,
                  height: 1.25,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    if (!_showResult) {
      return ElevatedButton.icon(
        onPressed: _selectedIndexes.isEmpty ? null : _evaluateForge,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 58, 32, 15),
          disabledBackgroundColor: Colors.grey.shade800,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          side: const BorderSide(
            color: Colors.amberAccent,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: const Icon(
          Icons.local_fire_department_rounded,
          color: Colors.white,
        ),
        label: Text(
          'Forjar llave',
          style: _medievalStyle.copyWith(
            fontSize: 15,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (!_won) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _retry,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
                side: const BorderSide(color: Colors.white38),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.refresh, color: Colors.white70),
              label: Text(
                'Reintentar',
                style: _medievalStyle.copyWith(
                  color: Colors.white70,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _finish,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 90, 25, 25),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.close, color: Colors.white),
              label: Text(
                'Fallé',
                style: _medievalStyle.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return ElevatedButton.icon(
      onPressed: _finish,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 25, 85, 50),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        side: const BorderSide(
          color: Colors.greenAccent,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      icon: const Icon(Icons.check_circle, color: Colors.white),
      label: Text(
        'Continuar misión',
        style: _medievalStyle.copyWith(
          fontSize: 15,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

Path _runeGemPath(Size size) {
  final w = size.width;
  final h = size.height;

  return Path()
    ..moveTo(w * 0.50, 0)
    ..lineTo(w * 0.88, h * 0.18)
    ..lineTo(w * 0.98, h * 0.52)
    ..lineTo(w * 0.72, h * 0.94)
    ..lineTo(w * 0.28, h * 0.94)
    ..lineTo(w * 0.02, h * 0.52)
    ..lineTo(w * 0.12, h * 0.18)
    ..close();
}

class _RuneGemClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return _runeGemPath(size);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class _RuneGemBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _RuneGemBorderPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _runeGemPath(size);

    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawPath(path, borderPaint);

    final innerPaint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final innerPath = Path()
      ..moveTo(size.width * 0.50, size.height * 0.08)
      ..lineTo(size.width * 0.78, size.height * 0.22)
      ..lineTo(size.width * 0.86, size.height * 0.50)
      ..lineTo(size.width * 0.66, size.height * 0.82)
      ..lineTo(size.width * 0.34, size.height * 0.82)
      ..lineTo(size.width * 0.14, size.height * 0.50)
      ..lineTo(size.width * 0.22, size.height * 0.22)
      ..close();

    canvas.drawPath(innerPath, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _RuneGemBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class _RuneCarvingPainter extends CustomPainter {
  final Color color;

  _RuneCarvingPainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final centerX = size.width * 0.5;

    canvas.drawLine(
      Offset(centerX, size.height * 0.12),
      Offset(centerX, size.height * 0.88),
      paint,
    );

    canvas.drawLine(
      Offset(size.width * 0.24, size.height * 0.30),
      Offset(size.width * 0.76, size.height * 0.30),
      paint,
    );

    canvas.drawLine(
      Offset(size.width * 0.30, size.height * 0.68),
      Offset(size.width * 0.70, size.height * 0.68),
      paint,
    );

    canvas.drawLine(
      Offset(size.width * 0.20, size.height * 0.50),
      Offset(size.width * 0.50, size.height * 0.20),
      paint,
    );

    canvas.drawLine(
      Offset(size.width * 0.80, size.height * 0.50),
      Offset(size.width * 0.50, size.height * 0.20),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RuneCarvingPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}