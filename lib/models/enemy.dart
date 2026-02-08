class Enemy {
  final String id;
  final String name;
  final String imageAsset;
  final String backgroundAsset; // Nuevo campo para el fondo
  int health;
  final int maxHealth;
  final int damage;
  final int level;

  Enemy({
    required this.id,
    required this.name,
    required this.imageAsset,
    required this.backgroundAsset, // Inicializar el nuevo campo
    required this.health,
    required this.maxHealth,
    required this.damage,
    required this.level,
  });

  int get enemyDamage => damage + (level * 5);
  int get enemyMaxHealth => maxHealth + (level * 10);
}
