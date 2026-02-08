import 'package:flutter/material.dart';

class MissionsScreen extends StatelessWidget {
  const MissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Misiones')),
      body: Center(
        child: Text('Aquí se mostrarán las misiones diarias y semanales'),
      ),
    );
  }
}
