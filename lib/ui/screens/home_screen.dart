import 'package:flutter/material.dart';
import '../../models/player_status.dart';
import '../../services/local_storage_service.dart';
import '../../data/game_missions.dart';
import '../../models/game_mission.dart';
import 'mission_intro_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  PlayerStatus? _player;
  late List<AnimationController> _controllers = [];
  late List<Animation<Offset>> _animations = [];

  static const TextStyle medievalStyle = TextStyle(
    fontFamily: 'MedievalSharp',
  );

  @override
  void initState() {
    super.initState();
    _loadPlayer();
  }

  Future<void> _loadPlayer() async {
    final character = await LocalStorageService().loadCharacter();
    if (character != null) {
      setState(() {
        _player = PlayerStatus.fromCharacter(character);
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildAnimatedMissionCard(GameMission mission, int index) {
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    final animation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    _controllers.add(controller);
    _animations.add(animation);

    Future.delayed(Duration(milliseconds: index * 100), () {
      if (mounted) controller.forward();
    });

    return SlideTransition(
      position: animation,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/textures/stone_texture.png',
                  fit: BoxFit.fill,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mission.title,
                        style: medievalStyle.copyWith(
                            fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 225, 218, 255))),
                    const SizedBox(height: 4),
                    Text(mission.shortDescription, style: medievalStyle.copyWith(color: Color.fromARGB(255, 225, 218, 255))),
                    const SizedBox(height: 8),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 27, 27, 48),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'MedievalSharp',
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                          side: const BorderSide(color: Color.fromARGB(255, 148, 147, 255), width: 1),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MissionIntroScreen(
                              playerStatus: _player!,
                              mission: mission,
                            ),
                          ),
                        ).then((_) => setState(() {}));
                      },
                      child: const Text('Comenzar Misión'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar(String label, int value, int max, Color color) {
    double percentage = value / max;
    double barWidth = 250;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: medievalStyle.copyWith(fontSize: 16, color: Color.fromARGB(255, 225, 218, 255))),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            children: [
              Container(
                height: 12,
                width: barWidth,
                color: Colors.grey[300],
              ),
              Container(
                height: 12,
                width: barWidth * percentage,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text('$value / $max', style: medievalStyle.copyWith(fontSize: 14, color: Color.fromARGB(255, 225, 218, 255))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final constrainedScaleFactor = mediaQuery.textScaleFactor.clamp(1.0, 1.2);

    if (_player == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final dailyMissions = gameMissions.where((m) => m.missionType == MissionType.diaria).toList();
    final weeklyMissions = gameMissions.where((m) => m.missionType == MissionType.semanal).toList();

    return MediaQuery(
      data: mediaQuery.copyWith(textScaler: TextScaler.linear(constrainedScaleFactor)),
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/backgrounds/character_selection_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Bienvenido, ${_player!.name}',
                          style: medievalStyle.copyWith(fontSize: 22, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 225, 218, 255))),
                      Row(
                        children: [
                          Image.asset(
                            'assets/icons/coin_icon.png',
                            width: 50,
                            height: 50,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_player!.coins}',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontFamily: 'MedievalSharp',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          CircleAvatar(radius: 50, backgroundImage: AssetImage(_player!.avatar)),
                          const SizedBox(height: 8),
                          Text('Nivel ${_player!.level}',
                              style: medievalStyle.copyWith(fontSize: 16, color: Color.fromARGB(255, 225, 218, 255))),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatusBar('Salud', _player!.health, _player!.maxHealth, const Color.fromARGB(255, 102, 25, 20)),
                            const SizedBox(height: 16),
                            _buildStatusBar('XP', _player!.xp, _player!.maxXp, const Color.fromARGB(255, 211, 199, 29)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text('Misiones Diarias',
                      style: medievalStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 225, 218, 255))),
                  const SizedBox(height: 10),
                  ...dailyMissions.asMap().entries.map((entry) => _buildAnimatedMissionCard(entry.value, entry.key)),
                  const SizedBox(height: 20),
                  Text('Misiones Semanales',
                      style: medievalStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 225, 218, 255))),
                  const SizedBox(height: 10),
                  ...weeklyMissions.asMap().entries.map((entry) => _buildAnimatedMissionCard(entry.value, entry.key + dailyMissions.length)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
