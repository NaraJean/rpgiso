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

class _CombatEngineState extends State<CombatEngine> with SingleTickerProviderStateMixin {
  late int _enemyHealth;
  late int _playerHealth;

  late AnimationController _controller;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _enemyHealth = widget.enemy.health;
    _playerHealth = widget.playerStatus.health;

    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
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

  Widget _buildHealthBar(String label, int current, int max, Color color) {
    double percentage = current / max;
    return Column(
      children: [
        if (label.isNotEmpty)
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        Stack(
          children: [
            Container(height: 16, width: 250, color: Colors.grey[300]),
            Container(height: 16, width: 250 * percentage, color: color),
          ],
        ),
        const SizedBox(height: 4),
        Text('$current / $max', style: const TextStyle(fontSize: 14, color: Colors.white)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(widget.enemy.backgroundAsset, fit: BoxFit.cover),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.enemy.name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    _buildHealthBar('', _enemyHealth, widget.enemy.maxHealth, const Color.fromARGB(255, 68, 13, 9)),
                    const SizedBox(height: 8),
                    AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_shakeAnimation.value, 0),
                          child: child,
                        );
                      },
                      child: Image.asset(widget.enemy.imageAsset, width: 200, height: 200),
                    ),
                    const SizedBox(height: 12),
                    _buildHealthBar('Salud', _playerHealth, widget.playerStatus.maxHealth, const Color.fromARGB(255, 29, 94, 21)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.black.withOpacity(0.5),
            child: widget.child(dealDamageToEnemy, takeDamage),
          ),
        ),
      ],
    );
  }
}
