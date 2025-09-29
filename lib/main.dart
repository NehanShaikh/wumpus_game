import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/save_load_screen.dart';

void main() {
  runApp(const WumpusApp());
}

class WumpusApp extends StatelessWidget {
  const WumpusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 👈 removes DEBUG banner globally
      title: 'Wumpus Game',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/saves': (context) => SaveLoadScreen(),
        // '/game' is not here because it requires a GameLogic instance
      },
    );
  }
}
