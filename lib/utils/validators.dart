class Validators {
  /// Valida el formato de un email
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    
    // Regex para validar formato de email
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    return emailRegex.hasMatch(email);
  }

  /// Valida que la contraseña cumpla con los requisitos de seguridad
  /// Requisitos: mínimo 8 caracteres, al menos 1 mayúscula, 1 número
  static bool isValidPassword(String password) {
    if (password.isEmpty || password.length < 8) return false;
    
    // Verificar que tenga al menos una mayúscula
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    
    // Verificar que tenga al menos un número
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    
    return hasUppercase && hasNumber;
  }

  /// Obtiene el mensaje de error para un email inválido
  static String getEmailError(String email) {
    if (email.isEmpty) {
      return 'El correo electrónico es obligatorio';
    }
    if (!isValidEmail(email)) {
      return 'Formato de correo electrónico inválido';
    }
    return '';
  }

  /// Obtiene el mensaje de error para una contraseña inválida
  static String getPasswordError(String password) {
    if (password.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (password.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'La contraseña debe contener al menos una mayúscula';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'La contraseña debe contener al menos un número';
    }
    return '';
  }

  /// Valida que dos contraseñas coincidan
  static bool passwordsMatch(String password, String confirmPassword) {
    return password == confirmPassword && password.isNotEmpty;
  }

  /// Obtiene el mensaje de error cuando las contraseñas no coinciden
  static String getPasswordMatchError(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      return 'Debes confirmar tu contraseña';
    }
    if (!passwordsMatch(password, confirmPassword)) {
      return 'Las contraseñas no coinciden';
    }
    return '';
  }
}
