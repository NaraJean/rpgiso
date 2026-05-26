import 'package:flutter/material.dart';

import '../../models/player_status.dart';
import '../../services/local_storage_service.dart';

import '../../data/game_missions.dart';
import '../../data/narrative_missions.dart';

import '../../models/game_mission.dart';
import '../../models/narrative_mission.dart';

import 'mission_intro_screen.dart';
import 'narrative_mission_screen.dart';
import 'dungeon_knowledge_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  PlayerStatus? _player;

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

    if (!mounted) return;

    if (character != null) {
      setState(() {
        _player = PlayerStatus.fromCharacter(character);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final constrainedScaleFactor = mediaQuery.textScaleFactor.clamp(1.0, 1.2);

    if (_player == null) {
      return const Scaffold(
        backgroundColor: Color.fromARGB(255, 8, 8, 20),
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.amberAccent,
          ),
        ),
      );
    }

    final dailyMissions = gameMissions
        .where((mission) => mission.missionType == MissionType.diaria)
        .toList();

    final weeklyMissions = gameMissions
        .where((mission) => mission.missionType == MissionType.semanal)
        .toList();

    return MediaQuery(
      data: mediaQuery.copyWith(
        textScaler: TextScaler.linear(constrainedScaleFactor),
      ),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/backgrounds/character_selection_bg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            color: Colors.black.withOpacity(0.35),
            child: SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                    children: [
                      _buildPlayerHeader(),
                      const SizedBox(height: 18),
                      _buildCampaignBanner(),
                      const SizedBox(height: 18),
                      _buildDungeonCard(),
                      const SizedBox(height: 18),
                      _buildSectionHeader(
                        title: 'Campaña Principal',
                        subtitle: 'Reino de los Datos',
                        icon: Icons.auto_stories_rounded,
                        badge: 'ISO 27001',
                      ),
                      const SizedBox(height: 12),
                      ...narrativeMissions.asMap().entries.map(
                            (entry) => _buildNarrativeMissionCard(
                              mission: entry.value,
                              index: entry.key,
                            ),
                          ),
                      _buildComingSoonMissionCard(),
                      const SizedBox(height: 24),
                      _buildSectionHeader(
                        title: 'Entrenamientos',
                        subtitle: 'Misiones diarias',
                        icon: Icons.shield_rounded,
                        badge: 'Práctica',
                      ),
                      const SizedBox(height: 12),
                      ...dailyMissions.asMap().entries.map(
                            (entry) => _buildTrainingMissionCard(
                              mission: entry.value,
                              index: entry.key,
                            ),
                          ),
                      const SizedBox(height: 24),
                      _buildSectionHeader(
                        title: 'Desafíos Semanales',
                        subtitle: 'Retos especiales',
                        icon: Icons.workspace_premium_rounded,
                        badge: 'Bonus',
                      ),
                      const SizedBox(height: 12),
                      ...weeklyMissions.asMap().entries.map(
                            (entry) => _buildTrainingMissionCard(
                              mission: entry.value,
                              index: entry.key + dailyMissions.length,
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER DEL JUGADOR
  // ---------------------------------------------------------------------------

  Widget _buildPlayerHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(210, 12, 12, 30),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.amberAccent.withOpacity(0.45),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amberAccent.withOpacity(0.08),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          _buildAvatarFrame(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _player!.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: medievalStyle.copyWith(
                    color: Colors.amberAccent,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Guardián del Reino de los Datos',
                  style: medievalStyle.copyWith(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildSmallStatBadge(
                      icon: Icons.military_tech_rounded,
                      label: 'Nivel ${_player!.level}',
                      color: Colors.lightBlueAccent,
                    ),
                    const SizedBox(width: 8),
                    _buildCoinBadge(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFrame() {
    return Container(
      width: 78,
      height: 78,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.45),
        border: Border.all(
          color: Colors.amberAccent.withOpacity(0.75),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amberAccent.withOpacity(0.14),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundColor: const Color.fromARGB(255, 20, 20, 45),
        backgroundImage: AssetImage(_player!.avatar),
      ),
    );
  }

  Widget _buildCoinBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.amberAccent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.amberAccent.withOpacity(0.45),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/icons/coin_icon.png',
            width: 16,
            height: 16,
            errorBuilder: (_, __, ___) {
              return const Icon(
                Icons.monetization_on_rounded,
                color: Colors.amberAccent,
                size: 16,
              );
            },
          ),
          const SizedBox(width: 5),
          Text(
            '${_player!.coins}',
            style: medievalStyle.copyWith(
              color: Colors.amberAccent,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStatBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 5),
          Text(
            label,
            style: medievalStyle.copyWith(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BANNER CAMPAÑA
  // ---------------------------------------------------------------------------

  Widget _buildCampaignBanner() {
    final completedVisual = 4;
    final totalVisual = 5;
    final progress = completedVisual / totalVisual;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(215, 18, 16, 42),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF9B6EC8).withOpacity(0.65),
          width: 1.3,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.castle_rounded,
                color: Color(0xFFCB9AFF),
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Campaña: Reino de los Datos',
                  style: medievalStyle.copyWith(
                    color: const Color(0xFFCB9AFF),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Completa misiones narrativas para aprender conceptos clave de seguridad de la información mediante retos, combates y decisiones guiadas.',
            style: medievalStyle.copyWith(
              color: Colors.white70,
              fontSize: 12.5,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Container(
                  height: 10,
                  color: Colors.white.withOpacity(0.15),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.amberAccent.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '4 misiones jugables · 1 próxima expansión',
            style: medievalStyle.copyWith(
              color: Colors.white54,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MAZMORRA DEL CONOCIMIENTO
  // ---------------------------------------------------------------------------

  Widget _buildDungeonCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(220, 22, 12, 45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFCB9AFF).withOpacity(0.75),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCB9AFF).withOpacity(0.18),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _openDungeon,
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCB9AFF).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFCB9AFF).withOpacity(0.65),
                      ),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.amberAccent,
                      size: 29,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mazmorra del Conocimiento',
                          style: medievalStyle.copyWith(
                            color: Colors.amberAccent,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Modo extra de supervivencia',
                          style: medievalStyle.copyWith(
                            color: const Color(0xFFCB9AFF),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white54,
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: 13),
              Text(
                'Responde 30 preguntas seguidas, derrota enemigos y sobrevive hasta el final. '
                'Cada acierto permite atacar; cada fallo permite que el enemigo contraataque.',
                style: medievalStyle.copyWith(
                  color: Colors.white70,
                  fontSize: 12.5,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 13),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildDungeonTag(
                    icon: Icons.quiz_rounded,
                    label: '30 preguntas',
                    color: Colors.amberAccent,
                  ),
                  _buildDungeonTag(
                    icon: Icons.favorite_rounded,
                    label: 'Supervivencia',
                    color: Colors.redAccent,
                  ),
                  _buildDungeonTag(
                    icon: Icons.shield_rounded,
                    label: 'Enemigos rotativos',
                    color: const Color(0xFFCB9AFF),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: _buildStartButton(
                  label: 'Entrar',
                  accentColor: const Color(0xFFCB9AFF),
                  onPressed: _openDungeon,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDungeonTag({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.38),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: medievalStyle.copyWith(
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _openDungeon() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DungeonKnowledgeScreen(
          playerStatus: _player!,
        ),
      ),
    ).then((_) => setState(() {}));
  }

  // ---------------------------------------------------------------------------
  // SECCIONES
  // ---------------------------------------------------------------------------

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
    required String badge,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.45),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: Colors.amberAccent.withOpacity(0.45),
            ),
          ),
          child: Icon(
            icon,
            color: Colors.amberAccent,
            size: 22,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: medievalStyle.copyWith(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 225, 218, 255),
                ),
              ),
              Text(
                subtitle,
                style: medievalStyle.copyWith(
                  fontSize: 11,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF7B4EA0).withOpacity(0.28),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFCB9AFF).withOpacity(0.5),
            ),
          ),
          child: Text(
            badge,
            style: medievalStyle.copyWith(
              fontSize: 10,
              color: const Color(0xFFCB9AFF),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TARJETAS DE MISIONES NARRATIVAS
  // ---------------------------------------------------------------------------

  Widget _buildNarrativeMissionCard({
    required NarrativeMission mission,
    required int index,
  }) {
    final missionNumber = index + 1;
    final accentColor = _missionAccentColor(index);
    final missionIcon = _missionIcon(index);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 360 + (index * 90)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 22 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.25),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/textures/stone_texture.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      color: const Color.fromARGB(255, 18, 18, 38),
                    );
                  },
                ),
              ),
              Positioned.fill(
                child: Container(
                  color: const Color.fromARGB(210, 10, 10, 25),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 6,
                  color: accentColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMissionTopRow(
                      missionNumber: missionNumber,
                      missionIcon: missionIcon,
                      accentColor: accentColor,
                      label: 'JUGABLE',
                    ),
                    const SizedBox(height: 12),
                    Text(
                      mission.title,
                      style: medievalStyle.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 237, 232, 255),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      mission.shortDescription,
                      style: medievalStyle.copyWith(
                        color: const Color.fromARGB(210, 210, 205, 240),
                        fontSize: 12.5,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildMissionTag(
                          icon: Icons.security_rounded,
                          label: mission.concept,
                          color: Colors.lightBlueAccent,
                        ),
                        _buildMissionTag(
                          icon: Icons.format_list_numbered_rounded,
                          label: '${mission.steps.length} pasos',
                          color: Colors.amberAccent,
                        ),
                        if (mission.specialReward != null)
                          _buildMissionTag(
                            icon: Icons.workspace_premium_rounded,
                            label: mission.specialReward!,
                            color: accentColor,
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.bolt_rounded,
                                color: Colors.yellowAccent,
                                size: 17,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '+${mission.xpReward} XP',
                                style: medievalStyle.copyWith(
                                  fontSize: 12,
                                  color: Colors.yellowAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Image.asset(
                                'assets/icons/coin_icon.png',
                                width: 16,
                                height: 16,
                                errorBuilder: (_, __, ___) {
                                  return const Icon(
                                    Icons.monetization_on_rounded,
                                    color: Colors.amberAccent,
                                    size: 16,
                                  );
                                },
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '+${mission.coinReward}',
                                style: medievalStyle.copyWith(
                                  fontSize: 12,
                                  color: Colors.amberAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildStartButton(
                          label: 'Entrar',
                          accentColor: accentColor,
                          onPressed: () => _openNarrativeMission(mission),
                        ),
                      ],
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

  Widget _buildMissionTopRow({
    required int missionNumber,
    required IconData missionIcon,
    required Color accentColor,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.14),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: accentColor.withOpacity(0.7),
              width: 1.3,
            ),
          ),
          child: Icon(
            missionIcon,
            color: accentColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'MISIÓN ${missionNumber.toString().padLeft(2, '0')}',
            style: medievalStyle.copyWith(
              color: accentColor,
              fontSize: 12,
              letterSpacing: 1.3,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: accentColor.withOpacity(0.55),
            ),
          ),
          child: Text(
            label,
            style: medievalStyle.copyWith(
              color: accentColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMissionTag({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.38),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: medievalStyle.copyWith(
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton({
    required String label,
    required Color accentColor,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        backgroundColor: accentColor.withOpacity(0.16),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        textStyle: const TextStyle(
          fontFamily: 'MedievalSharp',
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
          side: BorderSide(
            color: accentColor.withOpacity(0.7),
            width: 1,
          ),
        ),
      ),
      onPressed: onPressed,
      icon: const Icon(
        Icons.play_arrow_rounded,
        size: 17,
        color: Colors.white,
      ),
      label: Text(label),
    );
  }

  void _openNarrativeMission(NarrativeMission mission) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NarrativeMissionScreen(
          playerStatus: _player!,
          mission: mission,
        ),
      ),
    ).then((_) => setState(() {}));
  }

  // ---------------------------------------------------------------------------
  // MISIÓN 5 VISUAL
  // ---------------------------------------------------------------------------

  Widget _buildComingSoonMissionCard() {
    const accentColor = Color(0xFF8A8A8A);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/textures/stone_texture.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    color: const Color.fromARGB(255, 22, 22, 30),
                  );
                },
              ),
            ),
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.70),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 6,
                color: accentColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMissionTopRow(
                    missionNumber: 5,
                    missionIcon: Icons.crisis_alert_rounded,
                    accentColor: accentColor,
                    label: 'PRÓXIMAMENTE',
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'La Brecha del Reino',
                    style: medievalStyle.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Una amenaza mayor se acerca al núcleo del Reino de los Datos. Esta misión abordará gestión de incidentes, respuesta y recuperación.',
                    style: medievalStyle.copyWith(
                      color: Colors.white54,
                      fontSize: 12.5,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildMissionTag(
                        icon: Icons.report_problem_rounded,
                        label: 'Gestión de incidentes',
                        color: Colors.white54,
                      ),
                      _buildMissionTag(
                        icon: Icons.lock_clock_rounded,
                        label: 'Bloqueada',
                        color: Colors.white38,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white54,
                      side: BorderSide(
                        color: Colors.white.withOpacity(0.22),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'La Brecha del Reino estará disponible en una próxima versión.',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.hourglass_empty_rounded, size: 16),
                    label: Text(
                      'No disponible',
                      style: medievalStyle.copyWith(
                        fontSize: 13,
                      ),
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

  // ---------------------------------------------------------------------------
  // ENTRENAMIENTOS ANTIGUOS
  // ---------------------------------------------------------------------------

  Widget _buildTrainingMissionCard({
    required GameMission mission,
    required int index,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 320 + (index * 70)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 18 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color.fromARGB(210, 13, 13, 31),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white.withOpacity(0.14),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mission.title,
              style: medievalStyle.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 225, 218, 255),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              mission.shortDescription,
              style: medievalStyle.copyWith(
                color: Colors.white60,
                fontSize: 12,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 27, 27, 48),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontFamily: 'MedievalSharp',
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(
                    color: Color.fromARGB(255, 148, 147, 255),
                    width: 1,
                  ),
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
              icon: const Icon(Icons.play_arrow_rounded, size: 17),
              label: const Text('Comenzar entrenamiento'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPERS VISUALES
  // ---------------------------------------------------------------------------

  Color _missionAccentColor(int index) {
    switch (index) {
      case 0:
        return Colors.amberAccent;
      case 1:
        return const Color(0xFFD19A3A);
      case 2:
        return const Color(0xFF4CAF90);
      case 3:
        return const Color(0xFF6E8CBA);
      default:
        return const Color(0xFFCB9AFF);
    }
  }

  IconData _missionIcon(int index) {
    switch (index) {
      case 0:
        return Icons.key_rounded;
      case 1:
        return Icons.mark_email_unread_rounded;
      case 2:
        return Icons.door_front_door_rounded;
      case 3:
        return Icons.backup_rounded;
      default:
        return Icons.shield_rounded;
    }
  }
}