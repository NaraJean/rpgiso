import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/local_user.dart';

class LocalAuthService {
  static const String _userKey = 'local_user';

  /// Guarda el usuario localmente
  Future<void> register(LocalUser user) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  /// Obtiene el usuario activo si existe
  Future<LocalUser?> getActiveUser() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_userKey);
    if (json == null) return null;
    return LocalUser.fromJson(jsonDecode(json));
  }

  /// Verifica si las credenciales coinciden
  Future<bool> login(String email, String password) async {
    final user = await getActiveUser();
    if (user == null) return false;
    return user.email == email && user.password == password;
  }

  /// Elimina el usuario guardado
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_userKey);
  }
}

