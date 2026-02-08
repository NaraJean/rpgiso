import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/character.dart';

class LocalStorageService {
  static const _characterKey = 'character_data';

  Future<void> saveCharacter(Character character) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_characterKey, jsonEncode(character.toJson()));
  }

  Future<Character?> loadCharacter() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_characterKey);
    if (data == null) return null;
    return Character.fromJson(jsonDecode(data));
  }

  Future<void> saveUserCharacter(String email, Character character) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('character_$email', jsonEncode(character.toJson()));
  }

  Future<Character?> getUserCharacter(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('character_$email');
    if (data == null) return null;
    return Character.fromJson(jsonDecode(data));
  }
}
