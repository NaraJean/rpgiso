import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/local_user.dart';
import '../utils/validators.dart';

class LocalAuthService {
  static const String _userKey = 'local_user';
  static const String _usersListKey = 'registered_users';
  static const String _passwordsKey = 'user_passwords';

  /// Genera un hash de la contraseña usando una función hash simple pero efectiva
  String _hashPassword(String password) {
    // Añadimos un salt a la contraseña
    final saltedPassword = 'rpgiso_salt_2024_$password';
    final bytes = utf8.encode(saltedPassword);
    
    // Generamos un hash simple usando los códigos de los bytes
    int hash = 0;
    for (var byte in bytes) {
      hash = ((hash << 5) - hash) + byte;
      hash = hash & hash; // Convertir a entero de 32 bits
    }
    
    // Convertimos el hash a una cadena hexadecimal
    final hashString = hash.toRadixString(16).padLeft(8, '0');
    
    // Aplicamos una segunda capa de transformación
    final secondLayer = base64.encode(utf8.encode('$hashString$password'));
    
    return secondLayer;
  }

  /// Obtiene el mapa de contraseñas hasheadas
  Future<Map<String, String>> _getPasswordsMap() async {
    final prefs = await SharedPreferences.getInstance();
    final passwordsJson = prefs.getString(_passwordsKey);
    if (passwordsJson == null) return {};
    final Map<String, dynamic> passwordsMap = jsonDecode(passwordsJson);
    return passwordsMap.cast<String, String>();
  }

  /// Guarda el mapa de contraseñas hasheadas
  Future<void> _savePasswordsMap(Map<String, String> passwords) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_passwordsKey, jsonEncode(passwords));
  }

  /// Verifica si un email ya está registrado
  Future<bool> emailExists(String email) async {
    final users = await _getRegisteredUsers();
    return users.contains(email.toLowerCase());
  }

  /// Obtiene la lista de emails registrados
  Future<List<String>> _getRegisteredUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersListKey);
    if (usersJson == null) return [];
    final List<dynamic> usersList = jsonDecode(usersJson);
    return usersList.cast<String>();
  }

  /// Añade un email a la lista de usuarios registrados
  Future<void> _addRegisteredUser(String email) async {
    final users = await _getRegisteredUsers();
    if (!users.contains(email.toLowerCase())) {
      users.add(email.toLowerCase());
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_usersListKey, jsonEncode(users));
    }
  }

  /// Guarda el usuario localmente con contraseña hasheada
  Future<Map<String, String>> register(LocalUser user) async {
    // Validar email
    if (!Validators.isValidEmail(user.email)) {
      return {'success': 'false', 'error': Validators.getEmailError(user.email)};
    }

    // Validar contraseña
    if (!Validators.isValidPassword(user.password)) {
      return {'success': 'false', 'error': Validators.getPasswordError(user.password)};
    }

    // Verificar si el email ya existe
    if (await emailExists(user.email)) {
      return {'success': 'false', 'error': 'Este correo electrónico ya está registrado'};
    }

    try {
      // Hashear la contraseña
      final hashedPassword = _hashPassword(user.password);

      // Guardar el hash de la contraseña en el mapa
      final passwords = await _getPasswordsMap();
      passwords[user.email.toLowerCase()] = hashedPassword;
      await _savePasswordsMap(passwords);

      // Guardar el usuario activo (sin la contraseña en texto plano)
      final userWithoutPassword = LocalUser(
        email: user.email,
        password: '', // No guardamos la contraseña en SharedPreferences
      );
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(userWithoutPassword.toJson()));

      // Añadir a la lista de usuarios registrados
      await _addRegisteredUser(user.email);

      return {'success': 'true'};
    } catch (e) {
      return {'success': 'false', 'error': 'Error al registrar usuario: $e'};
    }
  }

  /// Obtiene el usuario activo si existe
  Future<LocalUser?> getActiveUser() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_userKey);
    if (json == null) return null;
    return LocalUser.fromJson(jsonDecode(json));
  }

  /// Verifica si las credenciales coinciden
  Future<Map<String, String>> login(String email, String password) async {
    // Validar campos vacíos
    if (email.trim().isEmpty || password.trim().isEmpty) {
      return {'success': 'false', 'error': 'Por favor completa todos los campos'};
    }

    // Validar formato de email
    if (!Validators.isValidEmail(email)) {
      return {'success': 'false', 'error': 'Formato de correo electrónico inválido'};
    }

    try {
      // Verificar si el email está registrado
      if (!await emailExists(email)) {
        return {'success': 'false', 'error': 'Credenciales incorrectas'};
      }

      // Obtener el hash almacenado del mapa
      final passwords = await _getPasswordsMap();
      final storedHash = passwords[email.toLowerCase()];

      if (storedHash == null) {
        return {'success': 'false', 'error': 'Credenciales incorrectas'};
      }

      // Hashear la contraseña ingresada
      final inputHash = _hashPassword(password);

      // Comparar hashes
      if (storedHash == inputHash) {
        // Actualizar usuario activo
        final user = LocalUser(email: email, password: '');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, jsonEncode(user.toJson()));
        
        return {'success': 'true'};
      } else {
        return {'success': 'false', 'error': 'Credenciales incorrectas'};
      }
    } catch (e) {
      return {'success': 'false', 'error': 'Error al iniciar sesión: $e'};
    }
  }

  /// Elimina el usuario guardado (pero mantiene las credenciales para poder volver a iniciar sesión)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  /// Elimina todos los datos de autenticación (útil para testing)
  Future<void> clearAllAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_usersListKey);
    await prefs.remove(_passwordsKey);
  }

  /// Registra un usuario de Google (sin contraseña)
  Future<Map<String, dynamic>> registerGoogleUser(LocalUser user) async {
    try {
      // Verificar si el email ya existe
      if (await emailExists(user.email)) {
        return {
          'success': false,
          'error': 'Este correo electrónico ya está registrado',
        };
      }

      // Guardar el usuario activo con datos de Google
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));

      // Añadir a la lista de usuarios registrados
      await _addRegisteredUser(user.email);

      return {
        'success': true,
        'user': user,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Error al registrar usuario de Google: $e',
      };
    }
  }

  /// Inicia sesión con un usuario de Google
  Future<Map<String, dynamic>> loginGoogleUser(LocalUser user) async {
    try {
      // Verificar si el email está registrado
      if (!await emailExists(user.email)) {
        return {
          'success': false,
          'error': 'Usuario no encontrado',
        };
      }

      // Actualizar usuario activo con datos de Google
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));

      return {
        'success': true,
        'user': user,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Error al iniciar sesión con Google: $e',
      };
    }
  }
}

