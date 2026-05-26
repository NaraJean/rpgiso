import 'package:flutter/material.dart';
import '../../models/enemy.dart';
import '../../models/player_status.dart';

typedef CombatAction = void Function(int damage);

class CombatEngine extends StatefulWidget {
  final Enemy enemy;
  final PlayerStatus playerStatus;
  final Widget Function(CombatAction dealDamage, CombatAction takeDamage) child;
  final VoidCallback onVictory;
  final VoidCallback onDefeat;

  const CombatEngine({
    super.key,
    required this.enemy,
    required this.playerStatus,
    required this.child,
    required this.onVictory,
    required this.onDefeat,
  });

  @override
  State<CombatEngine> createState() => _CombatEngineState();
}

class _CombatEngineState extends State<CombatEngine>
    with SingleTickerProviderStateMixin {
  late int _enemyHealth;
  late int _playerHealth;

  late AnimationController _controller;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _enemyHealth = widget.enemy.health;
    _playerHealth = widget.playerStatus.health;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _shakeAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 0.0), weight: 1),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void dealDamageToEnemy(int damage) {
    setState(() {
      _enemyHealth -= damage;

      if (_enemyHealth <= 0) {
        _enemyHealth = 0;
        _applyPlayerHealth();
        widget.onVictory();
      }
    });

    _controller.forward(from: 0.0);
  }

  void takeDamage(int damage) {
    setState(() {
      _playerHealth -= damage;

      if (_playerHealth <= 0) {
        _playerHealth = 0;
        _applyPlayerHealth();
        widget.onDefeat();
      }
    });
  }

  void _applyPlayerHealth() {
    widget.playerStatus.health = _playerHealth;
  }

  Widget _buildHealthBar({
    required String label,
    required int current,
    required int max,
    required Color color,
    required double width,
    required bool compact,
  }) {
    final safeMax = max <= 0 ? 1 : max;
    final percentage = (current / safeMax).clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: TextStyle(
              fontSize: compact ? 12 : 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'MedievalSharp',
            ),
          ),
          const SizedBox(height: 3),
        ],
        Stack(
          children: [
            Container(
              height: compact ? 10 : 12,
              width: width,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            Container(
              height: compact ? 10 : 12,
              width: width * percentage,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          '$current / $max',
          style: TextStyle(
            fontSize: compact ? 11 : 12,
            color: Colors.white,
            fontFamily: 'MedievalSharp',
          ),
        ),
      ],
    );
  }

  double _enemySpriteSize(double availableHeight, double availableWidth) {
    final byHeight = availableHeight * 0.43;
    final byWidth = availableWidth * 0.58;

    final size = byHeight < byWidth ? byHeight : byWidth;

    return size.clamp(220.0, 300.0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 5,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 360;
              final barWidth = constraints.maxWidth.clamp(230.0, 300.0);
              final enemySize = _enemySpriteSize(
                constraints.maxHeight,
                constraints.maxWidth,
              );

              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    widget.enemy.backgroundAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        color: const Color.fromARGB(255, 10, 18, 30),
                      );
                    },
                  ),
                  Container(
                    color: Colors.black.withOpacity(0.18),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      12,
                      compact ? 8 : 12,
                      12,
                      compact ? 6 : 10,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.enemy.name,
                          style: TextStyle(
                            fontSize: compact ? 17 : 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'MedievalSharp',
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: compact ? 5 : 7),
                        _buildHealthBar(
                          label: '',
                          current: _enemyHealth,
                          max: widget.enemy.maxHealth,
                          color: const Color.fromARGB(255, 108, 13, 9),
                          width: barWidth,
                          compact: compact,
                        ),
                        SizedBox(height: compact ? 3 : 6),
                        Expanded(
                          child: Center(
                            child: AnimatedBuilder(
                              animation: _shakeAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(_shakeAnimation.value, 0),
                                  child: child,
                                );
                              },
                              child: Image.asset(
                                widget.enemy.imageAsset,
                                width: enemySize,
                                height: enemySize,
                                fit: BoxFit.contain,
                                alignment: Alignment.center,
                                errorBuilder: (_, __, ___) {
                                  return Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.redAccent,
                                    size: enemySize * 0.45,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: compact ? 3 : 6),
                        _buildHealthBar(
                          label: 'Salud',
                          current: _playerHealth,
                          max: widget.playerStatus.maxHealth,
                          color: const Color.fromARGB(255, 29, 120, 35),
                          width: barWidth,
                          compact: compact,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Expanded(
          flex: 5,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
            color: Colors.black.withOpacity(0.58),
            child: widget.child(dealDamageToEnemy, takeDamage),
          ),
        ),
      ],
    );
  }
}