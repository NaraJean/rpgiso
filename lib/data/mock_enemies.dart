import '../models/enemy.dart';

final List<Enemy> enemies = [
  Enemy(
    id: '1',
    name: 'Orco ISO',
    imageAsset: 'assets/enemies/orc.png',
    backgroundAsset: 'assets/battle/orc_bg.png', // Fondo específico
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
];
