// TEMPORALMENTE DESHABILITADO - Problema con el analizador de Dart
// import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  // TEMPORALMENTE DESHABILITADO - Problema con el analizador de Dart
  // final GoogleSignIn _googleSignIn = GoogleSignIn(
  //   scopes: ['email', 'profile'],
  // );

  /// Inicia sesión con Google
  /// TEMPORALMENTE DESHABILITADO - Retorna error hasta resolver problema del analizador
  Future<Map<String, dynamic>> signInWithGoogle() async {
    return {
      'success': false,
      'error': 'Google Sign-In temporalmente deshabilitado. Por favor, usa email/password.',
    };
    
    /* CÓDIGO ORIGINAL - DESCOMENTAR CUANDO SE RESUELVA EL PROBLEMA
    // try {
    //   // Iniciar el flujo de autenticación de Google
    //   final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    //   if (googleUser == null) {
    //     // El usuario canceló el inicio de sesión
    //     return {
    //       'success': false,
    //       'error': 'Inicio de sesión cancelado',
    //     };
    //   }

    //   // Obtener los detalles del usuario
    //   final String email = googleUser.email;
    //   final String? displayName = googleUser.displayName;
    //   final String? photoUrl = googleUser.photoUrl;

    //   // Crear el objeto LocalUser con los datos de Google
    //   final LocalUser googleLocalUser = LocalUser(
    //     email: email,
    //     password: '', // Los usuarios de Google no tienen contraseña local
    //     displayName: displayName,
    //     photoUrl: photoUrl,
    //     authProvider: 'google',
    //   );

    //   // Verificar si el usuario ya existe
    //   final localAuthService = LocalAuthService();
    //   final bool userExists = await localAuthService.emailExists(email);

    //   if (userExists) {
    //     // Usuario existente - iniciar sesión
    //     final result = await localAuthService.loginGoogleUser(googleLocalUser);
    //     if (result['success'] == true) {
    //       return {
    //         'success': true,
    //         'user': googleLocalUser,
    //         'isNewUser': false,
    //       };
    //     }
    //     return result;
    //   } else {
    //     // Nuevo usuario - registrar
    //     final result = await localAuthService.registerGoogleUser(googleLocalUser);
    //     if (result['success'] == true) {
    //       return {
    //         'success': true,
    //         'user': googleLocalUser,
    //         'isNewUser': true,
    //       };
    //     }
    //     return result;
    //   }
    // } catch (error) {
    //   return {
    //     'success': false,
    //     'error': 'Error al iniciar sesión con Google: $error',
    //   };
    // }
    */
  }

  /// Cierra sesión de Google
  Future<void> signOut() async {
    // TEMPORALMENTE DESHABILITADO
    // try {
    //   await _googleSignIn.signOut();
    // } catch (error) {
    //   // Ignorar errores al cerrar sesión
    // }
  }

  /// Obtiene el usuario actual de Google (si existe)
  Future<dynamic> getCurrentUser() async {
    // TEMPORALMENTE DESHABILITADO
    return null;
    // return _googleSignIn.currentUser;
  }

  /// Verifica si hay una sesión activa de Google
  Future<bool> isSignedIn() async {
    // TEMPORALMENTE DESHABILITADO
    return false;
    // return await _googleSignIn.isSignedIn();
  }
}
