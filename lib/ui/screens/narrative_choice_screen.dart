import 'package:flutter/material.dart';

import '../../models/mission_step.dart';
import '../../models/player_status.dart';

class NarrativeChoiceScreen extends StatefulWidget {
  final PlayerStatus playerStatus;
  final MissionStep step;
  final void Function(bool won) onComplete;

  const NarrativeChoiceScreen({
    super.key,
    required this.playerStatus,
    required this.step,
    required this.onComplete,
  });

  @override
  State<NarrativeChoiceScreen> createState() => _NarrativeChoiceScreenState();
}

class _NarrativeChoiceScreenState extends State<NarrativeChoiceScreen> {
  int? _selectedIndex;
  bool _answered = false;
  bool _isCorrect = false;

  static const TextStyle _medievalStyle = TextStyle(
    fontFamily: 'MedievalSharp',
  );

  List<String> get _options => widget.step.options;

  int get _correctIndex {
    if (widget.step.correctOptionIndexes.isEmpty) return 0;
    return widget.step.correctOptionIndexes.first;
  }

  String get _questionText {
    final value = widget.step.extraData?['question']?.toString();

    if (value != null && value.trim().isNotEmpty) {
      return value;
    }

    return widget.step.contextText;
  }

  String get _npcName {
    final value = widget.step.extraData?['npcName']?.toString();

    if (value != null && value.trim().isNotEmpty) {
      return value;
    }

    return widget.step.preStepDialogue?.npcName ?? 'Guardián';
  }

  String get _correctFeedback {
    final value = widget.step.extraData?['correctFeedback']?.toString();

    if (value != null && value.trim().isNotEmpty) {
      return value;
    }

    return 'Correcto. Esa decisión protege mejor el Reino de los Datos.';
  }

  String get _wrongFeedback {
    final value = widget.step.extraData?['wrongFeedback']?.toString();

    if (value != null && value.trim().isNotEmpty) {
      return value;
    }

    return 'No es la mejor decisión. El riesgo sigue presente, pero aprendiste antes de que el reino explotara. Algo es algo.';
  }

  String get _technicalNote {
    final value = widget.step.extraData?['technicalNote']?.toString();

    if (value != null && value.trim().isNotEmpty) {
      return value;
    }

    return '';
  }

