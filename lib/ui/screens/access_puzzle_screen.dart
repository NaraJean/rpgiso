import 'package:flutter/material.dart';

import '../../models/mission_step.dart';
import '../../models/player_status.dart';

class AccessPuzzleScreen extends StatefulWidget {
  final PlayerStatus playerStatus;
  final MissionStep step;
  final void Function(bool won) onComplete;

  const AccessPuzzleScreen({
    super.key,
    required this.playerStatus,
    required this.step,
    required this.onComplete,
  });

  @override
  State<AccessPuzzleScreen> createState() => _AccessPuzzleScreenState();
}

class _AccessPuzzleScreenState extends State<AccessPuzzleScreen>
    with SingleTickerProviderStateMixin {
  int _currentCaseIndex = 0;
  int _score = 0;

  final Set<int> _selectedIndexes = {};

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  static const TextStyle _medievalStyle = TextStyle(
    fontFamily: 'MedievalSharp',
  );

  List<Map<String, dynamic>> get _cases {
    final rawCases = widget.step.extraData?['accessCases'];

    if (rawCases is List) {
      return rawCases
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    return const [];
  }

  Map<String, dynamic> get _currentCase => _cases[_currentCaseIndex];

  String get _roleName => (_currentCase['role'] ?? 'Rol desconocido').toString();

  String get _description =>
      (_currentCase['description'] ?? 'Sin descripción.').toString();

  List<String> get _permissions {
    final rawPermissions = _currentCase['permissions'];

    if (rawPermissions is List) {
      return rawPermissions.map((item) => item.toString()).toList();
    }

    return const [];
  }

  List<int> get _correctIndexes {
    final rawIndexes = _currentCase['correctIndexes'];

    if (rawIndexes is List) {
      return rawIndexes.whereType<int>().toList();
    }

    return const [];
  }

  bool get _isLastCase => _currentCaseIndex == _cases.length - 1;

  double get _caseProgress {
    if (_cases.isEmpty) return 0;
    return (_currentCaseIndex + 1) / _cases.length;
  }

  Color get _statusColor {
    if (_selectedIndexes.isEmpty) {
      return Colors.white70;
    }

    return Colors.amberAccent;
  }

  String get _statusText {
    if (_selectedIndexes.isEmpty) {
      return 'Sin puertas asignadas';
    }

    if (_selectedIndexes.length == 1) {
      return '1 puerta seleccionada';
    }

    return '${_selectedIndexes.length} puertas seleccionadas';
  }

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.20,
      end: 0.70,
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

  @override
  Widget build(BuildContext context) {
    if (_cases.isEmpty) {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 12, 14, 30),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _buildTextBox(
                'Este reto no tiene casos configurados.\n\n'
                'Revisa extraData["accessCases"] en la misión.',
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxHeight < 760;

                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 14 : 18,
                      vertical: compact ? 10 : 14,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 470),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildGameHeader(compact: compact),
                            SizedBox(height: compact ? 8 : 10),
                            _buildAccessBoard(compact: compact),
                            SizedBox(height: compact ? 8 : 10),
                            Expanded(
                              child: _buildPermissionGrid(),
                            ),
                            SizedBox(height: compact ? 8 : 10),
                            _buildPrimaryButton(),
                            SizedBox(height: compact ? 6 : 8),
                            _buildHint(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.58),
                const Color.fromARGB(255, 14, 18, 32).withOpacity(0.78),
                Colors.black.withOpacity(0.86),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameHeader({required bool compact}) {
    return Row(
      children: [
        Container(
          width: compact ? 42 : 48,
          height: compact ? 42 : 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.amberAccent.withOpacity(0.10),
            border: Border.all(
              color: Colors.amberAccent.withOpacity(0.55),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.amberAccent.withOpacity(0.10),
                blurRadius: 14,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Icon(
            Icons.door_front_door_rounded,
            color: Colors.amberAccent,
            size: 25,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.step.title,
                style: _medievalStyle.copyWith(
                  color: Colors.amberAccent,
                  fontSize: compact ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Caso ${_currentCaseIndex + 1} de ${_cases.length} · Principio de mínimo privilegio',
                style: _medievalStyle.copyWith(
                  color: Colors.white70,
                  fontSize: compact ? 10.8 : 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.greenAccent.withOpacity(0.09),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.greenAccent.withOpacity(0.42),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.verified_user_rounded,
                color: Colors.greenAccent,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                '$_score',
                style: _medievalStyle.copyWith(
                  color: Colors.greenAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccessBoard({required bool compact}) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final pulse = _pulseAnimation.value;

        return Container(
          padding: EdgeInsets.all(compact ? 13 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(232, 18, 24, 46),
                Color.fromARGB(235, 12, 12, 28),
                Color.fromARGB(225, 38, 28, 12),
              ],
            ),
            border: Border.all(
              color: _statusColor.withOpacity(0.38 + pulse * 0.25),
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
                  _buildRoleSeal(compact: compact),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _roleName,
                          style: _medievalStyle.copyWith(
                            color: Colors.amberAccent,
                            fontSize: compact ? 17 : 19,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _description,
                          style: _medievalStyle.copyWith(
                            color: const Color(0xFFCBD8F0),
                            fontSize: compact ? 11.5 : 12.5,
                            height: 1.18,
                          ),
                          maxLines: compact ? 2 : 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: compact ? 10 : 12),
              _buildProgressBar(),
              SizedBox(height: compact ? 9 : 11),
              Row(
                children: [
                  Expanded(
                    child: _buildMiniStat(
                      icon: Icons.door_front_door_rounded,
                      label: 'Puertas',
                      value: '${_permissions.length}',
                      color: Colors.amberAccent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMiniStat(
                      icon: Icons.lock_open_rounded,
                      label: 'Elegidas',
                      value: '${_selectedIndexes.length}',
                      color: _statusColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMiniStat(
                      icon: Icons.shield_rounded,
                      label: 'Aciertos',
                      value: '$_score',
                      color: Colors.greenAccent,
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

  Widget _buildRoleSeal({required bool compact}) {
    return Container(
      width: compact ? 58 : 66,
      height: compact ? 58 : 66,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.amberAccent.withOpacity(0.09),
        border: Border.all(
          color: Colors.amberAccent.withOpacity(0.60),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amberAccent.withOpacity(0.14),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            _iconForRole(),
            color: Colors.amberAccent,
            size: compact ? 29 : 33,
          ),
          Positioned(
            right: compact ? 10 : 11,
            bottom: compact ? 9 : 10,
            child: Icon(
              Icons.key_rounded,
              color: Colors.white.withOpacity(0.75),
              size: compact ? 15 : 17,
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForRole() {
    final role = _roleName.toLowerCase();

    if (role.contains('biblioteca') || role.contains('archivo')) {
      return Icons.menu_book_rounded;
    }

    if (role.contains('guardia') || role.contains('seguridad')) {
      return Icons.shield_rounded;
    }

    if (role.contains('administrador') || role.contains('admin')) {
      return Icons.admin_panel_settings_rounded;
    }

    if (role.contains('aprendiz') || role.contains('estudiante')) {
      return Icons.school_rounded;
    }

    if (role.contains('tesorero') || role.contains('tesoro')) {
      return Icons.account_balance_rounded;
    }

    return Icons.person_rounded;
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _statusText,
          style: _medievalStyle.copyWith(
            color: _statusColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Container(
                height: 9,
                color: Colors.white.withOpacity(0.12),
              ),
              FractionallySizedBox(
                widthFactor: _caseProgress,
                child: Container(
                  height: 9,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.amberAccent.withOpacity(0.80),
                        Colors.greenAccent.withOpacity(0.85),
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
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.25),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(height: 3),
          Text(
            value,
            style: _medievalStyle.copyWith(
              color: color,
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: _medievalStyle.copyWith(
              color: Colors.white60,
              fontSize: 9.8,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionGrid() {
    return GridView.builder(
      itemCount: _permissions.length,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.10,
      ),
      itemBuilder: (context, index) {
        return _buildPermissionGate(index);
      },
    );
  }

  Widget _buildPermissionGate(int index) {
    final selected = _selectedIndexes.contains(index);
    final color = _permissionColor(index);
    final icon = _permissionIcon(index);
    final label = _permissions[index];

    return GestureDetector(
      onTap: () {
        setState(() {
          if (selected) {
            _selectedIndexes.remove(index);
          } else {
            _selectedIndexes.add(index);
          }
        });
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 160),
        scale: selected ? 1.03 : 1.0,
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
                        color: color.withOpacity(0.28),
                        blurRadius: 22,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 190),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: selected
                      ? [
                          color.withOpacity(0.30),
                          const Color.fromARGB(230, 18, 18, 42),
                          Colors.black.withOpacity(0.70),
                        ]
                      : [
                          const Color.fromARGB(220, 20, 20, 44),
                          const Color.fromARGB(210, 12, 12, 28),
                          Colors.black.withOpacity(0.60),
                        ],
                ),
                border: Border.all(
                  color: selected ? color.withOpacity(0.95) : Colors.white24,
                  width: selected ? 1.8 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -16,
                    top: -14,
                    child: Icon(
                      Icons.castle_rounded,
                      color: Colors.white.withOpacity(0.045),
                      size: 78,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withOpacity(selected ? 0.16 : 0.08),
                          border: Border.all(
                            color: color.withOpacity(selected ? 0.65 : 0.30),
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: selected ? color : Colors.white70,
                          size: 27,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        label,
                        style: _medievalStyle.copyWith(
                          color: selected ? color : Colors.white70,
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          height: 1.08,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        selected ? 'Acceso abierto' : 'Bloqueado',
                        style: _medievalStyle.copyWith(
                          color: selected ? Colors.amberAccent : Colors.white38,
                          fontSize: 10.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Icon(
                      selected
                          ? Icons.lock_open_rounded
                          : Icons.lock_outline_rounded,
                      color: selected ? Colors.amberAccent : Colors.white30,
                      size: 19,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _permissionColor(int index) {
    final label = _permissions[index].toLowerCase();

    if (label.contains('admin') || label.contains('global')) {
      return Colors.redAccent;
    }

    if (label.contains('tesoro') || label.contains('financ')) {
      return Colors.amberAccent;
    }

    if (label.contains('consejo') || label.contains('direct')) {
      return const Color(0xFFCB9AFF);
    }

    if (label.contains('editar') || label.contains('modificar')) {
      return const Color(0xFF7DD3FC);
    }

    if (label.contains('consultar') ||
        label.contains('ver') ||
        label.contains('lectura')) {
      return Colors.greenAccent;
    }

    return const Color(0xFFCBD8F0);
  }

  IconData _permissionIcon(int index) {
    final label = _permissions[index].toLowerCase();

    if (label.contains('admin') || label.contains('global')) {
      return Icons.admin_panel_settings_rounded;
    }

    if (label.contains('tesoro') || label.contains('financ')) {
      return Icons.account_balance_rounded;
    }

    if (label.contains('consejo') || label.contains('direct')) {
      return Icons.groups_rounded;
    }

    if (label.contains('editar') || label.contains('modificar')) {
      return Icons.edit_document;
    }

    if (label.contains('consultar') ||
        label.contains('ver') ||
        label.contains('lectura')) {
      return Icons.visibility_rounded;
    }

    if (label.contains('archivo') || label.contains('registro')) {
      return Icons.folder_open_rounded;
    }

    return Icons.door_front_door_rounded;
  }

  Widget _buildPrimaryButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 24, 47, 72),
        disabledBackgroundColor: Colors.grey.shade800,
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(
          color: Color.fromARGB(255, 148, 147, 255),
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: _evaluateCurrentCase,
      icon: Icon(
        _isLastCase
            ? Icons.verified_user_rounded
            : Icons.arrow_forward_rounded,
        color: Colors.white,
      ),
      label: Text(
        _isLastCase ? 'Finalizar asignación' : 'Confirmar permisos',
        style: _medievalStyle.copyWith(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHint() {
    return Text(
      'Regla del guardián: no abras más puertas de las necesarias.',
      style: _medievalStyle.copyWith(
        color: Colors.white38,
        fontSize: 11.5,
      ),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
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

  void _evaluateCurrentCase() {
    final selected = _selectedIndexes.toList()..sort();
    final correct = _correctIndexes.toList()..sort();

    final isCorrect = _listEquals(selected, correct);

    if (isCorrect) {
      _score++;
    }

    _showCaseResult(isCorrect);
  }

  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;

    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }

    return true;
  }

  void _showCaseResult(bool isCorrect) {
    final explanation =
        (_currentCase['explanation'] ?? 'Sin explicación.').toString();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: const Color.fromARGB(255, 18, 18, 42),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: isCorrect ? Colors.greenAccent : Colors.redAccent,
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCorrect
                      ? Icons.check_circle_rounded
                      : Icons.error_outline_rounded,
                  color: isCorrect ? Colors.greenAccent : Colors.redAccent,
                  size: 54,
                ),
                const SizedBox(height: 12),
                Text(
                  isCorrect ? 'Permisos correctos' : 'Permisos riesgosos',
                  style: _medievalStyle.copyWith(
                    color: isCorrect ? Colors.greenAccent : Colors.redAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  explanation,
                  style: _medievalStyle.copyWith(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.25,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 24, 47, 72),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _continueAfterResult();
                  },
                  child: Text(
                    _isLastCase ? 'Ver resultado' : 'Siguiente caso',
                    style: _medievalStyle.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _continueAfterResult() {
    if (_isLastCase) {
      final minScoreToWin = (_cases.length * 0.7).ceil();
      final won = _score >= minScoreToWin;

      _showFinalResult(won, minScoreToWin);
      return;
    }

    setState(() {
      _currentCaseIndex++;
      _selectedIndexes.clear();
    });
  }

  void _showFinalResult(bool won, int minScoreToWin) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: const Color.fromARGB(255, 18, 18, 42),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: won ? Colors.amberAccent : Colors.redAccent,
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  won
                      ? Icons.workspace_premium_rounded
                      : Icons.shield_outlined,
                  color: won ? Colors.amberAccent : Colors.redAccent,
                  size: 62,
                ),
                const SizedBox(height: 14),
                Text(
                  won ? 'Accesos protegidos' : 'La fortaleza quedó vulnerable',
                  style: _medievalStyle.copyWith(
                    color: won ? Colors.amberAccent : Colors.redAccent,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Resultado: $_score de ${_cases.length}\n'
                  'Mínimo necesario: $minScoreToWin',
                  style: _medievalStyle.copyWith(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                Text(
                  won
                      ? 'Asignaste los permisos con criterio. No todos necesitan abrir todas las puertas.'
                      : 'Algunos permisos quedaron mal asignados. El control de acceso exige precisión, no generosidad medieval sin supervisión.',
                  style: _medievalStyle.copyWith(
                    color: Colors.white60,
                    fontSize: 13,
                    height: 1.25,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 22),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 24, 47, 72),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    widget.onComplete(won);
                    Navigator.pop(context);
                  },
                  child: Text(
                    won ? 'Continuar misión' : 'Reintentar luego',
                    style: _medievalStyle.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}