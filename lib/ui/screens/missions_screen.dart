import 'package:flutter/material.dart';

import '../../data/narrative_missions.dart';
import '../../models/narrative_mission.dart';
import '../../models/player_status.dart';
import '../../services/mission_progress_service.dart';

import 'narrative_mission_screen.dart';
import 'dungeon_knowledge_screen.dart';

class MissionsScreen extends StatefulWidget {
  final PlayerStatus playerStatus;

  const MissionsScreen({
    super.key,
    required this.playerStatus,
  });

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
  final MissionProgressService _progressService = MissionProgressService();

  bool _loading = true;

  static const TextStyle _medievalStyle = TextStyle(
    fontFamily: 'MedievalSharp',
  );

  @override
  void initState() {
    super.initState();
    _loadMissionProgress();
  }

  Future<void> _loadMissionProgress() async {
    await _progressService.loadProgress();

    if (!mounted) return;

    setState(() {
      _loading = false;
    });
  }

  Future<void> _openMission(NarrativeMission mission) async {
    final unlocked = _progressService.isUnlocked(mission.requiredMissionIds);

    if (!unlocked) {
      _showLockedMessage(mission);
      return;
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => NarrativeMissionScreen(
          playerStatus: widget.playerStatus,
          mission: mission,
        ),
      ),
    );

