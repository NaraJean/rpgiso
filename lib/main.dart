import 'package:flutter/material.dart';
import 'ui/screens/main_dashboard_screen.dart';
import 'ui/screens/auth/login_screen.dart';
import 'services/local_auth_service.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialScreen() async {
    final user = await LocalAuthService().getActiveUser();
    if (user != null) {
      return const MainDashboardScreen();
    } else {
      return const LoginScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ISO RPG',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'MedievalSharp',
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const MainDashboardScreen(),
      },
      home: FutureBuilder<Widget>(
        future: _getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            return snapshot.data!;
          }
        },
      ),
    );
  }
}
