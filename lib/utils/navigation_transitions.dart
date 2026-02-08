import 'package:flutter/material.dart';

void fadeToNextScreen(BuildContext context, Widget nextScreen) {
  Navigator.of(context).pushReplacement(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return Stack(
          children: [
            Container(color: Colors.black), // Primero negro total
            FadeTransition(opacity: animation, child: child), // Luego aparece el nuevo contenido
          ],
        );
      },
      transitionDuration: const Duration(milliseconds: 1200),
    ),
  );
}
