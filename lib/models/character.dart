enum CharacterClass { mago, guerrero, arquero, nigromante }


class Character {
  String name;
  CharacterClass characterClass;
  int level;
  int experience;
  int coins;
  String avatarAsset;
  List<String> inventory;
  String? equippedWeapon;
  String? equippedArmor;
  String? equippedSpecial;
  String? equippedShield;

  Character({
    required this.name,
    required this.characterClass,
    this.level = 1,
    this.experience = 0,
    this.coins = 0,
    this.avatarAsset = '',
    this.inventory = const [],
    this.equippedWeapon,
    this.equippedArmor,
    this.equippedSpecial,
    this.equippedShield,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'characterClass': characterClass.index,
        'level': level,
        'experience': experience,
        'coins': coins,
        'avatarAsset': avatarAsset,
        'inventory': inventory,
        'equippedWeapon': equippedWeapon,
        'equippedArmor': equippedArmor,
        'equippedSpecial': equippedSpecial,
        'equippedShield': equippedShield,
      };

  static Character fromJson(Map<String, dynamic> json) {
    return Character(
      name: json['name'],
      characterClass: CharacterClass.values[json['characterClass']],
      level: json['level'],
      experience: json['experience'],
      coins: json['coins'],
      avatarAsset: json['avatarAsset'],
      inventory: List<String>.from(json['inventory']),
      equippedWeapon: json['equippedWeapon'],
      equippedArmor: json['equippedArmor'],
      equippedSpecial: json['equippedSpecial'],
      equippedShield: json['equippedShield'],
    );
  }
}
