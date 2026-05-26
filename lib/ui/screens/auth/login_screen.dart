import 'package:flutter/material.dart';

import '../../../services/local_auth_service.dart';
import '../../../services/google_auth_service.dart';
import '../../../services/local_storage_service.dart';
import '../../../services/mission_progress_service.dart';

import '../../../models/character.dart';

import '../pre_character_selection_screen.dart';
import '../main_dashboard_screen.dart';

import 'register_screen.dart';

import '../../../utils/navigation_transitions.dart';
import '../../screens/intro_story_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isGoogleLoading = false;

  final _googleAuthService = GoogleAuthService();

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Por favor completa todos los campos');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await LocalAuthService().login(email, password);

      if (!mounted) return;

      if (result['success'] == 'true') {
        fadeToNextScreen(context, const PreCharacterSelectionScreen());
      } else {
        _showError(result['error'] ?? 'Error al iniciar sesión');
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

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final result = await _googleAuthService.signInWithGoogle();

      if (!mounted) return;

      if (result['success'] == true) {
        final user = result['user'];
        final isNewUser = result['isNewUser'] ?? false;

        if (isNewUser) {
          _showSuccess(
            '¡Registro exitoso con Google! Bienvenido ${user?.displayName ?? ''}',
          );

          await Future.delayed(const Duration(seconds: 1));

          if (!mounted) return;

          fadeToNextScreen(context, const IntroStoryScreen());
        } else {
          _showSuccess(
            '¡Bienvenido de nuevo ${user?.displayName ?? ''}!',
          );

          await Future.delayed(const Duration(milliseconds: 500));

          if (!mounted) return;

          fadeToNextScreen(context, const PreCharacterSelectionScreen());
        }
      } else {
        _showError(result['error'] ?? 'Error al iniciar sesión con Google');
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

  /// BOTÓN TEMPORAL DE DESARROLLO
  ///
  /// Este método crea un personaje de prueba y salta directamente al dashboard.
  /// Sirve para probar misiones sin pasar por registro, intro, selección de clase
  /// y nombre. No debería quedarse activo en una versión final.
  Future<void> _enterTestMode() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final testCharacter = Character(
        name: 'TestGuard',
        characterClass: CharacterClass.mago,
        level: 1,
        experience: 0,
        coins: 500,
        avatarAsset: 'assets/characters/mago.png',
        inventory: const [],
      );

      await LocalStorageService().saveCharacter(testCharacter);
  // TEMPORAL PARA PRUEBAS:
    // Marca la misión 1 como completada para desbloquear la misión 2.
      final progressService = MissionProgressService();
      await progressService.loadProgress();
      await progressService.markAsCompleted('llave_guardian');
      await progressService.markAsCompleted('mensaje_impostor');
      await progressService.markAsCompleted('puertas_reino');
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MainDashboardScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showError('Error al entrar en modo prueba: $e');
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

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RegisterScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAnyLoading = _isLoading || _isGoogleLoading;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/backgrounds/login_bg.png',
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.6),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      height: 200,
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Iniciar Sesión',
                      style: TextStyle(
                        fontSize: 26,
                        color: Colors.white,
                        fontFamily: 'MedievalSharp',
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 24),

                    _buildInputField(
                      'Correo electrónico',
                      _emailController,
                    ),

                    const SizedBox(height: 16),

                    _buildInputField(
                      'Contraseña',
                      _passwordController,
                      obscure: true,
                    ),

                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: isAnyLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontFamily: 'MedievalSharp',
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blue,
                                ),
                              ),
                            )
                          : const Text('Iniciar Sesión'),
                    ),

                    const SizedBox(height: 16),

                    OutlinedButton(
                      onPressed: isAnyLoading ? null : _goToRegister,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.blueGrey),
                        foregroundColor: Colors.white,
                        backgroundColor:
                            const Color.fromARGB(255, 19, 34, 54)
                                .withOpacity(0.7),
                        textStyle: const TextStyle(
                          fontFamily: 'MedievalSharp',
                        ),
                      ),
                      child: const Text('¿No tienes cuenta? Regístrate aquí'),
                    ),

                    const SizedBox(height: 24),

                    const Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.white54,
                            thickness: 1,
                          ),
                        ),
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
                        Expanded(
                          child: Divider(
                            color: Colors.white54,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    ElevatedButton.icon(
                      onPressed: isAnyLoading ? null : _signInWithGoogle,
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
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blue,
                                ),
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
                      label: const Text('Iniciar sesión con Google'),
                    ),

                    const SizedBox(height: 14),

                    OutlinedButton.icon(
                      onPressed: isAnyLoading ? null : _enterTestMode,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.amberAccent,
                        ),
                        foregroundColor: Colors.amberAccent,
                        backgroundColor: Colors.black.withOpacity(0.35),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                          fontFamily: 'MedievalSharp',
                          fontSize: 14,
                        ),
                      ),
                      icon: const Icon(Icons.bug_report_rounded),
                      label: const Text('Modo prueba: ir a misiones'),
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

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(
        color: Colors.white,
        fontFamily: 'MedievalSharp',
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.white70,
          fontFamily: 'MedievalSharp',
        ),
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