import '../models/enemy.dart';

final List<Enemy> enemies = [
  // Enemigos antiguos, se dejan para no romper misiones anteriores
  Enemy(
    id: '1',
    name: 'Orco ISO',
    imageAsset: 'assets/enemies/orc.png',
    backgroundAsset: 'assets/battle/orc_bg.png',
    health: 50,
    maxHealth: 50,
    damage: 15,
    level: 1,
  ),
  Enemy(
    id: '2',
    name: 'Hechicero del Caos',
    imageAsset: 'assets/enemies/mage.png',
    backgroundAsset: 'assets/battle/mage_bg.png',
    health: 120,
    maxHealth: 120,
    damage: 20,
    level: 1,
  ),
  Enemy(
    id: '3',
    name: 'Defensor del Conocimiento',
    imageAsset: 'assets/enemies/defender.png',
    backgroundAsset: 'assets/battle/defender_bg.png',
    health: 120,
    maxHealth: 120,
    damage: 20,
    level: 1,
  ),

  // Enemigos nuevos narrativos
  Enemy(
    id: 'golem_cerradura_debil',
    name: 'Gólem de la Cerradura Débil',
    imageAsset: 'assets/enemies/golem_cerradura.png',
    backgroundAsset: 'assets/battle/defender_bg.png',
    health: 100,
    maxHealth: 100,
    damage: 18,
    level: 2,
  ),
  Enemy(
    id: 'heraldo_impostor',
    name: 'Heraldo Impostor',
    imageAsset: 'assets/enemies/heraldo_impostor.png',
    backgroundAsset: 'assets/battle/mage_bg.png',
    health: 90,
    maxHealth: 90,
    damage: 18,
    level: 2,
  ),
  Enemy(
    id: 'sombra_intrusa',
    name: 'Sombra Intrusa',
    imageAsset: 'assets/enemies/sombra_intrusa.png',
    backgroundAsset: 'assets/battle/defender_bg.png',
    health: 110,
    maxHealth: 110,
    damage: 20,
    level: 3,
  ),
  Enemy(
    id: 'devorador_memorias',
    name: 'Devorador de Memorias',
    imageAsset: 'assets/enemies/devorador_memorias.png',
    backgroundAsset: 'assets/battle/mage_bg.png',
    health: 130,
    maxHealth: 130,
    damage: 22,
    level: 3,
  ),
];

Enemy getEnemyById(String id) {
  return enemies.firstWhere(
    (enemy) => enemy.id == id,
    orElse: () => enemies.first,
  );
}