import 'character.dart';

class PlayerStatus {
  final String name;
  final String avatar;
  final CharacterClass characterClass;
  int level;
  int health;
  int maxHealth;
  int xp;
  int maxXp;
  int coins;
  Map<String, int> inventory;
  String? equippedWeapon;
  String? equippedArmor;
  String? equippedSpecial;
  String? equippedShield;
  

  PlayerStatus({
    required this.name,
    required this.avatar,
    required this.characterClass,
    this.level = 1,
    this.health = 50,
    this.maxHealth = 50,
    this.xp = 0,
    this.maxXp = 100,
    this.coins = 0,
    Map<String, int>? inventory,
    this.equippedWeapon,
    this.equippedArmor,
    this.equippedSpecial,
    this.equippedShield,
  }) : inventory = inventory ?? {};

   factory PlayerStatus.fromCharacter(Character character) {
    final calculatedMaxHealth = 50 + (character.level * 10);
    return PlayerStatus(
      name: character.name,
      avatar: _profileAvatars[character.characterClass] ?? character.avatarAsset,
      characterClass: character.characterClass,
      level: character.level,
      health: calculatedMaxHealth,
      maxHealth: calculatedMaxHealth,
      xp: character.experience,
      maxXp: character.level * 100,
      coins: character.coins,
      inventory: { for (var item in character.inventory) item : 1 },
      equippedWeapon: character.equippedWeapon,
      equippedArmor: character.equippedArmor,
      equippedSpecial: character.equippedSpecial,
      equippedShield: character.equippedShield,
    );
  }

  static const Map<CharacterClass, String> _profileAvatars = {
    CharacterClass.mago: 'assets/profile/mago_profile.png',
    CharacterClass.guerrero: 'assets/profile/guerrero_profile.png',
    CharacterClass.arquero: 'assets/profile/arquero_profile.png',
    CharacterClass.nigromante: 'assets/profile/nigromante_profile.png',
  };

  void gainXp(int amount) {
    xp += amount;
    while (xp >= maxXp) {
      xp -= maxXp;
      level++;
      maxHealth += 20;
      health = maxHealth;
      maxXp += 50;
    }
  }

  int get playerDamage => 10 + (level * 5);
  int get playerMaxHealth => 50 + (level * 10);

 Character toCharacter() {
  return Character(
    name: name,
    characterClass: _getClassFromAvatar(avatar),
    level: level,
    experience: xp,
    coins: coins,
    inventory: inventory.entries
        .expand((entry) => List.filled(entry.value, entry.key))
        .toList(),
    avatarAsset: avatar,
    equippedWeapon: equippedWeapon,
    equippedArmor: equippedArmor,
    equippedSpecial: equippedSpecial,
    equippedShield: equippedShield,
  );
}

  CharacterClass _getClassFromAvatar(String avatarPath) {
    return _profileAvatars.entries
            .firstWhere((entry) => entry.value == avatarPath, orElse: () => MapEntry(CharacterClass.mago, ''))
            .key;
  }
}
