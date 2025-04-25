import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyApp',
      initialRoute: '/',
      routes: {
        '/': (ctx) => const LoginScreen(),
        '/home': (ctx) => const HomeScreen(),
      },
    );
  }
}

