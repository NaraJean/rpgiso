import 'character.dart';

class UserProfile {
  final String email;
  final String password;
  final Character character;

  UserProfile({
    required this.email,
    required this.password,
    required this.character,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'character': {
          'name': character.name,
          'characterClass': character.characterClass.name,
          'level': character.level,
          'experience': character.experience,
          'coins': character.coins,
          'avatarAsset': character.avatarAsset,
          'inventory': character.inventory,
        }
      };

  static UserProfile fromJson(Map<String, dynamic> json) {
    return UserProfile(
      email: json['email'],
      password: json['password'],
      character: Character(
        name: json['character']['name'],
        characterClass: CharacterClass.values.firstWhere(
            (e) => e.name == json['character']['characterClass']),
        level: json['character']['level'],
        experience: json['character']['experience'],
        coins: json['character']['coins'],
        avatarAsset: json['character']['avatarAsset'],
        inventory: List<String>.from(json['character']['inventory']),
      ),
    );
  }
}
