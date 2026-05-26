import 'package:flutter/material.dart';
import '../../screens/intro_story_screen.dart';
import '../../../models/local_user.dart';
import '../../../services/local_auth_service.dart';
import '../../../services/google_auth_service.dart';
import '../../../utils/navigation_transitions.dart';
import '../../../utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  final _googleAuthService = GoogleAuthService();

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validar campos vacíos
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showError('Por favor completa todos los campos');
      return;
    }

    // Validar formato de email
    if (!Validators.isValidEmail(email)) {
      _showError(Validators.getEmailError(email));
      return;
    }

    // Validar requisitos de contraseña
    if (!Validators.isValidPassword(password)) {
      _showError(Validators.getPasswordError(password));
      return;
    }

    // Validar que las contraseñas coincidan
    if (!Validators.passwordsMatch(password, confirmPassword)) {
      _showError(Validators.getPasswordMatchError(password, confirmPassword));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = LocalUser(email: email, password: password);
      final result = await LocalAuthService().register(user);

      if (!mounted) return;

      if (result['success'] == 'true') {
        _showSuccess('¡Registro exitoso! Bienvenido');
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        fadeToNextScreen(context, const IntroStoryScreen());
      } else {
        _showError(result['error'] ?? 'Error al registrar usuario');
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Error inesperado: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _signUpWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final result = await _googleAuthService.signInWithGoogle();

      if (!mounted) return;

      if (result['success'] == true) {
        final user = result['user'];
        _showSuccess('¡Registro exitoso con Google! Bienvenido ${user?.displayName ?? ''}');
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        fadeToNextScreen(context, const IntroStoryScreen());
      } else {
        _showError(result['error'] ?? 'Error al registrarse con Google');
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Error inesperado: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/backgrounds/login_bg.png', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.6)),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset('assets/logo.png', height: 200),
                    const SizedBox(height: 20),
                    const Text(
                      'Registro',
                      style: TextStyle(
                        fontSize: 26,
                        color: Colors.white,
                        fontFamily: 'MedievalSharp',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    _buildInputField('Correo electrónico', _emailController),
                    const SizedBox(height: 16),
                    _buildInputField('Contraseña', _passwordController, obscure: true),
                    const SizedBox(height: 16),
                    _buildInputField('Confirmar Contraseña', _confirmPasswordController, obscure: true),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'La contraseña debe tener:\n• Mínimo 8 caracteres\n• Al menos 1 mayúscula\n• Al menos 1 número',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontFamily: 'MedievalSharp',
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        textStyle: const TextStyle(fontFamily: 'MedievalSharp'),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                            )
                          : const Text('Registrar'),
                    ),
                    const SizedBox(height: 24),
                    const Row(
                      children: [
                        Expanded(child: Divider(color: Colors.white54, thickness: 1)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'O',
                            style: TextStyle(
                              color: Colors.white70,
                              fontFamily: 'MedievalSharp',
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.white54, thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _isGoogleLoading ? null : _signUpWithGoogle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                          fontFamily: 'MedievalSharp',
                          fontSize: 14,
                        ),
                      ),
                      icon: _isGoogleLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                            )
                          : Image.network(
                              'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                              height: 20,
                              width: 20,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.login, size: 20);
                              },
                            ),
                      label: const Text('Registrarse con Google'),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.blueGrey),
                        foregroundColor: Colors.white,
                        backgroundColor: const Color.fromARGB(255, 19, 34, 54).withOpacity(0.7),
                        textStyle: const TextStyle(fontFamily: 'MedievalSharp'),
                      ),
                      child: const Text('¿Ya tienes cuenta? Inicia sesión aquí'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white, fontFamily: 'MedievalSharp'),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70, fontFamily: 'MedievalSharp'),
        filled: true,
        fillColor: Colors.transparent,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}