    if (result == true) {
      await _loadMissionProgress();
      setState(() {});
    }
  }

  void _openDungeon() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DungeonKnowledgeScreen(
          playerStatus: widget.playerStatus,
        ),
      ),
    );
  }

  void _showLockedMessage(NarrativeMission mission) {
    final missingRequirements = mission.requiredMissionIds
        .where((id) => !_progressService.isCompleted(id))
        .toList();

    final requiredText = missingRequirements.isEmpty
        ? 'Debes completar misiones anteriores.'
        : 'Debes completar: ${missingRequirements.join(", ")}';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(requiredText),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedMissions = [...narrativeMissions]
      ..sort((a, b) => a.order.compareTo(b.order));

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/backgrounds/story_bg.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return Container(
                color: const Color.fromARGB(255, 14, 16, 35),
              );
            },
          ),
          Container(color: Colors.black.withOpacity(0.65)),
          SafeArea(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.amberAccent,
                    ),
                  )
                : Column(
                    children: [
                      _buildHeader(),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
                          itemCount: sortedMissions.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return _buildDungeonCard();
                            }

                            final mission = sortedMissions[index - 1];
                            return _buildMissionCard(mission);
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final completedCount = narrativeMissions
        .where((mission) => _progressService.isCompleted(mission.id))
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
      child: Column(
        children: [
          Text(
            'Misiones Narrativas',
            style: _medievalStyle.copyWith(
              fontSize: 26,
              color: Colors.amberAccent,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Campaña principal de DataGuardians',
            style: _medievalStyle.copyWith(
              fontSize: 14,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.45),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.amberAccent.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Text(
              'Progreso: $completedCount / ${narrativeMissions.length}',
              style: _medievalStyle.copyWith(
                fontSize: 13,
                color: Colors.amberAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDungeonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: const Color.fromARGB(185, 20, 12, 42),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.deepPurpleAccent.withOpacity(0.85),
          width: 1.7,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurpleAccent.withOpacity(0.20),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.deepPurpleAccent.withOpacity(0.20),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.deepPurpleAccent.withOpacity(0.75),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.local_fire_department_rounded,
                      color: Colors.amberAccent,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mazmorra del Conocimiento',
                          style: _medievalStyle.copyWith(
                            color: Colors.amberAccent,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Modo extra de supervivencia',
                          style: _medievalStyle.copyWith(
                            color: const Color(0xFFC4B5FD),
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
                'Cada acierto te permite atacar; cada fallo permite que el enemigo contraataque.',
                style: _medievalStyle.copyWith(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildDungeonChip(
                    icon: Icons.quiz_rounded,
                    text: '30 preguntas',
                    color: Colors.amberAccent,
                  ),
                  _buildDungeonChip(
                    icon: Icons.favorite_rounded,
                    text: 'Supervivencia',
                    color: Colors.redAccent,
                  ),
                  _buildDungeonChip(
                    icon: Icons.shield_rounded,
                    text: 'Enemigos rotativos',
                    color: const Color(0xFFC4B5FD),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _openDungeon,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 34, 24, 70),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: BorderSide(
                      color: Colors.amberAccent.withOpacity(0.75),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(
                    Icons.door_front_door_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: Text(
                    'Entrar a la mazmorra',
                    style: _medievalStyle.copyWith(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDungeonChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.45),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 5),
          Text(
            text,
            style: _medievalStyle.copyWith(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard(NarrativeMission mission) {
    final completed = _progressService.isCompleted(mission.id);
    final unlocked = _progressService.isUnlocked(mission.requiredMissionIds);

    final Color borderColor;
    final Color statusColor;
    final IconData statusIcon;
    final String statusText;

    if (completed) {
      borderColor = Colors.greenAccent;
      statusColor = Colors.greenAccent;
      statusIcon = Icons.check_circle;
      statusText = 'Completada';
    } else if (unlocked) {
      borderColor = Colors.amberAccent;
      statusColor = Colors.amberAccent;
      statusIcon = Icons.lock_open_rounded;
      statusText = 'Disponible';
    } else {
      borderColor = Colors.white24;
      statusColor = Colors.white38;
      statusIcon = Icons.lock_rounded;
      statusText = 'Bloqueada';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.48),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor.withOpacity(completed || unlocked ? 0.75 : 0.45),
          width: completed || unlocked ? 1.5 : 1,
        ),
        boxShadow: [
          if (unlocked || completed)
            BoxShadow(
              color: borderColor.withOpacity(0.12),
              blurRadius: 12,
              spreadRadius: 1,
            ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openMission(mission),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMissionTopRow(
                mission: mission,
                statusIcon: statusIcon,
                statusColor: statusColor,
                statusText: statusText,
              ),
              const SizedBox(height: 12),
              Text(
                mission.shortDescription,
                style: _medievalStyle.copyWith(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 14),
              _buildMissionInfoBox(
                icon: Icons.school_rounded,
                label: 'Concepto',
                text: mission.concept,
                color: const Color(0xFF6E8CBA),
              ),
              const SizedBox(height: 8),
              _buildMissionInfoBox(
                icon: Icons.verified_user_outlined,
                label: 'ISO 27001',
                text: mission.isoRelation,
                color: const Color(0xFFB8A040),
              ),
              const SizedBox(height: 12),
              _buildRewardRow(mission),
              const SizedBox(height: 14),
              _buildActionButton(
                mission: mission,
                completed: completed,
                unlocked: unlocked,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMissionTopRow({
    required NarrativeMission mission,
    required IconData statusIcon,
    required Color statusColor,
    required String statusText,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.amberAccent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.amberAccent.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Text(
            mission.order.toString(),
            style: _medievalStyle.copyWith(
              fontSize: 20,
              color: Colors.amberAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            mission.title,
            style: _medievalStyle.copyWith(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              height: 1.15,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          children: [
            Icon(
              statusIcon,
              color: statusColor,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              statusText,
              style: _medievalStyle.copyWith(
                fontSize: 10,
                color: statusColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMissionInfoBox({
    required IconData icon,
    required String label,
    required String text,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.45),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: _medievalStyle.copyWith(
                  fontSize: 13,
                  color: Colors.white70,
                  height: 1.2,
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: _medievalStyle.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardRow(NarrativeMission mission) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        _buildRewardChip(
          icon: Icons.bolt,
          text: '${mission.xpReward} XP',
        ),
        _buildRewardChip(
          icon: Icons.monetization_on_rounded,
          text: '${mission.coinReward} monedas',
        ),
        if (mission.specialReward != null)
          _buildRewardChip(
            icon: Icons.workspace_premium_rounded,
            text: mission.specialReward!,
          ),
      ],
    );
  }

  Widget _buildRewardChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.amberAccent.withOpacity(0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.amberAccent, size: 16),
          const SizedBox(width: 5),
          Text(
            text,
            style: _medievalStyle.copyWith(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required NarrativeMission mission,
    required bool completed,
    required bool unlocked,
  }) {
    final String label;
    final IconData icon;
    final Color backgroundColor;

    if (completed) {
      label = 'Repetir misión';
      icon = Icons.replay_rounded;
      backgroundColor = const Color.fromARGB(255, 25, 70, 45);
    } else if (unlocked) {
      label = 'Iniciar misión';
      icon = Icons.play_arrow_rounded;
      backgroundColor = const Color.fromARGB(255, 19, 34, 54);
    } else {
      label = 'Bloqueada';
      icon = Icons.lock_rounded;
      backgroundColor = Colors.grey.shade800;
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: unlocked || completed ? () => _openMission(mission) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: Colors.grey.shade900,
          padding: const EdgeInsets.symmetric(vertical: 13),
          side: BorderSide(
            color: unlocked || completed
                ? Colors.amberAccent.withOpacity(0.7)
                : Colors.white24,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
        ),
        icon: Icon(
          icon,
          color: unlocked || completed ? Colors.white : Colors.white38,
          size: 18,
        ),
        label: Text(
          label,
          style: _medievalStyle.copyWith(
            color: unlocked || completed ? Colors.white : Colors.white38,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}