  bool get _mustBeCorrect {
    final value = widget.step.extraData?['mustBeCorrect'];

    if (value is bool) return value;

    // Por defecto los microeventos no bloquean la misión.
    // Enseñan, corrigen y dejan continuar.
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (_options.isEmpty) {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 12, 14, 30),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _buildTextBox(
                'Este microevento no tiene opciones configuradas.\n\n'
                'Revisa el campo options en MissionStep.',
              ),
            ),
          ),
        ),
      );
    }

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
                  horizontal: 22,
                  vertical: 24,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 18),
                        _buildQuestionCard(),
                        const SizedBox(height: 18),
                        _buildOptions(),
                        const SizedBox(height: 22),
                        if (!_answered) _buildConfirmButton(),
                        if (_answered) _buildFeedbackCard(),
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
              color: const Color.fromARGB(255, 12, 14, 30),
            );
          },
        ),
        Container(
          color: Colors.black.withOpacity(0.70),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Icon(
          Icons.psychology_alt_rounded,
          color: Colors.amberAccent,
          size: 58,
        ),
        const SizedBox(height: 10),
        Text(
          widget.step.title,
          style: _medievalStyle.copyWith(
            color: Colors.amberAccent,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Microevento narrativo',
          style: _medievalStyle.copyWith(
            color: Colors.white70,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.44),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.amberAccent.withOpacity(0.55),
          width: 1.3,
        ),
      ),
      child: Column(
        children: [
          Text(
            _npcName,
            style: _medievalStyle.copyWith(
              color: Colors.amberAccent,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            _questionText,
            style: _medievalStyle.copyWith(
              color: const Color(0xFFCBD8F0),
              fontSize: 15,
              height: 1.25,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOptions() {
    return Column(
      children: List.generate(_options.length, (index) {
        final option = _options[index];
        final selected = _selectedIndex == index;

        Color borderColor = selected ? Colors.amberAccent : Colors.white24;
        Color textColor = selected ? Colors.amberAccent : Colors.white70;
        Color iconColor = selected ? Colors.amberAccent : Colors.white38;

        if (_answered) {
          if (index == _correctIndex) {
            borderColor = Colors.greenAccent;
            textColor = Colors.greenAccent;
            iconColor = Colors.greenAccent;
          } else if (selected && index != _correctIndex) {
            borderColor = Colors.redAccent;
            textColor = Colors.redAccent;
            iconColor = Colors.redAccent;
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _answered
                ? null
                : () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.amberAccent.withOpacity(0.16)
                    : Colors.black.withOpacity(0.36),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: borderColor,
                  width: selected || _answered ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: iconColor,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option,
                      style: _medievalStyle.copyWith(
                        color: textColor,
                        fontSize: 15,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildConfirmButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 19, 34, 54),
        disabledBackgroundColor: Colors.grey.shade800,
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(
          color: Color.fromARGB(255, 148, 147, 255),
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
        ),
      ),
      onPressed: _selectedIndex == null ? null : _evaluateChoice,
      icon: const Icon(
        Icons.check_rounded,
        color: Colors.white,
      ),
      label: Text(
        'Confirmar decisión',
        style: _medievalStyle.copyWith(
          color: Colors.white,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildFeedbackCard() {
    final feedback = _isCorrect ? _correctFeedback : _wrongFeedback;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.46),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isCorrect ? Colors.greenAccent : Colors.redAccent,
          width: 1.6,
        ),
      ),
      child: Column(
        children: [
          Icon(
            _isCorrect
                ? Icons.check_circle_rounded
                : Icons.error_outline_rounded,
            color: _isCorrect ? Colors.greenAccent : Colors.redAccent,
            size: 58,
          ),
          const SizedBox(height: 12),
          Text(
            _isCorrect ? 'Buena decisión' : 'Decisión riesgosa',
            style: _medievalStyle.copyWith(
              color: _isCorrect ? Colors.greenAccent : Colors.redAccent,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            feedback,
            style: _medievalStyle.copyWith(
              color: Colors.white70,
              fontSize: 14,
              height: 1.25,
            ),
            textAlign: TextAlign.center,
          ),
          if (_technicalNote.isNotEmpty) ...[
            const SizedBox(height: 14),
            _buildTechnicalNote(),
          ],
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 19, 34, 54),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            onPressed: _finishChoice,
            icon: Icon(
              _canContinueAfterAnswer()
                  ? Icons.arrow_forward_rounded
                  : Icons.refresh_rounded,
              color: Colors.white,
            ),
            label: Text(
              _canContinueAfterAnswer() ? 'Continuar' : 'Reintentar',
              style: _medievalStyle.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.34),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.amberAccent.withOpacity(0.45),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Nota del Códice',
            style: _medievalStyle.copyWith(
              color: Colors.amberAccent,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _technicalNote,
            style: _medievalStyle.copyWith(
              color: Colors.white60,
              fontSize: 12,
              height: 1.25,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTextBox(String text) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.46),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white24,
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: _medievalStyle.copyWith(
          color: Colors.white70,
          fontSize: 15,
          height: 1.3,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _evaluateChoice() {
    if (_selectedIndex == null) return;

    setState(() {
      _answered = true;
      _isCorrect = _selectedIndex == _correctIndex;
    });
  }

  bool _canContinueAfterAnswer() {
    if (_isCorrect) return true;
    return !_mustBeCorrect;
  }

  void _finishChoice() {
    if (!_canContinueAfterAnswer()) {
      setState(() {
        _selectedIndex = null;
        _answered = false;
        _isCorrect = false;
      });
      return;
    }

    widget.onComplete(true);
    Navigator.pop(context);
  }
}