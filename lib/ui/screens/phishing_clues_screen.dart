import 'package:flutter/material.dart';

import '../../models/mission_step.dart';
import '../../models/player_status.dart';

class PhishingCluesScreen extends StatefulWidget {
  final PlayerStatus playerStatus;
  final MissionStep step;
  final void Function(bool won) onComplete;

  const PhishingCluesScreen({
    super.key,
    required this.playerStatus,
    required this.step,
    required this.onComplete,
  });

  @override
  State<PhishingCluesScreen> createState() => _PhishingCluesScreenState();
}

class _PhishingCluesScreenState extends State<PhishingCluesScreen>
    with SingleTickerProviderStateMixin {
  final Set<int> _selectedIndexes = {};

  bool _showResult = false;
  bool _won = false;

  String _resultTitle = '';
  String _resultDescription = '';

  int _score = 0;
  int _correctSelected = 0;
  int _wrongSelected = 0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  static const TextStyle _medievalStyle = TextStyle(
    fontFamily: 'MedievalSharp',
  );

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.25,
      end: 0.75,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleClue(int index) {
    if (_showResult) return;

    setState(() {
      if (_selectedIndexes.contains(index)) {
        _selectedIndexes.remove(index);
      } else {
        _selectedIndexes.add(index);
      }
    });
  }

  void _evaluateClues() {
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

    final totalCorrect = correctIndexes.length;
    final missedCorrect = totalCorrect - correctSelected;

    final calculatedScore = (correctSelected * 20) - (wrongSelected * 15);

    _correctSelected = correctSelected;
    _wrongSelected = wrongSelected;
    _score = calculatedScore < 0 ? 0 : calculatedScore;

    if (correctSelected == totalCorrect && wrongSelected == 0) {
      _resultTitle = 'Investigación perfecta';
      _resultDescription =
          'Detectaste todas las señales sospechosas del pergamino sin marcar elementos inocentes. El impostor ya no puede esconderse.';
      _won = true;
    } else if (correctSelected >= 4 && wrongSelected <= 1) {
      _resultTitle = 'Evidencia suficiente';
      _resultDescription =
          'Encontraste suficientes pistas para confirmar que el mensaje es peligroso. Aún podrías mejorar tu análisis, pero evitaste caer en la trampa.';
      _won = true;
    } else if (correctSelected >= 3 && wrongSelected <= 1) {
      _resultTitle = 'Sospecha parcial';
      _resultDescription =
          'Encontraste algunas señales, pero todavía faltaron $missedCorrect pistas importantes. El impostor podría seguir engañando a otros.';
      _won = false;
    } else {
      _resultTitle = 'Investigación débil';
      _resultDescription =
          'No encontraste suficientes señales de phishing. El pergamino sigue pareciendo confiable, que es exactamente lo que quiere el atacante.';
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
      _correctSelected = 0;
      _wrongSelected = 0;
    });
  }

  void _finish() {
    widget.onComplete(_won);
    Navigator.pop(context);
  }

  double get _investigationProgress {
    final totalCorrect = widget.step.correctOptionIndexes.length;

    if (totalCorrect == 0) {
      return 0;
    }

    final value = _correctSelected / totalCorrect;
    return value.clamp(0.0, 1.0);
  }

  String get _investigationStatus {
    if (!_showResult) {
      if (_selectedIndexes.isEmpty) {
        return 'Sin evidencia marcada';
      }

      return 'Analizando ${_selectedIndexes.length} pista(s)';
    }

    if (_won) {
      return 'Amenaza confirmada';
    }

    return 'Investigación incompleta';
  }

  Color get _statusColor {
    if (!_showResult) {
      return _selectedIndexes.isEmpty
          ? Colors.white70
          : const Color(0xFF7DD3FC);
    }

    return _won ? Colors.greenAccent : Colors.redAccent;
  }

  Color _getClueColor(int index) {
    if (!_showResult) {
      return _selectedIndexes.contains(index)
          ? const Color.fromARGB(255, 42, 58, 102)
          : const Color.fromARGB(220, 18, 18, 42);
    }

    final correctIndexes = widget.step.correctOptionIndexes.toSet();

    if (correctIndexes.contains(index) && _selectedIndexes.contains(index)) {
      return const Color.fromARGB(255, 28, 90, 55);
    }

    if (!correctIndexes.contains(index) && _selectedIndexes.contains(index)) {
      return const Color.fromARGB(255, 110, 32, 38);
    }

    if (correctIndexes.contains(index) && !_selectedIndexes.contains(index)) {
      return const Color.fromARGB(255, 110, 82, 28);
    }

    return const Color.fromARGB(215, 18, 18, 42);
  }

  Color _getClueBorderColor(int index) {
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

  IconData _getClueIcon(int index) {
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

    if (label.contains('remitente') || label.contains('dominio')) {
      return Icons.alternate_email_rounded;
    }

    if (label.contains('urgencia') || label.contains('urgente')) {
      return Icons.access_time_filled_rounded;
    }

    if (label.contains('enlace') || label.contains('link')) {
      return Icons.link_rounded;
    }

    if (label.contains('datos') || label.contains('contraseña')) {
      return Icons.password_rounded;
    }

    if (label.contains('amenaza') || label.contains('bloqueo')) {
      return Icons.report_problem_rounded;
    }

    if (label.contains('firma') || label.contains('saludo')) {
      return Icons.draw_rounded;
    }

    if (label.contains('ortografía') || label.contains('escritura')) {
      return Icons.spellcheck_rounded;
    }

    return Icons.search_rounded;
  }

  String _getClueSubtitle(int index) {
    final label = widget.step.options[index].toLowerCase();

    if (label.contains('remitente') || label.contains('dominio')) {
      return 'Verifica quién envía';
    }

    if (label.contains('urgencia') || label.contains('urgente')) {
      return 'Presión para actuar rápido';
    }

    if (label.contains('enlace') || label.contains('link')) {
      return 'Ruta posiblemente falsa';
    }

    if (label.contains('datos') || label.contains('contraseña')) {
      return 'Pide información sensible';
    }

    if (label.contains('amenaza') || label.contains('bloqueo')) {
      return 'Intenta causar miedo';
    }

    if (label.contains('firma') || label.contains('saludo')) {
      return 'Puede revelar falsedad';
    }

    if (label.contains('ortografía') || label.contains('escritura')) {
      return 'Señal de baja confianza';
    }

    return 'Elemento por revisar';
  }

  String _getHelpText() {
    if (!_showResult) {
      return 'Marca las señales que vuelven sospechoso este mensaje. No todo lo llamativo es una pista real, así que piensa antes de acusar al pergamino.';
    }

    return 'Verde: pistas correctas. Rojo: selección incorrecta. Amarillo: pista sospechosa que faltó.';
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
                    constraints: const BoxConstraints(maxWidth: 470),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 18),
                        _buildInvestigationBoard(),
                        const SizedBox(height: 16),
                        _buildMessageScroll(),
                        const SizedBox(height: 16),
                        _buildHelpBox(),
                        const SizedBox(height: 16),
                        _buildClueGrid(options),
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
                const Color.fromARGB(255, 14, 18, 32).withOpacity(0.78),
                Colors.black.withOpacity(0.84),
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
            'INVESTIGACIÓN DEL IMPOSTOR',
            style: _medievalStyle.copyWith(
              color: Colors.amberAccent,
              fontSize: 12,
              letterSpacing: 1.3,
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
          'Analiza el pergamino antes de entregar tu llave o seguir un enlace sospechoso.',
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

  Widget _buildInvestigationBoard() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final pulse = _pulseAnimation.value;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(230, 18, 24, 46),
                Color.fromARGB(235, 12, 12, 28),
                Color.fromARGB(225, 38, 26, 12),
              ],
            ),
            border: Border.all(
              color: _statusColor.withOpacity(0.42 + pulse * 0.28),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _statusColor.withOpacity(0.08 + pulse * 0.10),
                blurRadius: 22,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _buildSealIcon(),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _investigationStatus,
                          style: _medievalStyle.copyWith(
                            color: _statusColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _showResult
                              ? 'Puntaje de investigación: $_score'
                              : 'Pistas marcadas: ${_selectedIndexes.length}',
                          style: _medievalStyle.copyWith(
                            color: Colors.white70,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildInvestigationMeter(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMiniStat(
                      icon: Icons.check_circle_rounded,
                      label: 'Correctas',
                      value: '$_correctSelected',
                      color: Colors.greenAccent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMiniStat(
                      icon: Icons.cancel_rounded,
                      label: 'Erróneas',
                      value: '$_wrongSelected',
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMiniStat(
                      icon: Icons.visibility_rounded,
                      label: 'Marcadas',
                      value: '${_selectedIndexes.length}',
                      color: Colors.amberAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSealIcon() {
    return Container(
      width: 66,
      height: 66,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _statusColor.withOpacity(0.10),
        border: Border.all(
          color: _statusColor.withOpacity(0.65),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: _statusColor.withOpacity(0.18),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.mark_email_unread_rounded,
            color: _statusColor.withOpacity(0.9),
            size: 32,
          ),
          Positioned(
            right: 12,
            bottom: 11,
            child: Icon(
              _showResult
                  ? (_won
                      ? Icons.verified_rounded
                      : Icons.report_problem_rounded)
                  : Icons.search_rounded,
              color: Colors.amberAccent,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestigationMeter() {
    final value = _showResult ? _investigationProgress : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nivel de evidencia',
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
                        _statusColor.withOpacity(0.75),
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

  Widget _buildMiniStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.28),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: _medievalStyle.copyWith(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: _medievalStyle.copyWith(
              color: Colors.white60,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageScroll() {
    final fakeSender =
        widget.step.extraData['sender']?.toString() ?? 'Consejo Real';
    final fakeSubject =
        widget.step.extraData['subject']?.toString() ?? 'Aviso urgente';
    final fakeBody = widget.step.extraData['messageBody']?.toString() ??
        'Tu cuenta será suspendida. Entrega tu llave en el portal indicado para evitar perder el acceso.';

    return ClipPath(
      clipper: _ScrollClipper(),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE6C58C),
              Color(0xFFC99A57),
              Color(0xFF8B5E2B),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _ParchmentPainter(),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5B2E19).withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF5B2E19).withOpacity(0.35),
                      ),
                    ),
                    child: Text(
                      'Pergamino recibido',
                      style: _medievalStyle.copyWith(
                        color: const Color(0xFF4A2413),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildScrollRow(
                  label: 'Remitente',
                  value: fakeSender,
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 8),
                _buildScrollRow(
                  label: 'Asunto',
                  value: fakeSubject,
                  icon: Icons.mail_outline_rounded,
                ),
                const SizedBox(height: 14),
                Divider(
                  color: const Color(0xFF4A2413).withOpacity(0.45),
                  thickness: 1,
                ),
                const SizedBox(height: 10),
                Text(
                  fakeBody,
                  style: _medievalStyle.copyWith(
                    fontSize: 15,
                    color: const Color(0xFF3A1D10),
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: const Color(0xFF4A2413),
          size: 17,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: _medievalStyle.copyWith(
                color: const Color(0xFF3A1D10),
                fontSize: 13,
                height: 1.2,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: _medievalStyle.copyWith(
                    color: const Color(0xFF4A2413),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHelpBox() {
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
              _getHelpText(),
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

  Widget _buildClueGrid(List<String> options) {
    return GridView.builder(
      itemCount: options.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (context, index) {
        return _buildEvidenceSeal(index, options[index]);
      },
    );
  }

  Widget _buildEvidenceSeal(int index, String label) {
    final selected = _selectedIndexes.contains(index);
    final baseColor = _getClueColor(index);
    final borderColor = _getClueBorderColor(index);
    final icon = _getClueIcon(index);

    return GestureDetector(
      onTap: () => _toggleClue(index),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 160),
        scale: selected && !_showResult ? 1.04 : 1.0,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (selected)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: borderColor.withOpacity(0.28),
                        blurRadius: 22,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 190),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: borderColor.withOpacity(
                    selected || _showResult ? 0.95 : 0.42,
                  ),
                  width: selected || _showResult ? 1.8 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -12,
                    right: -12,
                    child: Icon(
                      Icons.fingerprint_rounded,
                      color: Colors.white.withOpacity(0.045),
                      size: 70,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: borderColor.withOpacity(0.12),
                          border: Border.all(
                            color: borderColor.withOpacity(0.55),
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: _showResult ? borderColor : Colors.white,
                          size: 27,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        label,
                        style: _medievalStyle.copyWith(
                          color: Colors.white,
                          fontSize: 12.8,
                          fontWeight: FontWeight.bold,
                          height: 1.08,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _getClueSubtitle(index),
                        style: _medievalStyle.copyWith(
                          color: Colors.white60,
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
            if (selected && !_showResult)
              Positioned(
                top: 10,
                right: 12,
                child: Icon(
                  Icons.push_pin_rounded,
                  color: Colors.amberAccent.withOpacity(0.95),
                  size: 22,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultBox() {
    final explanation = widget.step.extraData['explanation']?.toString();

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
                ? Icons.verified_user_rounded
                : Icons.report_gmailerrorred_rounded,
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
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amberAccent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.amberAccent.withOpacity(0.28),
              ),
            ),
            child: Text(
              'Pistas correctas: $_correctSelected / ${widget.step.correctOptionIndexes.length}\n'
              'Selecciones incorrectas: $_wrongSelected\n'
              'Puntaje de investigación: $_score',
              style: _medievalStyle.copyWith(
                fontSize: 12.2,
                color: Colors.amberAccent,
                height: 1.35,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (!_won && explanation != null) ...[
            const SizedBox(height: 12),
            Text(
              explanation,
              style: _medievalStyle.copyWith(
                fontSize: 12.2,
                color: const Color(0xFFCBD8F0),
                height: 1.25,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    if (!_showResult) {
      return ElevatedButton.icon(
        onPressed: _selectedIndexes.isEmpty ? null : _evaluateClues,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 24, 47, 72),
          disabledBackgroundColor: Colors.grey.shade800,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          side: const BorderSide(
            color: Color.fromARGB(255, 148, 147, 255),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: const Icon(
          Icons.manage_search_rounded,
          color: Colors.white,
        ),
        label: Text(
          'Evaluar pistas',
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
              icon: const Icon(
                Icons.refresh,
                color: Colors.white70,
              ),
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
              icon: const Icon(
                Icons.close,
                color: Colors.white,
              ),
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
      icon: const Icon(
        Icons.check_circle,
        color: Colors.white,
      ),
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

class _ScrollClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    return Path()
      ..moveTo(0, 18)
      ..quadraticBezierTo(w * 0.08, 0, w * 0.18, 16)
      ..quadraticBezierTo(w * 0.28, 30, w * 0.38, 12)
      ..quadraticBezierTo(w * 0.48, -4, w * 0.58, 14)
      ..quadraticBezierTo(w * 0.72, 32, w * 0.86, 12)
      ..quadraticBezierTo(w * 0.96, -2, w, 18)
      ..lineTo(w, h - 18)
      ..quadraticBezierTo(w * 0.94, h, w * 0.82, h - 14)
      ..quadraticBezierTo(w * 0.68, h - 30, w * 0.52, h - 12)
      ..quadraticBezierTo(w * 0.38, h + 4, w * 0.24, h - 14)
      ..quadraticBezierTo(w * 0.10, h - 30, 0, h - 18)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class _ParchmentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stainPaint = Paint()
      ..color = const Color(0xFF5B2E19).withOpacity(0.08)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.18, size.height * 0.22),
      26,
      stainPaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.68),
      34,
      stainPaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.52, size.height * 0.48),
      18,
      stainPaint,
    );

    final linePaint = Paint()
      ..color = const Color(0xFF4A2413).withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (double y = 28; y < size.height; y += 26) {
      canvas.drawLine(
        Offset(12, y),
        Offset(size.width - 12, y),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}