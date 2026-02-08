import 'package:flutter/material.dart';
import '../../../services/local_auth_service.dart';
import '../character_selection_screen.dart';
import 'register_screen.dart';
import '../../../utils/navigation_transitions.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (await LocalAuthService().login(email, password)) {
      if (!mounted) return;
      fadeToNextScreen(context, const CharacterSelectionScreen());
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credenciales incorrectas')),
      );
    }
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
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
                      'Iniciar Sesión',
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
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        textStyle: const TextStyle(fontFamily: 'MedievalSharp'),
                      ),
                      child: const Text('Iniciar Sesión'),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: _goToRegister,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.blueGrey),
                        foregroundColor: Colors.white,
                        backgroundColor: const Color.fromARGB(255, 19, 34, 54).withOpacity(0.7),
                        textStyle: const TextStyle(fontFamily: 'MedievalSharp'),
                      ),
                      child: const Text('¿No tienes cuenta? Regístrate aquí'),
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
