import 'package:flutter/material.dart';

import '../../models/mission_step.dart';
import '../../models/player_status.dart';

class BackupTimelineScreen extends StatefulWidget {
  final PlayerStatus playerStatus;
  final MissionStep step;
  final void Function(bool won) onComplete;

  const BackupTimelineScreen({
    super.key,
    required this.playerStatus,
    required this.step,
    required this.onComplete,
  });

  @override
  State<BackupTimelineScreen> createState() => _BackupTimelineScreenState();
}

class _BackupTimelineScreenState extends State<BackupTimelineScreen>
    with SingleTickerProviderStateMixin {
  late List<String> _items;
  late List<int> _correctOrder;

  bool _answered = false;
  bool _won = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  static const TextStyle _medievalStyle = TextStyle(
    fontFamily: 'MedievalSharp',
  );

  @override
  void initState() {
    super.initState();

    final originalItems = List<String>.from(widget.step.options);
    _items = List<String>.from(originalItems);

    final rawCorrectOrder = widget.step.correctOrder;

    if (rawCorrectOrder != null && rawCorrectOrder.isNotEmpty) {
      _correctOrder = List<int>.from(rawCorrectOrder);
    } else {
      _correctOrder = List.generate(_items.length, (index) => index);
    }

    if (_items.length > 1) {
      int attempts = 0;

      do {
        _items.shuffle();
        attempts++;
      } while (_listEquals(_items, _correctItems) && attempts < 10);
    }

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1350),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.22,
      end: 0.72,
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

  List<String> get _correctItems {
    return _correctOrder.map((index) => widget.step.options[index]).toList();
  }

  int get _correctPositionCount {
    int count = 0;

    for (int i = 0; i < _items.length; i++) {
      if (i < _correctItems.length && _items[i] == _correctItems[i]) {
        count++;
      }
    }

    return count;
  }

  double get _progressValue {
    if (_items.isEmpty) return 0;
    return _correctPositionCount / _items.length;
  }

  Color get _statusColor {
    if (!_answered) {
      return const Color(0xFF7DD3FC);
    }

    return _won ? Colors.greenAccent : Colors.redAccent;
  }

  String get _statusLabel {
    if (!_answered) {
      return 'Cristales desordenados';
    }

    return _won ? 'Ritual restaurado' : 'Secuencia inestable';
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 12, 14, 30),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _buildTextBox(
                'Este reto no tiene pasos configurados.\n\n'
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
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildGameHeader(compact: compact),
                            SizedBox(height: compact ? 8 : 10),
                            _buildCrystalBoard(compact: compact),
                            SizedBox(height: compact ? 8 : 10),
                            Expanded(
                              child: _buildTimelineList(),
                            ),
                            SizedBox(height: compact ? 8 : 10),
                            if (!_answered) _buildEvaluateButton(),
                            if (_answered) _buildResultPanel(compact: compact),
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
                const Color.fromARGB(255, 10, 18, 34).withOpacity(0.78),
                Colors.black.withOpacity(0.88),
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
            color: Colors.lightBlueAccent.withOpacity(0.10),
            border: Border.all(
              color: Colors.lightBlueAccent.withOpacity(0.55),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.lightBlueAccent.withOpacity(0.12),
                blurRadius: 14,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Icon(
            Icons.backup_rounded,
            color: Colors.lightBlueAccent,
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
                widget.step.minigameLabel.isNotEmpty
                    ? widget.step.minigameLabel
                    : 'Ordena el ritual de restauración',
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
            color: _statusColor.withOpacity(0.11),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _statusColor.withOpacity(0.45),
            ),
          ),
          child: Row(
            children: [
              Icon(
                _answered
                    ? (_won
                        ? Icons.check_circle_rounded
                        : Icons.error_outline_rounded)
                    : Icons.timeline_rounded,
                color: _statusColor,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                '$_correctPositionCount/${_items.length}',
                style: _medievalStyle.copyWith(
                  color: _statusColor,
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

  Widget _buildCrystalBoard({required bool compact}) {
    final npcInstruction =
        widget.step.extraData?['npcInstruction']?.toString() ??
            'Ordena los pasos desde la acción inicial hasta la restauración segura.';

    final npcName =
        widget.step.extraData?['npcName']?.toString() ?? 'Archivista Thalen';

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
                Color.fromARGB(232, 16, 24, 48),
                Color.fromARGB(235, 12, 12, 30),
                Color.fromARGB(225, 20, 38, 54),
              ],
            ),
            border: Border.all(
              color: _statusColor.withOpacity(0.38 + pulse * 0.26),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _statusColor.withOpacity(0.08 + pulse * 0.12),
                blurRadius: 22,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              _buildMainCrystal(compact: compact),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      npcName,
                      style: _medievalStyle.copyWith(
                        color: Colors.amberAccent,
                        fontSize: compact ? 15.5 : 17,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      npcInstruction,
                      style: _medievalStyle.copyWith(
                        color: const Color(0xFFCBD8F0),
                        fontSize: compact ? 11.3 : 12.3,
                        height: 1.16,
                      ),
                      maxLines: compact ? 3 : 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    _buildProgressBar(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainCrystal({required bool compact}) {
    return SizedBox(
      width: compact ? 64 : 72,
      height: compact ? 86 : 94,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: compact ? 58 : 66,
            height: compact ? 58 : 66,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _statusColor.withOpacity(0.10),
              boxShadow: [
                BoxShadow(
                  color: _statusColor.withOpacity(0.20),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          ClipPath(
            clipper: _CrystalClipper(),
            child: Container(
              width: compact ? 48 : 54,
              height: compact ? 72 : 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _statusColor.withOpacity(0.95),
                    const Color(0xFF2563EB).withOpacity(0.72),
                    Colors.black.withOpacity(0.72),
                  ],
                ),
              ),
            ),
          ),
          CustomPaint(
            size: Size(compact ? 48 : 54, compact ? 72 : 80),
            painter: _CrystalBorderPainter(
              color: _statusColor.withOpacity(0.95),
              strokeWidth: 1.4,
            ),
          ),
          Icon(
            _answered
                ? (_won ? Icons.restore_rounded : Icons.sync_problem_rounded)
                : Icons.auto_awesome_rounded,
            color: Colors.white.withOpacity(0.90),
            size: compact ? 24 : 28,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final value = _answered ? _progressValue : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _statusLabel,
          style: _medievalStyle.copyWith(
            color: _statusColor,
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Container(
                height: 9,
                color: Colors.white.withOpacity(0.12),
              ),
              FractionallySizedBox(
                widthFactor: value,
                child: Container(
                  height: 9,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _statusColor.withOpacity(0.80),
                        Colors.amberAccent.withOpacity(0.92),
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

  Widget _buildTimelineList() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.32),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.14),
          width: 1,
        ),
      ),
      child: ReorderableListView.builder(
        padding: EdgeInsets.zero,
        itemCount: _items.length,
        onReorder: _answered ? (_, __) {} : _onReorder,
        proxyDecorator: (child, index, animation) {
          return Material(
            color: Colors.transparent,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 1,
                end: 1.035,
              ).animate(animation),
              child: child,
            ),
          );
        },
        itemBuilder: (context, index) {
          final item = _items[index];

          return Padding(
            key: ValueKey(item),
            padding: const EdgeInsets.only(bottom: 9),
            child: _buildTimelineCrystal(index, item),
          );
        },
      ),
    );
  }

  Widget _buildTimelineCrystal(int index, String item) {
    Color borderColor = Colors.white24;
    Color crystalColor = _crystalColor(index);
    IconData stateIcon = Icons.drag_handle_rounded;

    if (_answered) {
      final correctItem = _correctItems[index];
      final isCorrectPosition = item == correctItem;

      borderColor = isCorrectPosition ? Colors.greenAccent : Colors.redAccent;
      crystalColor = isCorrectPosition ? Colors.greenAccent : Colors.redAccent;
      stateIcon = isCorrectPosition
          ? Icons.check_circle_rounded
          : Icons.cancel_rounded;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            crystalColor.withOpacity(0.13),
            const Color.fromARGB(220, 18, 18, 42),
            Colors.black.withOpacity(0.58),
          ],
        ),
        border: Border.all(
          color: _answered ? borderColor : crystalColor.withOpacity(0.42),
          width: _answered ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: crystalColor.withOpacity(0.08),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipPath(
                  clipper: _SmallCrystalClipper(),
                  child: Container(
                    width: 34,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          crystalColor.withOpacity(0.92),
                          crystalColor.withOpacity(0.45),
                          Colors.black.withOpacity(0.65),
                        ],
                      ),
                    ),
                  ),
                ),
                Text(
                  '${index + 1}',
                  style: _medievalStyle.copyWith(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: crystalColor.withOpacity(0.65),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item,
              style: _medievalStyle.copyWith(
                color: Colors.white70,
                fontSize: 13.2,
                height: 1.16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            stateIcon,
            color: _answered ? borderColor : Colors.white38,
            size: 23,
          ),
        ],
      ),
    );
  }

  Color _crystalColor(int index) {
    const colors = [
      Color(0xFF7DD3FC),
      Color(0xFF60A5FA),
      Color(0xFFA78BFA),
      Color(0xFFFACC15),
      Color(0xFF34D399),
      Color(0xFFFB7185),
    ];

    return colors[index % colors.length];
  }

  Widget _buildEvaluateButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 24, 47, 72),
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(
          color: Color.fromARGB(255, 148, 147, 255),
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: _evaluateOrder,
      icon: const Icon(
        Icons.auto_awesome_rounded,
        color: Colors.white,
      ),
      label: Text(
        'Activar restauración',
        style: _medievalStyle.copyWith(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildResultPanel({required bool compact}) {
    final explanation = widget.step.extraData?['explanation']?.toString() ??
        'Las copias de seguridad deben estar ordenadas, verificadas y disponibles para restauración.';

    return Container(
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _won ? Colors.greenAccent : Colors.redAccent,
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
          Row(
            children: [
              Icon(
                _won
                    ? Icons.check_circle_rounded
                    : Icons.error_outline_rounded,
                color: _won ? Colors.greenAccent : Colors.redAccent,
                size: 30,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _won ? 'Cristal restaurado' : 'Secuencia incorrecta',
                  style: _medievalStyle.copyWith(
                    color: _won ? Colors.greenAccent : Colors.redAccent,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            explanation,
            style: _medievalStyle.copyWith(
              color: Colors.white70,
              fontSize: compact ? 11.5 : 12.4,
              height: 1.18,
            ),
            textAlign: TextAlign.center,
            maxLines: compact ? 2 : 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _won
                  ? const Color.fromARGB(255, 25, 85, 50)
                  : const Color.fromARGB(255, 90, 25, 25),
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: BorderSide(
                color: _won ? Colors.greenAccent : Colors.redAccent,
                width: 1,
              ),
            ),
            onPressed: () {
              widget.onComplete(_won);
              Navigator.pop(context);
            },
            icon: Icon(
              _won ? Icons.arrow_forward_rounded : Icons.refresh_rounded,
              color: Colors.white,
            ),
            label: Text(
              _won ? 'Continuar misión' : 'Reintentar misión',
              style: _medievalStyle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
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

  void _onReorder(int oldIndex, int newIndex) {
    if (_answered) return;

    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });
  }

  void _evaluateOrder() {
    final currentOrderIsCorrect = _listEquals(_items, _correctItems);

    setState(() {
      _answered = true;
      _won = currentOrderIsCorrect;
    });
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;

    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }

    return true;
  }
}

Path _crystalPath(Size size) {
  final w = size.width;
  final h = size.height;

  return Path()
    ..moveTo(w * 0.50, 0)
    ..lineTo(w * 0.86, h * 0.22)
    ..lineTo(w * 0.72, h * 0.82)
    ..lineTo(w * 0.50, h)
    ..lineTo(w * 0.28, h * 0.82)
    ..lineTo(w * 0.14, h * 0.22)
    ..close();
}

class _CrystalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return _crystalPath(size);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class _SmallCrystalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return _crystalPath(size);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class _CrystalBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _CrystalBorderPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _crystalPath(size);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawPath(path, paint);

    final innerPaint = Paint()
      ..color = Colors.white.withOpacity(0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final innerPath = Path()
      ..moveTo(size.width * 0.50, size.height * 0.10)
      ..lineTo(size.width * 0.68, size.height * 0.28)
      ..lineTo(size.width * 0.58, size.height * 0.72)
      ..lineTo(size.width * 0.50, size.height * 0.88)
      ..lineTo(size.width * 0.42, size.height * 0.72)
      ..lineTo(size.width * 0.32, size.height * 0.28)
      ..close();

    canvas.drawPath(innerPath, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _CrystalBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}