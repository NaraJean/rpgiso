import '../models/enemy.dart';

/// Enemigos disponibles en DataGuardians.
///
/// Los primeros enemigos se conservan para compatibilidad con las misiones viejas.
/// Los nuevos enemigos se agregan para las misiones narrativas principales.
final List<Enemy> enemies = [
  // ---------------------------------------------------------------------------
  // ENEMIGOS ANTIGUOS / COMPATIBILIDAD
  // ---------------------------------------------------------------------------
  Enemy(
    id: 'orco_iso',
    name: 'Orco ISO',
    imageAsset: 'assets/enemies/orc.png',
    backgroundAsset: 'assets/battle/orc_bg.png',
    health: 50,
    maxHealth: 50,
    damage: 15,
    level: 1,
  ),
  Enemy(
    id: 'hechicero_caos',
    name: 'Hechicero del Caos',
    imageAsset: 'assets/enemies/mage.png',
    backgroundAsset: 'assets/battle/mage_bg.png',
    health: 120,
    maxHealth: 120,
    damage: 20,
    level: 1,
  ),
  Enemy(
    id: 'defensor_conocimiento',
    name: 'Defensor del Conocimiento',
    imageAsset: 'assets/enemies/defender.png',
    backgroundAsset: 'assets/battle/defender_bg.png',
    health: 120,
    maxHealth: 120,
    damage: 20,
    level: 1,
  ),

  // ---------------------------------------------------------------------------
  // MISIÓN 1: CONTRASEÑAS SEGURAS
  // ---------------------------------------------------------------------------
  Enemy(
    id: 'golem_cerradura_debil',
    name: 'Gólem de la Cerradura Débil',
    imageAsset: 'assets/enemies/defender.png',
    backgroundAsset: 'assets/battle/defender_bg.png',
    health: 70,
    maxHealth: 70,
    damage: 15,
    level: 1,
  ),

  // ---------------------------------------------------------------------------
  // MISIÓN 2: PHISHING
  // ---------------------------------------------------------------------------
  Enemy(
    id: 'heraldo_impostor',
    name: 'Heraldo Impostor',
    imageAsset: 'assets/enemies/mage.png',
    backgroundAsset: 'assets/battle/mage_bg.png',
    health: 110,
    maxHealth: 110,
    damage: 18,
    level: 2,
  ),

  // ---------------------------------------------------------------------------
  // MISIÓN 3: CONTROL DE ACCESO
  // ---------------------------------------------------------------------------
  Enemy(
    id: 'sombra_intrusa',
    name: 'Sombra Intrusa',
    imageAsset: 'assets/enemies/orc.png',
    backgroundAsset: 'assets/battle/orc_bg.png',
    health: 100,
    maxHealth: 100,
    damage: 18,
    level: 2,
  ),
  Enemy(
    id: 'caballero_privilegio_excesivo',
    name: 'Caballero del Privilegio Excesivo',
    imageAsset: 'assets/enemies/defender.png',
    backgroundAsset: 'assets/battle/defender_bg.png',
    health: 140,
    maxHealth: 140,
    damage: 22,
    level: 3,
  ),

  // ---------------------------------------------------------------------------
  // MISIÓN 4: COPIAS DE SEGURIDAD
  // ---------------------------------------------------------------------------
  Enemy(
    id: 'devorador_memorias',
    name: 'Devorador de Memorias',
    imageAsset: 'assets/enemies/mage.png',
    backgroundAsset: 'assets/battle/mage_bg.png',
    health: 150,
    maxHealth: 150,
    damage: 22,
    level: 3,
  ),

  // ---------------------------------------------------------------------------
  // MISIÓN 5: INCIDENTE DE SEGURIDAD
  // ---------------------------------------------------------------------------
  Enemy(
    id: 'sombra_vacio',
    name: 'La Sombra del Vacío',
    imageAsset: 'assets/enemies/mage.png',
    backgroundAsset: 'assets/battle/mage_bg.png',
    health: 220,
    maxHealth: 220,
    damage: 28,
    level: 5,
  ),
];

/// Busca un enemigo por ID.
///
/// Si no lo encuentra, devuelve el primer enemigo como respaldo.
/// Porque claro, incluso los enemigos necesitan plan B.
Enemy getEnemyById(String id) {
  return enemies.firstWhere(
    (enemy) => enemy.id == id,
    orElse: () => enemies.first,
  );
}