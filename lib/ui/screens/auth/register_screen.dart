import 'package:flutter/material.dart';
import '../../screens/intro_story_screen.dart';
import '../../../models/local_user.dart';
import '../../../services/local_auth_service.dart';
import '../../../utils/navigation_transitions.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) return;

    final user = LocalUser(email: email, password: password);
    await LocalAuthService().register(user);

    if (!mounted) return;
    fadeToNextScreen(context, const IntroStoryScreen());
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
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        textStyle: const TextStyle(fontFamily: 'MedievalSharp'),
                      ),
                      child: const Text('Registrar'),
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
